import 'package:aurgo/views/driver/AppDrawer.dart';
import 'package:aurgo/views/driver/EarningsDetailsScreen.dart';
import 'package:aurgo/views/driver/NewTaskScreen.dart';
import 'package:aurgo/views/driver/NotificationsScreen.dart';
import 'package:aurgo/views/driver/RatingsScreen.dart';
import 'package:aurgo/views/driver/StatisticsScreen.dart';
import 'package:aurgo/views/driver/SupportScreen.dart';
import 'package:aurgo/views/driver/TaskTrackingScreen.dart';
import 'package:aurgo/views/driver/TasksScreen.dart';
import 'package:aurgo/views/driver/TripsHistoryScreen.dart';
import 'package:flutter/material.dart';

class DriverApp extends StatelessWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2D62F0),
      brightness: Brightness.light,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Driver Dashboard',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF6F8FB),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.zero,
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: DriverDashboardScreen(),
      ),
    );
  }
}

class DriverDashboardScreen extends StatelessWidget {
  const DriverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      drawer: const AppDrawer(
        userName: "محمد علي",
        userEmail: "mohamed@example.com",
        userImage:
            "https://i.pravatar.cc/150?img=3", // صورة افتراضية للملف الشخصي
      ),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'مرحباً، أحمد',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'سائق نشط',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(width: 12),
            const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
            ),
            const SizedBox(width: 12),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.topLeft,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreenDriver(),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              Positioned(
                right: 10,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: cs.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      height: 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          children: [
            // Summary Row
            _SectionTitle(title: 'ملخص اليوم'),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                final isWide = w > 520;
                return Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          // Navigate to Earnings Details Screen
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => const EarningsDetailsScreen(),
                            ),
                          );
                        },
                        child: _StatCard(
                          emoji: '💰',
                          title: 'الأرباح',
                          value: 'ر.س 245',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          // Navigate to Tasks Screen
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const TasksScreen(),
                            ),
                          );
                        },
                        child: _StatCard(
                          emoji: '📦',
                          title: 'المهام',
                          value: '5 مهام',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (isWide)
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            // Navigate to Ratings Screen
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const RatingsScreen(),
                              ),
                            );
                          },
                          child: _StatCard(
                            emoji: '⭐',
                            title: 'التقييم',
                            value: '4.8/5',
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            // Last stat in narrow width
            LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                if (w > 520) return const SizedBox.shrink();
                return Column(
                  children: [
                    const _Gap(12),
                    InkWell(
                      onTap: () {
                        // Navigate to Ratings Screen
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RatingsScreen(),
                          ),
                        );
                      },
                      child: const _StatCard(
                        emoji: '⭐',
                        title: 'التقييم',
                        value: '4.8/5',
                      ),
                    ),
                  ],
                );
              },
            ),

            const _Gap(20),
            _SectionTitle(title: 'المهام الحالية'),
            const _Gap(12),
            _CurrentTaskCard(
              title: 'توصيل طرد',
              subtitle: 'إلى حي الملز',
              timeLabel: 'الوقت المتبقي',
              timeValue: '15 دقيقة',
              badgeIcon: Icons.card_giftcard_rounded,
              onFollowUp: () {
                // Navigate to Tasks Screen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TaskTrackingScreen(),
                  ),
                );
              },
            ),

            const _Gap(24),
            _SectionTitle(title: 'الإجراءات السريعة'),
            _Gap(12),
            _QuickActionsGrid(
              actions: [
                _QuickAction(
                  label: 'الإحصائيات',
                  onTap: () {
                    // Navigate to Statistics Screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const StatisticsScreen(),
                      ),
                    );
                  },
                  icon: Icons.bar_chart_rounded,
                  tint: const Color(0xFFEAE2FF),
                ),
                _QuickAction(
                  onTap: () {
                    // Navigate to Tasks Screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NewTaskScreen(),
                      ),
                    );
                  },
                  label: 'مهمة جديدة',
                  icon: Icons.add_rounded,
                  tint: Color(0xFFE8FFF0),
                ),
                _QuickAction(
                  label: 'سجل الرحلات',
                  onTap: () {
                    // Navigate to Tasks Screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TripsHistoryScreen(),
                      ),
                    );
                  },
                  icon: Icons.rotate_left_rounded,
                  tint: Color(0xFFFFF1E5),
                ),
                _QuickAction(
                  label: 'الدعم الفني',
                  onTap: () {
                    // Navigate to Support Screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SupportScreenDriver(),
                      ),
                    );
                  },
                  icon: Icons.headset_mic_rounded,
                  tint: Color(0xFFFFECEE),
                ),
              ],
            ),

            const _Gap(24),
            _SectionTitle(title: 'الخريطة'),
            const _Gap(12),
            _MapCard(),

            const _Gap(12),
            _StatusTile(
              statusText: 'متصل',
              detail: 'موقعك الحالي\nشارع الملك فهد، الرياض',
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String value;

  const _StatCard({
    required this.emoji,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentTaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String timeLabel;
  final String timeValue;
  final IconData badgeIcon;
  final VoidCallback onFollowUp;

  const _CurrentTaskCard({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.timeValue,
    required this.badgeIcon,
    required this.onFollowUp,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$title  ',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(badgeIcon, color: cs.primary),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: '$timeLabel  ',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      children: [
                        TextSpan(
                          text: timeValue,
                          style: TextStyle(
                            color: const Color(0xFFE65100),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onFollowUp,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'متابعة المهمة',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color tint;
  final void Function()? onTap;
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.tint,
    required this.onTap,
  });
}

class _QuickActionsGrid extends StatelessWidget {
  final List<_QuickAction> actions;
  const _QuickActionsGrid({required this.actions});

  @override
  Widget build(BuildContext context) {
    final cross = MediaQuery.sizeOf(context).width > 520 ? 4 : 2;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cross,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 110,
      ),
      itemBuilder: (context, i) {
        final a = actions[i];
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (a.onTap != null) {
                a.onTap!();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: a.tint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(a.icon),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        a.label,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MapCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // خريطة تجريبية بصورة ثابتة — استبدلها بـ GoogleMap/Mapbox عند الربط الحقيقي
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              'https://maps.googleapis.com/maps/api/staticmap?center=24.7136,46.6753&zoom=13&size=800x450&maptype=roadmap&markers=color:blue%7C24.7136,46.6753',
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) {
                return Container(
                  color: const Color(0xFFEFF3F8),
                  alignment: Alignment.center,
                  child: const Icon(Icons.map_rounded, size: 56),
                );
              },
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.my_location_rounded),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: _MiniStatusBar(color: cs.primary),
          ),
        ],
      ),
    );
  }
}

class _MiniStatusBar extends StatelessWidget {
  final Color color;
  const _MiniStatusBar({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        children: [
          const SizedBox(width: 6),
          Container(
            height: 6,
            width: 6,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: color.withOpacity(.25),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  final String statusText;
  final String detail;

  const _StatusTile({required this.statusText, required this.detail});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
      leading: const Icon(Icons.circle, color: Colors.green, size: 12),
      title: Text(
        'موقعك الحالي',
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        detail,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
      ),
      trailing: Text(
        statusText,
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Gap extends StatelessWidget {
  final double h;
  const _Gap(this.h);

  @override
  Widget build(BuildContext context) => SizedBox(height: h);
}
