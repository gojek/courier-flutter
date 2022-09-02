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

  @override
  final ConnectionInfo? connectionInfo;

  MQTTConnectAtttemptEvent(this.name, this.connectionInfo);

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return connectionInfo?.convertToMap() ?? {};
  }
}

class MQTTConnectSuccessEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  MQTTConnectSuccessEvent(this.name, this.connectionInfo);

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return connectionInfo?.convertToMap() ?? {};
  }
}

class MQTTConnectFailureEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;

  final int reason;

  MQTTConnectFailureEvent(this.name, this.connectionInfo, this.reason);

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"reason": reason},
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

  MQTTConnectionLostEvent(this.name, this.connectionInfo, this.reason);

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"reason": reason},
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

  MQTTSubscribeSuccessEvent(this.name, this.connectionInfo, this.topic);

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"topic": topic},
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

  MQTTSubscribeFailureEvent(
      this.name, this.connectionInfo, this.topic, this.reason);

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"topic": topic, "reason": reason},
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

  MQTTUnsubscribeSuccessEvent(this.name, this.connectionInfo, this.topic);

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"topic": topic},
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

  MQTTUnsubscribeFailureEvent(
      this.name, this.connectionInfo, this.topic, this.reason);

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {"topic": topic, "reason": reason};
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

  MQTTPingSuccessEvent(this.name, this.connectionInfo);

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return connectionInfo?.convertToMap() ?? {};
  }
}

class MQTTPingFailureEvent implements CourierEvent {
  @override
  final String name;

  @override
  final ConnectionInfo? connectionInfo;
  final int reason;

  MQTTPingFailureEvent(this.name, this.connectionInfo, this.reason);

  @override
  Map<String, dynamic> getEventPropertiesMap() {
    return {
      ...{"reason": reason},
      ...connectionInfo?.convertToMap() ?? {}
    };
  }
}
