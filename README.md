![Build and Smoketest Status](https://github.com/gojekfarm/courier-flutter/actions/workflows/ci.yml/badge.svg)
<a href="https://gojek.github.io/courier-flutter/">
		<img alt="Documentation" src="https://img.shields.io/badge/documentation-yes-brightgreen.svg" target="_blank" />
	</a>
	<a href="https://github.com/gojekfarm/courier-flutter/graphs/commit-activity">
		<img alt="Maintenance" src="https://img.shields.io/badge/maintained-yes-green.svg" target="_blank" />
	</a>
<a href="https://github.com/gojekfarm/courier-flutter/releases/latest">
<img alt="GitHub Release Date" src="https://img.shields.io/github/release-date/gojekfarm/courier-flutter"></a>
<a href="https://github.com/gojekfarm/courier-flutter/commits/main">
<img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/gojekfarm/courier-flutter"></a>
[![Discord : Gojek Courier](https://img.shields.io/badge/Discord-Gojek%20Courier-blue.svg)](https://discord.gg/C823qK4AK7)

<p align="center">
<img src="https://github.com/gojekfarm/courier-flutter/blob/main/docs/static/img/courier-logo-full-black.svg#gh-light-mode-only" width="500"/>
</p>

<p align="center">
<img src="https://github.com/gojekfarm/courier-flutter/blob/main/docs/static/img/courier-logo-full-white.svg#gh-dark-mode-only" width="500"/>
</p>

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
pod 'CourierCore', '0.0.8', :modular_headers => true
pod 'CourierMqtt', '0.0.8', :modular_headers => true
```