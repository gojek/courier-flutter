import Dispatch

extension DispatchQueue {
    private static var token: DispatchSpecificKey<Void> = {
        let key = DispatchSpecificKey<Void>()
        DispatchQueue.main.setSpecific(key: key, value: ())
        return key
    }()

    static var isMain: Bool {
        DispatchQueue.getSpecific(key: token) != nil
    }
}
