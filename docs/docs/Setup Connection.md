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

`CourierConnectOptions` represents the properties of the underlying MQTT connection in Courier.

- **IP**: host URI of an MQTT broker.
- **Port**: port of an MQTT broker.
- **Client Id**: Unique ID of the MQTT client.
- **Username**: Username of the MQTT client.
- **Password**: Password of the MQTT client.
- **KeepAlive Interval**: Interval at which keep alive packets are sent for the MQTT connection.
- **Clean Session Flag**: When clean session is false, a persistent connection is created. Otherwise, non-persistent connection is created and all persisted information is cleared from both client and broker.

```dart
final String host;
final int port;
final int keepAliveSeconds;
final String clientId;
final String username;
final String password;
final Bool isCleanSession;
```