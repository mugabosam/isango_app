import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isango_app/core/auth/auth_exception.dart';
import 'package:isango_app/core/auth/mock_auth_repository.dart';
import 'package:isango_app/core/constants/app_routes.dart';
import 'package:isango_app/core/theme/app_colors.dart';
import 'package:isango_app/core/utils/validators.dart';
import 'package:isango_app/widgets/auth/form_banner.dart';
import 'package:isango_app/widgets/auth/password_rules_view.dart';
import 'package:isango_app/widgets/auth/primary_button.dart';

typedef SignUpHandler = Future<void> Function({
  required String fullName,
  required String email,
  required String password,
});

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, this.onSignUp});

  final SignUpHandler? onSignUp;

  static const fullNameFieldKey = Key('signup-full-name-field');
  static const emailFieldKey = Key('signup-email-field');
  static const passwordFieldKey = Key('signup-password-field');
  static const confirmFieldKey = Key('signup-confirm-field');
  static const submitButtonKey = Key('signup-submit');
  static const loginLinkKey = Key('signup-login-link');
  static const backButtonKey = Key('signup-back');

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _submitting = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;
  String? _serverError;
  bool _showSignInHint = false;
  PasswordRules _rules = const PasswordRules(
    hasMinLength: false,
    hasUppercase: false,
    hasSymbol: false,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String value) {
    setState(() => _rules = AuthValidators.passwordRules(value));
    _clearServerError();
  }

  void _clearServerError() {
    if (_serverError != null || _showSignInHint) {
      setState(() {
        _serverError = null;
        _showSignInHint = false;
      });
    }
  }

  String? _confirmValidator(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _defaultSignUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await MockAuthRepository.instance.signUp(
      fullName: fullName,
      email: email,
      password: password,
    );
  }

  Future<void> _onSubmit() async {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }

    setState(() {
      _submitting = true;
      _serverError = null;
      _showSignInHint = false;
    });

    final handler = widget.onSignUp ?? _defaultSignUp;

    try {
      await handler(
        fullName: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.verifyEmail);
    } on EmailAlreadyInUseException catch (e) {
      if (!mounted) return;
      setState(() {
        _serverError = e.message;
        _showSignInHint = true;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _serverError = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          key: SignUpScreen.backButtonKey,
          icon: const Icon(Icons.arrow_back, color: AppColors.nearBlackInk),
          tooltip: 'Back',
          onPressed: _submitting ? null : _goToLogin,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autovalidate,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _UniversityLogo(),
                      const SizedBox(height: 24),
                      const Text(
                        'Create your Isango account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.nearBlackInk,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Join the campus community to discover and share '
                        'student events.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.mutedOperationalInk,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 22),
                      if (_serverError != null) ...[
                        FormBanner(
                          message: _serverError!,
                          action: _showSignInHint
                              ? FormBannerAction(
                                  label: 'Sign In',
                                  onPressed: _submitting ? null : _goToLogin,
                                )
                              : null,
                        ),
                        const SizedBox(height: 14),
                      ],
                      _MinimalField(
                        fieldKey: SignUpScreen.fullNameFieldKey,
                        controller: _nameController,
                        hint: 'Display name',
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(60),
                        ],
                        enabled: !_submitting,
                        validator: AuthValidators.fullName,
                        onChanged: (_) => _clearServerError(),
                      ),
                      const SizedBox(height: 10),
                      _MinimalField(
                        fieldKey: SignUpScreen.emailFieldKey,
                        controller: _emailController,
                        hint: 'University email',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [
                          AutofillHints.username,
                          AutofillHints.email,
                        ],
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          LengthLimitingTextInputFormatter(254),
                        ],
                        autocorrect: false,
                        enableSuggestions: false,
                        enabled: !_submitting,
                        validator: AuthValidators.universityEmail,
                        onChanged: (_) => _clearServerError(),
                      ),
                      const SizedBox(height: 10),
                      _MinimalField(
                        fieldKey: SignUpScreen.passwordFieldKey,
                        controller: _passwordController,
                        hint: 'Password',
                        obscureText: _obscurePassword,
                        enableSuggestions: false,
                        autocorrect: false,
                        enabled: !_submitting,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(128),
                        ],
                        validator: AuthValidators.signUpPassword,
                        onChanged: _onPasswordChanged,
                        suffix: IconButton(
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: AppColors.mutedOperationalInk,
                          ),
                          tooltip: _obscurePassword ? 'Show' : 'Hide',
                        ),
                      ),
                      const SizedBox(height: 10),
                      _MinimalField(
                        fieldKey: SignUpScreen.confirmFieldKey,
                        controller: _confirmController,
                        hint: 'Confirm password',
                        obscureText: _obscureConfirm,
                        enableSuggestions: false,
                        autocorrect: false,
                        enabled: !_submitting,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.newPassword],
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(128),
                        ],
                        validator: _confirmValidator,
                        onFieldSubmitted: (_) => _onSubmit(),
                        suffix: IconButton(
                          onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: AppColors.mutedOperationalInk,
                          ),
                          tooltip: _obscureConfirm ? 'Show' : 'Hide',
                        ),
                      ),
                      const SizedBox(height: 14),
                      PasswordStrengthBar(strength: _rules.strength),
                      const SizedBox(height: 18),
                      PrimaryButton(
                        key: SignUpScreen.submitButtonKey,
                        label: 'Create Account',
                        loading: _submitting,
                        onPressed: _submitting ? null : _onSubmit,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'We’ll send a verification link to your university '
                        'email next.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedOperationalInk,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.softBorder)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account? ',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.mutedOperationalInk,
                  ),
                ),
                GestureDetector(
                  key: SignUpScreen.loginLinkKey,
                  onTap: _submitting ? null : _goToLogin,
                  child: const Text(
                    'Log in',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.commandBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UniversityLogo extends StatelessWidget {
  const _UniversityLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.logisticsNavy,
          ),
          child: const Icon(
            Icons.school_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Isango',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: AppColors.logisticsNavy,
          ),
        ),
      ],
    );
  }
}

class _MinimalField extends StatelessWidget {
  const _MinimalField({
    this.fieldKey,
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.enabled = true,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.suffix,
  });

  final Key? fieldKey;
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled;
  final bool enableSuggestions;
  final bool autocorrect;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      enabled: enabled,
      enableSuggestions: enableSuggestions,
      autocorrect: autocorrect,
      style: const TextStyle(fontSize: 14, color: AppColors.nearBlackInk),
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffix,
      ),
    );
  }
}
