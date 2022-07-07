import Foundation

protocol IMulticastCourierEventHandlerFactory {
    func makeHandler() -> IMulticastCourierEventHandler
}

struct MulticastCourierEventHandlerFactory: IMulticastCourierEventHandlerFactory {
    func makeHandler() -> IMulticastCourierEventHandler {
        MulticastCourierEventHandler()
    }
}
