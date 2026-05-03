import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_profile.dart';
import '../theme/tokens.dart';
import '../widgets/pact_stage_background.dart';

enum _PairStep { landing, enterCode, shareCode }

class PairingScreen extends StatefulWidget {
  final UserProfile userProfile;
  final Future<void> Function(String inviteCode) onPair;
  final Future<void> Function() onSignOut;

  const PairingScreen({
    super.key,
    required this.userProfile,
    required this.onPair,
    required this.onSignOut,
  });

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  _PairStep _step = _PairStep.landing;
  final _codeCtrls = List.generate(6, (_) => TextEditingController());
  final _codeFocus = List.generate(6, (_) => FocusNode());
  String? _error;
  bool _verifying = false;
  bool _copied = false;

  @override
  void dispose() {
    for (final c in _codeCtrls) {
      c.dispose();
    }
    for (final f in _codeFocus) {
      f.dispose();
    }
    super.dispose();
  }

  bool get _codeFilled =>
      _codeCtrls.every((c) => c.text.trim().isNotEmpty);

  String get _enteredCode =>
      _codeCtrls.map((c) => c.text.trim().toUpperCase()).join();

  String get _inviteCode => widget.userProfile.inviteCode.trim().toUpperCase();

  Future<void> _verify() async {
    if (!_codeFilled || _verifying) return;
    setState(() {
      _error = null;
      _verifying = true;
    });
    try {
      await widget.onPair(_enteredCode);
    } catch (e) {
      if (mounted) setState(() => _error = _pairErrorMessage(e));
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  static String _pairErrorMessage(Object e) {
    final s = e.toString();
    if (s.contains('not found')) return 'That code was not found.';
    if (s.contains('yourself')) return 'You cannot use your own code.';
    if (s.contains('already paired')) return 'You are already paired.';
    if (s.contains('permission')) return 'Could not pair. Check your connection.';
    return 'Could not connect. Try again.';
  }

  Future<void> _copyInviteCode() async {
    final code = widget.userProfile.inviteCode.trim();
    if (code.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  Future<void> _shareGeneric() async {
    final code = _inviteCode;
    if (code.isEmpty) return;
    await Share.share('My Pact pairing code: $code');
  }

  Future<void> _shareEmail() async {
    final code = _inviteCode;
    final uri = Uri.parse(
      'mailto:?subject=${Uri.encodeComponent('Pact pairing code')}'
      '&body=${Uri.encodeComponent('Here is my pairing code: $code')}',
    );
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _shareMessage() async {
    final code = _inviteCode;
    final uri = Uri.parse(
      'sms:?body=${Uri.encodeComponent('Pact code: $code')}',
    );
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _onCodeChanged(int i, String raw) {
    final c = raw.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    final char = c.isEmpty ? '' : c[c.length - 1];
    if (char.isNotEmpty && !RegExp(r'^[A-Z0-9]$').hasMatch(char)) return;

    setState(() {
      _codeCtrls[i].text = char;
      _codeCtrls[i].selection = TextSelection.collapsed(offset: char.length);
      _error = null;
    });

    if (char.isNotEmpty && i < 5) {
      _codeFocus[i + 1].requestFocus();
    }
  }

  KeyEventResult _onCodeKey(int i, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_codeCtrls[i].text.isEmpty && i > 0) {
        _codeFocus[i - 1].requestFocus();
        setState(() {
          _codeCtrls[i - 1].clear();
        });
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: Stack(
        children: [
          const Positioned.fill(child: PactStageBackground()),
          SafeArea(
            child: switch (_step) {
              _PairStep.landing => _buildLanding(context),
              _PairStep.enterCode => _buildEnterCode(context),
              _PairStep.shareCode => _buildShareCode(context),
            },
          ),
        ],
      ),
    );
  }

  Widget _backRow({required VoidCallback onBack, bool signOut = false}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onBack,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.ink2,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: Icon(LucideIcons.chevronLeft, size: 18, color: AppColors.ink2),
        label: Text(
          signOut ? 'Sign out' : 'Back',
          style: AppText.body(size: 13, weight: FontWeight.w500, color: AppColors.ink2),
        ),
      ),
    );
  }

  Widget _buildLanding(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _backRow(
            signOut: true,
            onBack: () => widget.onSignOut(),
          ),
          const SizedBox(height: 12),
          Text(
            'STEP 2 OF 2 · PAIR WITH PARTNER',
            style: AppText.tracked(size: 9, color: AppColors.you),
          ),
          const SizedBox(height: 10),
          Text(
            'Pact is built\nfor two.',
            style: AppText.display(
              size: 32,
              weight: FontWeight.w700,
              color: AppColors.ink0,
              letterSpacing: -1.12,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Connect with one accountability partner. You\'ll both see each other\'s daily commitments — nothing more.',
            style: AppText.body(
              size: 14,
              color: AppColors.ink2,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 32),
          _ChoiceCard(
            badge: 'A',
            title: 'I have a code',
            subtitle: 'A partner shared their pairing code with me',
            onTap: () => setState(() => _step = _PairStep.enterCode),
          ),
          const SizedBox(height: 12),
          _ChoiceCard(
            badge: 'B',
            title: 'Share my code',
            subtitle: 'Send my code to a partner so they can connect',
            onTap: () => setState(() => _step = _PairStep.shareCode),
          ),
          const SizedBox(height: 28),
          Text(
            'One partner, one pact. You can change this later.',
            textAlign: TextAlign.center,
            style: AppText.body(
              size: 11.5,
              color: AppColors.ink3,
            ).copyWith(fontStyle: FontStyle.italic, letterSpacing: -0.06),
          ),
        ],
      ),
    );
  }

  Widget _buildEnterCode(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _backRow(onBack: () => setState(() => _step = _PairStep.landing)),
          const SizedBox(height: 12),
          Text(
            'Enter their code',
            style: AppText.display(
              size: 28,
              weight: FontWeight.w700,
              color: AppColors.ink0,
              letterSpacing: -0.98,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Six characters, sent by your partner.',
            style: AppText.body(size: 14, color: AppColors.ink2, height: 1.45),
          ),
          const SizedBox(height: 30),
          FocusTraversalGroup(
            policy: WidgetOrderTraversalPolicy(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) {
                final filled = _codeCtrls[i].text.isNotEmpty;
                return Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
                  child: Focus(
                    onKeyEvent: (node, event) => _onCodeKey(i, event),
                    child: SizedBox(
                      width: 44,
                      height: 56,
                      child: TextField(
                        controller: _codeCtrls[i],
                        focusNode: _codeFocus[i],
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: AppText.display(
                          size: 22,
                          weight: FontWeight.w700,
                          color: AppColors.ink0,
                          letterSpacing: 0,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.card,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: filled ? AppColors.ink1 : AppColors.hairline,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: filled ? AppColors.ink1 : AppColors.hairline,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.ink1, width: 1),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                        textCapitalization: TextCapitalization.characters,
                        keyboardType: TextInputType.text,
                        onChanged: (v) => _onCodeChanged(i, v),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 28),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: !_codeFilled || _verifying ? null : _verify,
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                height: 52,
                decoration: BoxDecoration(
                  color: (!_codeFilled || _verifying) ? AppColors.bg3 : AppColors.ink0,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: (!_codeFilled || _verifying)
                      ? null
                      : const [
                          BoxShadow(
                            color: Color(0x4D14120C),
                            blurRadius: 18,
                            offset: Offset(0, 6),
                            spreadRadius: -4,
                          ),
                        ],
                ),
                child: Center(
                  child: _verifying
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Verify & connect',
                          style: AppText.body(
                            size: 15,
                            weight: FontWeight.w600,
                            color: (!_codeFilled || _verifying)
                                ? AppColors.ink3
                                : Colors.white,
                          ).copyWith(letterSpacing: -0.15),
                        ),
                ),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: AppText.body(size: 13, color: AppColors.alert),
            ),
          ],
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _step = _PairStep.shareCode),
              child: Text(
                'I don\'t have a code · share mine instead',
                style: AppText.body(size: 12.5, weight: FontWeight.w500, color: AppColors.ink2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareCode(BuildContext context) {
    final name = widget.userProfile.displayName.trim();
    final displayName = name.isEmpty ? 'Your' : name;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _backRow(onBack: () => setState(() => _step = _PairStep.landing)),
          const SizedBox(height: 12),
          Text(
            'Your pairing code',
            style: AppText.display(
              size: 28,
              weight: FontWeight.w700,
              color: AppColors.ink0,
              letterSpacing: -0.98,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Send this to your partner. We\'ll connect you the moment they enter it.',
            style: AppText.body(size: 14, color: AppColors.ink2, height: 1.45),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 22),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.hairline),
              boxShadow: AppShadows.card,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 120,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topCenter,
                        radius: 1.2,
                        colors: [
                          AppColors.youGlow.withValues(alpha: 0.35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '$displayName · PACT CODE',
                      style: AppText.tracked(size: 9, color: AppColors.ink3),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _inviteCode.isEmpty ? '------' : _inviteCode,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 6,
                        color: AppColors.ink0,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Material(
                      color: _copied ? AppColors.ok : AppColors.ink0,
                      borderRadius: BorderRadius.circular(100),
                      child: InkWell(
                        onTap: _inviteCode.isEmpty ? null : _copyInviteCode,
                        borderRadius: BorderRadius.circular(100),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _copied ? LucideIcons.check : LucideIcons.copy,
                                size: 13,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                _copied ? 'Copied' : 'Copy code',
                                style: AppText.body(
                                  size: 12.5,
                                  weight: FontWeight.w600,
                                  color: Colors.white,
                                ).copyWith(letterSpacing: -0.06),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ShareTile(
                  icon: '✉',
                  label: 'Email',
                  onTap: _shareEmail,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ShareTile(
                  icon: '◎',
                  label: 'Message',
                  onTap: _shareMessage,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ShareTile(
                  icon: '↗',
                  label: 'Share…',
                  onTap: _shareGeneric,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.bg2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.hairline),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.you,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Waiting for your partner to enter the code…',
                        style: AppText.body(
                          size: 13,
                          color: AppColors.ink1,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'We\'ll connect you automatically.',
                        style: AppText.body(size: 11.5, color: AppColors.ink3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _step = _PairStep.enterCode),
              child: Text(
                'I have a code instead',
                style: AppText.body(size: 12.5, weight: FontWeight.w500, color: AppColors.ink2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final String badge;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.hairline),
            boxShadow: AppShadows.card,
          ),
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.bg2,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.hairline),
                ),
                child: Text(
                  badge,
                  style: AppText.display(size: 14, weight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppText.body(
                        size: 15,
                        weight: FontWeight.w600,
                        color: AppColors.ink0,
                      ).copyWith(letterSpacing: -0.18),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppText.body(
                        size: 12.5,
                        color: AppColors.ink2,
                        height: 1.25,
                      ).copyWith(letterSpacing: -0.06),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, size: 16, color: AppColors.ink3),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareTile extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _ShareTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.hairline),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18, height: 1)),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppText.body(size: 12, weight: FontWeight.w500, color: AppColors.ink1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
