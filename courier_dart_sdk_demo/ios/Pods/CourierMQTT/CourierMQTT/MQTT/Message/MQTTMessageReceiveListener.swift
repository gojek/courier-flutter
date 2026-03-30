import CourierCore
import Foundation

/// Marked this class as `@unchecked Sendable` because it holds non-Sendable properties like `DispatchQueue`,
/// `Debouncer`, and `IncomingMessagePersistenceProtocol`. However, all shared mutable state is managed safely
/// using `@Atomic`, and interactions with shared resources (e.g. message persistence and dispatching) are confined to
/// controlled dispatch queues. Given this controlled access pattern, it's safe to treat this type as Sendable in our use case.

final class MqttMessageReceiverListener: IMessageReceiveListener, @unchecked Sendable {
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
        if IsIncomingMessagePersistenceEnabled, qos != .zero {
            publishSubjectDispatchQueue.async { [weak self] in
                guard let self = self else { return }
                let safeMessage = MQTTPacket(data: data, topic: topic, qos: qos)
                do {
                    try self.messagePersistence.saveMessage(safeMessage)
                } catch {
                    self.publishSubject.onNext(safeMessage)
                }
                self.handlePersistedMessages()
            }
        } else {
            publishSubjectDispatchQueue.async { [weak self] in
                let safeMessage = MQTTPacket(data: data, topic: topic, qos: qos)
                self?.publishSubject.onNext(safeMessage)
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
            self?.debouncer.handler = { [weak self] in
                guard let self = self else { return }
                self.publishSubjectDispatchQueue.async {
                    self.cleanupExpiredMessages()
                }
            }
        }
    }
    
    private func processMessages() {
        let topics = Array<String>(self.messagePublisherDict.keys)
        let messages = self.messagePersistence.getAllMessages(topics)
        guard !messages.isEmpty else {
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
        
        if !messageIDsToDelete.isEmpty {
            self.messagePersistence.deleteMessages(messageIDsToDelete)
        }
        scheduleCleanupExpiredMessages()
    }
    
    private func cleanupExpiredMessages() {
        let expiredDate = Date().addingTimeInterval(-self.messagePersistenceTTLSeconds)
        self.messagePersistence.deleteMessagesWithOlderTimestamp(expiredDate)
    }
}

