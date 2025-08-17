// Flutter 2050: Nearby Autonomous Cars + Timer -> AutonomousRideScreen
// by HOUSSAM & GPT-5 Thinking

import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class NearbyAutonomousScreen extends StatefulWidget {
  const NearbyAutonomousScreen({super.key});

  @override
  State<NearbyAutonomousScreen> createState() => _NearbyAutonomousScreenState();
}

class _NearbyAutonomousScreenState extends State<NearbyAutonomousScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgPulseCtrl;
  late final AnimationController _scanCtrl;

  String _filter = 'الكل';
  String _sort = 'الأقرب';
  final TextEditingController _searchCtrl = TextEditingController();

  // Mock nearby autonomous cars
  final List<_Car> cars = [
    _Car('Tesla Model X', 'كهربائية • مستوى L4', 0.8, 4.2, 93, 'TX-A1'),
    _Car('Waymo Van', 'كهربائية • مستوى L4', 1.5, 8.5, 76, 'WM-B7'),
    _Car('Cruise AV', 'كهربائية • مستوى L4', 2.1, 12.0, 64, 'CR-Z3'),
    _Car('Zoox Pod', 'كهربائية • مستوى L5', 0.5, 3.0, 88, 'ZX-Q9'),
    _Car('NIO ET7 AV', 'كهربائية • مستوى L4', 3.8, 16.5, 59, 'NIO-E7'),
    _Car('Mercedes DrivePilot', 'هجين • مستوى L3', 5.5, 20.0, 41, 'MB-DP'),
  ];

  @override
  void initState() {
    super.initState();
    _bgPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _bgPulseCtrl.dispose();
    _scanCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_Car> _filteredCars() {
    List<_Car> data =
        cars.where((c) {
          final q = _searchCtrl.text.trim();
          if (q.isEmpty) return true;
          return c.name.toLowerCase().contains(q.toLowerCase()) ||
              c.code.toLowerCase().contains(q.toLowerCase());
        }).toList();

    if (_filter == 'بطارية +70%') {
      data = data.where((c) => c.battery >= 70).toList();
    } else if (_filter == 'أقرب من 2 كم') {
      data = data.where((c) => c.distanceKm <= 2).toList();
    }

    if (_sort == 'الأقرب') {
      data.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    } else if (_sort == 'أسرع وصولاً') {
      data.sort((a, b) => a.etaMin.compareTo(b.etaMin));
    } else if (_sort == 'أعلى بطارية') {
      data.sort((a, b) => b.battery.compareTo(a.battery));
    }

    return data;
  }

  void _bookCar(_Car car) async {
    // فتح BottomSheet بستايل زجاجي + تايمر
    final selected = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => _GlassBottomSheet(
            child: _ArrivalTimerSheet(
              car: car,
              onArrived: () {
                Navigator.of(context).pop(true);
              },
            ),
          ),
    );

    if (selected == true && mounted) {
      // الانتقال إلى الشاشة المتكاملة
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => const AutonomousRideScreen(),
          transitionsBuilder: (_, anim, __, child) {
            final curved = CurvedAnimation(
              parent: anim,
              curve: Curves.easeOutCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: Transform.scale(
                scale: 0.98 + curved.value * 0.02,
                child: child,
              ),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgGradient = const LinearGradient(
      colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Stack(
            children: [
              // خلفية نبض نيون
              Positioned(
                top: -80,
                right: -60,
                child: _neonBlob(180, Colors.cyanAccent.withOpacity(.18)),
              ),
              Positioned(
                bottom: -70,
                left: -50,
                child: _neonBlob(170, Colors.purpleAccent.withOpacity(.16)),
              ),
              AnimatedBuilder(
                animation: _bgPulseCtrl,
                builder: (_, __) {
                  final v = 0.2 + _bgPulseCtrl.value * 0.15;
                  return Positioned(
                    top: 220,
                    left: -20,
                    child: _neonBlob(120, Colors.blueAccent.withOpacity(v)),
                  );
                },
              ),

              // طبقة "خريطة" مبسطة مع ماسح
              Positioned.fill(child: CustomPaint(painter: _GridMapPainter())),
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _scanCtrl,
                    builder:
                        (_, __) => CustomPaint(
                          painter: _ScannerSweepPainter(
                            progress: _scanCtrl.value,
                          ),
                        ),
                  ),
                ),
              ),

              // المحتوى
              Column(
                children: [
                  const SizedBox(height: 12),
                  _header(),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _searchBar(),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _filtersRow(),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: _carsList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(
            Icons.location_searching,
            color: Colors.cyanAccent,
            size: 26,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'سيارات ذاتية قريبة منك',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: .3,
              ),
            ),
          ),
          _glassPill(
            child: Row(
              children: const [
                Icon(
                  Icons.shield_moon_outlined,
                  color: Colors.cyanAccent,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'AI Scan',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return _glass(
      radius: 20,
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Icon(Icons.search, color: Colors.white70),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'ابحث باسم السيارة أو الكود…',
                hintStyle: TextStyle(color: Colors.white60),
                border: InputBorder.none,
              ),
            ),
          ),
          if (_searchCtrl.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchCtrl.clear();
                setState(() {});
              },
              icon: const Icon(Icons.close, color: Colors.white54),
            ),
        ],
      ),
    );
  }

  Widget _filtersRow() {
    final filters = ['الكل', 'بطارية +70%', 'أقرب من 2 كم'];
    final sorts = ['الأقرب', 'أسرع وصولاً', 'أعلى بطارية'];
    return Row(
      children: [
        Expanded(
          child: _segmented(
            values: filters,
            selected: _filter,
            onSelect: (v) => setState(() => _filter = v),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _segmented(
            values: sorts,
            selected: _sort,
            onSelect: (v) => setState(() => _sort = v),
          ),
        ),
      ],
    );
  }

  Widget _carsList() {
    final data = _filteredCars();
    if (data.isEmpty) {
      return Center(
        child: _glass(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.info_outline, color: Colors.white70),
                SizedBox(height: 8),
                Text(
                  'لا توجد سيارات مطابقة للبحث/المرشحات',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: data.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final c = data[i];
        return _carTile(c);
      },
    );
  }

  Widget _carTile(_Car c) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutBack,
      builder:
          (_, v, child) => Transform.translate(
            offset: Offset(0, (1 - v) * 24),
            child: Opacity(
              opacity: v.clamp(0.0, 1.0), // يمنع القيم خارج النطاق
              child: child,
            ),
          ),
      child: _glass(
        radius: 18,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              _avatarBadge(c),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      c.meta,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _chip(
                          icon: Icons.ev_station,
                          label: '${c.battery}%',
                          glow: c.battery >= 80,
                        ),
                        const SizedBox(width: 6),
                        _chip(
                          icon: Icons.place,
                          label: '${c.distanceKm.toStringAsFixed(1)} كم',
                        ),
                        const SizedBox(width: 6),
                        _chip(
                          icon: Icons.timer,
                          label: '${c.etaMin.toStringAsFixed(0)} د',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _primaryButton('احجز', () => _bookCar(c)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatarBadge(_Car c) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: CustomPaint(
            painter: _BatteryArcPainter(percent: c.battery / 100),
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(.06),
            border: Border.all(color: Colors.cyanAccent.withOpacity(.25)),
          ),
          child: const Icon(
            Icons.smart_toy,
            color: Colors.cyanAccent,
            size: 22,
          ),
        ),
      ],
    );
  }

  // ===== Small UI helpers

  Widget _chip({
    required IconData icon,
    required String label,
    bool glow = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(.05),
        border: Border.all(color: Colors.white10),
        boxShadow:
            glow
                ? [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
                : [],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _primaryButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [Colors.cyanAccent, Colors.blueAccent],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: .3,
          ),
        ),
      ),
    );
  }

  Widget _segmented({
    required List<String> values,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    return _glass(
      radius: 14,
      child: Row(
        children:
            values.map((v) {
              final sel = v == selected;
              return Expanded(
                child: InkWell(
                  onTap: () => onSelect(v),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient:
                          sel
                              ? const LinearGradient(
                                colors: [Colors.cyanAccent, Colors.blueAccent],
                              )
                              : null,
                      color: sel ? null : Colors.white.withOpacity(.03),
                    ),
                    child: Center(
                      child: Text(
                        v,
                        style: TextStyle(
                          color: sel ? Colors.black : Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _glass({required Widget child, double radius = 22}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.06),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.cyanAccent.withOpacity(.22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.35),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _glassPill({required Widget child}) {
    return _glass(
      radius: 999,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: child,
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

/// ========================
/// 2) Arrival Timer Sheet
/// ========================
class _ArrivalTimerSheet extends StatefulWidget {
  final _Car car;
  final VoidCallback onArrived;
  const _ArrivalTimerSheet({required this.car, required this.onArrived});

  @override
  State<_ArrivalTimerSheet> createState() => _ArrivalTimerSheetState();
}

class _ArrivalTimerSheetState extends State<_ArrivalTimerSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  static const int seconds = 6;
  late int _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = seconds;
    _ctrl =
        AnimationController(
            vsync: this,
            duration: const Duration(seconds: seconds),
          )
          ..addListener(() {
            final left = (seconds - (_ctrl.value * seconds)).ceil();
            if (left != _remaining) {
              setState(() => _remaining = left);
            }
          })
          ..addStatusListener((s) {
            if (s == AnimationStatus.completed) {
              widget.onArrived();
            }
          })
          ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        right: 16,
        left: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _sheetGrabber(),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.directions_car, color: Colors.cyanAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.car.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'ETA ~ ${widget.car.etaMin.toStringAsFixed(0)} د',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder:
                  (_, __) => CustomPaint(
                    painter: _CircularTimerPainter(progress: _ctrl.value),
                    child: Center(
                      child: Text(
                        'تصل خلال $_remaining ث',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _cancelBtn(() => Navigator.of(context).pop(false)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _primaryBtn('تأكيد الاستقبال', () {
                  // تقدم فوري
                  _ctrl.animateTo(
                    1.0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _sheetGrabber() {
    return Center(
      child: Container(
        width: 50,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }

  Widget _cancelBtn(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(.05),
          border: Border.all(color: Colors.white12),
        ),
        child: const Center(
          child: Text(
            'إلغاء',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _primaryBtn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [Colors.cyanAccent, Colors.blueAccent],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(.5),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              letterSpacing: .3,
            ),
          ),
        ),
      ),
    );
  }
}

/// ========================
/// 3) AutonomousRideScreen (متكاملة)
//   (نفس الروح البصرية، مع عدادات ورادار ومفاتيح أمان)
/// ========================
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

  double speed = 42;
  double etaMin = 18;
  double battery = 82;

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

  void _endRide() => Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (_) => const NearbyAutonomousScreen()),
  );

  @override
  Widget build(BuildContext context) {
    final bgGradient = const LinearGradient(
      colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
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
                    _rideHeader(),
                    const SizedBox(height: 16),
                    _glass(
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
                    _glass(
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
                    _glass(
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
                    _glass(
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
                            onChanged: (v) => setState(() => followLimits = v),
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
                            onChanged: (v) => setState(() => safeDistance = v),
                            subtitle: 'المحافظة على مسافة تفاعلية مع المركبات.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(child: _primaryCTA('إنهاء الرحلة', _endRide)),
                        const SizedBox(width: 12),
                        _sosBtn(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === UI parts (reuse) ===
  Widget _rideHeader() {
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
      ],
    );
  }

  Widget _glass({required Widget child, double radius = 22}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.06),
            borderRadius: BorderRadius.circular(radius),
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
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(seconds: 3),
              curve: Curves.easeInOut,
              builder:
                  (context, t, _) =>
                      CustomPaint(painter: _PathPainter(progress: t)),
            ),
          ),
          Positioned(right: 10, top: 10, child: _Dot(label: 'انطلاق')),
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
      onTap:
          () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إرسال نداء الطوارئ')),
          ),
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

/// ========================
/// Painters + Models
/// ========================
class _Car {
  final String name;
  final String meta;
  final double distanceKm;
  final double etaMin;
  final int battery;
  final String code;

  _Car(
    this.name,
    this.meta,
    this.distanceKm,
    this.etaMin,
    this.battery,
    this.code,
  );
}

class _BatteryArcPainter extends CustomPainter {
  final double percent; // 0..1
  _BatteryArcPainter({required this.percent});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = min(size.width, size.height) / 2;
    final bg =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..color = Colors.white12;
    final fg =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..shader = SweepGradient(
            colors: [Colors.cyanAccent, Colors.blueAccent],
            startAngle: -pi / 2,
            endAngle: 3 * pi / 2,
          ).createShader(Rect.fromCircle(center: c, radius: r));

    canvas.drawCircle(c, r - 3, bg);
    final sweep = 2 * pi * percent;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r - 3),
      -pi / 2,
      sweep,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _BatteryArcPainter old) =>
      old.percent != percent;
}

class _CircularTimerPainter extends CustomPainter {
  final double progress; // 0..1
  _CircularTimerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = min(size.width, size.height) / 2 - 8;

    final bg =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..color = Colors.white24;

    final glow =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..color = Colors.cyanAccent.withOpacity(.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final fg =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round
          ..shader = SweepGradient(
            colors: [Colors.cyanAccent, Colors.blueAccent],
          ).createShader(Rect.fromCircle(center: c, radius: r));

    canvas.drawCircle(c, r, bg);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -pi / 2,
      2 * pi * progress,
      false,
      glow,
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -pi / 2,
      2 * pi * progress,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularTimerPainter old) =>
      old.progress != progress;
}

class _GridMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.white.withOpacity(.05);

    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScannerSweepPainter extends CustomPainter {
  final double progress;
  _ScannerSweepPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width - 90, 150);
    final radius = 110.0;
    final start = progress * 2 * pi;
    final sweep = pi / 2;

    final sector =
        Paint()
          ..shader = SweepGradient(
            startAngle: start,
            endAngle: start + sweep,
            colors: [Colors.cyanAccent.withOpacity(.25), Colors.transparent],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, sector);

    final ring =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.cyanAccent.withOpacity(.25);
    canvas.drawCircle(center, radius, ring);
    canvas.drawCircle(center, radius * .66, ring);
    canvas.drawCircle(center, radius * .33, ring);
  }

  @override
  bool shouldRepaint(covariant _ScannerSweepPainter old) =>
      old.progress != progress;
}

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
    p.moveTo(size.width * .1, size.height * .8);
    p.quadraticBezierTo(
      size.width * .45,
      size.height * .2,
      size.width * .9,
      size.height * .2,
    );

    canvas.drawPath(p, glowPaint);

    final metrics = p.computeMetrics().first;
    final extract = metrics.extractPath(0, metrics.length * progress);
    canvas.drawPath(extract, pathPaint);

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

    final ring =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = Colors.white.withOpacity(.15);
    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * (i / 4), ring);
    }

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

/// ============
/// UI Wrappers
/// ============
class _GlassBottomSheet extends StatelessWidget {
  final Widget child;
  const _GlassBottomSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.06),
            border: Border(
              top: BorderSide(color: Colors.cyanAccent.withOpacity(.22)),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final String label;
  const _Dot({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
