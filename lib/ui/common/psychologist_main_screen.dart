import 'package:flutter/material.dart';
import 'psychologist_bottom_nav.dart';

class PsychologistMainScreen extends StatefulWidget {
  final Widget child;
  final int selectedIndex;

  const PsychologistMainScreen({
    super.key,
    required this.child,
    required this.selectedIndex,
  });

  @override
  State<PsychologistMainScreen> createState() => _PsychologistMainScreenState();
}

class _PsychologistMainScreenState extends State<PsychologistMainScreen> {

  void onTabTapped(int index) {

    switch (index) {

      case 0:
        Navigator.pushReplacementNamed(context, "/psySetting");
        break;

      case 1:
        Navigator.pushReplacementNamed(context, "/statsPatients");
        break;

      case 2:
        Navigator.pushReplacementNamed(context, "/psychologist-dashboard");
        break;

      case 3:
        Navigator.pushReplacementNamed(context, "/psychologistSchedule");
        break;

      case 4:
        Navigator.pushReplacementNamed(context, "/psychologist-profile");
        break;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,

      bottomNavigationBar: PsychologistBottomNav(
        selectedIndex: widget.selectedIndex,
        onTap: onTabTapped,
      ),
    );
  }
}