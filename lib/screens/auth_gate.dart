import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/pair_service.dart';
import '../services/user_service.dart';
import 'pairing_screen.dart';
import 'welcome_auth_screen.dart';

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

  Widget _routeForProfile(UserProfile profile) {
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
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final firebaseUser = authSnapshot.data;
        if (firebaseUser == null) {
          return WelcomeAuthScreen(
            onSignIn: _handleLogin,
            onSignUp: _handleSignup,
          );
        }

        return StreamBuilder<UserProfile?>(
          stream: _userService.watchByUid(firebaseUser.uid),
          builder: (context, profileSnap) {
            if (profileSnap.connectionState == ConnectionState.waiting &&
                profileSnap.data == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (profileSnap.hasError) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Failed to load profile: ${profileSnap.error}'),
                  ),
                ),
              );
            }

            if (profileSnap.data != null) {
              return _routeForProfile(profileSnap.data!);
            }

            return FutureBuilder<UserProfile>(
              future: _ensureUserProfile(firebaseUser),
              builder: (context, ensured) {
                if (ensured.connectionState != ConnectionState.done) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (ensured.hasError) {
                  return Scaffold(
                    body: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text('Failed to load user profile: ${ensured.error}'),
                      ),
                    ),
                  );
                }
                if (!ensured.hasData) {
                  return const Scaffold(
                    body: Center(child: Text('Failed to load user profile.')),
                  );
                }
                return _routeForProfile(ensured.data!);
              },
            );
          },
        );
      },
    );
  }
}
