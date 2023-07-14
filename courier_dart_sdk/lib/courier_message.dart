class CourierMessage {
  final Object payload;
  final String topic;
  final QoS qos;

  CourierMessage(
      {required this.payload, required this.topic, required this.qos});
}

enum QoS { zero, one, two }

extension QoSExtension on QoS {
  int get value {
    switch (this) {
      case QoS.zero:
        return 0;
      case QoS.one:
        return 1;
      case QoS.two:
        return 2;
      default:
        return 0;
    }
  }
}
