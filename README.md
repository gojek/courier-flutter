![Build and Smoketest Status](https://github.com/gojek/courier-flutter/actions/workflows/ci.yml/badge.svg)
<a href="https://gojek.github.io/courier-flutter/">
		<img alt="Documentation" src="https://img.shields.io/badge/documentation-yes-brightgreen.svg" target="_blank" />
	</a>
	<a href="https://github.com/gojek/courier-flutter/graphs/commit-activity">
		<img alt="Maintenance" src="https://img.shields.io/badge/maintained-yes-green.svg" target="_blank" />
	</a>
<a href="https://github.com/gojek/courier-flutter/releases/latest">
<img alt="GitHub Release Date" src="https://img.shields.io/github/release-date/gojek/courier-flutter"></a>
<a href="https://github.com/gojek/courier-flutter/commits/main">
<img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/gojek/courier-flutter"></a>
[![Discord : Gojek Courier](https://img.shields.io/badge/Discord-Gojek%20Courier-blue.svg)](https://discord.gg/C823qK4AK7)

<p align="center">
<img src="https://github.com/gojek/courier-flutter/blob/main/docs/static/img/courier-logo-full-black.svg#gh-light-mode-only" width="500"/>
</p>

<p align="center">
<img src="https://github.com/gojek/courier-flutter/blob/main/docs/static/img/courier-logo-full-white.svg#gh-dark-mode-only" width="500"/>
</p>


## Overview

Courier is a library for creating long running connections using [MQTT](https://mqtt.org) which is the industry standard for IoT Messaging. Long running connection is a persistent connection established between client & server for bi-directional communication. A long running connection is maintained for as long as possible with the help of keepalive packets for instant updates. This also saves battery and data on mobile devices.

## Detailed Documentation

Find the detailed documentation here - https://gojek.github.io/courier-flutter/

End-to-end courier example - https://gojek.github.io/courier/docs/Introduction

## Getting Started

Setup Courier to subscribe, send, and receive message with bi-directional long running connection between iOS device and broker.

### Sample App

A sample application is added here which makes Courier connection with a HiveMQ public broker. It demonstrates multiple functionalities of Courier like Connect, Disconnect, Publish, Subscribe and Unsubscribe.

Running sample app
- Clone the project from GitHub
- Open `courier_dart_sdk_demo` folder
- Run `flutter run`

### Installation

Run this command:

With Flutter:

```shell
$ flutter pub add courier_flutter
```

This will add a line like this to your package's pubspec.yaml (and run an implicit flutter pub get):

```yaml
dependencies:
  courier_flutter: ^0.0.7
```

Alternatively, your editor might support flutter pub get. Check the docs for your editor to learn more.

### Import it

Now in your Dart code, you can use:

```dart
import 'package:courier_dart_sdk/courier_client.dart';
```

### To integrate iOS Courier SDK

Add the following snippet to Podfile in your project's iOS folder:
```shell
      pod 'CourierCore', '0.0.19', :modular_headers => true
      pod 'CourierMQTT', '0.0.19', :modular_headers => true
```

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
      )
  );
```

## AuthProvider
This is an interface containing method to fetchConnectOptions used by the Client to connect to broker

## Required Configs
- **authRetryPolicy**: Retry policy used to handle retry when tokenAPI URL fails

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
      )
  );
```

### Managing Connection Lifecycle in CourierClient
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

Courier internally handles reconnection in case of bad/lost internet connection.

### QoS level in MQTT

The Quality of Service (QoS) level is an agreement between the sender of a message and the receiver of a message that defines the guarantee of delivery for a specific message. There are 3 QoS levels in MQTT:
- At most once (0)
- At least once (1)
- Exactly once (2).

When you talk about QoS in MQTT, you need to consider the two sides of message delivery:
- Message delivery form the publishing client to the broker.
- Message delivery from the broker to the subscribing client.

You can read more about the detail of QoS in MQTT from [HiveMQ](https://www.hivemq.com/blog/mqtt-essentials-part-6-mqtt-quality-of-service-levels/) site.

### Subscribe to topics from Broker

To subscribe to a topic from the broker, invoke `susbscribe` method on CourierClient passing the topic string and QoS.
```dart
courierClient.subscribe("chat/user1", QoS.one);
```

### Receive Message from Subscribed Topic

After you have subscribed to the topic, you need to listen to a message stream passing the associated topic. The type of the parameter in the listen callback is byte array `UInt8List`.

```dart
courierClient.courierMessageStream("chat/user1").listen((message) {
    print("Message received: ${event}");
});
```

### Unsubscribe from topics

To unsubscribe from a topic, simply invoke `unsubscribe` passing the topic string.

```dart
courierClient.unsubscribe("chat/user/1");
```

### Send Message to Broker

To publish message to the broker, you need to serialize your data to byte array `UInt8List`

```dart
// Example of Custom TestData class
Uint8List testDataEncoder(TestData testData) => testData.toBytes();
```

Next, you need to initalize `CourierMessage` instance passing the `bytes`, `topic` string, and `qos` like so.

```dart
final message = CourierMessage(
    bytes: testDataEncoder(TestData("Hello World")),
    topic: "/chat/user1",
    qos: QoS.one
)
```

Finally, you need to invoke `publishCourierMessage` on `CourierClient` passing the message.

```dart
courierClient.publishCourierMessage(mesage);
```

### Listening to Courier System Events

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
- ...

### MQTT Chuck

This can be used to inspects all the outgoing or incoming packets for an underlying Courier MQTT connection. It intercepts all the packets, persisting them and providing a UI for accessing all the MQTT packets sent or received. It also provides multiple other features like search, share, and clear data.

#### Android MQTT Chuck

Uses the native Android Notification and launchable Activity Intent from the notification banner. You need to pass `enableMQTTChuck` flag as `true` to `CourierConfiguration` when initializing `CourierClient` instance. Make sure you also request permission notification and it is granted by the user.

<p align="center">
<img src="https://user-images.githubusercontent.com/6789991/238231835-9a9745a4-960a-4811-962a-42f4d01a7057.png"/>
</p>


#### iOS MQTT Chuck
Uses embedded flutter host native view, it uses SwiftUI under the hood and require minimum version of iOS 15. You can simply import `MQTTChuckView` and use it in your Flutter App.

```dart
import 'package:courier_dart_sdk/chuck/mqtt_chuck_view.dart';

Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const MQTTChuckView()),
);
```

<p align="center">
<img src="https://user-images.githubusercontent.com/6789991/238231869-cf11a711-99b5-4437-a5e9-af21ef95b4a6.png"/>
</p>


## Contribution Guidelines

Read our [contribution guide](./CONTRIBUTION.md) to learn about our development process, how to propose bugfixes and improvements, and how to build and test your changes to Courier iOS library.

## License

All Courier modules are [MIT Licensed](./LICENSES/LICENSE).
