class CourierConnectOptions {
  final String clientId;
  final String username;
  final String password;
  final String scheme;
  final String host;
  final int port;
  final bool cleanSession;
  final int keepAliveSeconds;

  CourierConnectOptions(
      {required this.clientId,
      required this.username,
      required this.password,
      this.scheme = "ssl",
      required this.host,
      required this.port,
      required this.cleanSession,
      required this.keepAliveSeconds});

  Map<String, Object> convertToMap() {
    return {
      "clientId": clientId,
      "username": username,
      "password": password,
      "scheme": scheme,
      "host": host,
      "port": port,
      "cleanSession": cleanSession,
      "keepAliveSeconds": keepAliveSeconds,
    };
  }
}
