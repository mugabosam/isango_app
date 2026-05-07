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
import 'package:isango_app/widgets/auth/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = MockAuthRepository.instance;

  bool _obscurePassword = true;
  bool _submitting = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;
  String? _serverError;
  bool _showSignUpHint = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearServerError() {
    if (_serverError != null || _showSignUpHint) {
      setState(() {
        _serverError = null;
        _showSignUpHint = false;
      });
    }
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
      _showSignUpHint = false;
    });

    try {
      await _auth.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } on UserNotFoundException catch (e) {
      if (!mounted) return;
      setState(() {
        _serverError = e.message;
        _showSignUpHint = true;
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
                  title: 'Welcome back!',
                  subtitle:
                      'Sign in to access your personalized\ncampus events feed.',
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
                              action: _showSignUpHint
                                  ? FormBannerAction(
                                      label: 'Sign Up',
                                      onPressed: _submitting
                                          ? null
                                          : () => Navigator.of(context)
                                              .pushReplacementNamed(
                                                  AppRoutes.signUp),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 16),
                          ],
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
                                'Password',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.nearBlackInk,
                                ),
                              ),
                              GestureDetector(
                                onTap: _submitting
                                    ? null
                                    : () => Navigator.of(context).pushNamed(
                                        AppRoutes.forgotPassword),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.commandBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            enableSuggestions: false,
                            autocorrect: false,
                            enabled: !_submitting,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(128),
                            ],
                            validator: AuthValidators.loginPassword,
                            onChanged: (_) => _clearServerError(),
                            onFieldSubmitted: (_) => _onSubmit(),
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
                          const SizedBox(height: 24),
                          PrimaryButton(
                            label: 'Sign In',
                            loading: _submitting,
                            onPressed: _submitting ? null : _onSubmit,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.mutedOperationalInk,
                                ),
                              ),
                              GestureDetector(
                                onTap: _submitting
                                    ? null
                                    : () => Navigator.of(context)
                                        .pushReplacementNamed(AppRoutes.signUp),
                                child: const Text(
                                  'Sign Up',
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
