To connect to the broker, you simply need to invoke `connect` method

```dart
courierClient.connect();
```

To disconnect, you just need to invoke `disconnect` method

```dart
courierClient.disconnect();
```

As MQTT supports QoS 1 and QoS 2 message to ensure deliverability when there is no internet connection and user reconnected back to broker, we also persists those message in local cache. To disconnect and remove all of this cache, you can invoke.

```dart
courierClient.destroy();
```

## Network Lost Handling
Courier internally handles reconnection in case of bad/lost internet connection.
