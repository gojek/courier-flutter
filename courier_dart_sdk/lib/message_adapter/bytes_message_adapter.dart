import 'dart:typed_data';

import 'package:courier_dart_sdk/message_adapter/message_adapter.dart';

class BytesMessageAdapter extends MessageAdapter {
  const BytesMessageAdapter();

  @override
  String contentType() => "application/octet-stream";

  @override
  T decode<T>(Uint8List bytes, dynamic decoder) {
    if (T is Uint8List) {
      return bytes as T;
    }
    T item = decoder(bytes);
    return item;
  }

  @override
  Uint8List encode(Object object, String topic, dynamic encoder) {
    if (object is Uint8List) {
      return object;
    }
    return encoder(object);
  }
}
