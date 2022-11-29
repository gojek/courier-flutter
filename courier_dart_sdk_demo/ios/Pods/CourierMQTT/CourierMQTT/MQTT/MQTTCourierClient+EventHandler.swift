import CourierCore
import UIKit

extension MQTTCourierClient: ICourierEventHandler {

    func onEvent(_ event: CourierEvent) {
        switch event.type {
        case .connectionAttempt:
            onMQTTConnectAttempt()
        case .connectionSuccess:
            onMQTTConnectSuccess()
        case .connectionFailure:
            onMQTTConnectFailure()
        case .connectionLost:
            onMQTTConnectionLost()
        case .connectionDisconnect:
            onMQTTDisconnect()
        case .unsubscribeSuccess(let topics, _):
            onMQTTUnsubscribeSuccess(topics: topics)
        case .appForeground:
            onAppForeground()
        case .appBackground:
            onAppBackground()
        case .connectionAvailable:
            connect()

        default: break
        }
    }

    private func onMQTTConnectAttempt() {
        publishConnectionState(connectionState)
    }

    private func onMQTTConnectSuccess() {
        let isCleanSession = client.connectOptions?.isCleanSession ?? false
        if isCleanSession {
            subscriptionStore.clearAllSubscriptions()
        }

        publishConnectionState(connectionState)
        client.unsubscribe( Array(subscriptionStore.pendingUnsubscriptions))
        client.subscribe(subscriptionStore.subscriptions.map { ($0.key, $0.value) })
    }

    private func onMQTTConnectFailure() {
        publishConnectionState(connectionState)
    }

    private func onMQTTConnectionLost() {
        publishConnectionState(connectionState)
    }

    private func onMQTTDisconnect() {
        courierEventHandler.onEvent(.init(connectionInfo: client.connectOptions, event: .courierDisconnect(clearState: isDestroyed)))
        publishConnectionState(connectionState)
    }

    private func onMQTTUnsubscribeSuccess(topics: [String]) {
        subscriptionStore.unsubscribeAcked(topics)
    }

    private func onAppBackground() {
        self.backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "Cleanup pending unsub") { [weak self] in
            self?.invalidateBackgroundTask()
        }

        #if DEBUG || INTEGRATION
        printDebug("MQTT - COURIER: ON App Background, Unsubscribing: \(self.subscriptionStore.pendingUnsubscriptions.map { $0 })")
        #endif

        dispatchQueue.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.invalidateBackgroundTask()
        }
    }

    private func onAppForeground() {
        self.invalidateBackgroundTask()
        dispatchQueue.async { [weak self] in
            self?.connect()
        }
    }
    
    private func invalidateBackgroundTask() {
        if let backgroundTaskID = self.backgroundTaskID {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
        }
    }
}
