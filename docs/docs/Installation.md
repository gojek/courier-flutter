## Use this package as a library

### Depend on it

Run this command:

With Flutter:

```shell
$ flutter pub add courier_flutter
```

This will add a line like this to your package's pubspec.yaml (and run an implicit flutter pub get):

```yaml
dependencies:
  courier_flutter: ^0.0.3
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
      pod 'CourierCore', '0.0.8', :modular_headers => true
      pod 'CourierMqtt', '0.0.8', :modular_headers => true
```