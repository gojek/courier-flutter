import CourierCore
import Foundation

final class MqttMessageReceiverListener: IMessageReceiveListener {
    private var publishSubject: PublishSubject<MQTTPacket>
    private let publishSubjectDispatchQueue: DispatchQueue
    
    @Atomic<[String: Int]>([:]) var messagePublisherDict

    private let messagePersistence: IncomingMessagePersistenceProtocol
    private let messagePersistenceTTLSeconds: TimeInterval
    private let debouncer: Debouncer
    
    var publisherTopicDict: [String: Int] {
        messagePublisherDict
    }
    
    var IsIncomingMessagePersistenceEnabled: Bool {
        messagePersistenceTTLSeconds > 0
    }

    init(publishSubject: PublishSubject<MQTTPacket>,
         publishSubjectDispatchQueue: DispatchQueue,
         enableIncomingMessagePersistence: Bool = false,
         incomingMessagePersistence: IncomingMessagePersistenceProtocol = IncomingMessagePersistence(),
         messagePersistenceTTLSeconds: TimeInterval = 0,
         messageCleanupInterval: TimeInterval = 10) {
        self.publishSubject = publishSubject
        self.publishSubjectDispatchQueue = publishSubjectDispatchQueue
        self.messagePersistence = incomingMessagePersistence
        self.messagePersistenceTTLSeconds = messagePersistenceTTLSeconds
        self.debouncer = Debouncer(timeInterval: messageCleanupInterval)
    }
    
    func addPublisherDict(topic: String) {
        guard IsIncomingMessagePersistenceEnabled else { return }
        _messagePublisherDict.mutate { dict in
            dict[topic, default: 0] += 1
        }
        self.publishSubjectDispatchQueue.async { [weak self] in
            self?.handlePersistedMessages()
        }
    }
    
    func removePublisherDict(topic: String) {
        guard IsIncomingMessagePersistenceEnabled else { return }
        _messagePublisherDict.mutate { dict in
            let value = dict[topic, default: 0]
            if value > 0 {
                dict[topic, default: 0] -= 1
            }
        }
    }

    func messageArrived(data: Data, topic: String, qos: QoS) {
        let message = MQTTPacket(data: data, topic: topic, qos: qos)
        
        if IsIncomingMessagePersistenceEnabled, qos != .zero {
            publishSubjectDispatchQueue.async { [weak self] in
                guard let self = self else { return }
                do {
                    try self.messagePersistence.saveMessage(message)
                } catch {
                    self.publishSubject.onNext(message)
                }
                self.handlePersistedMessages()
            }
        } else {
            publishSubjectDispatchQueue.async { [weak self] in
                self?.publishSubject.onNext(message)
            }
        }
    }
    
    func clearPersistedMessages() {
        self.messagePersistence.deleteAllMessages()
    }
    
    func handlePersistedMessages() {
        self.processMessages()
    }
    
    func scheduleCleanupExpiredMessages() {
        DispatchQueue.main.async { [weak self] in
            self?.debouncer.renewInterval()
            self?.debouncer.handler = {
                self?.publishSubjectDispatchQueue.async {
                    self?.cleanupExpiredMessages()
                }
            }
        }
    }
    
    private func processMessages() {
        let topics = Array<String>(self.messagePublisherDict.keys)
        let messages = self.messagePersistence.getAllMessages(topics)
        guard messages.count > 0 else {
            printDebug("COURIER Incoming Message - No persisted incoming messages for topics: \(topics)")
            return
        }
        
        var messageIDsToDelete = [String]()
        for message in messages {
            if messagePublisherDict[message.topic, default: 0] > 0 {
                self.publishSubject.onNext(message)
                messageIDsToDelete.append(message.id)
                printDebug("COURIER Incoming Message - Message published to subscribers, deleting message. id:\(message.id) topic: \(message.topic)")
            }
            printDebug("COURIER Incoming Message - Successfully processed message id:\(message.id) topic:\(message.topic)")
        }
        
        if messageIDsToDelete.count > 0 {
            self.messagePersistence.deleteMessages(messageIDsToDelete)
        }
        scheduleCleanupExpiredMessages()
    }
    
    private func cleanupExpiredMessages() {
        let expiredDate = Date().addingTimeInterval(-self.messagePersistenceTTLSeconds)
        self.messagePersistence.deleteMessagesWithOlderTimestamp(expiredDate)
    }
}

