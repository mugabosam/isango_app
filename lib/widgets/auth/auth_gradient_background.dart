import 'package:flutter/material.dart';

class AuthGradientBackground extends StatelessWidget {
  const AuthGradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB6C4F4),
            Color(0xFFE9C8E0),
            Color(0xFFF6C7A6),
          ],
        ),
      ),
      child: child,
    );
  }
}
