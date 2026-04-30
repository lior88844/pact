import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'models/user_profile.dart';
import 'screens/auth_gate.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/today_screen.dart';
import 'state/pact_state.dart';
import 'theme/tokens.dart';
import 'widgets/bottom_nav.dart';

class PactApp extends StatelessWidget {
  const PactApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pact',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          surface: AppColors.bg0,
          primary: AppColors.you,
        ),
        scaffoldBackgroundColor: AppColors.bg0,
        textTheme: GoogleFonts.interTextTheme(),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      home: AuthGate(
        homeBuilder: (profile) => _AuthedApp(profile: profile),
      ),
    );
  }
}

class _AuthedApp extends StatelessWidget {
  final UserProfile profile;
  const _AuthedApp({required this.profile});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PactState()..initialize(profile),
      child: const _PactShell(),
    );
  }
}

class _PactShell extends StatelessWidget {
  const _PactShell();

  static const _screens = [
    TodayScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Lock to portrait
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    final state = context.watch<PactState>();

    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: Stack(
        children: [
          // ── Background gradient ─────────────────────────────────────
          Positioned.fill(child: _AppBackground()),

          // ── Screens ────────────────────────────────────────────────
          IndexedStack(
            index: state.tab,
            children: _screens,
          ),

          // ── Floating bottom nav ─────────────────────────────────────
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 0,
            right: 0,
            child: Center(
              child: BottomNav(
                selected: state.tab,
                onTap: state.setTab,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Warm-top, cool-bottom gradient matching the HTML prototype
class _AppBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.35, 1.0],
          colors: [
            Color(0xFFEFE8D4), // warm cream — top radial approximation
            Color(0xFFFAF9F6), // bg0 neutral
            Color(0xFFE5EBF3), // cool blue — bottom radial approximation
          ],
        ),
      ),
    );
  }
}
