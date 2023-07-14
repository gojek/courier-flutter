import 'dart:convert';
import 'dart:typed_data';

import 'package:courier_dart_sdk/message_adapter/message_adapter.dart';

class StringMessageAdapter extends MessageAdapter {
  const StringMessageAdapter();

  @override
  String contentType() => "text/plain";

  @override
  T decode<T>(Uint8List bytes, dynamic decoder) {
    String text = utf8.decode(bytes);
    return text as T;
  }

  @override
  Uint8List encode(Object object, String topic, dynamic encoder) {
    if (object is String) {
      List<int> bytes = utf8.encode(object);
      return Uint8List.fromList(bytes);
    }
    return encoder(object);
  }
}
