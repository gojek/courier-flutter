import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MQTTChuckView extends StatelessWidget {
  const MQTTChuckView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String viewType = 'mqtt-chuck-view';
    final Map<String, dynamic> creationParams = <String, dynamic>{};

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return Stack(
          children: [
            UiKitView(
              viewType: viewType,
              layoutDirection: TextDirection.ltr,
              creationParams: creationParams,
              creationParamsCodec: const StandardMessageCodec(),
            ),
            Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 32, bottom: 32),
                  child: FloatingActionButton(
                      child: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                )),
          ],
        );

      case TargetPlatform.android:
        return Scaffold(
          appBar: AppBar(
            title: const Text('MQTT Chuck'),
          ),
          body: Center(
              child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "To enable MQTT Chuck on Android. Pass \"enableMQTTChuck\" as \"True\" when invoking Platform Channel \"initialise\" method.\n\n" +
                  "You need to grant notification permission access to the App.\n\n" +
                  "Notification will be posted as new MQTT log arrives, you can tap on banner from the Notification drawer to launch the transaction list Activity Screen.",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          )),
        );

      default:
        return const Text("Unsupported Platform");
    }
  }
}
