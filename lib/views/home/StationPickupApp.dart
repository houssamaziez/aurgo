import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:ui';
import 'dart:ui' as ui;

class StationPickupScreen extends StatefulWidget {
  const StationPickupScreen({super.key});

  @override
  State<StationPickupScreen> createState() => _StationPickupScreenState();
}

class _StationPickupScreenState extends State<StationPickupScreen>
    with TickerProviderStateMixin {
  // Map & animations
  final MapController _mapController = MapController();
  late final AnimationController _bgPulseCtrl;
  late final AnimationController _markerPulseCtrl;

  // Search & filters
  final TextEditingController _searchCtrl = TextEditingController();
  String _stationTypeFilter = 'الكل'; // الكل / قطار / مترو / مطار / باص

  // Mock stations data
  final List<_Station> _stations = [
    _Station(
      name: 'محطة المركزية',
      type: 'قطار',
      latLng: LatLng(36.7538, 3.0588),
      distanceKm: 0.6,
      etaMin: 3,
      code: 'ST-CEN',
      image:
          'https://images.unsplash.com/photo-1467269204594-9661b134dd2b?auto=format&fit=crop&w=800&q=60',
    ),
    _Station(
      name: 'محطة الشمال',
      type: 'مترو',
      latLng: LatLng(36.7550, 3.0625),
      distanceKm: 1.2,
      etaMin: 5,
      code: 'ST-NOR',
      image:
          'https://images.unsplash.com/photo-1509223197845-458d87318791?auto=format&fit=crop&w=800&q=60',
    ),
    _Station(
      name: 'المطار الدولي',
      type: 'مطار',
      latLng: LatLng(36.745, 3.040),
      distanceKm: 12.0,
      etaMin: 18,
      code: 'ST-AP01',
      image:
          'https://images.unsplash.com/photo-1505765051750-2a0ef8b7fb3b?auto=format&fit=crop&w=800&q=60',
    ),
    _Station(
      name: 'محطة المدينة مول',
      type: 'حافلة',
      latLng: LatLng(36.7516, 3.060),
      distanceKm: 0.9,
      etaMin: 4,
      code: 'ST-MALL',
      image:
          'https://images.unsplash.com/photo-1467269204594-9661b134dd2b?auto=format&fit=crop&w=800&q=60',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bgPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _markerPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _bgPulseCtrl.dispose();
    _markerPulseCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_Station> get _visibleStations {
    final q = _searchCtrl.text.trim();
    return _stations.where((s) {
      if (_stationTypeFilter != 'الكل' && s.type != _stationTypeFilter)
        return false;
      if (q.isEmpty) return true;
      return s.name.contains(q) || s.code.contains(q);
    }).toList();
  }

  Future<void> _requestPickup(_Station station) async {
    // Center map on station
    _mapController.move(station.latLng, 15);

    // Open glass bottom sheet with timer
    final arrived = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => _GlassBottomSheet(
            child: _StationArrivalSheet(
              station: station,
              seconds: 8,
              onArrived: () {
                Navigator.of(context).pop(true);
              },
            ),
          ),
    );

    if (arrived == true && mounted) {
      // Navigate to monitoring/ride screen (AutonomousRideScreen) with transition
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => const AutonomousRideScreen(),
          transitionsBuilder: (_, anim, __, child) {
            final curved = CurvedAnimation(
              parent: anim,
              curve: Curves.easeOutCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved),
                child: child,
              ),
            );
          },
        ),
      );
    }
  }

  void _centerOnStation(_Station station) {
    _mapController.move(station.latLng, 15);
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
              // Neon decorative blobs
              Positioned(
                top: -80,
                right: -60,
                child: _neonBlob(180, Colors.cyanAccent.withOpacity(.18)),
              ),
              Positioned(
                bottom: -70,
                left: -50,
                child: _neonBlob(170, Colors.purpleAccent.withOpacity(.14)),
              ),
              AnimatedBuilder(
                animation: _bgPulseCtrl,
                builder: (_, __) {
                  final v = 0.18 + _bgPulseCtrl.value * 0.16;
                  return Positioned(
                    top: 220,
                    left: -20,
                    child: _neonBlob(120, Colors.blueAccent.withOpacity(v)),
                  );
                },
              ),

              // Map layer (below header)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(top: 132.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(0),
                    ),
                    child: Opacity(
                      opacity: 0.98,
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.stationpickup',
                          ),
                          MarkerLayer(
                            markers:
                                _visibleStations.map((s) {
                                  return Marker(
                                    width: 64,
                                    height: 80,
                                    point: s.latLng,
                                    child: GestureDetector(
                                      onTap: () {
                                        _centerOnStation(s);
                                        _requestPickup(s);
                                      },
                                      child: ScaleTransition(
                                        scale: Tween(
                                          begin: 0.95,
                                          end: 1.08,
                                        ).animate(
                                          CurvedAnimation(
                                            parent: _markerPulseCtrl,
                                            curve: Curves.easeInOut,
                                          ),
                                        ),
                                        child: _mapStationMarker(s),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Header + search + filters
              Column(
                children: [
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _header(),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _searchField(),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _typesRow(),
                  ),
                ],
              ),

              // bottom overlay list of stations (glass cards)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _stationsCarousel(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.cyanAccent,
            size: 26,
          ),
        ),

        Spacer(),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'توصيل من محطة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: .3,
            ),
          ),
        ),
        const Icon(Icons.place, color: Colors.cyanAccent, size: 26),
      ],
    );
  }

  Widget _searchField() {
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
                hintText: 'ابحث عن محطة أو كود...',
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

  Widget _typesRow() {
    final types = ['الكل', 'قطار', 'مترو', 'مطار', 'حافلة'];
    return Row(
      children:
          types.map((t) {
            final sel = t == _stationTypeFilter;
            return Expanded(
              child: InkWell(
                onTap: () => setState(() => _stationTypeFilter = t),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient:
                        sel
                            ? const LinearGradient(
                              colors: [Colors.cyanAccent, Colors.blueAccent],
                            )
                            : const LinearGradient(
                              colors: [Colors.white, Colors.white],
                            ),
                    color: sel ? Colors.white : Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      t,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _mapStationMarker(_Station s) {
    return Column(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Colors.cyanAccent, Colors.blueAccent],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(.38),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.train, color: Colors.black),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Text(
            '${s.etaMin.toStringAsFixed(0)} د',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _stationsCarousel() {
    final visible = _visibleStations;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 64,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: visible.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final s = visible[i];
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 420 + i * 80),
                  curve: Curves.easeOutBack,
                  builder: (_, value, child) {
                    final v = value.clamp(0.0, 1.0);
                    return Transform.translate(
                      offset: Offset(0, (1 - v) * 24),
                      child: Opacity(opacity: v, child: child),
                    );
                  },
                  child: _stationCard(s),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _stationCard(_Station s) {
    return GestureDetector(
      onTap: () => _requestPickup(s),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.35),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // image + badge
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        s.image,
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.cyanAccent, Colors.blueAccent],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${s.type}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  s.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'كود: ${s.code} • ${s.distanceKm.toStringAsFixed(1)} كم',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const Spacer(),
                Row(
                  children: [
                    _infoChip(
                      icon: Icons.place,
                      label: '${s.distanceKm.toStringAsFixed(1)} كم',
                    ),
                    const SizedBox(width: 8),
                    _infoChip(
                      icon: Icons.timer,
                      label: '${s.etaMin.toStringAsFixed(0)} د',
                    ),
                    const Spacer(),
                    _primaryButton('اطلب التوصيل', () => _requestPickup(s)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // small UI helpers
  Widget _infoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(.04),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 14),
          const SizedBox(width: 6),
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
          ),
        ),
      ),
    );
  }

  Widget _glass({required Widget child, double radius = 20}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.06),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.cyanAccent.withOpacity(.22)),
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

/// ======================
/// Arrival Timer Bottom Sheet (glass)
/// ======================
class _StationArrivalSheet extends StatefulWidget {
  final _Station station;
  final int seconds;
  final VoidCallback onArrived;

  const _StationArrivalSheet({
    required this.station,
    this.seconds = 8,
    required this.onArrived,
  });

  @override
  State<_StationArrivalSheet> createState() => _StationArrivalSheetState();
}

class _StationArrivalSheetState extends State<_StationArrivalSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late int _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
    _ctrl =
        AnimationController(
            vsync: this,
            duration: Duration(seconds: widget.seconds),
          )
          ..addListener(() {
            final left = max(
              0,
              (widget.seconds - (_ctrl.value * widget.seconds)).ceil(),
            );
            if (left != _remaining) setState(() => _remaining = left);
          })
          ..addStatusListener((s) {
            if (s == AnimationStatus.completed) widget.onArrived();
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
              const Icon(Icons.train, color: Colors.cyanAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.station.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'ETA ~ ${widget.station.etaMin.toStringAsFixed(0)} د',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder:
                  (_, __) => CustomPaint(
                    painter: _CircularTimerPainter(
                      progress: _ctrl.value.clamp(0.0, 1.0),
                    ),
                    child: Center(
                      child: Text(
                        'تبقّى $_remaining ث',
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
                child: _primaryBtn(
                  'استدعاء الآن',
                  () => _ctrl.animateTo(
                    1.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _sheetGrabber() => Center(
    child: Container(
      width: 50,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(999),
      ),
    ),
  );

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

/// ======================
/// AutonomousRideScreen (same design)
/// ======================
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
  double etaMin = 12;
  double battery = 82;

  late final AnimationController _radarCtrl;
  final _fromCtrl = TextEditingController(text: 'المحطة — نقطة التحميل');
  final _toCtrl = TextEditingController(text: 'وجهتك');

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
    MaterialPageRoute(builder: (_) => const StationPickupScreen()),
  );
  Widget _neonBlob({
    double size = 180,
    List<Color> colors = const [Colors.cyanAccent, Colors.blueAccent],
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
    double opacity = 0.3,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: colors.map((c) => c.withOpacity(opacity)).toList(),
          center: Alignment.center,
          radius: 0.85,
        ),
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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -70,
                right: -50,
                child: _neonBlob(
                  size: 170,
                  opacity: 0.1,
                  colors: [Colors.cyanAccent, Colors.blueAccent],
                ),
              ),
              Positioned(
                bottom: -60,
                left: -40,
                child: _neonBlob(
                  size: 160,
                  opacity: 0.1,
                  colors: [Colors.cyanAccent, Colors.blueAccent],
                ),
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
                            icon: Icons.location_pin,
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
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 3),
              curve: Curves.easeInOut,
              builder:
                  (context, t, _) =>
                      CustomPaint(painter: PathPainter(progress: t)),
            ),
          ),
          const Positioned(right: 10, top: 10, child: _Dot(label: 'محطة')),
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
}

/// =====================
/// Painters + Models
/// =====================

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
      2 * pi * (progress.clamp(0.0, 1.0)),
      false,
      glow,
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -pi / 2,
      2 * pi * (progress.clamp(0.0, 1.0)),
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularTimerPainter old) =>
      old.progress != progress;
}

class PathPainter extends CustomPainter {
  final double progress;
  PathPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double safeProgress = progress.clamp(0.0, 1.0);

    final ui.Paint pathPaint =
        ui.Paint()
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFF00E5FF).withOpacity(.85);

    final ui.Paint glowPaint =
        ui.Paint()
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 8
          ..color = const Color(0xFF00E5FF).withOpacity(.20)
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8);

    final ui.Path p = ui.Path();
    p.moveTo(size.width * .1, size.height * .8);
    p.quadraticBezierTo(
      size.width * .45,
      size.height * .2,
      size.width * .9,
      size.height * .2,
    );

    // Glow الخلفي
    canvas.drawPath(p, glowPaint);

    // المسار المتقدم
    final metrics = p.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final ui.PathMetric metric = metrics.first;
    final ui.Path extract = metric.extractPath(0, metric.length * safeProgress);
    canvas.drawPath(extract, pathPaint);

    // الخطوط المتقطعة
    final ui.Paint dashPaint =
        ui.Paint()
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFFFFFFFF).withOpacity(.25);

    const double dash = 8.0;
    const double gap = 6.0;
    double dist = 0;

    while (dist < metric.length * safeProgress) {
      final double end = (dist + dash).clamp(0, metric.length * safeProgress);
      final ui.Path seg = metric.extractPath(dist, end);
      canvas.drawPath(seg, dashPaint);
      dist += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant PathPainter old) => old.progress != progress;
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

/// Dot helper used in route preview
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

/// Station model
class _Station {
  final String name;
  final String type;
  final LatLng latLng;
  final double distanceKm;
  final double etaMin;
  final String code;
  final String image;

  _Station({
    required this.name,
    required this.type,
    required this.latLng,
    required this.distanceKm,
    required this.etaMin,
    required this.code,
    required this.image,
  });
}

/// Glass bottom sheet wrapper
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
