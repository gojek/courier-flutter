import Foundation

public protocol CourierEventManager {

    func addEventHandler(_ handler: ICourierEventHandler)

    func removeEventHandler(_ handler: ICourierEventHandler)

}
