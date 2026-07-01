import 'package:flutter/material.dart';
import '../screens/styles/colors.dart';


class PsychologistBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const PsychologistBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  Widget bottomNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [

          // MAIN BAR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.text(context).withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  bottomNavItem(
                      icon: Icons.settings,
                      label: "Setting",
                      index: 0),
                  bottomNavItem(
                      icon: Icons.pie_chart,
                      label: "Stats",
                      index: 1),
                  const SizedBox(width: 48),
                  bottomNavItem(
                      icon: Icons.check_box_outlined,
                      label: "Schedule",

                      index: 3),
                  bottomNavItem(
                      icon: Icons.person_outline,
                      label: "Profile",
                      index: 4),
                ],
              ),
            ),
          ),

          // FLOATING HOME
          Positioned(
            top: -5,
            child: GestureDetector(
              onTap: () => onTap(2),
              child: Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: selectedIndex == 2
                      ? AppColors.primary
                      : Colors.white,
                  shape: BoxShape.circle,
                  border:
                  Border.all(color: AppColors.primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.text(context).withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.home,
                  size: 28,
                  color: selectedIndex == 2
                      ? Colors.white
                      : AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
