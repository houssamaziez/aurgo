import 'package:aurgo/core/network/api_client.dart';
import 'package:aurgo/core/network/api_response.dart' show ApiResponse;
import 'package:aurgo/core/network/network_config.dart';
import 'package:aurgo/core/network/token_storage.dart';

class AuthRepository {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  AuthRepository(this.apiClient, this.tokenStorage);

  Future<ApiResponse<String>> login(String login, String password) async {
    final body = {'login': login, 'password': password};
    final resp = await apiClient.post<Map<String, dynamic>>(
      NetworkConfig.loginPath,
      data: body,
    );
    if (resp.success && resp.data != null) {
      try {
        final token =
            (resp.data as Map<String, dynamic>)['data']['token'] as String?;
        if (token != null) {
          await tokenStorage.saveToken(token);
          return ApiResponse.success(token, statusCode: resp.statusCode);
        }
      } catch (_) {}
    }
    return ApiResponse.failure(
      message: resp.message ?? 'Login failed',
      statusCode: resp.statusCode,
    );
  }

  Future<void> logout() async {
    await tokenStorage.deleteToken();
    // optionally call server revoke endpoint
  }
}
