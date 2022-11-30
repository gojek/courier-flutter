import 'package:courier_dart_sdk/courier_connect_info.dart';

abstract class CourierEvent {
  final String name;
  final ConnectionInfo? connectionInfo;

  CourierEvent(this.name, this.connectionInfo);
  Map<String, dynamic> getEventPropertiesMap();
}

class MQTTConnectAtttemptEvent implements CourierEvent {
  @override
  final String name;

  final bool? isOptimalKeepAlive;

  @override
  final ConnectionInfo? connectionInfo;

  MQTTConnectAtttemptEvent(
      {required this.name, this.isOptimalKeepAlive, this.connectionInfo});

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    Map<String, dynamic> map = connectionInfo?.convertToMap() ?? {};
    if (isOptimalKeepAlive != null) {
      map['optimalKeepAlive'] = isOptimalKeepAlive;
    }
    return map;
  }
}

class MQTTConnectDiscardedEvent implements CourierEvent {
  @override
  final String name;

  final String reason;

  @override
  final ConnectionInfo? connectionInfo;

  MQTTConnectDiscardedEvent(
      {required this.name, required this.reason, this.connectionInfo});

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"reason": reason},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
}

class MQTTConnectSuccessEvent implements CourierEvent {
  @override
  final String name;

  final int timeTaken;

  @override
  final ConnectionInfo? connectionInfo;

  MQTTConnectSuccessEvent(
      {required this.name, required this.timeTaken, this.connectionInfo});

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"timeTaken": timeTaken},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
}

class MQTTConnectFailureEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final int reason;
  final int timeTaken;

  MQTTConnectFailureEvent(
      {required this.name,
      required this.timeTaken,
      required this.reason,
      this.connectionInfo});

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"timeTaken": timeTaken, "reason": reason},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
}

class MQTTConnectionLostEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final int reason;
  final int timeTaken;

  MQTTConnectionLostEvent(
      {required this.name,
      required this.timeTaken,
      required this.reason,
      this.connectionInfo});

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"timeTaken": timeTaken, "reason": reason},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
}

class MQTTDisconnectEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  MQTTDisconnectEvent(this.name, this.connectionInfo);

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return connectionInfo?.convertToMap() ?? {};
  }
}

class SocketConnectAttemptEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final int timeout;

  SocketConnectAttemptEvent(
      {required this.name, required this.timeout, this.connectionInfo});

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"timeout": timeout},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
}

class SocketConnectSuccessEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final int timeout;
  final int timeTaken;

  SocketConnectSuccessEvent(
      {required this.name,
      required this.timeout,
      required this.timeTaken,
      this.connectionInfo});

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"timeout": timeout, "timeTaken": timeTaken},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
}

class SocketConnectFailureEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final int timeout;
  final int timeTaken;
  final int reason;

  SocketConnectFailureEvent(
      {required this.name,
      required this.timeout,
      required this.timeTaken,
      required this.reason,
      this.connectionInfo});

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"timeout": timeout, "timeTaken": timeTaken, "reason": reason},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
}

class SSLSocketAttemptEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final int timeout;

  SSLSocketAttemptEvent(
      {required this.name, required this.timeout, this.connectionInfo});

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"timeout": timeout},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
}

class SSLSocketSuccessEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final int timeout;
  final int timeTaken;

  SSLSocketSuccessEvent(
      {required this.name,
      required this.timeout,
      required this.timeTaken,
      this.connectionInfo});

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"timeout": timeout, "timeTaken": timeTaken},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
}

class SSLSocketFailureEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final int timeout;
  final int timeTaken;
  final int reason;

  SSLSocketFailureEvent(
      {required this.name,
      required this.timeout,
      required this.timeTaken,
      required this.reason,
      this.connectionInfo});

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"timeout": timeout, "timeTaken": timeTaken, "reason": reason},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
}

class SSLHandshakeSuccessEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final int timeout;
  final int timeTaken;

  SSLHandshakeSuccessEvent(
      {required this.name,
      required this.timeout,
      required this.timeTaken,
      this.connectionInfo});

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"timeout": timeout, "timeTaken": timeTaken},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
}

class ConnectPacketSendEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  ConnectPacketSendEvent(this.name, this.connectionInfo);

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return connectionInfo?.convertToMap() ?? {};
  }
}

class MQTTSubscribeAttemptEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final String topic;

  MQTTSubscribeAttemptEvent(this.name, this.connectionInfo, this.topic);

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"topic": topic},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
}

class MQTTSubscribeSuccessEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final String topic;
  final int qos;
  final int timeTaken;

  MQTTSubscribeSuccessEvent({
    required this.name,
    required this.topic,
    required this.qos,
    required this.timeTaken,
    this.connectionInfo,
  });

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"topic": topic, "qos": qos, "timeTaken": timeTaken},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
}

class MQTTSubscribeFailureEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final String topic;
  final int reason;
  final int qos;
  final int timeTaken;

  MQTTSubscribeFailureEvent(
      {required this.name,
      required this.topic,
      required this.qos,
      required this.timeTaken,
      required this.reason,
      this.connectionInfo});

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"topic": topic, "qos": qos, "timeTaken": timeTaken, "reason": reason},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
}

class MQTTUnsubscribeAttemptEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final String topic;

  MQTTUnsubscribeAttemptEvent(this.name, this.connectionInfo, this.topic);

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"topic": topic},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
}

class MQTTUnsubscribeSuccessEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final String topic;
  final int timeTaken;

  MQTTUnsubscribeSuccessEvent(
      {required this.name,
      required this.topic,
      required this.timeTaken,
      this.connectionInfo});

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"topic": topic, "timeTaken": timeTaken},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
}

class MQTTUnsubscribeFailureEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final String topic;
  final int reason;
  final int timeTaken;

  MQTTUnsubscribeFailureEvent(
      {required this.name,
      required this.topic,
      required this.reason,
      required this.timeTaken,
      this.connectionInfo});

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"topic": topic, "reason": reason, "timeTaken": timeTaken},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
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

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"topic": topic, "sizeBytes": sizeBytes},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
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

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"topic": topic, "reason": reason, "sizeBytes": sizeBytes},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
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

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"topic": topic, "qos": qos, "sizeBytes": sizeBytes},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
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

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"topic": topic, "qos": qos, "sizeBytes": sizeBytes},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
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

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"topic": topic, "qos": qos, "reason": reason, "sizeBytes": sizeBytes},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
}

class MQTTPingInitiatedEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  MQTTPingInitiatedEvent(this.name, this.connectionInfo);

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return connectionInfo?.convertToMap() ?? {};
  }
}

class MQTTPingSuccessEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final int timeTaken;

  MQTTPingSuccessEvent(
      {required this.name, required this.timeTaken, this.connectionInfo});

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"timeTaken": timeTaken},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
}

class MQTTPingFailureEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;
  final int reason;
  final int timeTaken;

  MQTTPingFailureEvent(
      {required this.name,
      required this.timeTaken,
      required this.reason,
      this.connectionInfo});

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"timeTaken": timeTaken, "reason": reason},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
}

class MqttPingExceptionEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;
  final int reason;

  MqttPingExceptionEvent(
      {required this.name, required this.reason, this.connectionInfo});

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"reason": reason},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
}

class BackgroundAlarmPingLimitReached implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  BackgroundAlarmPingLimitReached(this.name, this.connectionInfo);

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {...connectionInfo?.convertToMap() ?? {}};
  }
}

class OptimalKeepAliveFoundEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;
  final int timeMinutes;
  final int probeCount;
  final int convergenceTime;

  OptimalKeepAliveFoundEvent(
      {required this.name,
      required this.timeMinutes,
      required this.probeCount,
      required this.convergenceTime,
      this.connectionInfo});

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{
        "timeMinutes": timeMinutes,
        "probeCount": probeCount,
        "convergenceTime": convergenceTime
      },
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
}

class MQTTReconnectEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  MQTTReconnectEvent(this.name, this.connectionInfo);

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return connectionInfo?.convertToMap() ?? {};
  }
}

class MQTTDisconnectStartEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  MQTTDisconnectStartEvent(this.name, this.connectionInfo);

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return connectionInfo?.convertToMap() ?? {};
  }
}

class MQTTDisconnectCompleteEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  MQTTDisconnectCompleteEvent(this.name, this.connectionInfo);

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return connectionInfo?.convertToMap() ?? {};
  }
}

class OfflineMessageDiscardedEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  OfflineMessageDiscardedEvent(this.name, this.connectionInfo);

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return connectionInfo?.convertToMap() ?? {};
  }
}

class InboundInactivityEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  InboundInactivityEvent(this.name, this.connectionInfo);

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return connectionInfo?.convertToMap() ?? {};
  }
}

class HandlerThreadNotAliveEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final bool isInterrupted;
  final String state;

  HandlerThreadNotAliveEvent(
      {required this.name,
      required this.isInterrupted,
      required this.state,
      this.connectionInfo});

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"isInterrupted": isInterrupted, "state": state},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
}

class AuthenticatorAttemptEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final bool forceRefresh;

  AuthenticatorAttemptEvent(
      {required this.name, required this.forceRefresh, this.connectionInfo});

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"forceRefresh": forceRefresh},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
}

class AuthenticatorSuccessEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final int timeTaken;

  AuthenticatorSuccessEvent(
      {required this.name, required this.timeTaken, this.connectionInfo});

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"timeTaken": timeTaken},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
}

class AuthenticatorErrorEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final int reason;
  final int timeTaken;

  AuthenticatorErrorEvent(
      {required this.name,
      required this.reason,
      required this.timeTaken,
      this.connectionInfo});

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"timeTaken": timeTaken, "reason": reason},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
}
