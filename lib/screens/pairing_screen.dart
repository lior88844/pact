import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

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
  final _inviteCodeCtrl = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _inviteCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitPair() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      await widget.onPair(_inviteCodeCtrl.text.trim().toUpperCase());
    } catch (e) {
      debugPrint('Pairing failed: $e');
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _copyInviteCode() async {
    final code = widget.userProfile.inviteCode.trim();
    if (code.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Invite code copied')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 28),
              const Text('Pair with your partner', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Text('Your invite code: ${widget.userProfile.inviteCode}'),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _copyInviteCode,
                child: const Text('Copy code'),
              ),
              const SizedBox(height: 8),
              const Text('Share your code or enter your partner\'s code below.'),
              const SizedBox(height: 20),
              TextField(
                controller: _inviteCodeCtrl,
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Partner invite code',
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loading ? null : _submitPair,
                child: Text(_loading ? 'Pairing...' : 'Pair now'),
              ),
              TextButton(
                onPressed: _loading ? null : () => widget.onSignOut(),
                child: const Text('Sign out'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
