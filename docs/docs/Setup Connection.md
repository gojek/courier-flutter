## AuthProvider
This is an interface containing method to fetchConnectOptions used by the Client to connect to broker

## Setup CourierClient with DioAuthProvider
To fetch ConnectionCredential (host, port, etc) from HTTP endpoint, you can use `DioAuthProvider` passing these params.

- **Dio** : We use [dio](https://pub.dev/packages/dio) package for making HTTP request. This will provide you flexibility to use your own Dio instance in case you have various custom headers need to be sent to the server (e.g Authentication, etc). 

- **tokenApi**: An endpoint URL that returns JSON containing credential for mapping to `CourierConnectOptions`.

- **authResponseMapper**: Instance of `AuthResponseMapper` for mapping JSON returned by `tokenAPI` URL to `CourierConnectOptions`.

### Providing Token API URL with JSON Credential Response

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

### Map JSON to CourierConnectOptions

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

## Setup CourierClient with your own AuthProvider
In case you want to fetch the connect options using your own implementation, you can implement AuthProvider interface like so.

```dart
// Example of fetching connectOptions locally without making remote HTTP API Call.
class LocalAuthProvider implements AuthProvider {
  final CourierConnectOptions connectOptions;

  LocalAuthProvider({required this.connectOptions});

  @override
  Future<CourierConnectOptions> fetchConnectOptions() {
    return Future<CourierConnectOptions>.value(connectOptions);
  }
}
```

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