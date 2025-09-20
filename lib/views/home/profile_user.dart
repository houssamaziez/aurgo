import 'package:aurgo/core/utle/extentions.dart';
import 'package:aurgo/views/auth/controller/auth_cintroller.dart';
import 'package:aurgo/views/home/user/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:get/route_manager.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _listAnimCtrl;
  bool isDarkMode = false;
  bool isNotificationEnabled = true;

  @override
  void initState() {
    super.initState();
    _listAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _listAnimCtrl.dispose();
    super.dispose();
  }

  void _showBottomSheet(String title, Widget child) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1D2B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              child,
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = [
      {
        "icon": FontAwesomeIcons.bell,
        "title": "الإشعارات",
        "subtitle": "تفعيل أو إيقاف إشعارات التطبيق",
        "type": "switch",
      },
      {
        "icon": FontAwesomeIcons.language,
        "title": "اللغة",
        "subtitle": "اختر لغة التطبيق",
        "type": "sheet",
        "sheet": Column(
          children: const [
            ListTile(
              title: Text("الإنجليزية", style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              title: Text("الفرنسية", style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              title: Text("العربية", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      },
      {
        "icon": FontAwesomeIcons.moon,
        "title": "الوضع الداكن",
        "subtitle": "التبديل بين الوضع الفاتح والداكن",
        "type": "switch",
      },
      {
        "icon": FontAwesomeIcons.lock,
        "title": "الأمان",
        "subtitle": "تغيير كلمة المرور أو تفعيل البصمة",
        "type": "nav",
      },
      {
        "icon": FontAwesomeIcons.creditCard,
        "title": "المدفوعات",
        "subtitle": "إدارة البطاقات المحفوظة وطرق الدفع",
        "type": "sheet",
        "sheet": Column(
          children: const [
            ListTile(
              leading: Icon(Icons.credit_card, color: Colors.white),
              title: Text(
                "فيزا **** 2345",
                style: TextStyle(color: Colors.white),
              ),
              trailing: Icon(Icons.check, color: Colors.green),
            ),
            ListTile(
              leading: Icon(Icons.credit_card, color: Colors.white),
              title: Text(
                "ماستركارد **** 8890",
                style: TextStyle(color: Colors.white),
              ),
            ),
            ListTile(
              leading: Icon(Icons.add_circle_outline, color: Colors.white70),
              title: Text(
                "إضافة بطاقة جديدة",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      },
      {
        "icon": FontAwesomeIcons.headset,
        "title": "الدعم الفني",
        "subtitle": "تواصل مع خدمة العملاء",
        "type": "nav",
      },
      {
        "icon": FontAwesomeIcons.circleInfo,
        "title": "حول التطبيق",
        "subtitle": "معلومات النسخة والشروط والسياسات",
        "type": "nav",
      },
      {
        "icon": FontAwesomeIcons.rightFromBracket,
        "title": "تسجيل الخروج",
        "subtitle": "تسجيل الخروج من حسابك",
        "type": "action",
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                  const Spacer(),
                  const Text(
                    "الملف الشخصي",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Get.to(EditProfileScreen());
                    },
                    icon: const Icon(Icons.edit, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            /// PROFILE CARD
            GetBuilder<AuthController>(
              builder: (controller) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E5FF), Color(0xFF0099FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(
                          "https://i.pravatar.cc/150?img=3",
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.user!.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              controller.user!.email,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.settings, color: Colors.white),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 30),

            /// SETTINGS LIST
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: settings.length,
                itemBuilder: (context, index) {
                  final s = settings[index];
                  final anim = CurvedAnimation(
                    parent: _listAnimCtrl,
                    curve: Interval(
                      (index / settings.length) * 0.9,
                      1.0,
                      curve: Curves.easeOutBack,
                    ),
                  );

                  return AnimatedBuilder(
                    animation: anim,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          0,
                          (1 - anim.value.clamp(0.0, 1.0)) * 40,
                        ),
                        child: Opacity(
                          opacity: anim.value.clamp(0.0, 1.0),
                          child: child,
                        ),
                      );
                    },
                    child: GestureDetector(
                      onTap: () {
                        if (s["type"] == "sheet") {
                          _showBottomSheet(
                            s["title"] as String,
                            s["sheet"] as Widget,
                          );
                        } else if (s["type"] == "action") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("تم تسجيل الخروج بنجاح"),
                            ),
                          );
                        } else {
                          // التنقل أو المعالجة
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white.withOpacity(.05),
                          border: Border.all(
                            color: Colors.white.withOpacity(.08),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blueAccent.withOpacity(0.8),
                                    Colors.cyanAccent.withOpacity(0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Icon(
                                s["icon"] as IconData,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s["title"] as String,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    s["subtitle"] as String,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (s["type"] == "switch")
                              Switch(
                                value:
                                    s["title"] == "الوضع الداكن"
                                        ? isDarkMode
                                        : isNotificationEnabled,
                                onChanged: (val) {
                                  setState(() {
                                    if (s["title"] == "الوضع الداكن") {
                                      isDarkMode = val;
                                    } else {
                                      isNotificationEnabled = val;
                                    }
                                  });
                                },
                                activeColor: Colors.cyanAccent,
                              )
                            else
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white38,
                                size: 16,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ).withGradientBackground([]);
  }
}
