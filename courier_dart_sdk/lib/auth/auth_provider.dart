import 'package:courier_dart_sdk/courier_connect_options.dart';

abstract class AuthProvider {
  Future<CourierConnectOptions> fetchConnectOptions();
}
