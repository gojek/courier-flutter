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
