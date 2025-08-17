import 'package:aurgo/core/utle/extentions.dart';
import 'package:aurgo/views/home/RecentActivityScreen.dart';
import 'package:aurgo/views/home/notification/screen_notification.dart';
import 'package:aurgo/views/home/profile_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';

import '../model/ServiceOption.dart';

class FuturisticHomeScreen extends StatefulWidget {
  const FuturisticHomeScreen({super.key});

  @override
  State<FuturisticHomeScreen> createState() => _FuturisticHomeScreenState();
}

class _FuturisticHomeScreenState extends State<FuturisticHomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedQuickAction = -1;

  Widget _buildOptionCard({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
    required int index,
    required Function onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + index * 150),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        final v = value.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, (1 - v) * 50),
          child: Opacity(opacity: v, child: child),
        );
      },
      child: GestureDetector(
        onTap: () => onTap(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.6), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.white12,
                child: Icon(icon, color: Colors.cyanAccent, size: 28),
              ),
              const SizedBox(height: 15),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon, int index) {
    final isSelected = _selectedQuickAction == index;
    return Expanded(
      child: TweenAnimationBuilder<double>(
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
            gradient:
                isSelected
                    ? LinearGradient(
                      colors: [Colors.cyanAccent, Colors.blueAccent],
                    )
                    : LinearGradient(colors: [Colors.white10, Colors.white12]),
            borderRadius: BorderRadius.circular(25),

            border: Border.all(
              color:
                  isSelected
                      ? Colors.cyanAccent.withOpacity(0.6)
                      : Colors.white12,
            ),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Cosmic gradient background
      body: Container(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
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
                        children: const [
                          Text(
                            "مرحباً، حسام",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "كيف يمكننا مساعدتك اليوم؟",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
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
                            Icon(
                              Icons.notifications,
                              color: Colors.white,
                              size: 30,
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 6,
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Glassmorphic search bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.cyanAccent.withOpacity(0.3),
                          ),
                        ),
                        child: const TextField(
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "إلى أين ترغب في الذهاب؟",
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                            icon: Icon(Icons.search, color: Colors.white70),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Options Grid
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 15,
                          crossAxisSpacing: 15,
                        ),
                    itemCount: serviceOptions.length,
                    itemBuilder: (context, index) {
                      final opt = serviceOptions[index];
                      return _buildOptionCard(
                        color: opt.color as Color,
                        icon: opt.icon as IconData,
                        title: opt.title as String,
                        onTap: () => Get.to(opt.rout),
                        subtitle: opt.subtitle,
                        index: index,
                      );
                    },
                  ),
                  const SizedBox(height: 25),
                  // Special Offer with neon glow
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      final v = value.clamp(0.0, 1.0);
                      return Transform.translate(
                        offset: Offset(0, (1 - v) * 50),
                        child: Opacity(opacity: v, child: child),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.cyanAccent, Colors.blueAccent],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "عرض خاص !",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "خصم 25 % على أول رحلة",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              shadowColor: Colors.cyanAccent.withOpacity(0.6),
                              elevation: 10,
                            ),
                            child: const Text(
                              "استفد الآن",
                              style: TextStyle(
                                color: Colors.cyanAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Quick Actions
                  const Text(
                    "إجراءات سريعة",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Get.to(RecentActivityScreen());
                        },
                        child: _buildQuickAction(
                          "الرحلات السابقة",
                          Icons.history,
                          0,
                        ),
                      ),
                      _buildQuickAction(
                        "المحفظة",
                        Icons.account_balance_wallet,
                        1,
                      ),
                      _buildQuickAction("الدعم", Icons.headset_mic, 2),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).withGradientBackground([
      Colors.black,
      Colors.deepPurple.withOpacity(0.1),
    ]);
  }
}
