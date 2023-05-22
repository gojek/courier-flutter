MQTT Chuck can be used to inspects all the outgoing or incoming packets for an underlying Courier MQTT connection. It intercepts all the packets, persisting them and providing a UI for accessing all the MQTT packets sent or received. It also provides multiple other features like search, share, and clear data.

# Android MQTT Chuck

Uses the native Android Notification and launchable Activity Intent from the notification banner. You need to pass `enableMQTTChuck` flag as `true` to `CourierConfiguration` when initializing `CourierClient` instance. Make sure you also request permission notification and it is granted by the user.

<p align="center">
<img src="https://user-images.githubusercontent.com/6789991/238231835-9a9745a4-960a-4811-962a-42f4d01a7057.png"/>
</p>


# iOS MQTT Chuck
Uses embedded flutter host native view, it uses SwiftUI under the hood and require minimum version of iOS 15. You can simply import `MQTTChuckView` and use it in your Flutter App.

```dart
import 'package:courier_dart_sdk/chuck/mqtt_chuck_view.dart';
//...

Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const MQTTChuckView()),
);
```

<p align="center">
<img src="https://user-images.githubusercontent.com/6789991/238231869-cf11a711-99b5-4437-a5e9-af21ef95b4a6.png"/>
</p>
