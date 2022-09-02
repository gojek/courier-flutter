import 'dart:async';
import 'dart:developer';

import 'package:courier_dart_sdk/courier_connect_info.dart';
import 'package:courier_dart_sdk/event/courier_event.dart';

abstract class ICourierEventHandler {
  Stream<CourierEvent> courierEventStream();
  handleEvent(Map<dynamic, dynamic> arguments);
}

class CourierEventHandler implements ICourierEventHandler {
  final StreamController<CourierEvent> eventStreamController =
      StreamController();

  @override
  Stream<CourierEvent> courierEventStream() {
    return eventStreamController.stream;
  }

  @override
  handleEvent(Map arguments) {
    String eventName = (arguments)["name"] as String;
    Map<String, dynamic> eventProps = {};
    if ((arguments)["properties"] != null) {
      eventProps = Map<String, dynamic>.from((arguments)["properties"]);
    }
    log('Event received: $eventName with properties: $eventProps');

    final connectionInfoMap = eventProps["connectionInfo"];
    ConnectionInfo? connectionInfo;
    if (connectionInfoMap != null) {
      connectionInfo = ConnectionInfo(
        clientId: connectionInfoMap['clientId'] ?? "",
        username: connectionInfoMap['username'] ?? "",
        keepAliveSeconds: connectionInfoMap['keepAlive'] ?? -1,
        connectTimeout: connectionInfoMap['connectTimeout'] ?? -1,
        host: connectionInfoMap['host'] ?? "",
        port: connectionInfoMap['port'] ?? "",
        scheme: connectionInfoMap['scheme'] ?? "",
      );
    }

    switch (eventName) {
      case "Mqtt Connect Attempt":
        eventStreamController
            .add(MQTTConnectAtttemptEvent(eventName, connectionInfo));
        break;

      case "Mqtt Connect Success":
        eventStreamController
            .add(MQTTConnectSuccessEvent(eventName, connectionInfo));
        break;

      case "Mqtt Disconnect":
        eventStreamController
            .add(MQTTDisconnectEvent(eventName, connectionInfo));
        break;

      case "Mqtt Ping Initiated":
        eventStreamController
            .add(MQTTPingInitiatedEvent(eventName, connectionInfo));
        break;

      case "Mqtt Ping Success":
        eventStreamController
            .add(MQTTPingSuccessEvent(eventName, connectionInfo));
        break;

      case "Mqtt Ping Failure":
        eventStreamController.add(MQTTPingFailureEvent(
            eventName, connectionInfo, eventProps['reason'] ?? -1));
        break;

      case "Mqtt Connect Failure":
        eventStreamController.add(MQTTConnectFailureEvent(
            eventName, connectionInfo, eventProps['reason'] ?? -1));
        break;

      case "Mqtt Connection Lost":
        eventStreamController.add(MQTTConnectionLostEvent(
            eventName, connectionInfo, eventProps['reason'] ?? ""));
        break;

      case "Mqtt Subscribe Attempt":
        eventStreamController.add(MQTTSubscribeAttemptEvent(
            eventName, connectionInfo, eventProps['topic'] ?? ""));
        break;

      case "Mqtt Subscribe Success":
        eventStreamController.add(MQTTSubscribeSuccessEvent(
            eventName, connectionInfo, eventProps['topic'] ?? ""));
        break;

      case "Mqtt Subscribe Failure":
        eventStreamController.add(MQTTSubscribeFailureEvent(
            eventName,
            connectionInfo,
            eventProps['topic'] ?? "",
            eventProps['reason'] ?? -1));
        break;

      case "Mqtt Unsubscribe Attempt":
        eventStreamController.add(MQTTUnsubscribeAttemptEvent(
            eventName, connectionInfo, eventProps['topic'] ?? ""));
        break;

      case "Mqtt Unsubscribe Success":
        eventStreamController.add(MQTTUnsubscribeSuccessEvent(
            eventName, connectionInfo, eventProps['topic'] ?? ""));
        break;

      case "Mqtt Unsubscribe Failure":
        eventStreamController.add(MQTTUnsubscribeFailureEvent(
            eventName,
            connectionInfo,
            eventProps['topic'] ?? "",
            eventProps['reason'] ?? -1));
        break;

      case "Mqtt Message Receive":
        eventStreamController.add(MQTTMessageReceive(eventName, connectionInfo,
            eventProps['topic'] ?? "", eventProps['sizeBytes'] ?? -1));
        break;

      case "Mqtt Message Receive Failure":
        eventStreamController.add(MQTTMessageReceiveError(
            eventName,
            connectionInfo,
            eventProps['topic'] ?? "",
            eventProps['reason'] ?? -1,
            eventProps['sizeBytes'] ?? -1));
        break;

      case "Mqtt Message Send Attempt":
        eventStreamController.add(MQTTMessageSend(
            eventName,
            connectionInfo,
            eventProps['topic'] ?? "",
            eventProps['qos'] ?? -1,
            eventProps['sizeBytes'] ?? -1));
        break;

      case "Mqtt Message Send Success":
        eventStreamController.add(MQTTMessageSendSuccess(
            eventName,
            connectionInfo,
            eventProps['topic'] ?? "",
            eventProps['qos'] ?? -1,
            eventProps['sizeBytes'] ?? -1));
        break;

      case "Mqtt Message Send Failure":
        eventStreamController.add(MQTTMessageSendFailure(
            eventName,
            connectionInfo,
            eventProps['topic'] ?? "",
            eventProps['qos'] ?? -1,
            eventProps['reason'] ?? -1,
            eventProps['sizeBytes'] ?? -1));
        break;

      default:
        break;
    }
  }
}
