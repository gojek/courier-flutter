To publish message to the broker, you need can pass your object instance, it will try to loop all message adapters to encode the instance into Uint8List, the first one that is able to encode, will be used. You can also pass an optional, encoder function that will pass your instance as `dynamic` which you can use to call your own method to encode to `Uint8List`

You need to initalize `CourierMessage` instance passing the `payload`, `topic` string, and `qos` like so. Finally, you need to invoke `publishCourierMessage` on `CourierClient` passing the message.

```dart
/// This used JSONMessageAdapter which use dart jsonEncode to invoke toJson on object implicitly
courierClient.publishCourierMessage(CourierMessage(
    payload: Person(name: textMessage),
    topic: "person/6b57d4e5-0fce-4917-b343-c8a1c77405e5/update",
    qos: QoS.one));

/// For this TestData without toJson method, you can provide your own encode to convert to Uint8List/bytes
courierClient.publishCourierMessage(
    CourierMessage(
        payload: testData,
        topic: "orders/6b57d4e5-0fce-4917-b343-c8a1c77405e5/update",
        qos: QoS.one),
    encoder: (testData) => testData.toBytes());
```