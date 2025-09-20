import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthCintroller extends GetxController {
  bool isLogin = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  Future<void> login() async {
    print('login');
  }
}
