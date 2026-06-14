import 'package:dio/dio.dart';

class ClientApi {
  static const String _baseUrl = 'https://worldcup26.ir/';
  static const String _jwtToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjZhMmNhYTYxNWE5YjM0NGQyYmEyNWMxNyIsImlhdCI6MTc4MTMxMjA5NywiZXhwIjoxNzg4NTY5Njk3fQ.4e8UvaXXxUxeFQdq440fRevAD_ihs3HPBUiTxr-LEvo';

  static final Dio instance =
      Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              'Authorization': 'Bearer $_jwtToken',
              'Content-type': 'application/json',
            },
          ),
        )
        ..interceptors.add(
          LogInterceptor(requestBody: false, responseBody: true, error: true),
        );
}
