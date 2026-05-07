import 'package:flutter/material.dart';
import 'package:isango_app/core/theme/app_colors.dart';

class FormBannerAction {
  const FormBannerAction({required this.label, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;
}

class FormBanner extends StatelessWidget {
  const FormBanner({
    super.key,
    required this.message,
    this.action,
  });

  final String message;
  final FormBannerAction? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDEC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.criticalRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            size: 18,
            color: AppColors.criticalRed,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.criticalRed,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: action!.onPressed,
              child: Text(
                action!.label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.commandBlue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
