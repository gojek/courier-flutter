import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:courier_dart_sdk/auth/auth_provider.dart';
import 'package:courier_dart_sdk/config/courier_configuration.dart';
import 'package:courier_dart_sdk/connection_state.dart';
import 'package:courier_dart_sdk/courier_connect_options.dart';
import 'package:courier_dart_sdk/courier_message.dart';
import 'package:courier_dart_sdk/event/courier_event.dart';
import 'package:courier_dart_sdk/event/courier_event_handler.dart';
import 'package:courier_dart_sdk/message_adapter/bytes_message_adapter.dart';
import 'package:courier_dart_sdk/message_adapter/json_message_adapter.dart';
import 'package:courier_dart_sdk/message_adapter/message_adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

abstract class CourierClient {
  void connect();
  void disconnect();
  void destroy();
  void subscribe(String topic, QoS qos);
  void unsubscribe(String topic);
  Stream<T> courierMessageStream<T>(String topic,
      {MessageAdapter adapter, dynamic decoder});
  Stream<Uint8List> courierBytesStream(String topic);

  void publishCourierMessage(CourierMessage message,
      {MessageAdapter adapter, dynamic encoder});
  void publishCourierBytes(Uint8List bytes, String topic, QoS qos);
  Stream<CourierEvent> courierEventStream();

  static CourierClient create(
      {required AuthProvider authProvider,
      required CourierConfiguration config,
      List<MessageAdapter> messageAdapters = const <MessageAdapter>[
        BytesMessageAdapter(),
        JSONMessageAdapter()
      ]}) {
    return _CourierClientImpl(authProvider, config, messageAdapters);
  }
}

class _CourierClientImpl implements CourierClient {
  final AuthProvider authProvider;
  final CourierConfiguration courierConfiguration;
  final List<MessageAdapter> messageAdapters;

  static const _platform = MethodChannel('courier');

  final StreamController<CourierMessage> messageStreamController =
      StreamController.broadcast();
  final ICourierEventHandler eventHandler = CourierEventHandler();

  // This state is used only for avoiding multiple api calls due to multiple connect invocations
  ConnectionState _state = ConnectionState.disconnected;

  _CourierClientImpl(
      this.authProvider, this.courierConfiguration, this.messageAdapters) {
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
  void publishCourierMessage(CourierMessage message,
      {MessageAdapter? adapter, dynamic encoder}) {
    log('Send method invoked');
    _sendMessage(message, adapter, encoder);
  }

  @override
  void publishCourierBytes(Uint8List bytes, String topic, QoS qos) {
    publishCourierMessage(
        CourierMessage(payload: bytes, topic: topic, qos: qos),
        adapter: const BytesMessageAdapter());
  }

  @override
  Stream<T> courierMessageStream<T>(String topic,
      {MessageAdapter? adapter, dynamic decoder}) {
    log('courier message stream, topic: $topic $T');
    return messageStreamController.stream
        .where((event) => event.topic == topic)
        .map((event) {
      log('Decoding topic: $topic $T');
      final bytes = event.payload as Uint8List;
      if (adapter != null) {
        T item = adapter.decode(bytes, decoder);
        log('Decoding success with provided $adapter');
        return item;
      } else {
        for (final adapter in messageAdapters) {
          try {
            T item = adapter.decode(bytes, decoder);
            log('Decoding success with $adapter');
            return item;
          } catch (error) {
            log('Decoding Adapter $adapter not compatible ${error.toString()}');
          }
        }
      }
      T item = decoder(bytes);
      log('Decoding success for $T using decoder closure');
      return item;
    }).handleError((e) {
      log('Error Decode $T for $topic' + e.toString());
    });
  }

  @override
  Stream<Uint8List> courierBytesStream(String topic) =>
      courierMessageStream<Uint8List>(topic,
          adapter: const BytesMessageAdapter());

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
      CourierConnectOptions _options = await authProvider.fetchConnectOptions();
      eventHandler.handleCourierEvent(AuthenticatorSuccessEvent(
          name: "Courier Connect Succeeded",
          timeTaken: DateTime.now().millisecondsSinceEpoch - attemptTimestamp));
      courierConfiguration.authRetryPolicy.reset();
      _platform.invokeMethod('connect', _options.convertToMap());
      _state = ConnectionState.connected;
    } on Exception catch (error) {
      int reason = -1;
      if (error is DioException) {
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

  Future<void> _sendMessage(
      CourierMessage message, MessageAdapter? adapter, dynamic encoder) async {
    try {
      log('Send/Encoding: topic ${message.topic} ${message.payload.toString()}');
      if (adapter != null) {
        final map = _convertToMap(message, adapter, encoder);
        _platform.invokeMethod('send', map);
        log('Send/Encoding success with provided adapter $adapter topic ${message.topic} ${message.payload.toString()}');
        return;
      } else {
        for (final adapter in messageAdapters) {
          try {
            final map = _convertToMap(message, adapter, encoder);
            _platform.invokeMethod('send', map);
            log('Send/Encoding success with adapter $adapter topic ${message.topic} ${message.payload.toString()}');
            return;
          } catch (error) {
            log('Encoding Adapter $adapter not compatible ${error.toString()}');
            log(error.toString());
          }
        }
      }
      final map = {
        "message": encoder(message.payload),
        "topic": message.topic,
        "qos": message.qos.value
      };
      _platform.invokeMethod('send', map);
      log('Send/Encoding success with encoder. topic ${message.topic} ${message.payload.toString()}');
    } catch (e) {
      log('Send/Encoding failed: topic ${message.topic} } ${e.toString()}');
    }
  }

  Map<String, Object> _convertToMap(
      CourierMessage message, MessageAdapter messageAdapter, dynamic encoder) {
    final bytes =
        messageAdapter.encode(message.payload, message.topic, encoder);
    return {"message": bytes, "topic": message.topic, "qos": message.qos.value};
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

    try {
      log('Message receive: ${utf8.decode(bytes)} on topic: $topic');
    } on Exception catch (e) {
      log('Message receive: failed to decode using utf 8');
    }

    messageStreamController
        .add(CourierMessage(payload: bytes, topic: topic, qos: QoS.zero));
  }
}
