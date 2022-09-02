class ConnectionInfo {
  final String clientId;
  final String username;
  final int keepAliveSeconds;
  final int connectTimeout;
  final String host;
  final int port;
  final String scheme;

  ConnectionInfo(
      {required this.clientId,
      required this.username,
      required this.keepAliveSeconds,
      required this.connectTimeout,
      required this.host,
      required this.port,
      required this.scheme});

  Map<String, dynamic> convertToMap() {
    return {
      "clientId": clientId,
      "username": username,
      "keepAlive": keepAliveSeconds,
      "connectTimeout": connectTimeout,
      "host": host,
      "port": port,
      "scheme": scheme
    };
  }
}
