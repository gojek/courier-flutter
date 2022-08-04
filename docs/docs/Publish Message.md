To publish message to the broker, you need to serialize your data to byte array `UInt8List`

```dart
// Example of Custom TestData class
Uint8List testDataEncoder(TestData testData) => testData.toBytes();
```

Next, you need to initalize `CourierMessage` instance passing the `bytes`, `topic` string, and `qos` like so.

```dart
final message = CourierMessage(
    bytes: testDataEncoder(TestData("Hello World")),
    topic: "/chat/user1",
    qos: QoS.one
)
```

Finally, you need to invoke `publishCourierMessage` on `CourierClient` passing the message.

```dart
courierClient.publishCourierMessage(mesage);
```