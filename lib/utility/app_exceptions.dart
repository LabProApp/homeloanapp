class AppException implements Exception {
  final String message;
  AppException(this.message);
}

class NetworkException extends AppException {
  NetworkException() : super("No internet connection");
}

class ServerException extends AppException {
  ServerException() : super("Server error. Please try again later");
}

class TimeoutExceptionEx extends AppException {
  TimeoutExceptionEx() : super("Request timeout. Please try again");
}
