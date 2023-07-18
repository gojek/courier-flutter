import 'dart:typed_data';

import 'package:courier_dart_sdk/message_adapter/message_adapter.dart';
import 'package:protobuf/protobuf.dart';

class ProtobufMessageAdapter extends MessageAdapter {
  const ProtobufMessageAdapter();

  @override
  String contentType() => "application/x-protobuf";

  @override
  T decode<T>(Uint8List bytes, dynamic decoder) {
    if (T is GeneratedMessage) {
      return decoder(bytes);
    }
    throw Exception('$T is not of type protobuf generated message');
  }

  @override
  Uint8List encode(Object object, String topic, dynamic encoder) {
    if (object is GeneratedMessage) {
      return object.writeToBuffer();
    }
    return encoder(object);
  }
}
