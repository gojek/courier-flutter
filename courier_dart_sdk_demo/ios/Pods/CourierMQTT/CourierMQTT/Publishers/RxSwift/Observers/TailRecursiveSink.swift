enum TailRecursiveSinkCommand {
    case moveNext
    case dispose
}

class TailRecursiveSink<Sequence: Swift.Sequence, Observer: ObserverType>: Sink<Observer>,
                                                                           InvocableWithValueType where Sequence.Element: ObservableConvertibleType, Sequence.Element.Element == Observer.Element {
    typealias Value = TailRecursiveSinkCommand
    typealias Element = Observer.Element
    typealias SequenceGenerator = (generator: Sequence.Iterator, remaining: IntMax?)

    var generators: [SequenceGenerator] = []
    var disposed = false
    var subscription = SerialDisposable()

    var gate = AsyncLock<InvocableScheduledItem<TailRecursiveSink<Sequence, Observer>>>()

    #if DEBUG || TRACE_RESOURCES
    var maxTailRecursiveSinkStackSize = 0
    #endif

    override init(observer: Observer, cancel: Cancelable) {
        super.init(observer: observer, cancel: cancel)
    }

    func run(_ sources: SequenceGenerator) -> Disposable {
        generators.append(sources)

        schedule(.moveNext)

        return subscription
    }

    func invoke(_ command: TailRecursiveSinkCommand) {
        switch command {
        case .dispose:
            disposeCommand()
        case .moveNext:
            moveNextCommand()
        }
    }

    func schedule(_ command: TailRecursiveSinkCommand) {
        gate.invoke(InvocableScheduledItem(invocable: self, state: command))
    }

    func done() {
        forwardOn(.completed)
        dispose()
    }

    func extract(_: Observable<Element>) -> SequenceGenerator? {
        rxAbstractMethod()
    }

    private func moveNextCommand() {
        var next: Observable<Element>?

        repeat {
            guard let (g, left) = generators.last else {
                break
            }

            if isDisposed {
                return
            }

            generators.removeLast()

            var e = g

            guard let nextCandidate = e.next()?.asObservable() else {
                continue
            }

            if let knownOriginalLeft = left {

                if knownOriginalLeft - 1 >= 1 {
                    generators.append((e, knownOriginalLeft - 1))
                }
            } else {
                generators.append((e, nil))
            }

            let nextGenerator = extract(nextCandidate)

            if let nextGenerator = nextGenerator {
                generators.append(nextGenerator)
                #if DEBUG || TRACE_RESOURCES
                if maxTailRecursiveSinkStackSize < generators.count {
                    maxTailRecursiveSinkStackSize = generators.count
                }
                #endif
            } else {
                next = nextCandidate
            }
        } while next == nil

        guard let existingNext = next else {
            done()
            return
        }

        let disposable = SingleAssignmentDisposable()
        subscription.disposable = disposable
        disposable.setDisposable(subscribeToNext(existingNext))
    }

    func subscribeToNext(_: Observable<Element>) -> Disposable {
        rxAbstractMethod()
    }

    func disposeCommand() {
        disposed = true
        generators.removeAll(keepingCapacity: false)
    }

    override func dispose() {
        super.dispose()

        subscription.dispose()
        gate.dispose()

        schedule(.dispose)
    }
}
