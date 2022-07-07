<p align="center">
<img src="https://github.com/gojek/courier-iOS/blob/main/docs/static/img/courier-logo-full-black.svg#gh-light-mode-only" width="500"/>
</p>

<p align="center">
<img src="https://github.com/gojek/courier-iOS/blob/main/docs/static/img/courier-logo-full-white.svg#gh-dark-mode-only" width="500"/>
</p>

## Overview

Courier is a library for creating long running connections using [MQTT](https://mqtt.org) which is the industry standard for IoT Messaging. Long running connection is a persistent connection established between client & server for bi-directional communication. A long running connection is maintained for as long as possible with the help of keepalive packets for instant updates. This also saves battery and data on mobile devices.

## Detailed Documentation

Find the detailed documentation here - https://gojek.github.io/courier-iOS/

End-to-end courier example - https://gojek.github.io/courier/docs/Introduction

## Getting Started

Setup Courier to subscribe, send, and receive message with bi-directional long running connection between iOS device and broker.

### Sample App

You can run the sample App to connect to any broker that you can configure. Select `CourierE2EApp` from the scheme.


### Installation

Courier uses Cocoapods for adding it as a dependency to a project in a `Podfile`. It is separated into 5 modules:
- `CourierCore`: Contains public APIs such as protocols and data types for Courier. Other modules have basic dependency on this module. You can use this module if you want to implement the interface in your project without adding Courier implementation in your project.
- `CourierMQTT`: Contains implementation of `CourierClient` and `CourierSession` using `MQTT`. This module has dependency to `MQTTClientGJ`.
- `MQTTClientGJ`: A forked version of open source library [MQTT-Client-Framework](https://github.com/novastone-media/MQTT-Client-Framework). It add several features such as connect and inactivity timeout. It also fixes race condition crashes in `MQTTSocketEncoder` and `Connack` status 5 not completing the decode before `MQTTTransportDidClose` got invoked bugs.
- `CourierProtobuf`: Contains implementation of `ProtobufMessageAdapter` using `Protofobuf`. It has dependency to `SwiftProtobuf` library, this is `optional` and can be used if you are using protobuf for data serialization.


```ruby
// Podfile
target 'Example-App' do
  use_frameworks!
  pod 'CourierCore'
  pod 'CourierMQTT'
  pod 'CourierProtobuf'
end
```

### Implement IConnectionServiceProvider to provide ConnectOptions for Authentication

To connect to MQTT broker you need to implement IConnectionServiceProvider. First you need to implement `IConnectionServiceProvider/clientId` to return an unique string to identify your client. This must be unique for each device that connect to broker.

```swift
var clientId: String {
    UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
}
```

Next, you need to implement `IConnectionServiceProvider/getConnectOptions(completion:)` method. You need to provide `ConnectOptions` instance that will be used to make connection to the broker. This method provides an escaping closure, in case you need to retrieve the credential from remote API asynchronously. 

```swift
func getConnectOptions(completion: @escaping (Result<ConnectOptions, AuthError>) -> Void) {
    executeNetworkRequest { (response: ConnectOptions) in
        completion(.success(connectOptions))
    } failure: { _, _, error in
        completion(.failure(error))
    }
}
```

Here are the data that you need to provide in ConnectOptions.

```swift
/// IP Host address of the broker
public let host: String
/// Port of the broker
public let port: UInt16
/// Keep Alive interval used to ping the broker over time to maintain the long run connection
public let keepAlive: UInt16
/// Unique Client ID used by broker to identify connected clients
public let clientId: String
/// Username of the client
public let username: String
/// Password of the client used for authentication by the broker
public let password: String
/// Tells broker whether to clear the previous session by the clients
public let isCleanSession: Bool
```

### Configure and Create MQTT CourierClient Instance with CourierClientFactory

Next, we need to create instance of CourierClient that uses MQTT as its implementation. Initialize `CourierClientFactory` instance and invoke `CourierClientFactory/makeMQTTClient(config:)`. We need to pass instance MQTTClientConfig with several parameters that we can customize. 

```swift
let clientFactory = CourierClientFactory()
let courierClient = clientFactory.makeMQTTClient(
    config: MQTTClientConfig(
        authService: HiveMQAuthService(),
        messageAdapters: [
            JSONMessageAdapter(),
            ProtobufMessageAdapter()
        ],
        autoReconnectInterval: 1,
        maxAutoReconnectInterval: 30
    )
)
```

- `MQTTClientConfig/messageAdapters`: we need to pass array of `MessageAdapter`. This will be used for serialization when receiving from broker and sending message to the broker. `CourierMQTT` provides built in message adapters for JSON `(JSONMessageAdapter)` and Plist `(PlistMessageAdapter)` format that conforms to `Codable` protocol. You can only use one of them because both implements to Codable to avoid any conflict. To use protobuf, please import `CourierProtobuf` and pass `ProtobufMessageAdapter`.
- `MQTTClientConfig/authService`: we need to pass our implementation of IConnectionServiceProvider protocol for providing the ConnectOptions to the client.
- `MQTTClientConfig/autoReconnectInterval` The interval used to make reconnection to broker in case of connection lost. This will be multiplied by 2 for each time until it successfully make the connection. The upper limit is based on `MQTTClientConfig/maxAutoReconnectInterval`.


### Managing Connection Lifecycle in CourierClient

To connect to the broker, you simply need to invoke `connect` method

```swift
courierClient.connect()
```

To disconnect, you just need to invoke `disconnect` method

```swift
courierClient.disconnect()
```

To get the ConnectionState, you can access the CourierSession/connectionState property

```swift
courierClient.connectionState
```

You can also subscribe the `ConnectionState` publisher using the `CourierSession/connectionStatePublisher` property. The observable API that Courier provide is very similar to `Apple Combine` although it is implemented internally using `RxSwift` so we can support `iOS 12`.

```swift
courierClient.connectionStatePublisher
    .sink { [weak self] self?.handleConnectionStateEvent($0) }
    .store(in: &cancellables)
```

As MQTT supports QoS 1 and QoS 2 message to ensure deliverability when there is no internet connection and user reconnected back to broker, we also persists those message in local cache. To disconnect and remove all of this cache, you can invoke.

```swift
courierClient.destroy()
```

There are several things that you need to keep in mind when using Courier:
- Courier will always disconnect when the app goes to background as iOS doesn't support long run socket connection in background.
- Courier will always automatically reconnect when the app goes to foreground if there is a topic to subscribe.
- Courier handles reconnection in case of bad/lost internet connection using Reachability framework.
- Courier will persist QoS > 0 messages in case there are no active subscription to Observable/Publisher using configurable TTL.

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

To subscribe to a topic from the broker. we can invoke `CourierSession/subscribe(_:)` and pass a tuple containing the topic string and QoS enum.

```swift
courierClient.subscribe(("chat/user1", QoS.zero))
```

You can also subscribe to multiple topics, invoking `CourierSession/subscribe(_:)` and pass an array containing tuples of topic string and QoS enum

```swift
courierClient.subscribe([
    ("chat/user1", QoS.zero),
    ("order/1234", QoS.one),
    ("order/123456", QoS.two),
])
```

### Receive Message from Subscribed Topic

After you have subscribed to the topic, you need to subscribe to a message publisher passing the associated topic using `CourierSession/messagePublisher(topic:)`. This method uses `Generic` for serializing the binary data to a type. Make sure you have provided the associated MessageAdapter that can decode the data to the type. 

```swift
courierClient.messagePublisher(topic: topic)
    .sink { [weak self] (note: Note) in
        self?.messages.insert(Message(id: UUID().uuidString, name: "Protobuf: \(note.title)", timestamp: Date()), at: 0)
    }.store(in: &cancellables)
```

This method returns AnyPublisher which you can chain with operators such as `AnyPublisher/filter(predicate:)` or `AnyPublisher/map(transform:)`.

The observable API that Courier provide is very similar to Apple Combine although it is implemented internally using RxSwift so we can support iOS 12, only the `filter` and `map` operators are supported.

### Unsubscribe from topics

To unsubscribe from a topic. we can invoke `CourierSession/unsubscribe(_:)` and pass a topic string.

```swift
courierClient.unsubscribe("chat/user1")
```

You can also subscribe to multiple topics, invoking `CourierSession/unsubscribe(_:)` and pass an array containing tuples of topic string and QoS enum

```swift
courierClient.unsubscribe([
    "chat/user1",
    "order/"
])
```


### Send Message to Broker

To send the message to the broker, first make sure you have provided a `MessageAdapter` that is able to encode your object to the binary data format. For example, if you have a data struct that you want to send as JSON. Make sure, it conforms to `Encodable` protocol and pass `JSONMessageAdapter` in `MQTTClientConfig` when creating the `CourierClient` instance.

You simply need to invoke `CourierSession/publishMessage(_:topic:qos:)` passing the topic string and QoS enum. This is a `throwing` function which can throw in case it fails to encode to data.

```swift
let message = Message(
    id: UUID().uuidString,
    name: message,
    timestamp: Date()
)
        
try? courierService?.publishMessage(
    message,
    topic: "chat/1234",
    qos: QoS.zero
)
```

### Listen to Courier internal events

To listen to Courier system events such on `CourierEvent/connectionSuccess`, `CourierEvent/connectionAttempt`, and many more casess declared in `CourierEvent` enum, you can implement the `ICourierEventHandler` protocol and implement `ICourierEventHandler/onEvent(_:)` method. This method will be invoked for any courier system events.

Finally, make sure to have strong reference to the instance, and invoke `CourierEventManager/addEventHandler(_:)` passing the instance.

```swift
courierClient.addEventHandler(analytics)
```

## Contribution Guidelines

Read our [contribution guide](./CONTRIBUTION.md) to learn about our development process, how to propose bugfixes and improvements, and how to build and test your changes to Courier iOS library.

## License

All Courier modules except MQTTClientGJ are [MIT Licensed](./LICENSES/LICENSE). MQTTClientGJ is [Eclipse Licensed](./LICENSES/LICENSE.MQTTClientGJ).
