## Listening to Courier System Events

Courier provides ability to register and listen to library events emitted by the Client (connect attempt/success/failure, message send/receive, subscribe/unsubscribe). All you need to do is listen to `courierEventStream` from `CourieClient`.

```dart
courierClient.courierEventStream().listen((event) {
    print("Event received: ${event}");
});
```

The type of the parameter is an abstract class `CourierEvent` with these public interfaces:
- **name**: Name of the event.
- **connectionInfo** Connection Info tied to the event
- **getEventPropertiesMap**: A key value map containing the properties related to the event.

You can try to Cast the `CourierEvent` to concrete implementation that provides additional properties such as:
- MQTTConnectAttemptEvent
- MQTTConnectSuccessEvent
- MQTTConnectFailureEvent
- MQTTConnectionLostEvent
- MQTTDisconnectEvent
- MQTTSubscribeAttemptEvent
- MQTTSubscribeSuccessEvent
- ...
