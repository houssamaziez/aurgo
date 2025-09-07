import 'package:flutter/material.dart';

Widget buildOptionCard({
  required Color color,
  required IconData icon,
  required String title,
  required String subtitle,
  required int index,
  required Function onTap,
}) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: Duration(milliseconds: 500 + index * 150),
    curve: Curves.easeOutBack,
    builder: (context, value, child) {
      final v = value.clamp(0.0, 1.0);
      return Transform.translate(
        offset: Offset(0, (1 - v) * 50),
        child: Opacity(opacity: v, child: child),
      );
    },
    child: GestureDetector(
      onTap: () => onTap(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.6), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white12,
              child: Icon(icon, color: Colors.cyanAccent, size: 25),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );
}
