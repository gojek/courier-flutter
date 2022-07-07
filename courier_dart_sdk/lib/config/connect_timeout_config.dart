class ConnectTimeoutConfig {
  final int socketTimeout;
  final int handshakeTimeout;

  const ConnectTimeoutConfig({
    this.socketTimeout = 10,
    this.handshakeTimeout = 10,
  });

  Map<String, dynamic> convertToMap() {
    return {
      "socketTimeout": socketTimeout,
      "handshakeTimeout": handshakeTimeout,
    };
  }
}