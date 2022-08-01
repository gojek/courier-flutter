![image banner](./../static/img/courier-logo-full-black.svg#gh-light-mode-only)
![image banner](./../static/img/courier-logo-full-white.svg#gh-dark-mode-only)

Courier is a library for creating long running connections using [MQTT](https://mqtt.org) which is the industry standard for IoT Messaging. Long running connection is a persistent connection established between client & server for bi-directional communication. A long running connection is maintained for as long as possible with the help of keepalive packets for instant updates. This also saves battery and data on mobile devices.

## Features

* Quality of Service
    * Supports three QoS delivery levels: 0 (atmost once), 1 (atleast once) and 2 (exactly once)

* Clean API
    * Provides clean API for connect / disconnect, subscribe / unsubscribe and publish / receive functionalities

* Automatic Reconnect
    * Automatically reconnects in case of network or other unexpected failures

* Observability
    * Provides events for tracking end-to-end delivery

* Flexible Encoder/Decoder support
    * Converts message payload to and from any custom message type

* Open Source
    * Open-source client libraries for GoLang, Android, iOS, & Flutter

## Contribution Guidelines

Read our [contribution guide](./CONTRIBUTION.md) to learn about our development process, how to propose bugfixes and improvements, and how to build and test your changes to Courier Flutter library.

## License

[1]: https://medium.com/gojekengineering/courier-library-for-gojeks-information-superhighway-368dc5f052fa
[2]: https://broker.mqttdashboard.com/
[3]: https://github.com/gojek/courier-flutter/tree/main/app