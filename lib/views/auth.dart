import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:get/get.dart';

import 'FuturisticHomeScreen.dart';

class FuturisticLoginScreen extends StatefulWidget {
  const FuturisticLoginScreen({super.key});

  @override
  State<FuturisticLoginScreen> createState() => _FuturisticLoginScreenState();
}

class _FuturisticLoginScreenState extends State<FuturisticLoginScreen>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  void toggleForm() {
    Get.to(FuturisticHomeScreen());

    setState(() {
      isLogin = !isLogin;
      if (isLogin) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _textField({
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white12,
        prefixIcon: Icon(icon, color: Colors.red),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Animated futuristic background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.deepPurple.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon/logo
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.red.withOpacity(0.3),
                            child: const Icon(
                              Icons.car_rental,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 25),
                          Text(
                            isLogin ? "تسجيل الدخول" : "إنشاء حساب",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 25),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            child: Column(
                              key: ValueKey<bool>(isLogin),
                              children: [
                                if (!isLogin)
                                  _textField(
                                    hint: "الاسم الكامل",
                                    icon: Icons.person,
                                  ),
                                if (!isLogin) const SizedBox(height: 20),
                                _textField(
                                  hint: "البريد الإلكتروني",
                                  icon: Icons.email,
                                ),
                                const SizedBox(height: 20),
                                _textField(
                                  hint: "كلمة المرور",
                                  icon: Icons.lock,
                                  isPassword: true,
                                ),
                                const SizedBox(height: 30),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                      ),
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      shadowColor: Colors.red,
                                      elevation: 10,
                                    ),
                                    child: Text(
                                      isLogin ? "تسجيل الدخول" : "إنشاء حساب",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () => toggleForm(),
                            child: Text(
                              isLogin
                                  ? "ليس لديك حساب؟ إنشاء حساب"
                                  : "لديك حساب؟ تسجيل الدخول",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
