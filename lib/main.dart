import 'package:aurgo/views/driver/home.dart';
import 'package:aurgo/views/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

import 'views/auth/screen/auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: FuturisticLoginScreen(),
    );
  }
}
