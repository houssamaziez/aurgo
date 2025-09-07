import 'package:flutter/material.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> tasks = [
    {
      "title": "توصيل طرد",
      "subtitle": "إلى حي الملز",
      "status": "جارية",
      "time": "12:30 م",
      "icon": Icons.card_giftcard_rounded,
    },
    {
      "title": "استلام شحنة",
      "subtitle": "من شارع التحلية",
      "status": "مكتملة",
      "time": "09:15 ص",
      "icon": Icons.inventory_2_rounded,
    },
    {
      "title": "توصيل طعام",
      "subtitle": "إلى حي النرجس",
      "status": "ملغاة",
      "time": "08:10 ص",
      "icon": Icons.fastfood_rounded,
    },
    {
      "title": "توصيل طرد",
      "subtitle": "إلى حي الروابي",
      "status": "جارية",
      "time": "01:45 م",
      "icon": Icons.local_shipping_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "المهام",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          indicatorColor: cs.primary,
          tabs: const [
            Tab(text: "الكل"),
            Tab(text: "جارية"),
            Tab(text: "مكتملة"),
            Tab(text: "ملغاة"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTasksList("الكل"),
          _buildTasksList("جارية"),
          _buildTasksList("مكتملة"),
          _buildTasksList("ملغاة"),
        ],
      ),
    );
  }

  Widget _buildTasksList(String filter) {
    final filteredTasks =
        filter == "الكل"
            ? tasks
            : tasks.where((t) => t["status"] == filter).toList();

    if (filteredTasks.isEmpty) {
      return const Center(
        child: Text(
          "لا توجد مهام حالياً",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        return _TaskCard(
          title: task["title"],
          subtitle: task["subtitle"],
          status: task["status"],
          time: task["time"],
          icon: task["icon"],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TaskDetailsScreen(task: task)),
            );
          },
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final String time;
  final IconData icon;
  final VoidCallback onTap;

  const _TaskCard({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.time,
    required this.icon,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (status) {
      case "جارية":
        return Colors.blue;
      case "مكتملة":
        return Colors.green;
      case "ملغاة":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _getStatusColor()),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              status,
              style: TextStyle(
                color: _getStatusColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("تفاصيل المهمة"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  task["title"],
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  task["subtitle"],
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      "الوقت: ${task["time"]}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.flag, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      "الحالة: ${task["status"]}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            task["status"] == "جارية"
                                ? Colors.blue
                                : task["status"] == "مكتملة"
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: cs.primary,
                    ),
                    onPressed: () {},
                    child: const Text(
                      "بدء المهمة",
                      style: TextStyle(fontWeight: FontWeight.bold),
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
}
