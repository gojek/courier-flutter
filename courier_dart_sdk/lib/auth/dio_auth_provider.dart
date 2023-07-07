import 'dart:developer';
import 'package:courier_dart_sdk/auth/auth_provider.dart';
import 'package:courier_dart_sdk/auth/auth_response_mapper.dart';
import 'package:courier_dart_sdk/courier_connect_options.dart';
import 'package:dio/dio.dart';

class DioAuthProvider implements AuthProvider {
  final Dio dio;
  final String tokenApi;
  final AuthResponseMapper authResponseMapper;

  DioAuthProvider(
      {required this.dio,
      required this.tokenApi,
      required this.authResponseMapper});

  @override
  Future<CourierConnectOptions> fetchConnectOptions() async {
    final response = await dio.get(tokenApi);
    if (response.statusCode == 200) {
      return authResponseMapper.map(response.data);
    } else {
      log('${response.statusCode} : ${response.data.toString()}');
      final requestOptions = RequestOptions(path: tokenApi);
      throw DioError(
          requestOptions: requestOptions,
          response: Response(
              requestOptions: requestOptions, statusCode: response.statusCode),
          type: DioErrorType.response);
    }
  }
}
