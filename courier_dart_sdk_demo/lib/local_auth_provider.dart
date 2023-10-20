import 'package:courier_dart_sdk/auth/auth_provider.dart';
import 'package:courier_dart_sdk/courier_connect_options.dart';

class LocalAuthProvider implements AuthProvider {
  final CourierConnectOptions connectOptions;

  LocalAuthProvider({required this.connectOptions});

  @override
  Future<CourierConnectOptions> fetchConnectOptions() {
    return Future<CourierConnectOptions>.value(connectOptions);
  }

  @override
  Future<void> onAuthFailure() async {}
}
