// main.dart
// Futuristic Car Rental (2050 style) - Glassmorphism + Neon + Animations
// No external packages required.

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

class CarRentalHome extends StatefulWidget {
  const CarRentalHome({super.key});

  @override
  State<CarRentalHome> createState() => _CarRentalHomeState();
}

class _CarRentalHomeState extends State<CarRentalHome>
    with TickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  String _filter = 'الكل';
  String _sort = 'الأرخص';
  late final AnimationController _pulseCtrl;

  final List<_RentalCar> _cars = [
    _RentalCar(
      name: 'BMW i8',
      model: '2019 • هجين',
      seats: 4,
      pricePerDay: 22000,
      image:
          'https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=1000&q=60',
      code: 'BMW-i8',
    ),
    _RentalCar(
      name: 'Audi A8',
      model: '2022 • بنزين',
      seats: 5,
      pricePerDay: 18000,
      image:
          'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=1000&q=60',
      code: 'AUD-A8',
    ),
    _RentalCar(
      name: 'Nissan Patrol',
      model: '2021 • ديزل',
      seats: 7,
      pricePerDay: 15000,
      image:
          'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?auto=format&fit=crop&w=1000&q=60',
      code: 'NSP-PT',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_RentalCar> _filteredCars() {
    var list =
        _cars.where((c) {
          final q = _searchCtrl.text.trim();
          if (q.isEmpty) return true;
          return c.name.toLowerCase().contains(q.toLowerCase()) ||
              c.model.toLowerCase().contains(q.toLowerCase()) ||
              c.code.toLowerCase().contains(q.toLowerCase());
        }).toList();

    if (_filter == 'مكشوف') {
      list =
          list
              .where(
                (c) => c.name.toLowerCase().contains('convertible') == false,
              )
              .toList(); // dummy example
    }

    if (_sort == 'الأرخص') {
      list.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
    } else if (_sort == 'الأغلى') {
      list.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
    } else if (_sort == 'الأكثر مقعدا') {
      list.sort((a, b) => b.seats.compareTo(a.seats));
    }

    return list;
  }

  void _openBooking(_RentalCar car) async {
    final booked = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GlassBottomSheet(child: BookingSheet(car: car)),
    );

    if (booked == true && mounted) {
      // show confirmation overlay
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _BookingConfirmationDialog(car: car),
      );
      // auto close after 1.6s (simulate)
      Timer(const Duration(milliseconds: 1600), () {
        if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = const LinearGradient(
      colors: [Color(0xFF0F0C29), Color(0xFF24243E)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final data = _filteredCars();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bg),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _header(),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _searchBar(),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _controlsRow(),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: data.isEmpty ? _emptyState() : _carsList(data),
                ),
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
        const CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'استئجار سيارة',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ),
        _glassPill(
          child: Row(
            children: const [
              Icon(Icons.local_offer, color: Colors.cyanAccent, size: 16),
              SizedBox(width: 6),
              Text(
                'عروض',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
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
                hintText: 'ابحث عن موديل أو كود السيارة...',
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

  Widget _controlsRow() {
    return Row(
      children: [
        Expanded(
          child: _segmented(
            values: ['الكل', 'مريحة', 'عائلية'],
            selected: _filter,
            onSelect: (v) => setState(() => _filter = v),
          ),
        ),
        const SizedBox(width: 8),
        _glassPill(
          child: PopupMenuButton<String>(
            color: Colors.white12,
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder:
                (_) => const [
                  PopupMenuItem(value: 'الأرخص', child: Text('الأرخص')),
                  PopupMenuItem(value: 'الأغلى', child: Text('الأغلى')),
                  PopupMenuItem(
                    value: 'الأكثر مقعدا',
                    child: Text('الأكثر مقعدا'),
                  ),
                ],
            child: Row(
              children: [
                const Icon(Icons.sort, color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                Text(_sort, style: const TextStyle(color: Colors.white70)),
                const SizedBox(width: 6),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white70,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _carsList(List<_RentalCar> data) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: data.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final c = data[i];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 420 + i * 80),
          curve: Curves.easeOutBack,
          builder: (_, value, child) {
            final v = value.clamp(0.0, 1.0);
            return Transform.translate(
              offset: Offset(0, (1 - v) * 16),
              child: Opacity(opacity: v, child: child),
            );
          },
          child: _rentalCard(c),
        );
      },
    );
  }

  Widget _rentalCard(_RentalCar car) {
    return GestureDetector(
      onTap: () => _openBooking(car),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.35),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      car.image == null
                          ? Container()
                          : Image.network(
                            car.image,
                            width: 120,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              Text(
                                car.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                car.model,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          _primaryButton('تفاصيل', () => _openBooking(car)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: Colors.cyanAccent,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${car.seats} مقاعد',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${car.pricePerDay} دج / يوم',
                            style: const TextStyle(
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.search_off, color: Colors.white38, size: 56),
          SizedBox(height: 12),
          Text(
            'لم يتم العثور على سيارات',
            style: TextStyle(color: Colors.white60),
          ),
        ],
      ),
    );
  }

  // ui helpers
  Widget _ribbon(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.cyanAccent, Colors.blueAccent],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _primaryButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Colors.cyanAccent, Colors.blueAccent],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(.4),
              blurRadius: 12,
              offset: const Offset(0, 8),
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

  Widget _glass({required Widget child, double radius = 20}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
}

/// =====================
/// Booking Bottom Sheet
/// =====================
class BookingSheet extends StatefulWidget {
  final _RentalCar car;
  const BookingSheet({required this.car});

  @override
  State<BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<BookingSheet>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;
  int _hours = 24; // default 1 day
  String _payment = 'نقداً';
  bool _needDriver = true;
  bool _isSubmitting = false;

  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now().add(const Duration(hours: 2));
    _endDate = _startDate!.add(Duration(hours: _hours));
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  int _daysBetween(DateTime a, DateTime b) {
    final diff = b.difference(a).inHours;
    return (diff / 24).ceil();
  }

  int _calculatePrice() {
    final days = _daysBetween(
      _startDate ?? DateTime.now(),
      _endDate ?? DateTime.now().add(Duration(hours: _hours)),
    );
    final base = widget.car.pricePerDay * days;
    final driverFee = _needDriver ? 4000 * days : 0;
    final service = (base * 0.05).round(); // 5% service fee
    return base + driverFee + service;
  }

  Future<void> _pickStart() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (ctx, child) => _dateTheme(ctx, child),
    );
    if (picked == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: now.hour, minute: 0),
      builder: (ctx, child) => _dateTheme(ctx, child),
    );
    if (time == null) return;
    setState(() {
      _startDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time.hour,
        time.minute,
      );
      if (_endDate == null || _endDate!.isBefore(_startDate!)) {
        _endDate = _startDate!.add(Duration(hours: _hours));
      }
    });
  }

  Future<void> _pickEnd() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? now.add(Duration(hours: _hours)),
      firstDate: _startDate ?? now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (ctx, child) {
        return _dateTheme(ctx, child);
      },
    );
    if (picked == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: now.hour, minute: 0),
      builder: (ctx, child) => _dateTheme(ctx, child),
    );
    if (time == null) return;
    setState(() {
      _endDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time.hour,
        time.minute,
      );
      _hours = _endDate!.difference(_startDate ?? now).inHours;
    });
  }

  Widget _dateTheme(BuildContext context, Widget? child) {
    return Theme(
      data: ThemeData.light().copyWith(
        primaryColor: Colors.blue,
        colorScheme: const ColorScheme.light(primary: Colors.blue),
        buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
      ),
      child: child!,
    );
  }

  Future<void> _confirmBooking() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر تاريخ ووقت الاستلام والعودة')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2)); // simulate API
    setState(() => _isSubmitting = false);
    Navigator.of(context).pop(true); // indicate booked
  }

  @override
  Widget build(BuildContext context) {
    final price = _calculatePrice();
    final days = _daysBetween(
      _startDate ?? DateTime.now(),
      _endDate ?? DateTime.now().add(Duration(hours: _hours)),
    );

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
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.car.image,
                  width: 80,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.car.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.car.model,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _ribbon('${widget.car.pricePerDay} دج/يوم'),
            ],
          ),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _pickerTile(
                        title:
                            _startDate == null
                                ? 'تاريخ الاستلام'
                                : '${_formatDate(_startDate!)} • ${_formatTime(_startDate!)}',
                        icon: Icons.calendar_month,
                        onTap: _pickStart,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _pickerTile(
                        title:
                            _endDate == null
                                ? 'تاريخ الإرجاع'
                                : '${_formatDate(_endDate!)} • ${_formatTime(_endDate!)}',
                        icon: Icons.calendar_month_outlined,
                        onTap: _pickEnd,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _optionToggle(
                        'سائق مطلوب',
                        _needDriver,
                        (v) => setState(() => _needDriver = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _optionToggle(
                        'الدفع: نقد/بطاقة',
                        _payment == 'نقداً',
                        (v) => setState(() => _payment = v ? 'نقداً' : 'بطاقة'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _pricePreview(price: price, days: days),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: InkWell(
                    onTap: _isSubmitting ? null : _confirmBooking,
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient:
                            _isSubmitting
                                ? LinearGradient(
                                  colors: [Colors.white12, Colors.white10],
                                )
                                : const LinearGradient(
                                  colors: [
                                    Colors.cyanAccent,
                                    Colors.blueAccent,
                                  ],
                                ),
                        boxShadow:
                            _isSubmitting
                                ? []
                                : [
                                  BoxShadow(
                                    color: Colors.cyanAccent.withOpacity(.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                      ),
                      child: Center(
                        child:
                            _isSubmitting
                                ? const CircularProgressIndicator(
                                  color: Colors.black,
                                )
                                : const Text(
                                  'تأكيد الحجز',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

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

  Widget _pickerTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.cyanAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white70)),
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

  Widget _pricePreview({required int price, required int days}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'التكلفة التقريبية',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  '$price دج',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text('$days يوم', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text(_payment, style: const TextStyle(color: Colors.cyanAccent)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ribbon(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.cyanAccent, Colors.blueAccent],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// ======================
/// Booking confirmation dialog
/// ======================
class _BookingConfirmationDialog extends StatelessWidget {
  final _RentalCar car;
  const _BookingConfirmationDialog({required this.car});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF14172B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.cyanAccent,
              size: 64,
            ),
            const SizedBox(height: 12),
            Text(
              'تم تأكيد الحجز!',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'تم حجز ${car.name} بنجاح. سيصلك البريد الإلكتروني بالبيانات.',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// ======================
/// Models + small helpers
/// ======================
class _RentalCar {
  final String name;
  final String model;
  final int seats;
  final int pricePerDay;
  final String image;
  final String code;

  _RentalCar({
    required this.name,
    required this.model,
    required this.seats,
    required this.pricePerDay,
    required this.image,
    required this.code,
  });
}

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
