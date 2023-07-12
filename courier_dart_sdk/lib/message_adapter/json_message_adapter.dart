import 'dart:convert';
import 'dart:typed_data';

import 'package:courier_dart_sdk/message_adapter/message_adapter.dart';

class JSONMessageAdapter extends MessageAdapter {
  @override
  String contentType() {
    return "application/json";
  }

  @override
  T decode<T>(Uint8List bytes, dynamic decoder) {
    final json = jsonDecode(String.fromCharCodes(bytes));
    T item = decoder(json);
    return item;
  }

  @override
  Uint8List encode(Object object, String topic) {
    final json = jsonEncode(object);
    final List<int> codeUnits = json.codeUnits;
    final Uint8List byteArray = Uint8List.fromList(codeUnits);
    return byteArray;
  }
}
