import 'package:courier_dart_sdk/auth_response_mapper.dart';
import 'package:courier_dart_sdk/auth_retry_policy.dart';
import 'package:courier_dart_sdk/config/connect_retry_policy_config.dart';
import 'package:courier_dart_sdk/config/connect_timeout_config.dart';

class CourierConfiguration {
  final String tokenApi;
  final AuthResponseMapper authResponseMapper;
  final bool timerPingSenderEnabled;
  final int activityCheckIntervalSeconds;
  final int inactivityTimeoutSeconds;
  final int readTimeoutSeconds;
  final int disconnectDelaySeconds;
  final ConnectRetryPolicyConfig connectRetryPolicyConfig;
  final ConnectTimeoutConfig connectTimeoutConfig;
  final AuthRetryPolicy authRetryPolicy;
  final bool enableMQTTChuck;

  CourierConfiguration(
      {required this.tokenApi,
      required this.authResponseMapper,
      required this.authRetryPolicy,
      this.timerPingSenderEnabled = true,
      this.activityCheckIntervalSeconds = 12,
      this.inactivityTimeoutSeconds = 10,
      this.readTimeoutSeconds = 40,
      this.disconnectDelaySeconds = 0,
      this.connectRetryPolicyConfig = const ConnectRetryPolicyConfig(),
      this.connectTimeoutConfig = const ConnectTimeoutConfig(),
      this.enableMQTTChuck = false});

  Map<String, dynamic> convertToMap() {
    return {
      "timerPingSenderEnabled": timerPingSenderEnabled,
      "activityCheckIntervalSeconds": activityCheckIntervalSeconds,
      "inactivityTimeoutSeconds": inactivityTimeoutSeconds,
      "readTimeoutSeconds": readTimeoutSeconds,
      "disconnectDelaySeconds": disconnectDelaySeconds,
      "connectRetryPolicyConfig": connectRetryPolicyConfig.convertToMap(),
      "connectTimeoutConfig": connectTimeoutConfig.convertToMap(),
      "enableMQTTChuck": enableMQTTChuck
    };
  }
}
