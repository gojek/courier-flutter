## Create CourierClient

`CourierClient` is the class that we use for any MQTT tasks such as connection, subscription, send and receive message. To initialize an instance of CourierClient we can use the static method like so.

```dart
final CourierClient courierClient = CourierClient.create(
      dio: Dio(),
      config: CourierConfiguration(
          tokenApi: apiUrl,
          authResponseMapper: CourierResponseMapper(),
          authRetryPolicy: DefaultAuthRetryPolicy(),
          readTimeoutSeconds: 60,
      )
  );
```

To learn more about the `Dio`, `tokenAPI`, and `authResponseMapper`, please read the [Setup Connection](./Setup%20Connection.md) article.

## Required Configs
- **Dio** : We use [dio](https://pub.dev/packages/dio) package for making HTTP request. This will provide you flexibility to use your own Dio instance in case you have various custom headers need to be sent to the server (e.g Authentication, etc). 

- **tokenApi**: An endpoint URL that returns JSON containing credential for mapping to `CourierConnectOptions`.

- **authResponseMapper**: Instance of `AuthResponseMapper` for mapping JSON returned by `tokenAPI` URL to `CourierConnectOptions`.

- **authRetryPolicy**: Retry policy used to handle retry when tokenAPI URL fails


## Optional Configs
- **timerPingSenderEnabled**: Whether Courier should use timerPingSender internally (Android only). It defines the logic of sending ping requests over the MQTT connection. Default to `true`.

- **activityCheckIntervalSeconds**: Interval at which channel activity is checked for unacknowledged MQTT packets.. Default to `12`.

- **inactivityTimeoutSeconds**: When acknowledgement for an MQTT packet is not received within this interval, the connection is reestablished. Default to `10`.

- **readTimeoutSeconds**: The read timeout of the connection. Default to `40`.

- **connectRetryPolicyConfig**: A config to determine the retry policy. Default `baseRetryTimeSeconds` to `1` and `maxRetryTimeSeconds` to `30`.

- **connectTimeoutConfig**: A config to determine the connect timeout. Default `socketTimeout` to `10` and `handshakeTimeout` to `10`.
