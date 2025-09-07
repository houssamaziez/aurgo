import 'dart:async';
import 'dart:math';
import 'package:aurgo/core/utle/extentions.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

class SpecialOfferScreen extends StatefulWidget {
  const SpecialOfferScreen({super.key});

  @override
  State<SpecialOfferScreen> createState() => _SpecialOfferScreenState();
}

class _SpecialOfferScreenState extends State<SpecialOfferScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _cardsCtrl;
  late AnimationController _pulseCtrl;
  late ScrollController _scrollCtrl;

  // Countdown (مثال: 1 ساعة من الآن)
  late DateTime _endTime;
  late Timer _tick;

  // حالة
  double _usageProgress = 0.35; // نسبة استخدام العرض
  bool _copied = false;
  int _carouselIndex = 0;

  final _testimonials = const [
    {"name": "سارة", "text": "خصم قوي وخدمة ممتازة! أنصح به 👌"},
    {"name": "أمين", "text": "وفرت مبلغ محترم على رحلتي الأولى 👍"},
    {"name": "هدى", "text": "سهل الاستخدام والتفعيل كان فوري ⚡"},
  ];

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _cardsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _scrollCtrl = ScrollController();

    _endTime = DateTime.now().add(const Duration(hours: 1));
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {}); // لتحديث العد التنازلي
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _cardsCtrl.dispose();
    _pulseCtrl.dispose();
    _scrollCtrl.dispose();
    _tick.cancel();
    super.dispose();
  }

  Duration get _remaining {
    final now = DateTime.now();
    final diff = _endTime.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }

  String _fmt2(int n) => n.toString().padLeft(2, '0');

  void _openRedeemSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0E111A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => const _RedeemBottomSheet(),
    );
  }

  void _copyCode() async {
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _copied = false);
  }

  void _advanceCarousel(int dir) {
    setState(() {
      _carouselIndex = (_carouselIndex + dir) % _testimonials.length;
      if (_carouselIndex < 0) _carouselIndex = _testimonials.length - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bg = Colors.grey.shade900;

    final rem = _remaining;
    final h = rem.inHours;
    final m = rem.inMinutes % 60;
    final s = rem.inSeconds % 60;

    final pulse = (0.9 + 0.1 * sin(_pulseCtrl.value * pi)).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.cyanAccent,
        icon: const Icon(Icons.local_offer, color: Colors.black),
        label: const Text("استفد الآن", style: TextStyle(color: Colors.black)),
        onPressed: _openRedeemSheet,
      ),
      body: Stack(
        children: [
          // خلفية زخرفية
          AnimatedBuilder(
            animation: _bgCtrl,
            builder:
                (_, __) => CustomPaint(
                  painter: _OfferBgPainter(progress: _bgCtrl.value),
                  child: const SizedBox.expand(),
                ),
          ),
          // محتوى
          CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              // SliverAppBar(
              //   backgroundColor: Colors.transparent,
              //   elevation: 0,
              //   pinned: true,
              //   expandedHeight: 160,
              //   flexibleSpace: FlexibleSpaceBar(
              //     centerTitle: true,
              //     titlePadding: const EdgeInsetsDirectional.only(bottom: 12),
              //     title: const Text(
              //       "عرض خاص !",
              //       style: TextStyle(
              //         fontWeight: FontWeight.w900,
              //         letterSpacing: .2,
              //       ),
              //     ),
              //     background: _header(),
              //   ),
              // ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      title: const Text(
                        "عرض خاص !",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: .2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _mainOfferCard(h, m, s, pulse),
                    const SizedBox(height: 16),
                    _quickStatsRow(),
                    const SizedBox(height: 16),
                    _featureGrid(),
                    const SizedBox(height: 16),
                    _usageProgressCard(),
                    const SizedBox(height: 16),
                    _codeCard(),
                    const SizedBox(height: 16),
                    _pricingTiers(),
                    const SizedBox(height: 16),
                    _testimonialCarousel(),
                    const SizedBox(height: 16),
                    _termsSection(),
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 80,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).withGradientBackground([
      Colors.black,
      Colors.deepPurple.withOpacity(0.1),
    ]);
  }

  // Header background
  Widget _header() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0099FF), Color(0xFF00E5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(right: -30, bottom: -20, child: _circle(140, .09)),
          Positioned(left: -20, top: -20, child: _circle(100, .07)),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Text(
                "خصم 25% على أول رحلة – لفترة محدودة",
                style: TextStyle(color: Colors.white.withOpacity(.9)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double s, double o) => Container(
    width: s,
    height: s,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(o),
      shape: BoxShape.circle,
    ),
  );

  // Main Offer Card (countdown)
  Widget _mainOfferCard(int h, int m, int s, double pulse) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedBuilder(
        animation: _cardsCtrl,
        builder: (_, child) {
          final v = _cardsCtrl.value.clamp(0.0, 1.0);
          return Transform.translate(
            offset: Offset(0, (1 - v) * 34),
            child: Opacity(opacity: v, child: child),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF141925), Color(0xFF0F1420)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(.08),
                blurRadius: 24 * pulse,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _badge("جديد", Icons.flash_on),
                  const Spacer(),
                  _miniInfo(Icons.timer_outlined, "ينتهي قريباً"),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "خصم 25% على أول رحلة",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                "العرض سارٍ حتى نفاد الكمية أو انتهاء الوقت",
                style: TextStyle(color: Colors.white.withOpacity(.7)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              _countdown(h, m, s),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _openRedeemSheet,
                      icon: const Icon(Icons.local_offer, color: Colors.black),
                      label: const Text(
                        "استفد الآن",
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      _scrollCtrl.animateTo(
                        _scrollCtrl.position.maxScrollExtent * .6,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                      );
                    },
                    icon: const Icon(
                      Icons.info_outline,
                      color: Colors.cyanAccent,
                    ),
                    label: const Text(
                      "التفاصيل",
                      style: TextStyle(color: Colors.cyanAccent),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.cyanAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 14,
                      ),
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

  Widget _badge(String t, IconData ic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.cyanAccent.withOpacity(.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyanAccent.withOpacity(.3)),
      ),
      child: Row(
        children: [
          Icon(ic, color: Colors.cyanAccent, size: 16),
          const SizedBox(width: 6),
          Text(
            t,
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniInfo(IconData ic, String t) {
    return Row(
      children: [
        Icon(ic, color: Colors.white54, size: 18),
        const SizedBox(width: 6),
        Text(t, style: const TextStyle(color: Colors.white54)),
      ],
    );
  }

  Widget _countdown(int h, int m, int s) {
    final boxes = [
      {"label": "ساعات", "value": _fmt2(h)},
      {"label": "دقائق", "value": _fmt2(m)},
      {"label": "ثواني", "value": _fmt2(s)},
    ];
    return Row(
      children:
          boxes
              .map(
                (b) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(.08)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          b["value"]!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          b["label"]!,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _quickStatsRow() {
    final stats = [
      {"icon": Icons.star_rate_rounded, "t": "تقييم 4.9"},
      {"icon": Icons.shield_moon_outlined, "t": "آمن وموثوق"},
      {"icon": Icons.flash_on, "t": "تفعيل فوري"},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children:
            stats
                .map(
                  (s) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(.08),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            s["icon"] as IconData,
                            color: Colors.cyanAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            s["t"]!.toString(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
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

  Widget _featureGrid() {
    final feats = [
      {"ic": Icons.discount, "t": "خصم 25%"},
      {"ic": Icons.directions_car, "t": "كل الرحلات"},
      {"ic": Icons.account_balance_wallet, "t": "حد أقصى 200 د.ج"},
      {"ic": Icons.av_timer, "t": "صالح 24 ساعة"},
      {"ic": Icons.qr_code, "t": "كوبون رقمي"},
      {"ic": Icons.support_agent, "t": "دعم فوري"},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: feats.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.2,
        ),
        itemBuilder: (_, i) {
          final a = CurvedAnimation(
            parent: _cardsCtrl,
            curve: Interval(
              (i / feats.length) * .8,
              1,
              curve: Curves.easeOutBack,
            ),
          );
          final item = feats[i];
          return AnimatedBuilder(
            animation: a,
            builder:
                (_, child) => Transform.scale(
                  scale: (a.value * .2 + .8).clamp(.8, 1.0),
                  child: Opacity(
                    opacity: a.value.clamp(0.0, 1.0),
                    child: child,
                  ),
                ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(.08)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item["ic"] as IconData, color: Colors.cyanAccent),
                  const SizedBox(height: 6),
                  Text(
                    item["t"]!.toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _usageProgressCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "نسبة استخدام العرض",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                LayoutBuilder(
                  builder:
                      (_, c) => AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        width: c.maxWidth * _usageProgress.clamp(0.0, 1.0),
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.cyanAccent, Colors.blueAccent],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  "${(_usageProgress * 100).round()}%",
                  style: const TextStyle(color: Colors.white70),
                ),
                const Spacer(),
                Text(
                  "متبقٍ: ${(100 - (_usageProgress * 100)).round()}%",
                  style: const TextStyle(color: Colors.white38),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _usageProgress = (min(1.0, _usageProgress + .05));
                    });
                  },
                  icon: const Icon(Icons.refresh, color: Colors.cyanAccent),
                  label: const Text(
                    "تحديث",
                    style: TextStyle(color: Colors.cyanAccent),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.cyanAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  "تحديث يدوي",
                  style: TextStyle(color: Colors.white.withOpacity(.5)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _codeCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF101624), Color(0xFF0C1320)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(.08),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.qr_code, color: Colors.cyanAccent, size: 36),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "كود الخصم",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "AURGO25",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "استخدمه عند الدفع للحصول على الخصم",
                    style: TextStyle(
                      color: Colors.white.withOpacity(.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _copyCode,
              icon: Icon(
                _copied ? Icons.check : Icons.copy,
                color: Colors.black,
              ),
              label: Text(
                _copied ? "تم النسخ" : "نسخ",
                style: const TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pricingTiers() {
    final tiers = [
      {"name": "Basic", "price": "0 د.ج", "desc": "خصم 10% حتى 50 د.ج"},
      {"name": "Plus", "price": "199 د.ج", "desc": "خصم 20% حتى 120 د.ج"},
      {"name": "Max", "price": "399 د.ج", "desc": "خصم 25% حتى 200 د.ج"},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children:
            tiers.map((t) {
              final sel = t["name"] == "Max";
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color:
                          sel
                              ? Colors.cyanAccent
                              : Colors.white.withOpacity(.08),
                      width: sel ? 1.4 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        t["name"]!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t["price"]!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t["desc"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: _openRedeemSheet,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: sel ? Colors.cyanAccent : Colors.white24,
                          ),
                          foregroundColor:
                              sel ? Colors.cyanAccent : Colors.white70,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("اختيار"),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _testimonialCarousel() {
    final item = _testimonials[_carouselIndex];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(.08)),
        ),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "آراء المستخدمين",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  onPressed: () => _advanceCarousel(-1),
                  icon: const Icon(Icons.chevron_right, color: Colors.white54),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      key: ValueKey(_carouselIndex),
                      children: [
                        Text(
                          "“${item["text"]!}”",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "— ${item["name"]!}",
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _advanceCarousel(1),
                  icon: const Icon(Icons.chevron_left, color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _testimonials.length,
                (i) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color:
                        i == _carouselIndex
                            ? Colors.cyanAccent
                            : Colors.white24,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _termsSection() {
    final terms = [
      "الخصم يطبق على قيمة أجرة الرحلة فقط.",
      "لا يمكن الجمع بين هذا العرض وأي عرض آخر.",
      "صالح لمستخدم واحد وللاستخدام مرة واحدة فقط.",
      "قد يتم إلغاء العرض في حال إساءة الاستخدام.",
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(.08)),
        ),
        child: ExpansionTile(
          title: const Text(
            "الشروط والأحكام",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          iconColor: Colors.cyanAccent,
          collapsedIconColor: Colors.white38,
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            ...terms.map(
              (t) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("• ", style: TextStyle(color: Colors.white54)),
                    Expanded(
                      child: Text(
                        t,
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// BottomSheet الاستفادة من العرض
class _RedeemBottomSheet extends StatefulWidget {
  const _RedeemBottomSheet();

  @override
  State<_RedeemBottomSheet> createState() => _RedeemBottomSheetState();
}

class _RedeemBottomSheetState extends State<_RedeemBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController(text: "AURGO25");
  bool _agree = true;
  bool _submitting = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: pad),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "تفعيل العرض",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "أدخل كود الخصم للتفعيل",
                  style: TextStyle(color: Colors.white.withOpacity(.7)),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _codeCtrl,
                style: const TextStyle(color: Colors.white),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? "أدخل كوداً صالحاً"
                            : null,
                decoration: InputDecoration(
                  hintText: "أدخل الكود",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withOpacity(.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _agree,
                    onChanged: (v) => setState(() => _agree = v ?? false),
                    side: const BorderSide(color: Colors.white38),
                    checkColor: Colors.black,
                    activeColor: Colors.cyanAccent,
                  ),
                  const Expanded(
                    child: Text(
                      "أوافق على الشروط والأحكام",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      _submitting
                          ? null
                          : () async {
                            if (!_agree) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("يجب الموافقة على الشروط"),
                                ),
                              );
                              return;
                            }
                            if (_formKey.currentState?.validate() != true)
                              return;
                            setState(() => _submitting = true);
                            await Future.delayed(const Duration(seconds: 1));
                            if (!mounted) return;
                            setState(() => _submitting = false);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("تم تفعيل العرض بنجاح ✅"),
                              ),
                            );
                          },
                  icon:
                      _submitting
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.check, color: Colors.black),
                  label: Text(
                    _submitting ? "جاري التفعيل..." : "تفعيل العرض",
                    style: const TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// خلفية زخرفية
class _OfferBgPainter extends CustomPainter {
  final double progress;
  _OfferBgPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius =
        size.shortestSide * (0.65 + 0.1 * math.sin(progress * math.pi * 2));

    // استخدم ui.Gradient.radial (من dart:ui)
    final shader = ui.Gradient.radial(
      center,
      radius,
      [
        const Color(0xFF00E5FF).withOpacity(.06),
        const Color(0xFF0099FF).withOpacity(.04),
        Colors.transparent,
      ],
      [0.0, 0.4, 1.0],
    );

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);

    // بقية الرسم (نقاط/خطوط) كما هي...
    final rnd = math.Random(7);
    final dot = Paint()..color = Colors.white.withOpacity(.06);
    for (int i = 0; i < 26; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = (rnd.nextDouble() * size.height + progress * 60) % size.height;
      canvas.drawCircle(Offset(x, y), 1.5 + rnd.nextDouble() * 2.5, dot);
    }

    final line =
        Paint()
          ..color = Colors.white.withOpacity(.04)
          ..strokeWidth = 1;
    final step = size.width / 12;
    for (int i = 0; i < 12; i++) {
      final x = i * step + (progress * 10);
      canvas.drawLine(Offset(x, 0), Offset(x - 30, size.height), line);
    }
  }

  @override
  bool shouldRepaint(covariant _OfferBgPainter old) => old.progress != progress;
}
