import 'dart:typed_data';

class CourierMessage {
  final Uint8List bytes;
  final String topic;
  final QoS qos;

  CourierMessage({required this.bytes, required this.topic, required this.qos});

  Map<String, Object> convertToMap() {
    return {
      "message": bytes,
      "topic": topic,
      "qos": qos.value
    };
  }
}

enum QoS {
  zero, one, two
}

extension QoSExtension on QoS {
  int get value {
    switch(this) {
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