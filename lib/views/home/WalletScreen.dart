import 'dart:math';
import 'package:aurgo/core/utle/extentions.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _listCtrl;
  String _selectedFilter = "All";

  double balance = 12500.75;

  final List<Map<String, dynamic>> _transactions = [
    {
      "icon": LucideIcons.arrowDownCircle,
      "title": "إيداع رصيد",
      "amount": "+ 5000 DZD",
      "time": "اليوم",
      "type": "In",
      "color": Colors.greenAccent,
    },
    {
      "icon": LucideIcons.car,
      "title": "رحلة إلى المطار",
      "amount": "- 2200 DZD",
      "time": "أمس",
      "type": "Out",
      "color": Colors.redAccent,
    },
    {
      "icon": LucideIcons.creditCard,
      "title": "إضافة بطاقة جديدة",
      "amount": "0 DZD",
      "time": "منذ 3 أيام",
      "type": "Info",
      "color": Colors.blueAccent,
    },
    {
      "icon": LucideIcons.arrowUpCircle,
      "title": "تحويل رصيد",
      "amount": "- 3000 DZD",
      "time": "منذ أسبوع",
      "type": "Out",
      "color": Colors.orangeAccent,
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
            ? _transactions
            : _transactions.where((t) {
              if (_selectedFilter == "In") return t["type"] == "In";
              if (_selectedFilter == "Out") return t["type"] == "Out";
              return true;
            }).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade900,

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
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: const Text(
                  "المحفظة",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
              ),
              _buildBalanceCard(),
              _buildQuickStats(),
              _buildFilterBar(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final tx = filtered[i];
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
                      child: _transactionCard(tx),
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
          "إضافة رصيد",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        onPressed: () {},
      ),
    ).withGradientBackground( [
      
    ]);
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.cyanAccent, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "الرصيد الحالي",
            style: TextStyle(color: Colors.black87, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: balance),
            duration: const Duration(seconds: 2),
            builder:
                (_, value, __) => Text(
                  "${value.toStringAsFixed(2)} DZD",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _statCard("إجمالي المدفوعات", "7400 DZD", LucideIcons.arrowUp),
          const SizedBox(width: 12),
          _statCard("الرصيد المتاح", "$balance DZD", LucideIcons.wallet),
          const SizedBox(width: 12),
          _statCard("آخر عملية", "أمس", LucideIcons.history),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.cyanAccent, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    const filters = ["الكل", "دخول", "صادر"];
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
                    color: Colors.black,
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

  Widget _transactionCard(Map<String, dynamic> tx) {
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
            backgroundColor: tx["color"].withOpacity(.15),
            child: Icon(tx["icon"], color: tx["color"], size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              tx["title"],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                tx["amount"],
                style: TextStyle(
                  color: tx["color"],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tx["time"],
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
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
