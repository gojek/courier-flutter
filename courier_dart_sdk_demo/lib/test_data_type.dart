import 'dart:convert';
import 'dart:typed_data';

class TestData {
  String textMessage = "";

  TestData(this.textMessage);

  factory TestData.fromBytes(Uint8List bytes) {
    return TestData(utf8.decode(bytes));
  }

  Uint8List toBytes() {
    return Uint8List.fromList(utf8.encode(textMessage));
  }
}