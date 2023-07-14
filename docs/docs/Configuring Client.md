## Create CourierClient

`CourierClient` is the class that we use for any MQTT tasks such as connection, subscription, send and receive message. To initialize an instance of CourierClient we can use the static method like so.

### Create CourierClient

`CourierClient` is the class that we use for any MQTT tasks such as connection, subscription, send and receive message. To initialize an instance of CourierClient we can use the static method like so.

```dart
final CourierClient courierClient = CourierClient.create(
    authProvider: DioAuthProvider(
          dio: Dio(),
          tokenApi: apiUrl,
          authResponseMapper: CourierResponseMapper()),
      config: CourierConfiguration(
          authRetryPolicy: DefaultAuthRetryPolicy(),
          readTimeoutSeconds: 60,
      ),
      messageAdapters: const <MessageAdapter>[
          JSONMessageAdapter(),
          BytesMessageAdapter(),
          StringMessageAdapter()
      ])
  ;
```

## AuthProvider
This is an interface containing method to fetchConnectOptions used by the Client to connect to broker

## Required Configs
- **authRetryPolicy**: Retry policy used to handle retry when tokenAPI URL fails
- **messageAdapters**: List of MessageAdapters used to encode model to bytes and decode bytes to object. Prioritization will be based on the order of the adapter in the list. We provide built-in adapters such as: `JSONMessageAdapter`,`BytesMessageAdapter`, & `StringMessageAdapter`. Optionally, you can also depends on `courier_protobuf` lib to use `ProtobufMessageAdapter`.

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

final CourierClient courierClient = CourierClient.create(
    authProvider: LocalAuthProvider(
          connectOptions: CourierConnectOptions(
              clientId: const Uuid().v4(),
              username: "randomcourier1234567",
              host: "broker.mqttdashboard.com",
              port: 1883,
              cleanSession: true,
              keepAliveSeconds: 45,
              password: "1234")),
      config: CourierConfiguration(
          authRetryPolicy: DefaultAuthRetryPolicy(),
          readTimeoutSeconds: 60,
      ),
      //...
  );
```

## Optional Configs
- **timerPingSenderEnabled**: Whether Courier should use timerPingSender internally (Android only). It defines the logic of sending ping requests over the MQTT connection. Default to `true`.

- **activityCheckIntervalSeconds**: Interval at which channel activity is checked for unacknowledged MQTT packets.. Default to `12`.

- **inactivityTimeoutSeconds**: When acknowledgement for an MQTT packet is not received within this interval, the connection is reestablished. Default to `10`.

- **readTimeoutSeconds**: The read timeout of the connection. Default to `40`.

- **connectRetryPolicyConfig**: A config to determine the retry policy. Default `baseRetryTimeSeconds` to `1` and `maxRetryTimeSeconds` to `30`.

- **connectTimeoutConfig**: A config to determine the connect timeout. Default `socketTimeout` to `10` and `handshakeTimeout` to `10`.
