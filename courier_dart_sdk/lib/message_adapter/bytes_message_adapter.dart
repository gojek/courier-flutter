import 'dart:typed_data';
import 'dart:developer';
import 'package:courier_dart_sdk/message_adapter/message_adapter.dart';

class BytesMessageAdapter extends MessageAdapter {
  const BytesMessageAdapter();

  @override
  String contentType() => "application/octet-stream";

  @override
  T decode<T>(Uint8List bytes, dynamic decoder) => bytes as T;

  @override
  Uint8List encode(Object object, String topic, dynamic encoder) =>
      object as Uint8List;
}
