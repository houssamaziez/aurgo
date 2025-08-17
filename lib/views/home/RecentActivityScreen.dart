import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RecentActivityScreen extends StatefulWidget {
  const RecentActivityScreen({super.key});

  @override
  State<RecentActivityScreen> createState() => _RecentActivityScreenState();
}

class _RecentActivityScreenState extends State<RecentActivityScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _listCtrl;
  String _selectedFilter = "All";

  final List<Map<String, dynamic>> _activities = [
    {
      "icon": LucideIcons.car,
      "title": "رحلة إلى وسط المدينة",
      "subtitle": "دفعت 1200 DZD",
      "time": "قبل ساعتين",
      "type": "Trip",
      "status": "completed",
    },
    {
      "icon": LucideIcons.creditCard,
      "title": "إضافة بطاقة جديدة",
      "subtitle": "بطاقة Visa **** 2345",
      "time": "أمس",
      "type": "Payment",
      "status": "success",
    },
    {
      "icon": LucideIcons.bell,
      "title": "إشعار تذكير",
      "subtitle": "لديك حجز سيارة ذاتية القيادة",
      "time": "منذ 3 أيام",
      "type": "Notification",
      "status": "info",
    },
    {
      "icon": LucideIcons.mapPin,
      "title": "تم استلامك من محطة",
      "subtitle": "محطة الجزائر العاصمة",
      "time": "منذ أسبوع",
      "type": "Trip",
      "status": "completed",
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
    final filtered =
        _selectedFilter == "All"
            ? _activities
            : _activities.where((a) => a["type"] == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "النشاط الأخير",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
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
            children: [
              _buildFilterBar(),
              const SizedBox(height: 8),
              Expanded(
                child:
                    filtered.isEmpty
                        ? _emptyState()
                        : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) {
                            final act = filtered[i];
                            final anim = CurvedAnimation(
                              parent: _listCtrl,
                              curve: Interval(
                                (i / filtered.length) * 0.9,
                                1.0,
                                curve: Curves.easeOutBack,
                              ),
                            );
                            return AnimatedBuilder(
                              animation: anim,
                              builder: (_, child) {
                                return Transform.translate(
                                  offset: Offset(0, (1 - anim.value) * 50),
                                  child: Opacity(
                                    opacity: anim.value.clamp(0.0, 1.0),
                                    child: child,
                                  ),
                                );
                              },
                              child: _activityCard(act),
                            );
                          },
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    const filters = ["All", "Trip", "Payment", "Notification"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children:
            filters.map((f) {
              final sel = _selectedFilter == f;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ChoiceChip(
                  label: Text(f),
                  labelStyle: TextStyle(
                    color: sel ? Colors.black : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  selected: sel,
                  selectedColor: Colors.cyanAccent,
                  backgroundColor: Colors.white.withOpacity(.05),
                  onSelected: (_) {
                    setState(() => _selectedFilter = f);
                  },
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _activityCard(Map<String, dynamic> act) {
    final statusColor =
        {
          "completed": Colors.greenAccent,
          "success": Colors.blueAccent,
          "info": Colors.orangeAccent,
        }[act["status"]]!;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: statusColor.withOpacity(.15),
            child: Icon(act["icon"], color: statusColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  act["title"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  act["subtitle"],
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(Icons.circle, color: statusColor, size: 10),
              const SizedBox(height: 8),
              Text(
                act["time"],
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(LucideIcons.inbox, color: Colors.white30, size: 64),
          SizedBox(height: 16),
          Text(
            "لا يوجد نشاط بعد",
            style: TextStyle(color: Colors.white54, fontSize: 15),
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
      final r = (progress * (i + 1) * 60) + 80;
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BgCirclesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
