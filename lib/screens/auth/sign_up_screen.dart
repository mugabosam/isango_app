import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isango_app/core/auth/auth_exception.dart';
import 'package:isango_app/core/auth/mock_auth_repository.dart';
import 'package:isango_app/core/constants/app_routes.dart';
import 'package:isango_app/core/theme/app_colors.dart';
import 'package:isango_app/core/utils/validators.dart';
import 'package:isango_app/widgets/auth/auth_card.dart';
import 'package:isango_app/widgets/auth/auth_gradient_background.dart';
import 'package:isango_app/widgets/auth/form_banner.dart';
import 'package:isango_app/widgets/auth/isango_text_field.dart';
import 'package:isango_app/widgets/auth/password_rules_view.dart';
import 'package:isango_app/widgets/auth/primary_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _auth = MockAuthRepository.instance;

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

    try {
      await _auth.signUp(
        fullName: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthGradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: AuthCard(
                  title: 'Create your account',
                  child: AutofillGroup(
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _autovalidate,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_serverError != null) ...[
                            FormBanner(
                              message: _serverError!,
                              action: _showSignInHint
                                  ? FormBannerAction(
                                      label: 'Sign In',
                                      onPressed: _submitting
                                          ? null
                                          : () => Navigator.of(context)
                                              .pushReplacementNamed(
                                                  AppRoutes.login),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 16),
                          ],
                          IsangoTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            hint: 'Full Name',
                            prefixIcon: Icons.person_outline,
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
                          const SizedBox(height: 18),
                          IsangoTextField(
                            controller: _emailController,
                            label: 'University Email',
                            hint: 'student@university.edu',
                            prefixIcon: Icons.mail_outline,
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
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Create Password',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.nearBlackInk,
                                ),
                              ),
                              PasswordStrengthLabel(strength: _rules.strength),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
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
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                size: 20,
                                color: AppColors.mutedOperationalInk,
                              ),
                              suffixIcon: IconButton(
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
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          PasswordRulesView(rules: _rules),
                          const SizedBox(height: 18),
                          const Text(
                            'Confirm Password',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.nearBlackInk,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _confirmController,
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
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                size: 20,
                                color: AppColors.mutedOperationalInk,
                              ),
                              suffixIcon: IconButton(
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
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 24),
                          PrimaryButton(
                            label: 'Sign Up',
                            loading: _submitting,
                            onPressed: _submitting ? null : _onSubmit,
                          ),
                          const SizedBox(height: 16),
                          Row(
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
                                onTap: _submitting
                                    ? null
                                    : () => Navigator.of(context)
                                        .pushReplacementNamed(AppRoutes.login),
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.commandBlue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
