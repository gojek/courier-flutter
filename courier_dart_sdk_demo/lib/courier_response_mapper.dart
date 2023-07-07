import 'package:courier_dart_sdk/auth/auth_response_mapper.dart';
import 'package:courier_dart_sdk/courier_connect_options.dart';

class CourierResponseMapper implements AuthResponseMapper {
  @override
  CourierConnectOptions map(Map<String, dynamic> response) => CourierConnectOptions(
      clientId: response["clientId"],
      username: response["username"],
      scheme: response["scheme"] ?? "tcp",
      host: response["host"],
      port: response["port"],
      cleanSession: response["cleanSession"],
      keepAliveSeconds: response["keepAlive"],
      password:
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE2MDgxMTU2ODAsImlzcyI6Im1xdHQtYnJva2VyLWNvbm5lY3Rpb24tc2VydmljZSIsInJpZCI6IjZiNTdkNGU1LTBmY2UtNDkxNy1iMzQzLWM4YTFjNzc0MDVlNSJ9.kOahD5nlu_y_KavyFcc0omZD7CtbHGVgQc69AiloUGo");
}
