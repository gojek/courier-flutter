# courier_protobuf

Courier Protobuf MessageAdater for Courier Dart SDK

## Getting Started

Run this command:

With Flutter:

```shell
$ flutter pub add courier_protobuf
```

This will add a line like this to your package's pubspec.yaml (and run an implicit flutter pub get):

```yaml
dependencies:
  courier_protobuf: 0.0.1
```

You can use this package along with courier_dart_sdk if you want to use Protobuf as MesageAdapter for your CourierClient. 

```dart
final CourierClient courierClient = CourierClient.create(
    ...
      messageAdapters: const <MessageAdapter>[
          ProtobufMessageAdapter(),
          ...
      ])
  );
```

Decode bytes to Pet.pb GeneratedMessage:

```dart
courierClient
        .courierMessageStream<Pet>(
            "pet/6b57d4e5-0fce-4917-b343-c8a1c77405e5/update",
            decoder: Pet.fromBuffer)
        .listen((pet) {
      print("Message received Pet: ${pet.name}");
    });
```

Encode Pet GeneratedMessage pb to bytes:

```dart

final pet = Pet();
    pet.name = "Hello Pet";
    courierClient.publishCourierMessage(CourierMessage(
        payload: pet,
        topic: "pet/6b57d4e5-0fce-4917-b343-c8a1c77405e5/update",
        qos: QoS.one));
```