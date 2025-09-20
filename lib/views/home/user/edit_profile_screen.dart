import 'package:aurgo/core/utle/extentions.dart';
import 'package:aurgo/views/auth/controller/auth_cintroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:get/get_core/src/get_main.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: ListView(
            padding: const EdgeInsets.only(top: 0, left: 16, right: 16),
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                title: const Text(
                  "الملف الشخصي",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                actions: [],
              ),
              buildSectionCard(
                title: "الاسم",
                icon: Icons.person,
                controller: controller.updateNameController,
              ),
              buildSectionCard(
                title: "البريد الإلكتروني",
                icon: Icons.email,
                controller: controller.UpdateEmailController,
                keyboardType: TextInputType.emailAddress,
              ),
              buildSectionCard(
                title: "رقم الهاتف",
                icon: Icons.phone,
                controller: controller.UpdatePhoneController,
                keyboardType: TextInputType.phone,
              ),
              buildSectionCard(
                title: "المنطقة",
                icon: Icons.location_on,
                controller: controller.UpdateRegionController,
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.blueAccent,
                ),
                onPressed: () async {
                  await authController.updateProfile();

                  // if (_formKey.currentState!.validate()) {}
                },
                child: const Text(
                  "حفظ التغييرات",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ).withGradientBackground([]);
      },
    );
  }

  Widget buildSectionCard({
    required String title,
    required IconData icon,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.blueAccent),
          labelText: title,
          labelStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
