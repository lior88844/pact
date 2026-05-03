import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/tokens.dart';
import '../widgets/auth_chrome.dart';
import '../widgets/pact_stage_background.dart';

enum _AuthMode { signIn, signUp }

class WelcomeAuthScreen extends StatefulWidget {
  final Future<void> Function(String email, String password) onSignIn;
  final Future<void> Function(String email, String password, String displayName)
      onSignUp;

  const WelcomeAuthScreen({
    super.key,
    required this.onSignIn,
    required this.onSignUp,
  });

  @override
  State<WelcomeAuthScreen> createState() => _WelcomeAuthScreenState();
}

class _WelcomeAuthScreenState extends State<WelcomeAuthScreen> {
  /// Reserved height under the password field (2 lines) so layout does not jump.
  static const double _passwordRuleSlotHeight = 40;

  final _authService = AuthService();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  _AuthMode _mode = _AuthMode.signIn;
  String? _error;
  bool _loading = false;

  static bool _passwordRulesMet(String password) {
    if (password.length <= 6) return false;
    if (!RegExp(r'[A-Za-z]').hasMatch(password)) return false;
    if (!RegExp(r'\d').hasMatch(password)) return false;
    return true;
  }

  /// Sign-up only: inline message when the field is non-empty but invalid.
  String? _passwordRuleMessage() {
    if (_mode != _AuthMode.signUp) return null;
    final p = _passwordCtrl.text;
    if (p.isEmpty) return null;
    if (_passwordRulesMet(p)) return null;
    return 'Use at least 7 characters, including a letter and a number.';
  }

  bool get _signInValid =>
      _emailCtrl.text.contains('@') && _passwordCtrl.text.length >= 6;

  bool get _signUpValid =>
      _emailCtrl.text.contains('@') &&
      _nameCtrl.text.trim().length > 1 &&
      _passwordRulesMet(_passwordCtrl.text);

  bool get _formValid => _mode == _AuthMode.signIn ? _signInValid : _signUpValid;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formValid || _loading) return;
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      if (_mode == _AuthMode.signIn) {
        await widget.onSignIn(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
      } else {
        await widget.onSignUp(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
          _nameCtrl.text.trim(),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _error = _messageForAuthError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email first.')),
      );
      return;
    }
    try {
      await _authService.sendPasswordResetEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_messageForAuthError(e))),
      );
    }
  }

  static String _messageForAuthError(Object e) {
    final s = e.toString();
    if (s.contains('wrong-password') || s.contains('invalid-credential')) {
      return 'Wrong email or password.';
    }
    if (s.contains('user-not-found')) {
      return 'No account for that email.';
    }
    if (s.contains('email-already-in-use')) {
      return 'That email is already in use.';
    }
    if (s.contains('weak-password')) {
      return 'Password is too weak.';
    }
    if (s.contains('invalid-email')) {
      return 'Invalid email address.';
    }
    return 'Something went wrong. Try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const Positioned.fill(child: PactStageBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 40),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - MediaQuery.paddingOf(context).vertical,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                          const SizedBox(height: 40),
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.asset(
                                'assets/images/app_logo.png',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Pact',
                            textAlign: TextAlign.center,
                            style: AppText.display(
                              size: 36,
                              weight: FontWeight.w700,
                              color: AppColors.ink0,
                              letterSpacing: -1.44,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Two people. Five commitments. One quiet standard.',
                            textAlign: TextAlign.center,
                            style: AppText.editorial(size: 14, color: AppColors.ink2),
                          ),
                          const SizedBox(height: 36),
                          _ModeSegmentedControl(
                            signInSelected: _mode == _AuthMode.signIn,
                            onSelectSignIn: () {
                              setState(() {
                                _mode = _AuthMode.signIn;
                                _error = null;
                              });
                            },
                            onSelectSignUp: () {
                              setState(() {
                                _mode = _AuthMode.signUp;
                                _error = null;
                              });
                            },
                          ),
                          const SizedBox(height: 22),
                          if (_mode == _AuthMode.signUp) ...[
                            AuthLabeledField(
                              label: 'Your name',
                              controller: _nameCtrl,
                              hint: 'Alex',
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 12),
                          ],
                          AuthLabeledField(
                            label: 'Email',
                            controller: _emailCtrl,
                            hint: 'you@domain.com',
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 12),
                          AuthLabeledField(
                            label: 'Password',
                            controller: _passwordCtrl,
                            hint: '••••••••',
                            obscureText: true,
                            onChanged: (_) => setState(() {}),
                          ),
                          SizedBox(
                            height: _passwordRuleSlotHeight,
                            width: double.infinity,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                _passwordRuleMessage() ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.body(
                                  size: 12,
                                  height: 1.35,
                                  color: AppColors.alert,
                                ),
                              ),
                            ),
                          ),
                          if (_mode == _AuthMode.signIn) ...[
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _forgotPassword,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.only(top: 10),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Forgot password?',
                                  style: AppText.body(
                                    size: 12,
                                    weight: FontWeight.w500,
                                    color: AppColors.ink2,
                                  ),
                                ),
                              ),
                            ),
                          ] else
                            const SizedBox(height: 10),
                          const SizedBox(height: 14),
                          PactPrimaryButton(
                            label: _mode == _AuthMode.signIn
                                ? 'Continue'
                                : 'Create your Pact',
                            loading: _loading,
                            onPressed: _formValid && !_loading ? _submit : null,
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: AppText.body(
                                size: 13,
                                color: AppColors.alert,
                              ),
                            ),
                          ],
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: Text(
                            'By continuing, you agree to Pact\'s Terms & Privacy.',
                            textAlign: TextAlign.center,
                            style: AppText.body(
                              size: 11,
                              color: AppColors.ink3,
                            ).copyWith(letterSpacing: -0.055),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeSegmentedControl extends StatelessWidget {
  final bool signInSelected;
  final VoidCallback onSelectSignIn;
  final VoidCallback onSelectSignUp;

  const _ModeSegmentedControl({
    required this.signInSelected,
    required this.onSelectSignIn,
    required this.onSelectSignUp,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        // Stack lies inside padding(4); inner width = w - 8. Each tab is exactly half.
        final innerW = w - 8;
        final half = innerW / 2;
        return Container(
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.bg2,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 360),
                curve: const Cubic(0.34, 1.2, 0.4, 1),
                left: signInSelected ? 0 : half,
                top: 0,
                width: half,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: AppShadows.card,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _ModeTab(
                      label: 'Sign in',
                      selected: signInSelected,
                      onTap: onSelectSignIn,
                    ),
                  ),
                  Expanded(
                    child: _ModeTab(
                      label: 'Create account',
                      selected: !signInSelected,
                      onTap: onSelectSignUp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Center(
          child: Text(
            label,
            style: AppText.body(
              size: 13,
              weight: FontWeight.w600,
              color: selected ? AppColors.ink0 : AppColors.ink2,
            ).copyWith(letterSpacing: -0.065),
          ),
        ),
      ),
    );
  }
}
