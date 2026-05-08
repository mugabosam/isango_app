import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isango_app/core/auth/auth_exception.dart';
import 'package:isango_app/core/auth/mock_auth_repository.dart';
import 'package:isango_app/core/theme/app_colors.dart';
import 'package:isango_app/core/utils/validators.dart';
import 'package:isango_app/widgets/auth/form_banner.dart';
import 'package:isango_app/widgets/auth/password_rules_view.dart';
import 'package:isango_app/widgets/auth/primary_button.dart';

enum _ResetStep { email, code, newPassword, done }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _codeFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _auth = MockAuthRepository.instance;

  _ResetStep _step = _ResetStep.email;
  bool _submitting = false;
  String? _serverError;
  AutovalidateMode _emailAutovalidate = AutovalidateMode.disabled;
  AutovalidateMode _codeAutovalidate = AutovalidateMode.disabled;
  AutovalidateMode _passwordAutovalidate = AutovalidateMode.disabled;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  PasswordRules _rules = const PasswordRules(
    hasMinLength: false,
    hasUppercase: false,
    hasSymbol: false,
  );
  String? _demoCode;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_serverError != null) setState(() => _serverError = null);
  }

  Future<void> _sendCode() async {
    final form = _emailFormKey.currentState;
    if (form == null) return;
    if (!form.validate()) {
      setState(() => _emailAutovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    setState(() {
      _submitting = true;
      _serverError = null;
    });
    try {
      final code = await _auth.sendPasswordResetEmail(_emailController.text);
      if (!mounted) return;
      setState(() {
        _step = _ResetStep.code;
        _demoCode = code;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _serverError = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _verifyCode() async {
    final form = _codeFormKey.currentState;
    if (form == null) return;
    if (!form.validate()) {
      setState(() => _codeAutovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    setState(() {
      _submitting = true;
      _serverError = null;
    });
    try {
      await _auth.verifyResetCode(
        email: _emailController.text,
        code: _codeController.text,
      );
      if (!mounted) return;
      setState(() => _step = _ResetStep.newPassword);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _serverError = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _resetPassword() async {
    final form = _passwordFormKey.currentState;
    if (form == null) return;
    if (!form.validate()) {
      setState(
          () => _passwordAutovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    setState(() {
      _submitting = true;
      _serverError = null;
    });
    try {
      await _auth.resetPassword(
        email: _emailController.text,
        code: _codeController.text,
        newPassword: _passwordController.text,
      );
      if (!mounted) return;
      setState(() => _step = _ResetStep.done);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _serverError = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _goBack() {
    setState(() {
      _serverError = null;
      switch (_step) {
        case _ResetStep.email:
          Navigator.of(context).pop();
          return;
        case _ResetStep.code:
          _step = _ResetStep.email;
          _codeController.clear();
          break;
        case _ResetStep.newPassword:
          _step = _ResetStep.code;
          _passwordController.clear();
          _confirmController.clear();
          _rules = const PasswordRules(
            hasMinLength: false,
            hasUppercase: false,
            hasSymbol: false,
          );
          break;
        case _ResetStep.done:
          Navigator.of(context).pop();
          return;
      }
    });
  }

  String? _confirmValidator(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  String? _codeValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter the 6-digit code';
    if (v.length != 6) return 'The code must be 6 digits';
    return null;
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
          icon: const Icon(Icons.arrow_back, color: AppColors.nearBlackInk),
          onPressed: _submitting ? null : _goBack,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: AutofillGroup(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _buildStep(),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _step == _ResetStep.done
          ? null
          : SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.softBorder)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Remembered your password? ',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.mutedOperationalInk,
                        ),
                      ),
                      GestureDetector(
                        onTap: _submitting
                            ? null
                            : () => Navigator.of(context).pop(),
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

  Widget _buildStep() {
    switch (_step) {
      case _ResetStep.email:
        return _emailStep();
      case _ResetStep.code:
        return _codeStep();
      case _ResetStep.newPassword:
        return _passwordStep();
      case _ResetStep.done:
        return _doneStep();
    }
  }

  Widget _emailStep() {
    return Column(
      key: const ValueKey('email'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Header(
          icon: Icons.lock_reset_rounded,
          title: 'Forgot your password?',
          subtitle:
              'Enter the university email linked to your account and we’ll send you a verification code.',
        ),
        const SizedBox(height: 32),
        if (_serverError != null) ...[
          FormBanner(message: _serverError!),
          const SizedBox(height: 14),
        ],
        Form(
          key: _emailFormKey,
          autovalidateMode: _emailAutovalidate,
          child: _MinimalField(
            controller: _emailController,
            hint: 'University email',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
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
            onChanged: (_) => _clearError(),
            onFieldSubmitted: (_) => _sendCode(),
          ),
        ),
        const SizedBox(height: 18),
        PrimaryButton(
          label: 'Send code',
          loading: _submitting,
          onPressed: _submitting ? null : _sendCode,
        ),
      ],
    );
  }

  Widget _codeStep() {
    return Column(
      key: const ValueKey('code'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          icon: Icons.mark_email_read_outlined,
          title: 'Enter verification code',
          subtitle:
              'We’ve sent a 6-digit code to ${_emailController.text.trim()}.',
        ),
        const SizedBox(height: 28),
        if (_serverError != null) ...[
          FormBanner(message: _serverError!),
          const SizedBox(height: 14),
        ],
        Form(
          key: _codeFormKey,
          autovalidateMode: _codeAutovalidate,
          child: TextFormField(
            controller: _codeController,
            enabled: !_submitting,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            textAlign: TextAlign.center,
            maxLength: 6,
            autofocus: true,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 12,
              color: AppColors.nearBlackInk,
            ),
            validator: _codeValidator,
            onChanged: (_) => _clearError(),
            onFieldSubmitted: (_) => _verifyCode(),
            decoration: InputDecoration(
              counterText: '',
              hintText: '••••••',
              hintStyle: const TextStyle(
                fontSize: 22,
                letterSpacing: 12,
                color: AppColors.softBorder,
                fontWeight: FontWeight.w700,
              ),
              filled: true,
              fillColor: const Color(0xFFFAFAFA),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
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
            ),
          ),
        ),
        if (_demoCode != null) ...[
          const SizedBox(height: 10),
          Text(
            'Demo code: $_demoCode',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: AppColors.mutedOperationalInk,
            ),
          ),
        ],
        const SizedBox(height: 18),
        PrimaryButton(
          label: 'Verify',
          loading: _submitting,
          onPressed: _submitting ? null : _verifyCode,
        ),
        const SizedBox(height: 12),
        Center(
          child: GestureDetector(
            onTap: _submitting ? null : _sendCode,
            child: const Text(
              'Resend code',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.commandBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordStep() {
    return Column(
      key: const ValueKey('password'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Header(
          icon: Icons.lock_outline,
          title: 'Set a new password',
          subtitle: 'Choose a strong password you haven’t used before.',
        ),
        const SizedBox(height: 28),
        if (_serverError != null) ...[
          FormBanner(message: _serverError!),
          const SizedBox(height: 14),
        ],
        Form(
          key: _passwordFormKey,
          autovalidateMode: _passwordAutovalidate,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MinimalField(
                controller: _passwordController,
                hint: 'New password',
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
                onChanged: (v) {
                  setState(() => _rules = AuthValidators.passwordRules(v));
                  _clearError();
                },
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
                controller: _confirmController,
                hint: 'Confirm new password',
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
                onFieldSubmitted: (_) => _resetPassword(),
                suffix: IconButton(
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
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
            ],
          ),
        ),
        const SizedBox(height: 22),
        PrimaryButton(
          label: 'Update password',
          loading: _submitting,
          onPressed: _submitting ? null : _resetPassword,
        ),
      ],
    );
  }

  Widget _doneStep() {
    return Column(
      key: const ValueKey('done'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF1F8A4C),
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 44,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Password updated',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.nearBlackInk,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'You can now sign in with your new password.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.mutedOperationalInk,
          ),
        ),
        const SizedBox(height: 28),
        PrimaryButton(
          label: 'Back to log in',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

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
          child: Icon(icon, color: Colors.white, size: 38),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.nearBlackInk,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.mutedOperationalInk,
            height: 1.4,
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
