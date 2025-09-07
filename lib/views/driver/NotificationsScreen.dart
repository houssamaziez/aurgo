import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreenDriver extends StatefulWidget {
  const NotificationsScreenDriver({super.key});

  @override
  State<NotificationsScreenDriver> createState() =>
      _NotificationsScreenDriverState();
}

class _NotificationsScreenDriverState extends State<NotificationsScreenDriver> {
  final List<Map<String, dynamic>> notifications = [
    {
      "title": "رحلتك معتمدة ✅",
      "message": "تم تأكيد رحلتك من وسط المدينة إلى المطار.",
      "time": "منذ 5 دقائق",
      "type": "رحلات",
      "read": false,
    },
    {
      "title": "عرض خاص 🚖",
      "message": "احصل على خصم 20% على رحلتك القادمة.",
      "time": "قبل ساعة",
      "type": "عروض",
      "read": false,
    },
    {
      "title": "تنبيه أمني ⚠️",
      "message": "يرجى تحديث بياناتك للحفاظ على أمان حسابك.",
      "time": "أمس",
      "type": "تنبيهات",
      "read": true,
    },
    {
      "title": "تقييم الرحلة 🌟",
      "message": "لا تنسَ تقييم رحلتك الأخيرة مع السائق محمد.",
      "time": "قبل يومين",
      "type": "رحلات",
      "read": true,
    },
  ];

  void markAllAsRead() {
    setState(() {
      for (var n in notifications) {
        n["read"] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ تم تحديد جميع الإشعارات كمقروءة")),
    );
  }

  void clearAll() {
    setState(() {
      notifications.clear();
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("🗑️ تم حذف جميع الإشعارات")));
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case "عروض":
        return Colors.green;
      case "رحلات":
        return Colors.blue;
      case "تنبيهات":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "الإشعارات",
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: cs.primary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: cs.surface,
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: "تحديد كمقروء",
              onPressed: markAllAsRead,
            ),
          if (notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: "حذف الكل",
              onPressed: clearAll,
            ),
        ],
      ),
      body:
          notifications.isEmpty
              ? _buildEmptyState(cs)
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return _buildNotificationCard(notif, cs);
                },
              ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif, ColorScheme cs) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: notif["read"] ? cs.surfaceVariant : cs.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: _getNotificationColor(
            notif["type"],
          ).withOpacity(0.1),
          child: Icon(
            notif["type"] == "عروض"
                ? Icons.local_offer
                : notif["type"] == "رحلات"
                ? Icons.directions_car
                : Icons.warning,
            color: _getNotificationColor(notif["type"]),
          ),
        ),
        title: Text(
          notif["title"],
          style: GoogleFonts.cairo(
            fontWeight: notif["read"] ? FontWeight.normal : FontWeight.bold,
            fontSize: 16,
            color: cs.onSurface,
          ),
        ),
        subtitle: Text(
          notif["message"],
          style: GoogleFonts.cairo(color: cs.onSurfaceVariant, height: 1.4),
        ),
        trailing: Text(
          notif["time"],
          style: GoogleFonts.cairo(fontSize: 12, color: cs.onSurfaceVariant),
        ),
        onTap: () {
          setState(() {
            notif["read"] = true;
          });
        },
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off, size: 80, color: cs.primary),
            const SizedBox(height: 16),
            Text(
              "لا توجد إشعارات جديدة",
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "ستظهر هنا جميع إشعاراتك حول الرحلات والعروض",
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
