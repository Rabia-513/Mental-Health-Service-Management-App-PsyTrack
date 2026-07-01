import 'package:flutter/material.dart';
import '../../../app/app_constants.dart';
import '../styles/colors.dart';
import '../styles/text_styles.dart';
import '../widgets/custom_button.dart';
import '../../../app/routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.accent,
          image: DecorationImage(
            image: AssetImage("assets/background/icons.png"),
            fit: BoxFit.cover,
            repeat: ImageRepeat.repeat,
            opacity: 0.15,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 20),

              /// LOGO + TEXT
              Column(
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    height: 150,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Good to have you here!",
                    style: AppTextStyles.welcomeText,
                    textAlign: TextAlign.center,
                  ),

                ],
              ),

              /// BUTTONS
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: CustomButton(
                      text: "I already have an account",
                      isPrimary: true,
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: CustomButton(
                      text: "Let's get started",
                      isPrimary: false,
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.roleSelection);
                      },
                    ),
                  ),
                ],
              ),

              /// FOOTER
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  AppConstants.privacyText,
                  style: AppTextStyles.small.copyWith(
                    fontSize: 12,
                    color: AppColors.text(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
