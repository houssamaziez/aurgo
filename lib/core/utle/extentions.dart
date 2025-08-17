import 'package:flutter/material.dart';

extension GradientScaffold on Scaffold {
  Scaffold withGradientBackground(List<Color> colors) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: this.body,
      ),
    );
  }
}
