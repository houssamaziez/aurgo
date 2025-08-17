import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class AutonomousRideScreen extends StatefulWidget {
  const AutonomousRideScreen({super.key});

  @override
  State<AutonomousRideScreen> createState() => _AutonomousRideScreenState();
}

class _AutonomousRideScreenState extends State<AutonomousRideScreen>
    with SingleTickerProviderStateMixin {
  bool autopilot = true;
  bool followLimits = true;
  bool comfortMode = true;
  bool safeDistance = true;

  double speed = 42; // km/h (mock)
  double etaMin = 18; // minutes (mock)
  double battery = 82; // %

  late final AnimationController _radarCtrl;

  final _fromCtrl = TextEditingController(text: 'حي الأعمال، وسط المدينة');
  final _toCtrl = TextEditingController(text: 'محطة المستقبل A1');

  @override
  void initState() {
    super.initState();
    _radarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _radarCtrl.dispose();
    _fromCtrl.dispose();
    _toCtrl.dispose();
    super.dispose();
  }

  void _startRide() {
    if (!autopilot) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فعّل القيادة الذاتية أولاً (Autopilot)')),
      );
      return;
    }
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: const Color(0xFF14172B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'بدء الرحلة الذاتية',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'تم تفعيل الملاحة الذاتية والمحافظة على المسافة الآمنة.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'تم',
                  style: TextStyle(color: Colors.cyanAccent),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgGradient = const LinearGradient(
      colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: bgGradient),
          child: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: -70,
                  right: -50,
                  child: _neonBlob(170, Colors.cyanAccent.withOpacity(.20)),
                ),
                Positioned(
                  bottom: -60,
                  left: -40,
                  child: _neonBlob(150, Colors.purpleAccent.withOpacity(.18)),
                ),

                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(),
                      const SizedBox(height: 16),

                      _glassCard(
                        child: Column(
                          children: [
                            _field(
                              icon: Icons.radio_button_checked,
                              controller: _fromCtrl,
                              hint: 'نقطة الانطلاق',
                            ),
                            const SizedBox(height: 10),
                            _field(
                              icon: Icons.location_on,
                              controller: _toCtrl,
                              hint: 'الوجهة',
                            ),
                            const SizedBox(height: 10),
                            _routeMiniPreview(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      _glassCard(
                        child: Row(
                          children: [
                            _metricTile(
                              'السرعة',
                              '${speed.toStringAsFixed(0)} كم/س',
                              Icons.speed,
                            ),
                            _dividerV(),
                            _metricTile(
                              'الوصول',
                              '${etaMin.toStringAsFixed(0)} د',
                              Icons.timer_outlined,
                            ),
                            _dividerV(),
                            _metricTile(
                              'البطارية',
                              '${battery.toStringAsFixed(0)}%',
                              Icons.battery_charging_full,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // رادار استشعار (Lidar/Ultrasonic) تمثيلي
                      _glassCard(
                        child: SizedBox(
                          height: 160,
                          child: AnimatedBuilder(
                            animation: _radarCtrl,
                            builder:
                                (context, _) => CustomPaint(
                                  painter: _RadarPainter(
                                    progress: _radarCtrl.value,
                                  ),
                                  child: const SizedBox.expand(),
                                ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // إعدادات الأمان والراحة
                      _glassCard(
                        child: Column(
                          children: [
                            _switchTile(
                              title: 'Autopilot — القيادة الذاتية',
                              value: autopilot,
                              onChanged: (v) => setState(() => autopilot = v),
                              subtitle: 'تحكم كامل بالملاحة، التوجيه، والسرعة.',
                            ),
                            _switchTile(
                              title: 'Follow Speed Limits — الالتزام بالسرعات',
                              value: followLimits,
                              onChanged:
                                  (v) => setState(() => followLimits = v),
                              subtitle: 'تعديل السرعة تلقائياً حسب اللوائح.',
                            ),
                            _switchTile(
                              title: 'Comfort Mode — وضع الراحة',
                              value: comfortMode,
                              onChanged: (v) => setState(() => comfortMode = v),
                              subtitle: 'تسارع/فرملة ناعمة وتقليل المناورات.',
                            ),
                            _switchTile(
                              title: 'Safe Distance — مسافة آمنة',
                              value: safeDistance,
                              onChanged:
                                  (v) => setState(() => safeDistance = v),
                              subtitle:
                                  'المحافظة على مسافة تفاعلية مع المركبات.',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // CTA + أزرار مساعدة
                      Row(
                        children: [
                          Expanded(
                            child: _primaryCTA(
                              'ابدأ القيادة الذاتية',
                              _startRide,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _sosBtn(),
                        ],
                      ),

                      const SizedBox(height: 24),
                      _safetyNote(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== UI PARTS =====

  Widget _header() {
    return Row(
      children: [
        const Icon(Icons.smart_toy, color: Colors.cyanAccent, size: 28),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'سيارة ذاتية القيادة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: .4,
            ),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(.06),
              border: Border.all(color: Colors.cyanAccent.withOpacity(.25)),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.shield_moon_outlined,
                  color: Colors.cyanAccent,
                  size: 18,
                ),
                SizedBox(width: 6),
                Text(
                  'AI Guard',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.06),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.cyanAccent.withOpacity(.22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.35),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: child,
        ),
      ),
    );
  }

  Widget _field({
    required IconData icon,
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.white60),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _routeMiniPreview() {
    return Container(
      height: 80,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(.04),
        border: Border.all(color: Colors.white10),
      ),
      child: Stack(
        children: [
          // خط مسار بسيط متحرك
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(seconds: 3),
              curve: Curves.easeInOut,
              builder: (context, t, _) {
                return CustomPaint(painter: _PathPainter(progress: t));
              },
            ),
          ),
          // نقاط البداية والنهاية
          const Positioned(right: 10, top: 10, child: _Dot(label: 'انطلاق')),
          const Positioned(left: 10, bottom: 10, child: _Dot(label: 'وصول')),
        ],
      ),
    );
  }

  Widget _metricTile(String title, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.cyanAccent),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _dividerV() => Container(width: 1, height: 40, color: Colors.white12);

  Widget _switchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.black,
            activeTrackColor: Colors.cyanAccent,
            inactiveThumbColor: Colors.white54,
            inactiveTrackColor: Colors.white24,
          ),
        ],
      ),
    );
  }

  Widget _primaryCTA(String label, VoidCallback onTap) {
    return SizedBox(
      height: 56,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Colors.cyanAccent, Colors.blueAccent],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(.5),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                letterSpacing: .4,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sosBtn() {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم إرسال نداء الطوارئ')));
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.redAccent,
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(.5),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(Icons.sos, color: Colors.white),
      ),
    );
  }

  Widget _safetyNote() {
    return Opacity(
      opacity: .8,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline, color: Colors.white54, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'يرجى إبقاء يديك بالقرب من المقود والاستعداد للتدخل عند الضرورة. '
              'القيادة الذاتية قد تتطلب إشرافًا بشريًا وفق اللوائح المحلية.',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _neonBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 80, spreadRadius: 22)],
      ),
    );
  }
}

// ===== Painters =====

class _PathPainter extends CustomPainter {
  final double progress;
  _PathPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final pathPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFF00E5FF).withOpacity(.85);

    final glowPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..color = const Color(0xFF00E5FF).withOpacity(.20)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final p = Path();
    // مسار منحني بسيط
    p.moveTo(size.width * .1, size.height * .8);
    p.quadraticBezierTo(
      size.width * .45,
      size.height * .2,
      size.width * .9,
      size.height * .2,
    );

    // ارسم توهج خفيف
    canvas.drawPath(p, glowPaint);

    // تقدم مرسوم
    final metrics = p.computeMetrics().first;
    final extract = metrics.extractPath(0, metrics.length * progress);
    canvas.drawPath(extract, pathPaint);

    // نقاط متقطعة صغيرة
    final dashPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFFFFFFFF).withOpacity(.25);
    const dash = 8.0;
    const gap = 6.0;
    double dist = 0;
    while (dist < metrics.length * progress) {
      final double end = (dist + dash).clamp(0, metrics.length * progress);
      final seg = metrics.extractPath(dist, end);
      canvas.drawPath(seg, dashPaint);
      dist += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _PathPainter old) => old.progress != progress;
}

class _RadarPainter extends CustomPainter {
  final double progress;
  _RadarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2.2;

    // حلقات
    final ring =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = Colors.white.withOpacity(.15);
    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * (i / 4), ring);
    }

    // قوس ماسح متحرك
    final sweep = pi / 2;
    final start = progress * 2 * pi;
    final sector =
        Paint()
          ..shader = SweepGradient(
            startAngle: start,
            endAngle: start + sweep,
            colors: [
              Colors.cyanAccent.withOpacity(.45),
              Colors.cyanAccent.withOpacity(.05),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, sector);

    // نقاط أجسام (عشوائية ثابتة)
    final points = <Offset>[
      center + Offset(radius * .6, -radius * .2),
      center + Offset(-radius * .4, radius * .3),
      center + Offset(radius * .1, radius * .55),
    ];
    final dotPaint = Paint()..color = Colors.cyanAccent.withOpacity(.9);
    for (final o in points) {
      canvas.drawCircle(o, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) => old.progress != progress;
}

// ===== UI helpers =====

class _Dot extends StatelessWidget {
  final String label;
  const _Dot({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.cyanAccent,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
