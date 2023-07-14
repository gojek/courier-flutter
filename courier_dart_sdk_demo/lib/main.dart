import 'dart:typed_data';
import 'package:courier_dart_sdk/auth/default_auth_retry_policy.dart';
import 'package:courier_dart_sdk/auth/dio_auth_provider.dart';
import 'package:courier_dart_sdk/chuck/mqtt_chuck_view.dart';
import 'package:courier_dart_sdk/courier_client.dart';
import 'package:courier_dart_sdk/config/courier_configuration.dart';
import 'package:courier_dart_sdk/courier_connect_options.dart';
import 'package:courier_dart_sdk/courier_message.dart';
import 'package:courier_dart_sdk/message_adapter/bytes_message_adapter.dart';
import 'package:courier_dart_sdk/message_adapter/json_message_adapter.dart';
import 'package:courier_dart_sdk/message_adapter/string_message_adapter.dart';

import 'package:courier_dart_sdk/message_adapter/message_adapter.dart';
import 'package:courier_dart_sdk_demo/courier_response_mapper.dart';
import 'package:courier_dart_sdk_demo/local_auth_provider.dart';
import 'package:courier_dart_sdk_demo/test_data_type.dart';
import 'package:courier_dart_sdk_demo/test_person_data.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Courier Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Courier Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  static const apiUrl =
      "https://run.mocky.io/v3/93166bd2-3cbe-46a2-9a0f-0a3dce1ad304";

  final CourierClient courierClient = CourierClient.create(
      authProvider: DioAuthProvider(
          dio: Dio(),
          tokenApi: apiUrl,
          authResponseMapper: CourierResponseMapper()),
      // authProvider: LocalAuthProvider(
      //     connectOptions: CourierConnectOptions(
      //         clientId: const Uuid().v4(),
      //         username: "randomcourier1234567",
      //         host: "broker.mqttdashboard.com",
      //         port: 1883,
      //         cleanSession: true,
      //         keepAliveSeconds: 45,
      //         password: "1234")),
      config: CourierConfiguration(
          authRetryPolicy: DefaultAuthRetryPolicy(),
          readTimeoutSeconds: 60,
          disconnectDelaySeconds: 10,
          enableMQTTChuck: true),
      messageAdapters: const <MessageAdapter>[
        JSONMessageAdapter(),
        BytesMessageAdapter(),
        StringMessageAdapter()
      ]);

  String textMessage = "";

  void _onConnect() {
    courierClient.connect();
  }

  void _onDisconnect() {
    courierClient.disconnect();
  }

  void _onSubscribe() {
    courierClient.subscribe(
        "orders/6b57d4e5-0fce-4917-b343-c8a1c77405e5/update", QoS.one);
    courierClient.subscribe(
        "orders/6b57d4e5-0fce-4917-b343-c8a1c77405e5/update/foreground",
        QoS.one);

    courierClient
        .courierMessageStream<TestData>(
            "orders/6b57d4e5-0fce-4917-b343-c8a1c77405e5/update",
            decoder: TestData.fromBytes)
        .listen((event) {
      print("Message received testData: ${event.textMessage}");
    });

    courierClient.subscribe(
        "person/6b57d4e5-0fce-4917-b343-c8a1c77405e5/update", QoS.one);

    courierClient
        .courierMessageStream<Person>(
            "person/6b57d4e5-0fce-4917-b343-c8a1c77405e5/update",
            decoder: Person.fromJson)
        .listen((person) {
      print("Message received person: ${person.name}");
    });
  }

  void _onUnsubscribe() {
    courierClient
        .unsubscribe("orders/6b57d4e5-0fce-4917-b343-c8a1c77405e5/update");

    courierClient
        .unsubscribe("person/6b57d4e5-0fce-4917-b343-c8a1c77405e5/update");
  }

  void _onSend() {
    final testData = TestData(textMessage);

    courierClient.publishCourierMessage(
        CourierMessage(
            payload: testData,
            topic: "orders/6b57d4e5-0fce-4917-b343-c8a1c77405e5/update",
            qos: QoS.one),
        encoder: (testData) => testData.toBytes());

    courierClient.publishCourierMessage(CourierMessage(
        payload: Person(name: textMessage),
        topic: "person/6b57d4e5-0fce-4917-b343-c8a1c77405e5/update",
        qos: QoS.one));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _onConnect,
              child: Text('Connect'),
            ),
            ElevatedButton(
              onPressed: _onDisconnect,
              child: Text('Disconnect'),
            ),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Message',
              ),
              onChanged: (text) {
                this.textMessage = text;
              },
            ),
            ElevatedButton(
              onPressed: _onSend,
              child: Text('Send'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _onSubscribe,
                  child: Text('Subscribe'),
                ),
                ElevatedButton(
                  onPressed: _onUnsubscribe,
                  child: Text('Unsubscribe'),
                ),
              ],
            ),
            const SizedBox(
              height: 64,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MQTTChuckView()),
                );
              },
              child: const Text('MQTT Chuck'),
            ),
            if (defaultTargetPlatform == TargetPlatform.android)
              ElevatedButton(
                onPressed: () async {
                  Map<Permission, PermissionStatus> statuses = await [
                    Permission.notification,
                  ].request();

                  print(statuses);
                },
                child: const Text('Request Notification Permission'),
              )
          ],
        ),
      ),
    );
  }
}
