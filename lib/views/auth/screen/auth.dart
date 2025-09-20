import 'package:aurgo/views/auth/controller/auth_cintroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FuturisticLoginScreen extends StatelessWidget {
  FuturisticLoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final AuthController _controller = Get.put(AuthController());

  Widget _textField({
    required String hint,
    required IconData icon,
    bool isPassword = false,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: Colors.cyanAccent),
          filled: true,
          fillColor: Colors.white.withOpacity(0.08),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Colors.cyanAccent, width: 1.5),
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      _controller.login();
    }
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
        backgroundColor: Colors.black.withOpacity(0.5),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Form(
              key: _formKey,
              child: GetBuilder<AuthController>(
                builder: (controller) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Colors.cyanAccent, Colors.blueAccent],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyanAccent.withOpacity(.38),
                              blurRadius: 14,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            Icons.car_rental,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Title
                      Text(
                        controller.isLogin ? "تسجيل الدخول" : "إنشاء حساب",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyanAccent,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Name field (only in register mode)
                      if (!controller.isLogin)
                        _textField(
                          controller: controller.nameController,
                          hint: "الاسم الكامل",
                          icon: Icons.person,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "الاسم مطلوب";
                            }
                            return null;
                          },
                        ),

                      // Email
                      _textField(
                        controller: controller.emailController,
                        hint: "البريد الإلكتروني",
                        icon: Icons.email,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "البريد الإلكتروني مطلوب";
                          }
                          if (!val.contains("@")) {
                            return "بريد إلكتروني غير صالح";
                          }
                          return null;
                        },
                      ),

                      // Password
                      _textField(
                        controller: controller.passwordController,
                        hint: "كلمة المرور",
                        icon: Icons.lock,
                        isPassword: true,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "كلمة المرور مطلوبة";
                          }
                          if (val.length < 6) {
                            return "كلمة المرور يجب أن تكون 6 أحرف على الأقل";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      // Submit button
                      controller.isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _onSubmit,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                backgroundColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 0,
                              ).copyWith(
                                shadowColor: MaterialStateProperty.all(
                                  Colors.cyanAccent.withOpacity(.4),
                                ),
                                backgroundColor: MaterialStateProperty.all(
                                  Colors.transparent,
                                ),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.cyanAccent,
                                      Colors.blueAccent,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.cyanAccent.withOpacity(.38),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    controller.isLogin
                                        ? "تسجيل الدخول"
                                        : "إنشاء حساب",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                      const SizedBox(height: 15),

                      // Switch login/register
                      TextButton(
                        onPressed: () {
                          controller.isLogin = !controller.isLogin;
                          controller.update();
                        },
                        child: Text(
                          controller.isLogin
                              ? "ليس لديك حساب؟ إنشاء حساب"
                              : "لديك حساب؟ تسجيل الدخول",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
