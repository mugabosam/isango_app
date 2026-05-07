class AuthValidators {
  static final _emailRegex = RegExp(
    r"^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$",
  );

  static const _universityDomains = <String>[
    '.edu',
    '.ac.rw',
    '.ac.uk',
    '.edu.rw',
    'ur.ac.rw',
  ];

  static const int passwordMinLength = 8;
  static final _hasUppercase = RegExp(r'[A-Z]');
  static final _hasSymbol = RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\];/\\`~]');

  static String? fullName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your full name';
    if (v.length < 2) return 'Name is too short';
    if (v.length > 60) return 'Name is too long';
    if (!RegExp(r"^[A-Za-zÀ-ÿ' \-]+$").hasMatch(v)) {
      return 'Use letters, spaces, hyphens or apostrophes only';
    }
    return null;
  }

  static String? universityEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your university email';
    if (v.length > 254) return 'Email is too long';
    if (!_emailRegex.hasMatch(v)) {
      return 'Please enter a valid university email address';
    }
    final lower = v.toLowerCase();
    final isUniversity = _universityDomains.any(lower.endsWith);
    if (!isUniversity) {
      return 'Please enter a valid university email address';
    }
    return null;
  }

  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    return null;
  }

  static String? signUpPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Please create a password';
    final rules = passwordRules(v);
    if (!rules.allMet) return 'Password does not meet the requirements';
    return null;
  }

  static PasswordRules passwordRules(String value) {
    return PasswordRules(
      hasMinLength: value.length >= passwordMinLength,
      hasUppercase: _hasUppercase.hasMatch(value),
      hasSymbol: _hasSymbol.hasMatch(value),
    );
  }
}

class PasswordRules {
  const PasswordRules({
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasSymbol,
  });

  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasSymbol;

  bool get allMet => hasMinLength && hasUppercase && hasSymbol;

  PasswordStrength get strength {
    final score = (hasMinLength ? 1 : 0) +
        (hasUppercase ? 1 : 0) +
        (hasSymbol ? 1 : 0);
    return switch (score) {
      0 => PasswordStrength.empty,
      1 => PasswordStrength.weak,
      2 => PasswordStrength.medium,
      _ => PasswordStrength.strong,
    };
  }
}

enum PasswordStrength { empty, weak, medium, strong }
