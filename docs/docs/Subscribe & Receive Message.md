After we have connected to broker, we can subscribe to any topic that we want and receive emitted message from that particular topic when the broker pushes the message.

### Subscribe to Topic

To subscribe to a topic from the broker, invoke `susbscribe` method on CourierClient passing the topic string and QoS.
```dart
courierClient.subscribe("chat/user1", QoS.one);
```

### Receive Message from Subscribed Topic

After you have subscribed to the topic, you need to listen to a message stream passing the associated topic. The type of the parameter in the listen callback is byte array `UInt8List`.

```dart
courierClient.courierMessageStream("chat/user1").listen((message) {
    print("Message received: ${event}");
});
```

### Unsubscribe from Topic

To unsubscribe from a topic, simply invoke `unsubscribe` passing the topic string.

```dart
courierClient.unsubscribe("chat/user/1");
```
