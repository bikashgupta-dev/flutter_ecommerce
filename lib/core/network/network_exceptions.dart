import 'package:dio/dio.dart';

class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  const NetworkException(this.message, {this.statusCode});

  @override
  String toString() => message;

  factory NetworkException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return const NetworkException(
          'Connection timed out. Please check your internet connection.',
        );
      case DioExceptionType.sendTimeout:
        return const NetworkException(
          'Request send timed out. Please try again.',
        );
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          'Server response timed out. Please try again.',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return NetworkException(
            'The requested resource was not found.',
            statusCode: 404,
          );
        } else if (statusCode != null && statusCode >= 500) {
          return NetworkException(
            'Server error ($statusCode). Something went wrong on our end.',
            statusCode: statusCode,
          );
        }
        return NetworkException(
          'Request failed with status $statusCode.',
          statusCode: statusCode,
        );
      case DioExceptionType.cancel:
        return const NetworkException('Request was cancelled.');
      case DioExceptionType.connectionError:
        return const NetworkException(
          'Network unavailable. Please check your internet connection.',
        );
      case DioExceptionType.unknown:
      default:
        return NetworkException(
          error.message ?? 'An unexpected network error occurred.',
        );
    }
  }
}

class ParseException extends NetworkException {
  const ParseException([
    super.message = 'Failed to process server response data.',
  ]);
}
