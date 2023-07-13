import 'dart:convert';
import 'dart:typed_data';

import 'package:courier_dart_sdk/courier_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test courier message', () {
    Uint8List bytes = Uint8List.fromList(utf8.encode("test-message"));
    String topic = "test-topic";
    QoS qos = QoS.zero;

    CourierMessage courierMessage =
        CourierMessage(payload: bytes, topic: topic, qos: qos);
    expect(courierMessage.topic, "test-topic");
    expect(courierMessage.qos, 0);
  });
}
