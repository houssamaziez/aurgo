import 'package:aurgo/views/auth/screen/auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentIndex = 0;

  final List<Map<String, String>> _pages = [
    {
      "image": "assets/images/car.png",
      "title": "مرحباً بك في النقل الذكي",
      "subtitle":
          "رحلتك تبدأ هنا... حيث يلتقي الذكاء الاصطناعي بالتجربة الفاخرة",
    },
    {
      "image": "assets/images/car.png",
      "title": "عنوان الصفحة الثانية",
      "subtitle": "الوصف الخاص بالصفحة الثانية",
    },
    {
      "image": "assets/images/car.png",
      "title": "عنوان الصفحة الثالثة",
      "subtitle": "الوصف الخاص بالصفحة الثالثة",
    },
  ];

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < _pages.length - 1) {
      _currentIndex++;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    } else {
      Get.to(FuturisticLoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Futuristic gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.deepPurple.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Car Image
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) {
                          final v = value.clamp(0.0, 1.0);
                          return Transform.translate(
                            offset: Offset(0, (1 - v) * 50),
                            child: Opacity(opacity: v, child: child),
                          );
                        },
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.red.withOpacity(0.3),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundImage: AssetImage(page['image']!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Animated Title
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeInOut,
                        builder: (context, value, child) {
                          final v = value.clamp(0.0, 1.0);
                          return Opacity(
                            opacity: v,
                            child: Transform.translate(
                              offset: Offset(0, 30 * (1 - v)),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          page['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Animated Subtitle
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeInOut,
                        builder: (context, value, child) {
                          final v = value.clamp(0.0, 1.0);
                          return Opacity(
                            opacity: v,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - v)),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          page['subtitle']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Animated Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentIndex == i ? 16 : 10,
                            height: _currentIndex == i ? 16 : 10,
                            decoration: BoxDecoration(
                              color:
                                  _currentIndex == i
                                      ? Colors.redAccent
                                      : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Next Button
            Positioned(
              bottom: 40,
              right: 30,
              child: FloatingActionButton(
                onPressed: _nextPage,
                backgroundColor: Colors.redAccent,
                child: const Icon(Icons.arrow_forward),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
