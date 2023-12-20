## 0.0.17
* Fix invalid mapping for connection info in CourierEvent

## 0.0.16
* Bump Dio dependency back to ^5.3.3

## 0.0.15
* A special version that uses Dio 4.0.1 with onAuthFailure method in AuthProvider interface

## 0.0.14
* provide onAuthFailure method in AuthProvider interface

## 0.0.13
* Bump dio to ^5.33.0

## 0.0.12
* Update StreamController in EventHandler to use Broadcast to avoid Fatal Exception ` Bad state: Stream has already been listened to`

## 0.0.11
* Add optional `MessageAdapter` param for messageStream and publish If this is passed, it will use it to decode/encode the data, otherwise it will use the messageAdapters passed when initializing `CourierClient``

## 0.0.10
* Handle Stream onError for CourierMessageStream internally
* Fix BytesMessageAdapter encode & decode
* Granular debug log for encode and decode

## 0.0.9
* Add message adapter interface support for decode bytes to instance and encode instance to bytes

## 0.0.8
* Add AuthProviderInterface for fetching CourierConnectOptions.
* Pass scheme from arguments method channel to iOS connectOptions to connect with SSL/TLS.

## 0.0.7
* Add no-op mqttchuck to android gradle build for production build task.

## 0.0.6
* Add MQTT Chuck Logs for mqtt packets.

## 0.0.5
* Add try catch when logging handle message using UTF-8 decode 

## 0.0.4
* Adds more events and props to the Courier Events for each Android and iOS SDK
* Bump Courier iOS dependency to 0.0.14
* Fix missing Connection Info key in Courier Events (iOS)

## 0.0.3
* Make CourierEvent as abstract class
* Each event implements CourierEvent and provide their own properties

## 0.0.2
* Add support for disconnect delay on Android

## 0.0.1
* Initial release of Courier Flutter SDK
