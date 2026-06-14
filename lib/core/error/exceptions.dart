abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class TimeoutException extends AppException {
  const TimeoutException()
    : super('La solicitud tardó demasiado. Intentalo de nuevo.');
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException(super.message, {this.statusCode});
}

class NoDataException extends AppException {
  const NoDataException() : super('No se encontraron datos.');
}
