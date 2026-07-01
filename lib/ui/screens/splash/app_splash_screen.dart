import 'dart:async';
import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../styles/colors.dart';

class AppSplashScreen extends StatefulWidget {
  const AppSplashScreen({super.key});

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen> {
  double opacity = 0;

  @override
  void initState() {
    super.initState();

    // Fade animation
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        opacity = 1;
      });
    });

    // Navigate after 3 seconds
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accent,
      body: Center(
        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(seconds: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Logo
              Image.asset(
                "assets/images/logo.png",
                height: 120,
              ),

              const SizedBox(height: 20),

              // PSYTRACK styled text
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "PSY",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2A5A), // dark blue
                        letterSpacing: 2,
                      ),
                    ),
                    TextSpan(
                      text: "TRACK",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1AA39A), // teal
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Tagline (2 lines like image)
              const Text(
                "Connecting Psychologists, Patients, and Care\n– Digitally",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}