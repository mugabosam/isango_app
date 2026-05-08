import 'package:flutter/material.dart';
import 'package:isango_app/core/theme/app_colors.dart';
import 'package:isango_app/core/utils/validators.dart';

class PasswordRulesView extends StatelessWidget {
  const PasswordRulesView({super.key, required this.rules});

  final PasswordRules rules;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Rule(label: '8+ characters', met: rules.hasMinLength),
        _Rule(label: 'One symbol', met: rules.hasSymbol),
        _Rule(label: 'One uppercase', met: rules.hasUppercase),
      ],
    );
  }
}

class PasswordStrengthLabel extends StatelessWidget {
  const PasswordStrengthLabel({super.key, required this.strength});

  final PasswordStrength strength;

  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (strength) {
      PasswordStrength.empty => ('', Colors.transparent),
      PasswordStrength.weak => ('Weak', AppColors.criticalRed),
      PasswordStrength.medium => ('Medium', AppColors.safetyOrange),
      PasswordStrength.strong => ('Strong', Color(0xFF1F8A4C)),
    };
    if (text.isEmpty) return const SizedBox.shrink();
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}

class PasswordStrengthBar extends StatelessWidget {
  const PasswordStrengthBar({super.key, required this.strength});

  final PasswordStrength strength;

  static const _emptyColor = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    if (strength == PasswordStrength.empty) {
      return const SizedBox.shrink();
    }

    final (filled, color, label) = switch (strength) {
      PasswordStrength.weak => (1, AppColors.criticalRed, 'Weak'),
      PasswordStrength.medium => (2, AppColors.safetyOrange, 'Medium'),
      PasswordStrength.strong => (3, const Color(0xFF1F8A4C), 'Strong'),
      PasswordStrength.empty => (0, _emptyColor, ''),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (int i = 0; i < 3; i++) ...[
              Expanded(child: _Segment(active: i < filled, color: color)),
              if (i < 2) const SizedBox(width: 6),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.active, required this.color});

  final bool active;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 6,
      decoration: BoxDecoration(
        color: active ? color : PasswordStrengthBar._emptyColor,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.label, required this.met});

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final color = met ? const Color(0xFF1F8A4C) : AppColors.mutedOperationalInk;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: met ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
