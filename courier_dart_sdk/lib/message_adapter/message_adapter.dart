import 'dart:typed_data';

/// This class decode bytes to object and encode object to bytes
abstract class MessageAdapter {
  const MessageAdapter();

  /// Content Type (e.g application/json, etc)
  String contentType();

  /// Decode bytes to generic typed object.
  ///
  /// You need to pass `constructor tearoffs` for your type in [decoder] parameter.
  /// https://github.com/dart-lang/language/blob/main/accepted/2.15/constructor-tearoffs/feature-specification.md
  ///
  /// Example of using fromJson that accepts Map to constuct `Person` instance:
  /// ```dart
  /// Person personFromBytes = jsonMessageAdapter.decode(bytes, Person.fromJson);
  /// ```
  T decode<T>(Uint8List bytes, dynamic decoder);

  /// Encode object to bytes.
  ///
  /// Example:
  /// ```dart
  /// final person = Person(name: "john");
  /// final bytes = messageAdapter.encode(person);
  /// ```
  Uint8List encode(Object object, String topic, dynamic encoder);
}
