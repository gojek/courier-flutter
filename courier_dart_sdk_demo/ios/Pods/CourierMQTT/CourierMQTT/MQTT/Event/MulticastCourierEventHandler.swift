import CourierCore
import Foundation

protocol IMulticastCourierEventHandler: ICourierEventHandler {
    func addEventHandler(_ handler: ICourierEventHandler)
    func removeEventHandler(_ handler: ICourierEventHandler)
}

class MulticastCourierEventHandler: IMulticastCourierEventHandler {

    private let multicast: MulticastDelegate<ICourierEventHandler>

    init(multicast: MulticastDelegate<ICourierEventHandler> = .init()) {
        self.multicast = multicast
    }

    func onEvent(_ event: CourierEvent) {
        multicast.invoke { $0.onEvent(event) }
    }

    func addEventHandler(_ handler: ICourierEventHandler) {
        multicast.add(handler)
    }

    func removeEventHandler(_ handler: ICourierEventHandler) {
        multicast.remove(handler)
    }

    func reset() {
        multicast.invoke { $0.reset() }
    }

}
