import 'package:flutter/material.dart';

class BackgroundWrapper extends StatelessWidget {
  final Widget child;
  final String? imagePath;
  final double opacity;

  const BackgroundWrapper({
    super.key,
    required this.child,
    this.imagePath,
    this.opacity = 0.18,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null) {
      return child; // ❗ No background
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            imagePath!,
            fit: BoxFit.cover,
            opacity: AlwaysStoppedAnimation(opacity),
          ),
        ),
        child,
      ],
    );
  }
}
