import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController senderNameController = TextEditingController();
  final TextEditingController senderPhoneController = TextEditingController();
  final TextEditingController receiverNameController = TextEditingController();
  final TextEditingController receiverPhoneController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // DropDown
  String selectedTaskType = "توصيل طلب";
  final List<String> taskTypes = ["توصيل طلب", "نقل طرد", "خدمة خاصة"];

  // Locations
  LatLng? pickupLocation;
  LatLng? deliveryLocation;

  late GoogleMapController mapController;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _selectLocation(bool isPickup) async {
    // لاحقاً يمكن إضافة خريطة فعلية لاختيار المواقع
    final LatLng selected = const LatLng(24.7136, 46.6753);
    setState(() {
      if (isPickup) {
        pickupLocation = selected;
      } else {
        deliveryLocation = selected;
      }
    });
  }

  void _createTask() {
    if (_formKey.currentState!.validate()) {
      if (pickupLocation == null || deliveryLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("الرجاء تحديد موقعي الاستلام والتسليم")),
        );
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ تم إنشاء المهمة بنجاح")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "مهمة جديدة",
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: cs.primary,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildCard(
                  title: "تفاصيل المهمة",
                  child: DropdownButtonFormField<String>(
                    value: selectedTaskType,
                    items:
                        taskTypes
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (value) => setState(() => selectedTaskType = value!),
                    decoration: const InputDecoration(
                      labelText: "نوع المهمة",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                _buildCard(
                  title: "بيانات المرسل",
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: senderNameController,
                        label: "اسم المرسل",
                        icon: Icons.person,
                        validator:
                            (v) =>
                                v!.isEmpty ? "الرجاء إدخال اسم المرسل" : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: senderPhoneController,
                        label: "رقم المرسل",
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator:
                            (v) =>
                                v!.isEmpty ? "الرجاء إدخال رقم المرسل" : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                _buildCard(
                  title: "بيانات المستلم",
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: receiverNameController,
                        label: "اسم المستلم",
                        icon: Icons.person_outline,
                        validator:
                            (v) =>
                                v!.isEmpty ? "الرجاء إدخال اسم المستلم" : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: receiverPhoneController,
                        label: "رقم المستلم",
                        icon: Icons.phone_android,
                        keyboardType: TextInputType.phone,
                        validator:
                            (v) =>
                                v!.isEmpty ? "الرجاء إدخال رقم المستلم" : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                _buildCard(
                  title: "مواقع الاستلام والتسليم",
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectLocation(true),
                          icon: const Icon(Icons.my_location),
                          label: Text(
                            pickupLocation == null
                                ? "موقع الاستلام"
                                : "تم التحديد ✅",
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                pickupLocation == null
                                    ? cs.primary
                                    : Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                              color:
                                  pickupLocation == null
                                      ? cs.primary
                                      : Colors.green,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectLocation(false),
                          icon: const Icon(Icons.location_on),
                          label: Text(
                            deliveryLocation == null
                                ? "موقع التسليم"
                                : "تم التحديد ✅",
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                deliveryLocation == null
                                    ? cs.primary
                                    : Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                              color:
                                  deliveryLocation == null
                                      ? cs.primary
                                      : Colors.green,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                _buildCard(
                  title: "التكلفة والملاحظات",
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: priceController,
                        label: "سعر التوصيل (ر.س)",
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        validator:
                            (v) => v!.isEmpty ? "الرجاء إدخال السعر" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: "ملاحظات أو تفاصيل إضافية",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // زر إنشاء المهمة
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _createTask,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: cs.primary,
                    ),
                    child: Text(
                      "إنشاء المهمة",
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: cs.onPrimary,
                      ),
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

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }
}
