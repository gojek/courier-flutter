## Listening to Courier System Events

Courier provides ability to register and listen to library events emitted by the Client (connect attempt/success/failure, message send/receive, subscribe/unsubscribe). All you need to do is listen to `courierEventStream` from `CourieClient`.

```dart
courierClient.courierEventStream().listen((event) {
    print("Event received: ${event}");
});
```

The type of the parameter is `CourierEvent` with 2 properties:
- **name**: Name of the event.
- **properties**: A key value map containing the properties related to the event.