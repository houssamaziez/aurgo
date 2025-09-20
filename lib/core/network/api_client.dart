import 'package:aurgo/core/network/api_response.dart';
import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;
  ApiClient(this._dio);

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _buildResponse<T>(response);
    } on DioError catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _buildResponse<T>(response);
    } on DioError catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> put<T>(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return _buildResponse<T>(response);
    } on DioError catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(String path, {dynamic data}) async {
    try {
      final response = await _dio.delete(path, data: data);
      return _buildResponse<T>(response);
    } on DioError catch (e) {
      return _handleError<T>(e);
    }
  }

  ApiResponse<T> _buildResponse<T>(Response response) {
    final code = response.statusCode ?? 0;
    if (code >= 200 && code < 300) {
      return ApiResponse.success(response.data as T, statusCode: code);
    }
    return ApiResponse.failure(
      message: response.statusMessage,
      statusCode: code,
    );
  }

  ApiResponse<T> _handleError<T>(DioError e) {
    String? message = e.message;
    int? code = e.response?.statusCode;
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      message = 'Connection timed out';
    } else if (e.type == DioExceptionType.unknown) {
      message = 'Network error';
    } else if (code != null && e.response?.data != null) {
      try {
        final d = e.response!.data;
        if (d is Map && d['message'] != null) message = d['message'].toString();
      } catch (_) {}
    }
    return ApiResponse.failure(message: message, statusCode: code);
  }
}
