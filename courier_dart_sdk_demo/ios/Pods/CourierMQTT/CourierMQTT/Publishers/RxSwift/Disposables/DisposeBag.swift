







extension Disposable {



    func disposed(by bag: DisposeBag) {
        bag.insert(self)
    }
}

/**
 Thread safe bag that disposes added disposables on `deinit`.

 This returns ARC (RAII) like resource management to `RxSwift`.

 In case contained disposables need to be disposed, just put a different dispose bag
 or create a new one in its place.

 self.existingDisposeBag = DisposeBag()

 In case explicit disposal is necessary, there is also `CompositeDisposable`.
 */
final class DisposeBag: DisposeBase {
    private var lock = SpinLock()


    private var disposables = [Disposable]()
    private var isDisposed = false


    override init() {
        super.init()
    }




    func insert(_ disposable: Disposable) {
        _insert(disposable)?.dispose()
    }

    private func _insert(_ disposable: Disposable) -> Disposable? {
        lock.performLocked {
            if self.isDisposed {
                return disposable
            }

            self.disposables.append(disposable)

            return nil
        }
    }


    private func dispose() {
        let oldDisposables = _dispose()

        for disposable in oldDisposables {
            disposable.dispose()
        }
    }

    private func _dispose() -> [Disposable] {
        lock.performLocked {
            let disposables = self.disposables

            self.disposables.removeAll(keepingCapacity: false)
            self.isDisposed = true

            return disposables
        }
    }

    deinit {
        self.dispose()
    }
}

extension DisposeBag {

    convenience init(disposing disposables: Disposable...) {
        self.init()
        self.disposables += disposables
    }



    convenience init(@DisposableBuilder builder: () -> [Disposable]) {
        self.init(disposing: builder())
    }


    convenience init(disposing disposables: [Disposable]) {
        self.init()
        self.disposables += disposables
    }


    func insert(_ disposables: Disposable...) {
        insert(disposables)
    }


    func insert(@DisposableBuilder builder: () -> [Disposable]) {
        insert(builder())
    }


    func insert(_ disposables: [Disposable]) {
        lock.performLocked {
            if self.isDisposed {
                disposables.forEach { $0.dispose() }
            } else {
                self.disposables += disposables
            }
        }
    }


    @_functionBuilder
    enum DisposableBuilder {
        static func buildBlock(_ disposables: Disposable...) -> [Disposable] {
            return disposables
        }
    }
}
