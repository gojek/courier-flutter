import 'package:courier_dart_sdk/courier_connect_options.dart';

abstract class AuthResponseMapper {
  CourierConnectOptions map(Map<String, dynamic> response);
}