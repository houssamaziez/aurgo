import 'package:aurgo/core/network/network_config.dart';
import 'package:aurgo/core/network/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class NetworkManager {
  late final Dio dio;
  final TokenStorage tokenStorage;

  NetworkManager._internal(this.tokenStorage) {
    final options = BaseOptions(
      baseUrl: NetworkConfig.baseUrl,
      connectTimeout: NetworkConfig.connectTimeout,
      receiveTimeout: NetworkConfig.receiveTimeout,
      responseType: ResponseType.json,
      headers: {'Accept': 'application/json'},
    );

    dio = Dio(options);

    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStorage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer \$token';
          }
          return handler.next(options);
        },
        onError: (DioError err, handler) async {
          if (err.response?.statusCode == 401) {
            // simple behavior: clear token. For refresh flow, implement here.
            await tokenStorage.deleteToken();
          }
          return handler.next(err);
        },
        onResponse: (response, handler) => handler.next(response),
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
        ),
      );
    }
  }

  static NetworkManager? _instance;

  static Future<NetworkManager> getInstance({
    TokenStorage? tokenStorage,
  }) async {
    tokenStorage ??= TokenStorage();
    _instance ??= NetworkManager._internal(tokenStorage);
    return _instance!;
  }
}
