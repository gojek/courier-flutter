class ConnectRetryPolicyConfig {
  final int baseRetryTimeSeconds;
  final int maxRetryTimeSeconds;

  const ConnectRetryPolicyConfig({
    this.baseRetryTimeSeconds = 1,
    this.maxRetryTimeSeconds = 30,
  });

  Map<String, dynamic> convertToMap() {
    return {
      "baseRetryTimeSeconds": baseRetryTimeSeconds,
      "maxRetryTimeSeconds": maxRetryTimeSeconds,
    };
  }
}