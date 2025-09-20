import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/app_dependencies.dart';
import '../../../model/user_model.dart';
import '../../home_screen/FuturisticHomeScreen.dart';

class AuthController extends GetxController {
  // Reactive variables
  bool isLogin = true;
  bool isLoading = false;
  UserModel? user;

  // Text controllers
  final TextEditingController emailController = TextEditingController(
    text: 'john@example.com',
  );
  final TextEditingController passwordController = TextEditingController(
    text: "12345678",
  );
  final TextEditingController nameController = TextEditingController();

  // Dependencies
  late final AppDependencies deps;

  @override
  void onInit() {
    super.onInit();
    deps = AppDependencies();
    deps.init(); // init DI once
  }

  Future<void> login() async {
    isLoading = true;
    update();

    final email = emailController.text.trim();
    final password = passwordController.text;

    final resp = await deps.authRepository.login(email, password);

    if (resp.success) {
      // After successful login, fetch profile
      final profileResp = await deps.userRepository.fetchProfile();
      if (profileResp.success && profileResp.data != null) {
        user = profileResp.data!;
        Get.off(FuturisticHomeScreen());
        Get.snackbar('Welcome', 'Hello ${user!.name}', colorText: Colors.white);
      } else {
        Get.snackbar('Error', profileResp.message ?? 'Failed to load profile');
      }
    } else {
      Get.snackbar('Login Failed', resp.message ?? 'Unknown error');
    }

    isLoading = false;
    update();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.onClose();
  }
}
