import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TaskTrackingScreen extends StatefulWidget {
  const TaskTrackingScreen({super.key});

  @override
  State<TaskTrackingScreen> createState() => _TaskTrackingScreenState();
}

class _TaskTrackingScreenState extends State<TaskTrackingScreen> {
  late GoogleMapController _mapController;
  final LatLng _taskLocation = const LatLng(24.7136, 46.6753); // موقع الرياض
  String taskStatus = "قيد التنفيذ";

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "متابعة المهمة",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // خريطة المهمة
          SizedBox(
            height: 250,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _taskLocation,
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("taskLocation"),
                  position: _taskLocation,
                  infoWindow: const InfoWindow(title: "موقع التسليم"),
                ),
              },
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان المهمة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "توصيل طرد إلى حي النفل",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text(
                          taskStatus,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: cs.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // بيانات المرسل والمستلم
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            title: "المرسل",
                            value: "شركة المتاجر",
                            icon: Icons.store_mall_directory,
                          ),
                          const Divider(),
                          _buildInfoRow(
                            title: "المستلم",
                            value: "أحمد محمد",
                            icon: Icons.person,
                          ),
                          const Divider(),
                          _buildInfoRow(
                            title: "رقم المستلم",
                            value: "+966 55 123 4567",
                            icon: Icons.phone,
                          ),
                          const Divider(),
                          _buildInfoRow(
                            title: "سعر التوصيل",
                            value: "45 ر.س",
                            icon: Icons.attach_money,
                          ),
                          const Divider(),
                          _buildInfoRow(
                            title: "الوقت المتبقي",
                            value: "15 دقيقة",
                            icon: Icons.timer,
                            valueColor: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // أزرار التحكم
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            setState(() {
                              taskStatus = "تم التسليم";
                            });
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text(
                            "إتمام المهمة",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            // الاتصال بالعميل
                          },
                          icon: const Icon(Icons.phone),
                          label: const Text(
                            "اتصال",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      // بدء محادثة مع العميل
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text(
                      "محادثة مع العميل",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String title,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }
}
