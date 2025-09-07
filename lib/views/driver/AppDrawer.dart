import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userImage;

  const AppDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userImage,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(cs),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.home,
                  title: "الرئيسية",
                  color: cs.primary,
                  onTap: () => _navigate(context, "home"),
                ),
                _buildDrawerItem(
                  icon: Icons.history,
                  title: "سجل الرحلات",
                  color: Colors.orange,
                  onTap: () => _navigate(context, "trips"),
                ),
                _buildDrawerItem(
                  icon: Icons.notifications,
                  title: "الإشعارات",
                  color: Colors.blue,
                  onTap: () => _navigate(context, "notifications"),
                ),
                _buildDrawerItem(
                  icon: Icons.star,
                  title: "التقييمات",
                  color: Colors.amber,
                  onTap: () => _navigate(context, "ratings"),
                ),
                _buildDrawerItem(
                  icon: Icons.support_agent,
                  title: "الدعم الفني",
                  color: Colors.green,
                  onTap: () => _navigate(context, "support"),
                ),
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: "الإعدادات",
                  color: Colors.grey,
                  onTap: () => _navigate(context, "settings"),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("🚪 تم تسجيل الخروج بنجاح")),
                );
              },
              icon: const Icon(Icons.logout),
              label: Text(
                "تسجيل الخروج",
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme cs) {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: const BorderRadius.only(topRight: Radius.circular(28)),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: NetworkImage(userImage),
      ),
      accountName: Text(
        userName,
        style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      accountEmail: Text(userEmail, style: GoogleFonts.cairo(fontSize: 14)),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }

  void _navigate(BuildContext context, String route) {
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("📍 تم الانتقال إلى: $route")));
  }
}
