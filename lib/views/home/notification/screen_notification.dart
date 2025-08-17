import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  late AnimationController _listAnimCtrl;
  late AnimationController _bgAnimCtrl;

  final List<Map<String, dynamic>> _notifications = [
    {
      "title": "🚗 رحلتك جاهزة",
      "subtitle": "السيارة الذاتية القيادة وصلت إلى موقعك الآن.",
      "time": "منذ 2 دقيقة",
      "icon": LucideIcons.car,
      "color": Colors.cyanAccent,
    },
    {
      "title": "🎁 عرض حصري",
      "subtitle": "خصم 25% على جميع الرحلات اليوم فقط.",
      "time": "منذ 10 دقائق",
      "icon": LucideIcons.gift,
      "color": Colors.purpleAccent,
    },
    {
      "title": "💳 تذكير بالدفع",
      "subtitle": "لم يتم دفع الرحلة السابقة بعد.",
      "time": "منذ ساعة",
      "icon": LucideIcons.creditCard,
      "color": Colors.orangeAccent,
    },
    {
      "title": "🔒 تنبيه أمني",
      "subtitle": "تم تسجيل دخول جديد من جهاز مختلف.",
      "time": "منذ 3 ساعات",
      "icon": LucideIcons.shieldAlert,
      "color": Colors.redAccent,
    },
    {
      "title": "📅 تذكير بالرحلة",
      "subtitle": "رحلتك المجدولة ستبدأ بعد 30 دقيقة.",
      "time": "أمس",
      "icon": LucideIcons.calendar,
      "color": Colors.greenAccent,
    },
  ];

  @override
  void initState() {
    super.initState();
    _listAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _bgAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _listAnimCtrl.dispose();
    _bgAnimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// 🌌 خلفية متحركة (Glow Animation)
          AnimatedBuilder(
            animation: _bgAnimCtrl,
            builder: (context, child) {
              return CustomPaint(
                painter: _BgPainter(_bgAnimCtrl.value),
                size: MediaQuery.of(context).size,
              );
            },
          ),

          /// 📌 المحتوى الرئيسي
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),

                /// العنوان
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                    ),
                    Spacer(),
                    const Text(
                      "الإشعارات",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
                const SizedBox(height: 16),

                /// 📨 لائحة الإشعارات مع Animation
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final n = _notifications[index];
                      final animation = CurvedAnimation(
                        parent: _listAnimCtrl,
                        curve: Interval(
                          (index / _notifications.length) *
                              0.9, // 👈 يضمن < 1.0
                          1.0,
                          curve: Curves.easeOutBack,
                        ),
                      );

                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, 50 * (1 - animation.value)),
                            child: Opacity(
                              opacity: animation.value,
                              child: child,
                            ),
                          );
                        },
                        child: GestureDetector(
                          onTap: () => _showDetails(n),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: LinearGradient(
                                colors: [
                                  n["color"].withOpacity(0.18),
                                  Colors.white.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: n["color"].withOpacity(.35),
                                width: 1.3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: n["color"].withOpacity(.2),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                              leading: CircleAvatar(
                                radius: 28,
                                backgroundColor: n["color"].withOpacity(.25),
                                child: Icon(
                                  n["icon"],
                                  color: n["color"],
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                n["title"],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                n["subtitle"],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                              trailing: Text(
                                n["time"],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
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
        ],
      ),
    );
  }

  /// نافذة منبثقة لتفاصيل التنبيه
  void _showDetails(Map<String, dynamic> n) {
    showModalBottomSheet(
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(n["icon"], color: n["color"], size: 36),
              const SizedBox(height: 12),
              Text(
                n["title"],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: n["color"],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                n["subtitle"],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Text(
                n["time"],
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: n["color"],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("تم"),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 🎨 Painter للخلفية المتحركة
class _BgPainter extends CustomPainter {
  final double progress;
  _BgPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    final colors = [
      Colors.cyanAccent,
      Colors.purpleAccent,
      Colors.redAccent,
      Colors.orangeAccent,
    ];

    for (int i = 0; i < colors.length; i++) {
      paint.color = colors[i].withOpacity(0.12);
      final dx =
          (size.width * 0.5) +
          cos(progress * 2 * pi + (i * pi / 2)) * (size.width * 0.3);
      final dy =
          (size.height * 0.4) +
          sin(progress * 2 * pi + (i * pi / 2)) * (size.height * 0.25);
      canvas.drawCircle(Offset(dx, dy), size.width * 0.35, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BgPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
