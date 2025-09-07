import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

class RatingsScreen extends StatelessWidget {
  const RatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final double averageRating = 4.3;
    final int totalRatings = 128;

    final List<Map<String, dynamic>> ratingDistribution = [
      {"stars": 5, "count": 80},
      {"stars": 4, "count": 30},
      {"stars": 3, "count": 10},
      {"stars": 2, "count": 5},
      {"stars": 1, "count": 3},
    ];

    final List<Map<String, dynamic>> reviews = [
      {
        "name": "محمد أحمد",
        "avatar":
            "https://ui-avatars.com/api/?name=محمد+أحمد&background=0D8ABC&color=fff",
        "rating": 5.0,
        "comment": "خدمة رائعة وسرعة في التوصيل 👌",
        "date": DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        "name": "سارة خالد",
        "avatar":
            "https://ui-avatars.com/api/?name=سارة+خالد&background=F48FB1&color=fff",
        "rating": 4.0,
        "comment": "جيد جدًا لكن يمكن تحسين وقت الانتظار.",
        "date": DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        "name": "أحمد العلي",
        "avatar":
            "https://ui-avatars.com/api/?name=أحمد+العلي&background=4CAF50&color=fff",
        "rating": 3.0,
        "comment": "الخدمة متوسطة والتأخير كان واضح للأسف.",
        "date": DateTime.now().subtract(const Duration(days: 4)),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "التقييمات",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // متوسط التقييم
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // التقييم الكبير
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            averageRating.toStringAsFixed(1),
                            style: Theme.of(
                              context,
                            ).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          RatingBarIndicator(
                            rating: averageRating,
                            itemBuilder:
                                (context, index) =>
                                    Icon(Icons.star, color: cs.primary),
                            itemCount: 5,
                            itemSize: 28,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "$totalRatings تقييم",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // توزيع التقييمات
                    Expanded(
                      flex: 4,
                      child: Column(
                        children:
                            ratingDistribution.map((item) {
                              final percentage = (item["count"] / totalRatings)
                                  .clamp(0.0, 1.0);
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "${item["stars"]}★",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: LinearProgressIndicator(
                                          value: percentage,
                                          backgroundColor: Colors.grey.shade300,
                                          color: cs.primary,
                                          minHeight: 8,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "${item["count"]}",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // قائمة التقييمات
            Expanded(
              child: ListView.builder(
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(review["avatar"]),
                      ),
                      title: Text(
                        review["name"],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RatingBarIndicator(
                            rating: review["rating"],
                            itemBuilder:
                                (context, index) =>
                                    Icon(Icons.star, color: cs.primary),
                            itemCount: 5,
                            itemSize: 18,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            review["comment"],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      trailing: Text(
                        DateFormat("dd MMM").format(review["date"]),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
