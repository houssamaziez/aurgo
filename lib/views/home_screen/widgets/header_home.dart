import 'package:aurgo/views/auth/controller/auth_cintroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../home/notification/screen_notification.dart';
import '../../home/profile_user.dart';

class HeaderHome extends StatelessWidget {
  const HeaderHome({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (controller) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                Get.to(ProfileSettingsScreen());
              },
              child: CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(
                  "https://i.pravatar.cc/150?img=3",
                ),
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  controller.user == null
                      ? ""
                      : "مرحباً، ${controller.user!.name}",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "كيف يمكننا مساعدتك اليوم؟",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                Get.to(NotificationsScreen());
              },
              child: Stack(
                children: const [
                  Icon(Icons.notifications, color: Colors.white, size: 25),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: CircleAvatar(radius: 5, backgroundColor: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget _buildQuickAction(String title, IconData icon, int index) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: Duration(milliseconds: 400 + index * 100),
    curve: Curves.easeOut,
    builder: (context, value, child) {
      final v = value.clamp(0.0, 1.0);
      return Transform.translate(
        offset: Offset(0, (1 - v) * 30),
        child: Opacity(opacity: v, child: child),
      );
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 90,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white10, Colors.white12]),
        borderRadius: BorderRadius.circular(25),

        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(icon, color: Colors.cyanAccent, size: 28),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    ),
  );
}
