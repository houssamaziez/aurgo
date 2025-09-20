import 'package:aurgo/core/network/api_client.dart';
import 'package:aurgo/core/network/network_manager.dart';
import 'package:aurgo/core/network/token_storage.dart';
import 'package:aurgo/core/repositories/auth_repository.dart';
import 'package:aurgo/core/repositories/user_repository.dart';

class AppDependencies {
  late final TokenStorage tokenStorage;
  late final NetworkManager networkManager;
  late final ApiClient apiClient;
  late final AuthRepository authRepository;
  late final UserRepository userRepository;

  AppDependencies._();
  static final AppDependencies _instance = AppDependencies._();
  factory AppDependencies() => _instance;

  Future<void> init() async {
    tokenStorage = TokenStorage();
    networkManager = await NetworkManager.getInstance(
      tokenStorage: tokenStorage,
    );
    apiClient = ApiClient(networkManager.dio);

    authRepository = AuthRepository(apiClient, tokenStorage);
    userRepository = UserRepository(apiClient);
  }
}
