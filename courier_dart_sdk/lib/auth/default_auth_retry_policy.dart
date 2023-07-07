import 'dart:math';
import 'package:courier_dart_sdk/auth/auth_retry_policy.dart';

class DefaultAuthRetryPolicy extends AuthRetryPolicy {
  final double _baseRetryTime = 1;
  final double _maxRetryTime = 60;

  int _retryCount = 0;

  @override
  int getRetrySeconds(Exception error) {
    return min(_maxRetryTime, _baseRetryTime * pow(2.0, _retryCount++)).toInt();
  }

  @override
  reset() {
    _retryCount = 0;
  }
}
