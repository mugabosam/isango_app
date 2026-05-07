import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isango_app/core/auth/mock_auth_repository.dart';
import 'package:isango_app/core/theme/app_colors.dart';
import 'package:isango_app/core/utils/validators.dart';
import 'package:isango_app/widgets/auth/auth_card.dart';
import 'package:isango_app/widgets/auth/auth_gradient_background.dart';
import 'package:isango_app/widgets/auth/isango_text_field.dart';
import 'package:isango_app/widgets/auth/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _auth = MockAuthRepository.instance;

  bool _submitting = false;
  bool _sent = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    setState(() => _submitting = true);
    await _auth.sendPasswordResetEmail(_emailController.text);
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _sent = true;
    });
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
                  title: _sent ? 'Check your inbox' : 'Reset your password',
                  subtitle: _sent
                      ? "If an account exists for that email,\nwe've sent a reset link."
                      : "Enter your university email and we'll\nsend you a reset link.",
                  child: _sent
                      ? Column(
                          children: [
                            PrimaryButton(
                              label: 'Back to Sign In',
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        )
                      : Form(
                          key: _formKey,
                          autovalidateMode: _autovalidate,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              IsangoTextField(
                                controller: _emailController,
                                label: 'University Email',
                                hint: 'student@university.edu',
                                prefixIcon: Icons.mail_outline,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [
                                  AutofillHints.username,
                                  AutofillHints.email,
                                ],
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(
                                      RegExp(r'\s')),
                                  LengthLimitingTextInputFormatter(254),
                                ],
                                autocorrect: false,
                                enableSuggestions: false,
                                enabled: !_submitting,
                                validator: AuthValidators.universityEmail,
                                onFieldSubmitted: (_) => _onSubmit(),
                              ),
                              const SizedBox(height: 24),
                              PrimaryButton(
                                label: 'Send Reset Link',
                                loading: _submitting,
                                onPressed: _submitting ? null : _onSubmit,
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: _submitting
                                    ? null
                                    : () => Navigator.of(context).pop(),
                                child: const Text(
                                  'Back to Sign In',
                                  textAlign: TextAlign.center,
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
            ),
          ),
        ),
      ),
    );
  }
}
