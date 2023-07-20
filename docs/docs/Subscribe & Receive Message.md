After we have connected to broker, we can subscribe to any topic that we want and receive emitted message from that particular topic when the broker pushes the message.

### Subscribe to Topic

To subscribe to a topic from the broker, invoke `susbscribe` method on CourierClient passing the topic string and QoS.
```dart
courierClient.subscribe("chat/user1", QoS.one);
```

### Received Message from Subscribed Topic

After you have subscribed to the topic, you need to listen to a message stream passing the associated topic. `courierMessageStream` will loop message adapters trying to decode the data into specified type, the first one that is able to decode, will be used. You will need pass a decoder parameter to return instance of your object given 1 dynamic parameter depending on the adapter (JSONMessageAdapter pass you `Map<String, dynamic>`, BytesMessageAdapter pass you `Uint8List`)

Optionally you can pass `MessageAdapter` If this is passed, it will use it decode the data to `T`` type, otherwise it will use the messageAdapters list passed when initializing CourierClient.

```dart
/// This uses BytesMessageAdapter passed when initializing CourierClient and constructor tear-offs TestData.fromBytes
courierClient
    .courierMessageStream<TestData>(
        "orders/6b57d4e5-0fce-4917-b343-c8a1c77405e5/update",
        decoder: TestData.fromBytes)
    .listen((event) {
  print("Message received testData: ${event.textMessage}");
});

/// This uses passed JSONMessageAdapter and constructor tear-offs Person.fromJson
courierClient
    .courierMessageStream<Person>(
        "person/6b57d4e5-0fce-4917-b343-c8a1c77405e5/update",
        decoder: Person.fromJson,
        adapter: const JSONMessageAdapter())
    .listen((person) {
  print("Message received person: ${person.name}");
```

### Receive Bytes(Uint8List) from Subscribed Topic

After you have subscribed to the topic, you need to listen to a message stream passing the associated topic. The type of the parameter in the `courierBytesStream` listen callback is byte array `UInt8List`.

```dart
courierClient.courierBytesStream("chat/user1").listen((message) {
    print("Message received: ${event}");
});
```

### Unsubscribe from Topic

To unsubscribe from a topic, simply invoke `unsubscribe` passing the topic string.

```dart
courierClient.unsubscribe("chat/user/1");
```
