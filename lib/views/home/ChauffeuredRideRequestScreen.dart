import 'dart:ui';
import 'package:flutter/material.dart';

class ChauffeuredRideRequestScreen extends StatefulWidget {
  const ChauffeuredRideRequestScreen({super.key});

  @override
  State<ChauffeuredRideRequestScreen> createState() =>
      _ChauffeuredRideRequestScreenState();
}

class _ChauffeuredRideRequestScreenState
    extends State<ChauffeuredRideRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pickupCtrl = TextEditingController();
  final _dropoffCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  DateTime? _when;
  String _carType = 'اقتصادي';
  String _payment = 'نقداً';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _dropoffCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      builder: _dialogTheme,
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(minutes: 30))),
      builder: _dialogTheme,
    );
    if (time == null) return;

    setState(() {
      _when = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Widget _dialogTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Colors.cyanAccent,
          surface: Color(0xFF1B1F3B),
          onSurface: Colors.white,
        ),
        dialogBackgroundColor: const Color(0xFF14172B),
      ),
      child: child!,
    );
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || _when == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('أكمل الحقول واختر الوقت')));
      return;
    }
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2)); // محاكاة طلب API
    setState(() => _isSubmitting = false);

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: const Color(0xFF14172B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'تم إنشاء الطلب',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'تم حجز سيارة $_carType ${_when != null ? 'في ${_when!.hour.toString().padLeft(2, '0')}:${_when!.minute.toString().padLeft(2, '0')} - ${_when!.day}/${_when!.month}' : ''}',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'حسناً',
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
                // هالة نيون خفيفة خلفية
                Positioned(
                  top: -80,
                  right: -60,
                  child: _neonBlob(180, Colors.cyanAccent.withOpacity(.20)),
                ),
                Positioned(
                  bottom: -60,
                  left: -40,
                  child: _neonBlob(160, Colors.purpleAccent.withOpacity(.18)),
                ),

                // المحتوى
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(),
                      const SizedBox(height: 20),
                      _glassCard(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _field(
                                controller: _pickupCtrl,
                                icon: Icons.radio_button_checked,
                                hint: 'نقطة الانطلاق',
                                validator:
                                    (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'أدخل نقطة الانطلاق'
                                            : null,
                              ),
                              const SizedBox(height: 12),
                              _field(
                                controller: _dropoffCtrl,
                                icon: Icons.location_on,
                                hint: 'الوجهة',
                                validator:
                                    (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'أدخل الوجهة'
                                            : null,
                              ),
                              const SizedBox(height: 12),
                              _pickerTile(
                                title:
                                    _when == null
                                        ? 'اختر التاريخ والوقت'
                                        : 'الوقت: ${_when!.day}/${_when!.month} - ${_when!.hour.toString().padLeft(2, '0')}:${_when!.minute.toString().padLeft(2, '0')}',
                                icon: Icons.schedule,
                                onTap: _pickDateTime,
                              ),
                              const SizedBox(height: 16),
                              _sectionTitle('نوع السيارة'),
                              const SizedBox(height: 10),
                              _chips(
                                values: const [
                                  'اقتصادي',
                                  'مريح',
                                  'فاخر',
                                  'عائلي',
                                ],
                                selected: _carType,
                                onSelect: (v) => setState(() => _carType = v),
                              ),
                              const SizedBox(height: 16),
                              _sectionTitle('طريقة الدفع'),
                              const SizedBox(height: 10),
                              _chips(
                                values: const ['نقداً', 'بطاقة', 'محفظة'],
                                selected: _payment,
                                onSelect: (v) => setState(() => _payment = v),
                              ),
                              const SizedBox(height: 16),
                              _field(
                                controller: _noteCtrl,
                                icon: Icons.notes,
                                hint: 'ملاحظة للسائق (اختياري)',
                                maxLines: 3,
                              ),
                              const SizedBox(height: 20),
                              _priceRow(),
                              const SizedBox(height: 16),
                              _cta(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_isSubmitting)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.cyanAccent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== UI Parts =====

  Widget _header() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'طلب سيارة بسائق',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: .4,
            ),
          ),
        ),
        Directionality(
          textDirection: TextDirection.ltr,
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.06),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.cyanAccent.withOpacity(.25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.4),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: controller,
              validator: validator,
              maxLines: maxLines,
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

  Widget _pickerTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Colors.cyanAccent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const Icon(Icons.chevron_left, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Align(
    alignment: Alignment.centerRight,
    child: Text(
      t,
      style: const TextStyle(
        color: Colors.white70,
        fontWeight: FontWeight.w600,
        letterSpacing: .2,
      ),
    ),
  );

  Widget _chips({
    required List<String> values,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    return Row(
      children:
          values.map((v) {
            final isSel = v == selected;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient:
                      isSel
                          ? const LinearGradient(
                            colors: [Colors.cyanAccent, Colors.blueAccent],
                          )
                          : null,
                  color: isSel ? null : Colors.white.withOpacity(.04),
                  border: Border.all(
                    color:
                        isSel
                            ? Colors.cyanAccent.withOpacity(.6)
                            : Colors.white12,
                  ),
                  boxShadow:
                      isSel
                          ? [
                            BoxShadow(
                              color: Colors.cyanAccent.withOpacity(.45),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ]
                          : [],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onSelect(v),
                  child: Center(
                    child: Text(
                      v,
                      style: TextStyle(
                        color: isSel ? Colors.black : Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _priceRow() {
    // تقدير بسيط (تمثيلي)
    final est =
        480 +
        (_carType == 'فاخر'
            ? 220
            : _carType == 'مريح'
            ? 120
            : 0);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.attach_money, color: Colors.cyanAccent),
          const SizedBox(width: 8),
          const Text('تقدير السعر', style: TextStyle(color: Colors.white70)),
          const Spacer(),
          Text(
            '$est دج',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cta() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: InkWell(
        onTap: _isSubmitting ? null : _submit,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors:
                  _isSubmitting
                      ? [Colors.white24, Colors.white10]
                      : [Colors.cyanAccent, Colors.blueAccent],
            ),
            boxShadow:
                _isSubmitting
                    ? []
                    : [
                      BoxShadow(
                        color: Colors.cyanAccent.withOpacity(.5),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
          ),
          child: Center(
            child: Text(
              _isSubmitting ? 'جارٍ الإرسال…' : 'اطلب السيارة الآن',
              style: TextStyle(
                color: _isSubmitting ? Colors.white70 : Colors.black,
                fontWeight: FontWeight.bold,
                letterSpacing: .5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _neonBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 80, spreadRadius: 20)],
      ),
    );
  }
}
