import 'package:flutter/material.dart';
import 'package:isango_app/core/constants/app_routes.dart';
import 'package:isango_app/core/theme/app_colors.dart';
import 'package:isango_app/widgets/auth/primary_button.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.logisticsNavy,
                    ),
                    child: const Icon(
                      Icons.mark_email_read_outlined,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Verify your email',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.nearBlackInk,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We sent a verification link to your university email. '
                    'Open it to finish setting up your account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.mutedOperationalInk,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  PrimaryButton(
                    label: 'Back to log in',
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.login),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
