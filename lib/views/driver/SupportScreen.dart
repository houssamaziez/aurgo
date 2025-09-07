import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SupportScreenDriver extends StatefulWidget {
  const SupportScreenDriver({super.key});

  @override
  State<SupportScreenDriver> createState() => _SupportScreenDriverState();
}

class _SupportScreenDriverState extends State<SupportScreenDriver> {
  final TextEditingController messageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final List<Map<String, String>> faqs = [
    {
      "question": "كيف يمكنني حجز رحلة؟",
      "answer":
          "يمكنك حجز رحلة بسهولة عبر اختيار نقطة الانطلاق والوجهة ثم تأكيد الحجز.",
    },
    {
      "question": "كيف يمكنني إلغاء الرحلة؟",
      "answer":
          "يمكنك إلغاء الرحلة قبل تأكيد السائق عليها من خلال شاشة سجل الرحلات.",
    },
    {
      "question": "ما هي طرق الدفع المتاحة؟",
      "answer": "نوفر الدفع النقدي وبطاقات الائتمان والمحافظ الإلكترونية.",
    },
  ];

  final List<bool> faqExpanded = [];

  @override
  void initState() {
    super.initState();
    faqExpanded.addAll(List.generate(faqs.length, (_) => false));
  }

  void _sendMessage() {
    if (messageController.text.isEmpty || emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء إدخال البريد والرسالة")),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("✅ تم إرسال رسالتك بنجاح")));

    messageController.clear();
    emailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "الدعم الفني",
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: cs.primary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: cs.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // قسم الأسئلة الشائعة
            _buildSectionTitle("الأسئلة الشائعة", cs),
            const SizedBox(height: 8),
            _buildFAQList(cs),
            const SizedBox(height: 24),

            // قسم نموذج التواصل
            _buildSectionTitle("تواصل معنا", cs),
            const SizedBox(height: 8),
            _buildContactForm(cs),
            const SizedBox(height: 24),

            // أزرار التواصل السريع
            _buildSectionTitle("خيارات سريعة", cs),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickActionButton(
                  icon: Icons.call,
                  label: "اتصال هاتفي",
                  color: Colors.green,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("📞 جاري الاتصال بالدعم..."),
                      ),
                    );
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.chat,
                  label: "محادثة مباشرة",
                  color: cs.primary,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("💬 فتح المحادثة المباشرة")),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme cs) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: cs.onSurface,
        ),
      ),
    );
  }

  Widget _buildFAQList(ColorScheme cs) {
    return ExpansionPanelList(
      expandedHeaderPadding: EdgeInsets.zero,
      expansionCallback: (index, isExpanded) {
        setState(() {
          faqExpanded[index] = !isExpanded;
        });
      },
      children:
          faqs.asMap().entries.map((entry) {
            final index = entry.key;
            final faq = entry.value;

            return ExpansionPanel(
              backgroundColor: cs.surfaceVariant,
              isExpanded: faqExpanded[index],
              headerBuilder: (context, isExpanded) {
                return ListTile(
                  title: Text(
                    faq["question"]!,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                );
              },
              body: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  faq["answer"]!,
                  style: GoogleFonts.cairo(
                    color: cs.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildContactForm(ColorScheme cs) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "البريد الإلكتروني",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "رسالتك",
                prefixIcon: Icon(Icons.message),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send),
                label: const Text("إرسال"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: cs.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 22),
      label: Text(label, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
