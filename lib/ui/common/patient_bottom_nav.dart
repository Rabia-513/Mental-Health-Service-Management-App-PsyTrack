import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../app/translations.dart';
import '../screens/styles/colors.dart';
import '../../app/routes.dart';

class PatientBottomNav extends StatelessWidget {
  final int selectedIndex;
  final isUrdu = Translations.isUrdu;
   PatientBottomNav({
    super.key,
    required this.selectedIndex,
  });

  void handleNavigation(BuildContext context, int index) {

    if(index == selectedIndex) return;

    switch(index){

      case 0:
        Navigator.pushReplacementNamed(
            context,
            AppRoutes.patSetting
        );
        break;

      case 1:
        print("HISTORY CLICKED ✅");
        Navigator.pushNamed(

              context,
          "/family-history",
              arguments: {
                "patientUid": FirebaseAuth.instance.currentUser!.uid,
              },
        );

        break;

      case 2:
        Navigator.pushReplacementNamed(
            context,
            AppRoutes.patientDashboard
        );
        break;

      case 3:
        Navigator.pushReplacementNamed(
            context,
            AppRoutes.appointments
        );
        break;

      case 4:
        Navigator.pushReplacementNamed(
            context,
            AppRoutes.patientProfile
        );
        break;

    }
  }

  Widget bottomNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
  }) {

    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => handleNavigation(context,index),
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

          /// MAIN NAV BAR
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
                    context: context,
                    icon: Icons.settings,
                    label: isUrdu ? "ترتیبات" : "Settings",
                    index: 0,
                  ),

                  bottomNavItem(
                    context: context,
                    icon: Icons.history,
                    label: isUrdu ? "ہسٹری" : "History",
                    index: 1,
                  ),

                  bottomNavItem(
                    context: context,
                    icon: Icons.calendar_today,
                    label: isUrdu ? "اپائنٹمنٹس" : "Appointments",
                    index: 3,
                  ),

                  bottomNavItem(
                    context: context,
                    icon: Icons.person_outline,
                    label: isUrdu ? "پروفائل" : "Profile",
                    index: 4,
                  ),
                ],
              ),
            ),
          ),

          /// FLOATING HOME BUTTON
          Positioned(
            top: -5,
            child: GestureDetector(
              onTap: () => handleNavigation(context,2),
              child: Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: selectedIndex == 2
                      ? AppColors.primary
                      : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
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