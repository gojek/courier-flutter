struct InfiniteSequence<Element>: Sequence {
    typealias Iterator = AnyIterator<Element>

    private let repeatedValue: Element

    init(repeatedValue: Element) {
        self.repeatedValue = repeatedValue
    }

    func makeIterator() -> Iterator {
        let repeatedValue = self.repeatedValue
        return AnyIterator { repeatedValue }
    }
}
