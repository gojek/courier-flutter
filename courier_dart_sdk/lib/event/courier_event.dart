import 'package:courier_dart_sdk/courier_connect_info.dart';

abstract class CourierEvent {
  final String name;
  final ConnectionInfo? connectionInfo;

  CourierEvent(this.name, this.connectionInfo);
}

class MQTTConnectAtttemptEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  MQTTConnectAtttemptEvent(this.name, this.connectionInfo);
}

class MQTTConnectSuccessEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  MQTTConnectSuccessEvent(this.name, this.connectionInfo);
}

class MQTTConnectFailureEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final int reason;

  MQTTConnectFailureEvent(this.name, this.connectionInfo, this.reason);
}

class MQTTConnectionLostEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final int reason;

  MQTTConnectionLostEvent(this.name, this.connectionInfo, this.reason);
}

class MQTTDisconnectEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  MQTTDisconnectEvent(this.name, this.connectionInfo);
}

class MQTTSubscribeAttemptEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final String topic;

  MQTTSubscribeAttemptEvent(this.name, this.connectionInfo, this.topic);
}

class MQTTSubscribeSuccessEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final String topic;

  MQTTSubscribeSuccessEvent(this.name, this.connectionInfo, this.topic);
}

class MQTTSubscribeFailureEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final String topic;
  final int reason;

  MQTTSubscribeFailureEvent(
      this.name, this.connectionInfo, this.topic, this.reason);
}

class MQTTUnsubscribeAttemptEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final String topic;

  MQTTUnsubscribeAttemptEvent(this.name, this.connectionInfo, this.topic);
}

class MQTTUnsubscribeSuccessEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final String topic;

  MQTTUnsubscribeSuccessEvent(this.name, this.connectionInfo, this.topic);
}

class MQTTUnsubscribeFailureEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final String topic;
  final int reason;

  MQTTUnsubscribeFailureEvent(
      this.name, this.connectionInfo, this.topic, this.reason);
}

class MQTTMessageReceive implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final String topic;
  final int sizeBytes;

  MQTTMessageReceive(
      this.name, this.connectionInfo, this.topic, this.sizeBytes);
}

class MQTTMessageReceiveError implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final String topic;
  final int reason;
  final int sizeBytes;

  MQTTMessageReceiveError(
      this.name, this.connectionInfo, this.topic, this.reason, this.sizeBytes);
}

class MQTTMessageSend implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final String topic;
  final int qos;
  final int sizeBytes;

  MQTTMessageSend(
      this.name, this.connectionInfo, this.topic, this.qos, this.sizeBytes);
}

class MQTTMessageSendSuccess implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final String topic;
  final int qos;
  final int sizeBytes;

  MQTTMessageSendSuccess(
      this.name, this.connectionInfo, this.topic, this.qos, this.sizeBytes);
}

class MQTTMessageSendFailure implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final String topic;
  final int qos;
  final int reason;
  final int sizeBytes;

  MQTTMessageSendFailure(this.name, this.connectionInfo, this.topic, this.qos,
      this.reason, this.sizeBytes);
}

class MQTTPingInitiatedEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  MQTTPingInitiatedEvent(this.name, this.connectionInfo);
}

class MQTTPingSuccessEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  MQTTPingSuccessEvent(this.name, this.connectionInfo);
}

class MQTTPingFailureEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;
  final int reason;

  MQTTPingFailureEvent(this.name, this.connectionInfo, this.reason);
}
