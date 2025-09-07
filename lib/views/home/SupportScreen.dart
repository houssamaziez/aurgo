import 'dart:math';
import 'package:aurgo/core/utle/extentions.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _listCtrl;

  final List<Map<String, dynamic>> _tickets = [
    {
      "icon": LucideIcons.messageSquare,
      "title": "مشكلة في الدفع",
      "status": "مفتوح",
      "color": Colors.redAccent,
      "time": "اليوم",
    },
    {
      "icon": LucideIcons.wifiOff,
      "title": "انقطاع الخدمة",
      "status": "قيد المراجعة",
      "color": Colors.orangeAccent,
      "time": "أمس",
    },
    {
      "icon": LucideIcons.car,
      "title": "استفسار عن الرحلة",
      "status": "مغلق",
      "color": Colors.greenAccent,
      "time": "منذ 3 أيام",
    },
  ];

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _listCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _listCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) {
              return CustomPaint(
                painter: _BgCirclesPainter(progress: _bgCtrl.value),
                child: Container(),
              );
            },
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  "الدعم",
                  style: TextStyle(color: Colors.white),
                ),
                centerTitle: true,
                elevation: 0,
              ),
              _buildContactCard(),
              _buildQuickOptions(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "تذاكر الدعم",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tickets.length,
                  itemBuilder: (ctx, i) {
                    final tx = _tickets[i];
                    final anim = CurvedAnimation(
                      parent: _listCtrl,
                      curve: Interval(
                        (i / _tickets.length) * 0.9,
                        1.0,
                        curve: Curves.easeOutBack,
                      ),
                    );
                    return AnimatedBuilder(
                      animation: anim,
                      builder: (_, child) {
                        return Transform.translate(
                          offset: Offset(0, (1 - anim.value) * 40),
                          child: Opacity(
                            opacity: anim.value.clamp(0.0, 1.0),
                            child: child,
                          ),
                        );
                      },
                      child: _ticketCard(tx),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.cyanAccent,
        icon: const Icon(LucideIcons.plus, color: Colors.black),
        label: const Text(
          "تذكرة جديدة",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        onPressed: () {},
      ),
    ).withGradientBackground( [
      
    ]);
  }

  Widget _buildContactCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.cyanAccent, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.headphones, color: Colors.black, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "تواصل مع الدعم",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "فريقنا جاهز لمساعدتك في أي وقت",
                  style: TextStyle(color: Colors.black87, fontSize: 13),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {},
            child: const Text(
              "ابدأ",
              style: TextStyle(color: Colors.cyanAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickOptions() {
    final options = [
      {"icon": LucideIcons.bookOpen, "title": "مركز المساعدة"},
      {"icon": LucideIcons.helpCircle, "title": "الأسئلة الشائعة"},
      {"icon": LucideIcons.alertTriangle, "title": "الإبلاغ عن مشكلة"},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children:
            options
                .map(
                  (opt) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            opt["icon"] as IconData,
                            color: Colors.cyanAccent,
                            size: 26,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            opt["title"] as String,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _ticketCard(Map<String, dynamic> tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: tx["color"].withOpacity(.15),
            child: Icon(tx["icon"], color: tx["color"], size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx["title"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tx["time"],
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: tx["color"].withOpacity(.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              tx["status"],
              style: TextStyle(
                color: tx["color"],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BgCirclesPainter extends CustomPainter {
  final double progress;
  _BgCirclesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.cyanAccent.withOpacity(.05);

    final center = size.center(Offset.zero);

    for (int i = 0; i < 3; i++) {
      final r = (progress * (i + 1) * 60) + 100;
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BgCirclesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
