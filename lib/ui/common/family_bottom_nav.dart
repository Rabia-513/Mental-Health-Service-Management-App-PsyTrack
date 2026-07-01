import 'package:flutter/material.dart';
import '../../app/translations.dart';
import '../screens/styles/colors.dart';
import '../../app/routes.dart';

class FamilyBottomNav extends StatelessWidget {
  final int selectedIndex;
  final isUrdu = Translations.isUrdu;
FamilyBottomNav({
    super.key,
    required this.selectedIndex,
  });

  void _onTap(BuildContext context, int index) {

    if (index == selectedIndex) return;

    switch (index) {

      case 0:
        Navigator.pushNamed(context, "/family-settings");
        break;

      case 1:
        Navigator.pushNamed(context, "/family-history"); // ✅ FIXED
        break;

      case 2:
        Navigator.pushNamed(context, "/family-dashboard");
        break;

      case 3:
        Navigator.pushNamed(context, "/family-schedule");
        break;

      case 4:
        Navigator.pushNamed(context, "/family-profile");
        break;
    }
  }
  Widget item(
      BuildContext context,
      int index,
      IconData icon,
      String label,
      ) {
    final bool active = selectedIndex == index;

    return InkWell(
      onTap: () => _onTap(context, index),
      borderRadius: BorderRadius.circular(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: active ? AppColors.primary : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary),
            ),
            child: Icon(
              icon,
              color: active ? Colors.white : AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [


            item(context, 0, Icons.settings, isUrdu ? "ترتیبات" : "Settings"),
        item(context, 1, Icons.history, isUrdu ? "ہسٹری" : "History"),
        const SizedBox(width: 40),
        item(context, 3, Icons.calendar_today, isUrdu ? "اپائنٹمنٹس" : "Appointments"),
        item(context, 4, Icons.person, isUrdu ? "پروفائل" : "Profile"),
              ],
            ),
          ),
          Positioned(
            top: -1,
            child: GestureDetector(
              onTap: () => _onTap(context, 2),
              child: Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.home, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}