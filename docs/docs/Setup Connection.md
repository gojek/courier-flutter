## Providing Token API URL with JSON Credential Response

To connect to MQTT broker you need to provide an endpoint URL that returns JSON containing these payload. 

```json
{
	"clientId": "randomcourier1234567",
	"username": "randomcourier1234567",
    "password": "randomcourier4321",
	"host": "broker.mqttdashboard.com",
	"port": 1883,
	"cleanSession": true,
	"keepAlive": 45
}
```

## Map JSON to CourierConnectOptions

You need to create and implement `AuthResponseMapper` to map the JSON to the `CourierConnectOptions` instance.

```dart
class CourierResponseMapper implements AuthResponseMapper {
  @override
  CourierConnectOptions map(Map<String, dynamic> response) => CourierConnectOptions(
      clientId: response["clientId"],
      username: response["username"],
      host: response["host"],
      port: response["port"],
      cleanSession: response["cleanSession"],
      keepAliveSeconds: response["keepAlive"],
      password: response['password']
  );
}
```

## Setup CourierClient with Token API and Auth Mapper

You need to pass the `tokenAPI` URL and `authResponseMapper` when initializing the   `CourierClient` like so.

```dart
final CourierClient courierClient = CourierClient.create(
    dio: Dio(),
    config: CourierConfiguration(
        tokenApi: "https://example.com/courier-credentials/",
        authResponseMapper: CourierResponseMapper(),
        //...
    )
);
```

We use [dio](https://pub.dev/packages/dio) package for making HTTP request. This will provide you flexibility to use your own Dio instance in case you have various custom headers need to be sent to the server (e.g Authentication, etc). 

## Connect Options properties

```dart
/// IP Host address of the broker
final String host;
/// Port of the broker
final int port;
/// Keep Alive interval used to ping the broker over time to maintain the long run connection
final int keepAliveSeconds;
/// Unique Client ID used by broker to identify connected clients
final String clientId;
/// Username of the client
final String username;
/// Password of the client used for authentication by the broker
final String password;
/// Tells broker whether to clear the previous session by the clients
final Bool isCleanSession;
```