import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/pair_service.dart';
import '../services/user_service.dart';
import 'login_screen.dart';
import 'pairing_screen.dart';
import 'signup_screen.dart';

enum _AuthPage { login, signup }

class AuthGate extends StatefulWidget {
  final Widget Function(UserProfile profile) homeBuilder;

  const AuthGate({super.key, required this.homeBuilder});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authService = AuthService();
  final _userService = UserService();
  final _pairService = PairService();
  _AuthPage _authPage = _AuthPage.login;

  Future<void> _handleLogin(String email, String password) async {
    await _authService.signIn(email: email, password: password);
  }

  Future<void> _handleSignup(
    String email,
    String password,
    String displayName,
  ) async {
    final credential = await _authService.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
    final user = credential.user;
    if (user == null) throw StateError('Missing user after sign-up');

    await _userService.createUserProfile(
      uid: user.uid,
      email: user.email ?? email,
      displayName: displayName.isEmpty ? 'Pact User' : displayName,
    );
  }

  Future<UserProfile> _ensureUserProfile(User firebaseUser) async {
    final existing = await _userService.getByUid(firebaseUser.uid);
    if (existing != null) return existing;
    return _userService.createUserProfile(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? 'Pact User',
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final firebaseUser = authSnapshot.data;
        if (firebaseUser == null) {
          if (_authPage == _AuthPage.signup) {
            return SignupScreen(
              onSignup: _handleSignup,
              onGoToLogin: () => setState(() => _authPage = _AuthPage.login),
            );
          }
          return LoginScreen(
            onLogin: _handleLogin,
            onGoToSignup: () => setState(() => _authPage = _AuthPage.signup),
          );
        }

        return FutureBuilder<UserProfile>(
          future: _ensureUserProfile(firebaseUser),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (userSnapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Failed to load user profile: ${userSnapshot.error}'),
                  ),
                ),
              );
            }
            if (!userSnapshot.hasData) {
              return const Scaffold(body: Center(child: Text('Failed to load user profile.')));
            }

            final profile = userSnapshot.data!;
            if (profile.pairId == null) {
              return PairingScreen(
                userProfile: profile,
                onPair: (inviteCode) async {
                  await _pairService.pairUsers(
                    currentUid: profile.uid,
                    inviteCode: inviteCode,
                  );
                  if (mounted) setState(() {});
                },
                onSignOut: _authService.signOut,
              );
            }

            return widget.homeBuilder(profile);
          },
        );
      },
    );
  }
}
