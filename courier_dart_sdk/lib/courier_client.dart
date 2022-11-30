import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:courier_dart_sdk/config/courier_configuration.dart';
import 'package:courier_dart_sdk/connection_state.dart';
import 'package:courier_dart_sdk/courier_connect_options.dart';
import 'package:courier_dart_sdk/courier_message.dart';
import 'package:courier_dart_sdk/event/courier_event.dart';
import 'package:courier_dart_sdk/event/courier_event_handler.dart';
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
  final ICourierEventHandler eventHandler = CourierEventHandler();

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
    return eventHandler.courierEventStream();
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
    final attemptTimestamp = DateTime.now().millisecondsSinceEpoch;
    try {
      _state = ConnectionState.connecting;
      eventHandler.handleCourierEvent(AuthenticatorAttemptEvent(
          name: "Courier Connect Started", forceRefresh: false));
      CourierConnectOptions _options = await _fetchConnectOptions();
      eventHandler.handleCourierEvent(AuthenticatorSuccessEvent(
          name: "Courier Connect Succeeded",
          timeTaken: DateTime.now().millisecondsSinceEpoch - attemptTimestamp));
      courierConfiguration.authRetryPolicy.reset();
      _platform.invokeMethod('connect', _options.convertToMap());
      _state = ConnectionState.connected;
    } on Exception catch (error) {
      int reason = -1;
      if (error is DioError) {
        reason = error.type.index;
      }

      eventHandler.handleCourierEvent(AuthenticatorErrorEvent(
          name: "Courier Connect Failed",
          reason: reason,
          timeTaken: DateTime.now().millisecondsSinceEpoch - attemptTimestamp));
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
        eventHandler.handleEvent(methodCall.arguments);
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
}
