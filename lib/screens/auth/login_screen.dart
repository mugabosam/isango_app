import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isango_app/core/auth/auth_exception.dart';
import 'package:isango_app/core/auth/mock_auth_repository.dart';
import 'package:isango_app/core/constants/app_routes.dart';
import 'package:isango_app/core/theme/app_colors.dart';
import 'package:isango_app/core/utils/validators.dart';
import 'package:isango_app/widgets/auth/form_banner.dart';
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
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
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
                      const SizedBox(height: 40),
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
                        const SizedBox(height: 14),
                      ],
                      _MinimalField(
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
                        controller: _passwordController,
                        hint: 'Password',
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
                      const SizedBox(height: 18),
                      PrimaryButton(
                        label: 'Log in',
                        loading: _submitting,
                        onPressed: _submitting ? null : _onSubmit,
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: GestureDetector(
                          onTap: _submitting
                              ? null
                              : () => Navigator.of(context)
                                  .pushNamed(AppRoutes.forgotPassword),
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.commandBlue,
                            ),
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
                    'Sign up',
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
          width: 88,
          height: 88,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.logisticsNavy,
          ),
          child: const Icon(
            Icons.school_rounded,
            color: Colors.white,
            size: 48,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Isango',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: AppColors.logisticsNavy,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Your campus, your events',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.mutedOperationalInk,
          ),
        ),
      ],
    );
  }
}

class _MinimalField extends StatelessWidget {
  const _MinimalField({
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
        hintStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.mutedOperationalInk,
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        suffixIcon: suffix,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.softBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.softBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.logisticsNavy,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.criticalRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.criticalRed,
            width: 1.4,
          ),
        ),
        errorStyle: const TextStyle(
          fontSize: 12,
          color: AppColors.criticalRed,
        ),
      ),
    );
  }
}
