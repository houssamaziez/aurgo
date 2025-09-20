import 'package:aurgo/core/network/api_client.dart';
import 'package:aurgo/core/network/api_response.dart';
import 'package:aurgo/core/network/network_config.dart';
import 'package:aurgo/model/user_model.dart';

class UserRepository {
  final ApiClient apiClient;
  UserRepository(this.apiClient);

  Future<ApiResponse<UserModel>> fetchProfile() async {
    final resp = await apiClient.get<Map<String, dynamic>>(
      NetworkConfig.profilePath,
    );
    if (resp.success && resp.data != null) {
      try {
        final userJson =
            (resp.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
        final user = UserModel.fromJson(userJson);
        return ApiResponse.success(user, statusCode: resp.statusCode);
      } catch (e) {
        return ApiResponse.failure(
          message: 'Parsing error',
          statusCode: resp.statusCode,
        );
      }
    }
    return ApiResponse.failure(
      message: resp.message ?? 'Failed to fetch profile',
      statusCode: resp.statusCode,
    );
  }
}
