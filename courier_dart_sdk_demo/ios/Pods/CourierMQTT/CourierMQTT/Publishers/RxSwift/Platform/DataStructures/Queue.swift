/**
 Data structure that represents queue.

 Complexity of `enqueue`, `dequeue` is O(1) when number of operations is
 averaged over N operations.

 Complexity of `peek` is O(1).
 */
struct Queue<T>: Sequence {

    typealias Generator = AnyIterator<T>

    private let resizeFactor = 2

    private var storage: ContiguousArray<T?>
    private var innerCount = 0
    private var pushNextIndex = 0
    private let initialCapacity: Int

    /**
     Creates new queue.

     - parameter capacity: Capacity of newly created queue.
     */
    init(capacity: Int) {
        initialCapacity = capacity

        storage = ContiguousArray<T?>(repeating: nil, count: capacity)
    }

    private var dequeueIndex: Int {
        let index = pushNextIndex - count
        return index < 0 ? index + storage.count : index
    }

    var isEmpty: Bool { count == 0 }

    var count: Int { innerCount }

    func peek() -> T {
        precondition(count > 0)

        return storage[dequeueIndex]!
    }

    private mutating func resizeTo(_ size: Int) {
        var newStorage = ContiguousArray<T?>(repeating: nil, count: size)

        let count = self.count

        let dequeueIndex = self.dequeueIndex
        let spaceToEndOfQueue = storage.count - dequeueIndex

        let countElementsInFirstBatch = Swift.min(count, spaceToEndOfQueue)

        let numberOfElementsInSecondBatch = count - countElementsInFirstBatch

        newStorage[0 ..< countElementsInFirstBatch] = storage[dequeueIndex ..< (dequeueIndex + countElementsInFirstBatch)]
        newStorage[countElementsInFirstBatch ..< (countElementsInFirstBatch + numberOfElementsInSecondBatch)] = storage[0 ..< numberOfElementsInSecondBatch]

        innerCount = count
        pushNextIndex = count
        storage = newStorage
    }

    mutating func enqueue(_ element: T) {
        if count == storage.count {
            resizeTo(Swift.max(storage.count, 1) * resizeFactor)
        }

        storage[pushNextIndex] = element
        pushNextIndex += 1
        innerCount += 1

        if pushNextIndex >= storage.count {
            pushNextIndex -= storage.count
        }
    }

    private mutating func dequeueElementOnly() -> T {
        precondition(count > 0)

        let index = dequeueIndex

        defer {
            storage[index] = nil
            innerCount -= 1
        }

        return storage[index]!
    }

    mutating func dequeue() -> T? {
        if count == 0 {
            return nil
        }

        defer {
            let downsizeLimit = storage.count / (resizeFactor * resizeFactor)
            if count < downsizeLimit, downsizeLimit >= initialCapacity {
                resizeTo(storage.count / resizeFactor)
            }
        }

        return dequeueElementOnly()
    }

    func makeIterator() -> AnyIterator<T> {
        var i = dequeueIndex
        var innerCount = count

        return AnyIterator {
            if innerCount == 0 {
                return nil
            }

            defer {
                innerCount -= 1
                i += 1
            }

            if i >= self.storage.count {
                i -= self.storage.count
            }

            return self.storage[i]
        }
    }
}
