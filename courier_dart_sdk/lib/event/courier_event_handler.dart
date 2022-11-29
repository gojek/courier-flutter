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
        eventStreamController.add(MQTTConnectAtttemptEvent(
            name: eventName,
            isOptimalKeepAlive: eventProps['isOptimalKeepAlive'] ?? false,
            connectionInfo: connectionInfo));
        break;

      case "Mqtt Connect Discarded":
        eventStreamController.add(MQTTConnectDiscardedEvent(
            name: eventName,
            reason: eventProps['reason'] ?? -1,
            connectionInfo: connectionInfo));
        break;

      case "Mqtt Connect Success":
        eventStreamController.add(MQTTConnectSuccessEvent(
            name: eventName,
            timeTaken: eventProps['timeTaken'] ?? 0,
            connectionInfo: connectionInfo));
        break;

      case "Mqtt Connect Failure":
        eventStreamController.add(MQTTConnectFailureEvent(
            name: eventName,
            timeTaken: eventProps['timeTaken'] ?? 0,
            reason: eventProps['reason'] ?? -1,
            connectionInfo: connectionInfo));
        break;

      case "Mqtt Connection Lost":
        eventStreamController.add(MQTTConnectionLostEvent(
            name: eventName,
            reason: eventProps['reason'] ?? -1,
            timeTaken: eventProps['timeTaken'] ?? 0,
            connectionInfo: connectionInfo));
        break;

      case "Socket Connect Attempt":
        eventStreamController.add(SocketConnectAttemptEvent(
            name: eventName,
            timeout: eventProps['timeout'] ?? 0,
            connectionInfo: connectionInfo));
        break;

      case "Socket Connect Success":
        eventStreamController.add(SocketConnectSuccessEvent(
            name: eventName,
            timeout: eventProps['timeout'] ?? 0,
            timeTaken: eventProps['timeTaken'] ?? 0,
            connectionInfo: connectionInfo));
        break;

      case "Socket Connect Failure":
        eventStreamController.add(SocketConnectFailureEvent(
            name: eventName,
            timeout: eventProps['timeout'] ?? 0,
            timeTaken: eventProps['timeTaken'] ?? 0,
            reason: eventProps['reason'] ?? 0,
            connectionInfo: connectionInfo));
        break;

      case "SSL Socket Attempt":
        eventStreamController.add(SSLSocketAttemptEvent(
            name: eventName,
            timeout: eventProps['timeout'] ?? 0,
            connectionInfo: connectionInfo));
        break;

      case "SSL Socket Success":
        eventStreamController.add(SSLSocketSuccessEvent(
            name: eventName,
            timeout: eventProps['timeout'] ?? 0,
            timeTaken: eventProps['timeTaken'] ?? 0,
            connectionInfo: connectionInfo));
        break;

      case "SSL Socket Failure":
        eventStreamController.add(SSLSocketFailureEvent(
            name: eventName,
            timeout: eventProps['timeout'] ?? 0,
            timeTaken: eventProps['timeTaken'] ?? 0,
            reason: eventProps['reason'] ?? -1,
            connectionInfo: connectionInfo));
        break;

      case "SSL Socket Handshake Success":
        eventStreamController.add(SSLHandshakeSuccessEvent(
            name: eventName,
            timeout: eventProps['timeout'] ?? 0,
            timeTaken: eventProps['timeTaken'] ?? 0,
            connectionInfo: connectionInfo));
        break;

      case "Connect Packet Send":
        eventStreamController
            .add(ConnectPacketSendEvent(eventName, connectionInfo));
        break;

      case "Mqtt Subscribe Attempt":
        eventStreamController.add(MQTTSubscribeAttemptEvent(
            eventName, connectionInfo, eventProps['topic'] ?? ""));
        break;

      case "Mqtt Subscribe Success":
        eventStreamController.add(MQTTSubscribeSuccessEvent(
            name: eventName,
            topic: eventProps['topic'] ?? "",
            qos: eventProps['qos'] ?? 0,
            timeTaken: eventProps['timeTaken'] ?? 0,
            connectionInfo: connectionInfo));
        break;

      case "Mqtt Subscribe Failure":
        eventStreamController.add(MQTTSubscribeFailureEvent(
            name: eventName,
            topic: eventProps['topic'] ?? "",
            reason: eventProps['reason'] ?? -1,
            qos: eventProps['qos'] ?? 0,
            timeTaken: eventProps['timeTaken'] ?? 0,
            connectionInfo: connectionInfo));
        break;

      case "Mqtt Unsubscribe Attempt":
        eventStreamController.add(MQTTUnsubscribeAttemptEvent(
            eventName, connectionInfo, eventProps['topic'] ?? ""));
        break;

      case "Mqtt Unsubscribe Success":
        eventStreamController.add(MQTTUnsubscribeSuccessEvent(
            name: eventName,
            topic: eventProps['topic'] ?? "",
            timeTaken: eventProps['timeTaken'] ?? 0,
            connectionInfo: connectionInfo));
        break;

      case "Mqtt Unsubscribe Failure":
        eventStreamController.add(MQTTUnsubscribeFailureEvent(
            name: eventName,
            topic: eventProps['topic'] ?? "",
            reason: eventProps['reason'] ?? -1,
            timeTaken: eventProps['timeTaken'] ?? 0,
            connectionInfo: connectionInfo));
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

      case "Mqtt Ping Initiated":
        eventStreamController
            .add(MQTTPingInitiatedEvent(eventName, connectionInfo));
        break;

      case "Mqtt Ping Success":
        eventStreamController.add(MQTTPingSuccessEvent(
            name: eventName,
            timeTaken: eventProps['timeTaken'] ?? 0,
            connectionInfo: connectionInfo));
        break;

      case "Mqtt Ping Failure":
        eventStreamController.add(MQTTPingFailureEvent(
            name: eventName,
            reason: eventProps['reason'] ?? -1,
            timeTaken: eventProps['timeTaken'] ?? 0,
            connectionInfo: connectionInfo));
        break;

      case "Mqtt Ping Exception":
        eventStreamController.add(MqttPingExceptionEvent(
            name: eventName,
            reason: eventProps['reason'] ?? -1,
            connectionInfo: connectionInfo));
        break;

      case "Mqtt Background Alarm Ping Limit Reached":
        eventStreamController
            .add(BackgroundAlarmPingLimitReached(eventName, connectionInfo));
        break;

      case "Mqtt Optimal Keep Alive Found":
        eventStreamController.add(OptimalKeepAliveFoundEvent(
            name: eventName,
            timeMinutes: eventProps['timeMinutes'] ?? 0,
            probeCount: eventProps['probeCount'] ?? 0,
            convergenceTime: eventProps['convergenceTime'] ?? 0,
            connectionInfo: connectionInfo));
        break;

      case "Mqtt Reconnect":
        eventStreamController
            .add(MQTTReconnectEvent(eventName, connectionInfo));
        break;

      case "Mqtt Disconnect":
        eventStreamController
            .add(MQTTDisconnectEvent(eventName, connectionInfo));
        break;

      case "Mqtt Disconnect Start":
        eventStreamController
            .add(MQTTDisconnectStartEvent(eventName, connectionInfo));
        break;

      case "Mqtt Disconnect Complete":
        eventStreamController
            .add(MQTTDisconnectStartEvent(eventName, connectionInfo));
        break;

      case "Mqtt Offline Message Discarded":
        eventStreamController
            .add(OfflineMessageDiscardedEvent(eventName, connectionInfo));
        break;

      case "Mqtt Inbound Inactivity":
        eventStreamController
            .add(InboundInactivityEvent(eventName, connectionInfo));
        break;

      case "Handler Thread Not Alive":
        eventStreamController.add(HandlerThreadNotAliveEvent(
            name: eventName,
            isInterrupted: eventProps['isInterrupted'] ?? false,
            state: eventProps['state'] ?? '',
            connectionInfo: connectionInfo));
        break;

      default:
        break;
    }
  }
}
