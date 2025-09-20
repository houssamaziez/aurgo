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
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController regionController = TextEditingController();

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

  final TextEditingController updateNameController = TextEditingController(
    text: "John Doe",
  );
  final TextEditingController UpdateEmailController = TextEditingController(
    text: "john@example.com",
  );
  final TextEditingController UpdatePhoneController = TextEditingController(
    text: "+966512345678",
  );
  final TextEditingController UpdateRegionController = TextEditingController(
    text: "Riyadh",
  );
  Future<void> updateProfile() async {
    if (user == null) {
      Get.snackbar("Error", "User not logged in");
      return;
    }

    isLoading = true;
    update();

    final resp = await deps.authRepository.updateProfile(
      name:
          updateNameController.text.trim().isEmpty
              ? null
              : updateNameController.text.trim(),
      email:
          UpdateEmailController.text.trim().isEmpty
              ? null
              : UpdateEmailController.text.trim(),
      phone:
          UpdatePhoneController.text.trim().isEmpty
              ? null
              : UpdatePhoneController.text.trim(),
      region:
          UpdateRegionController.text.trim().isEmpty
              ? null
              : UpdateRegionController.text.trim(),
    );

    if (resp.success && resp.data != null) {
      final profileResp = await deps.userRepository.fetchProfile();
      if (profileResp.success && profileResp.data != null) {
        user = profileResp.data!;
        Get.snackbar(
          "Success",
          "تم تحديث الملف الشخصي",
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar("Update Failed", resp.message ?? "Unknown error");
    }

    isLoading = false;
    update();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    regionController.dispose();
    super.onClose();
  }
}
