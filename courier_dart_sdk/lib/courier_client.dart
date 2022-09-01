import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:courier_dart_sdk/config/courier_configuration.dart';
import 'package:courier_dart_sdk/connection_state.dart';
import 'package:courier_dart_sdk/courier_connect_info.dart';
import 'package:courier_dart_sdk/courier_connect_options.dart';
import 'package:courier_dart_sdk/courier_message.dart';
import 'package:courier_dart_sdk/event/courier_event.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

abstract class CourierClient {
  void connect();
  void disconnect();
  void destroy();
  void subscribe(String topic, QoS qos);
  void unsubscribe(String topic);
  Stream<Uint8List> courierMessageStream(String topic);
  void publishCourierMessage(CourierMessage message);
  Stream<CourierEvent> courierEventStream();

  static CourierClient create(
      {required Dio dio, required CourierConfiguration config}) {
    return _CourierClientImpl(dio, config);
  }
}

class _CourierClientImpl implements CourierClient {
  final Dio dio;
  final CourierConfiguration courierConfiguration;

  static const _platform = MethodChannel('courier');

  final StreamController<CourierMessage> messageStreamController =
      StreamController();
  final StreamController<CourierEvent> eventStreamController =
      StreamController();

  // This state is used only for avoiding multiple api calls due to multiple connect invocations
  ConnectionState _state = ConnectionState.disconnected;

  _CourierClientImpl(this.dio, this.courierConfiguration) {
    _initialiseCourier();
  }

  @override
  void connect() {
    log('Connect method invoked');
    if (_state != ConnectionState.disconnected) {
      log('Connect method ignored');
      return;
    }
    _connectCourier();
  }

  @override
  void disconnect() {
    log('Disconnect method invoked');
    _disconnectCourier(false);
  }

  @override
  void destroy() {
    log('Destroy method invoked');
    _disconnectCourier(true);
  }

  @override
  void subscribe(String topic, QoS qos) {
    log('Subscribe method invoked');
    _subscribeCourier(topic, qos);
  }

  @override
  void unsubscribe(String topic) {
    log('Unsubscribe method invoked');
    _unsubscribeCourier(topic);
  }

  @override
  void publishCourierMessage(CourierMessage message) {
    log('Send method invoked');
    _sendMessage(message);
  }

  @override
  Stream<Uint8List> courierMessageStream(String topic) {
    log('courier message stream, topic: $topic');
    return messageStreamController.stream
        .where((event) => event.topic == topic)
        .map((event) => event.bytes);
  }

  @override
  Stream<CourierEvent> courierEventStream() {
    log('courier event stream');
    return eventStreamController.stream;
  }

  Future<void> _initialiseCourier() async {
    try {
      _platform.invokeMethod('initialise', courierConfiguration.convertToMap());
      _platform.setMethodCallHandler(_callbackHandler);
    } on PlatformException catch (e) {
      log('initialise error: ${e.message}');
    }
  }

  Future<void> _connectCourier() async {
    try {
      _state = ConnectionState.connecting;
      CourierConnectOptions _options = await _fetchConnectOptions();
      courierConfiguration.authRetryPolicy.reset();
      _platform.invokeMethod('connect', _options.convertToMap());
      _state = ConnectionState.connected;
    } on Exception catch (error) {
      final retrySeconds =
          courierConfiguration.authRetryPolicy.getRetrySeconds(error);
      if (retrySeconds != -1) {
        log("Auth retry policy in action after: $retrySeconds");
        Timer(Duration(seconds: retrySeconds), connect);
      }
    }
  }

  Future<CourierConnectOptions> _fetchConnectOptions() async {
    final response = await dio.get(courierConfiguration.tokenApi);
    if (response.statusCode == 200) {
      return courierConfiguration.authResponseMapper.map(response.data);
    } else {
      log('${response.statusCode} : ${response.data.toString()}');
      final requestOptions =
          RequestOptions(path: courierConfiguration.tokenApi);
      throw DioError(
          requestOptions: requestOptions,
          response: Response(
              requestOptions: requestOptions, statusCode: response.statusCode),
          type: DioErrorType.response);
    }
  }

  Future<void> _disconnectCourier(bool clearState) async {
    try {
      Map<String, dynamic> arguments = {"clearState": clearState};
      _platform.invokeMethod('disconnect', arguments);
      _state = ConnectionState.disconnected;
    } on PlatformException catch (e) {
      log('Disconnect error: ${e.message}');
    }
  }

  Future<void> _subscribeCourier(String topic, QoS qos) async {
    try {
      Map<String, dynamic> arguments = {"topic": topic, "qos": qos.value};
      _platform.invokeMethod('subscribe', arguments);
    } on PlatformException catch (e) {
      log('subscribe error: ${e.message}');
    }
  }

  Future<void> _unsubscribeCourier(String topic) async {
    try {
      Map<String, dynamic> arguments = {"topic": topic};
      _platform.invokeMethod('unsubscribe', arguments);
    } on PlatformException catch (e) {
      log('unsubscribe error: ${e.message}');
    }
  }

  Future<void> _sendMessage(CourierMessage message) async {
    try {
      _platform.invokeMethod('send', message.convertToMap());
    } on PlatformException catch (e) {
      log('Send error: ${e.message}');
    }
  }

  Future<dynamic> _callbackHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'onAuthFailure':
        _handleAuthFailure();
        return;
      case 'onMessageReceive':
        _handleMessage(methodCall.arguments);
        return;
      case 'handleEvent':
        _handleEvent(methodCall.arguments);
        return;
      default:
        throw MissingPluginException('notImplemented');
    }
  }

  void _handleAuthFailure() {
    connect();
  }

  void _handleMessage(Map<dynamic, dynamic> arguments) {
    Uint8List bytes = (arguments)["message"] as Uint8List;
    String topic = (arguments)["topic"] as String;

    log('Message receive: ${utf8.decode(bytes)} on topic: $topic');
    messageStreamController
        .add(CourierMessage(bytes: bytes, topic: topic, qos: QoS.zero));
  }

  void _handleEvent(Map<dynamic, dynamic> arguments) {
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
