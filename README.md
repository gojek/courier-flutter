<div align="center">
<h3 align="center">Courier Flutter SDK</h3>
</div>

## About Courier

Courier is a library for creating long running connections. 

Courier long running connection is a persistent connection established between client & server for bi-directional communication. A long running connection is maintained for as long as possible with the help of keepalive packets. This also saves battery and data on mobile devices.

Run this to download the package:

```shell
flutter pub get
```

## How to use the SDK?

Courier Dart SDK can be initialised using the create factory method provided by CourierClient interface.
```shell
class CourierClient {
    static CourierClient create({required Dio dio, required CourierConfiguration config})
}
```

Courier Dart SDK exposes the CourierClient interface for various functionalities like connect, disconnect, subscribe, unsubscribe, send, receive.
```shell
class CourierClient {
    void connect();
    void disconnect();
    void destroy();
    void subscribe(String topic, QoS qos);
    void unsubscribe(String topic);
    void send(Message message);
    Stream<CourierMessage> receive();
    Stream<CourierEvent> eventStream();
}
```

### To integrate iOS Courier SDK

Add the following snippet to Podfile in your project's iOS folder:
```shell
      pod 'CourierCore', '0.0.7', :modular_headers => true
      pod 'CourierMqtt', '0.0.7', :modular_headers => true
```