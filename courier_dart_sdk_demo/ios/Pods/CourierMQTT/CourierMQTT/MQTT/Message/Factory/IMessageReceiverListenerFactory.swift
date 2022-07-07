import Foundation

protocol IMessageReceiveListenerFactory {

    func makeListener(publishSubject: PublishSubject<MQTTPacket>,
                      publishSubjectDispatchQueue: DispatchQueue,
                      messagePersistenceTTLSeconds: TimeInterval,
                      messageCleanupInterval: TimeInterval) -> IMessageReceiveListener

}

struct MessageReceiveListenerFactory: IMessageReceiveListenerFactory {

    func makeListener(publishSubject: PublishSubject<MQTTPacket>,
                      publishSubjectDispatchQueue: DispatchQueue,
                      messagePersistenceTTLSeconds: TimeInterval,
                      messageCleanupInterval: TimeInterval) -> IMessageReceiveListener {
        MqttMessageReceiverListener(
            publishSubject: publishSubject,
            publishSubjectDispatchQueue: publishSubjectDispatchQueue,
            messagePersistenceTTLSeconds: messagePersistenceTTLSeconds,
            messageCleanupInterval: messageCleanupInterval
        )
    }
        
}
