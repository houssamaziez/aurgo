import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TripsHistoryScreen extends StatefulWidget {
  const TripsHistoryScreen({super.key});

  @override
  State<TripsHistoryScreen> createState() => _TripsHistoryScreenState();
}

class _TripsHistoryScreenState extends State<TripsHistoryScreen> {
  String selectedFilter = "الكل";

  final List<Map<String, dynamic>> trips = [
    {
      "pickup": "الرياض - العليا",
      "destination": "الدمام - الكورنيش",
      "date": "2025-09-01 14:30",
      "price": 150.0,
      "status": "مكتملة",
    },
    {
      "pickup": "جدة - السلامة",
      "destination": "مكة - الحرم",
      "date": "2025-08-29 09:15",
      "price": 80.0,
      "status": "ملغاة",
    },
    {
      "pickup": "الدمام - الواجهة البحرية",
      "destination": "الخبر - الراكة",
      "date": "2025-08-25 18:20",
      "price": 60.0,
      "status": "جارية",
    },
  ];

  List<Map<String, dynamic>> get filteredTrips {
    if (selectedFilter == "الكل") return trips;
    return trips.where((trip) => trip["status"] == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cs.surface,
        centerTitle: true,
        title: Text(
          "سجل الرحلات",
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: cs.primary,
          ),
        ),
      ),
      body: Column(
        children: [
          // شريط الفلترة
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              height: 45,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterButton("الكل"),
                  const SizedBox(width: 8),
                  _buildFilterButton("مكتملة"),
                  const SizedBox(width: 8),
                  _buildFilterButton("ملغاة"),
                  const SizedBox(width: 8),
                  _buildFilterButton("جارية"),
                ],
              ),
            ),
          ),
          const Divider(height: 0),

          // قائمة الرحلات
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filteredTrips.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final trip = filteredTrips[index];
                return _buildTripCard(trip, cs);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String filter) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = selectedFilter == filter;

    return GestureDetector(
      onTap: () => setState(() => selectedFilter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surfaceVariant,
          borderRadius: BorderRadius.circular(30),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                  : [],
        ),
        child: Text(
          filter,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip, ColorScheme cs) {
    Color statusColor;
    IconData statusIcon;

    switch (trip["status"]) {
      case "مكتملة":
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case "ملغاة":
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.timelapse;
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // العنوانين
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: cs.primary, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    trip["pickup"],
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.flag, color: cs.secondary, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    trip["destination"],
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // تفاصيل الرحلة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTripDetail(Icons.calendar_today, trip["date"], cs),
                _buildTripDetail(
                  Icons.attach_money,
                  "${trip["price"]} ر.س",
                  cs,
                ),
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 22),
                    const SizedBox(width: 5),
                    Text(
                      trip["status"],
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripDetail(IconData icon, String text, ColorScheme cs) {
    return Row(
      children: [
        Icon(icon, color: cs.primary, size: 18),
        const SizedBox(width: 5),
        Text(
          text,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
