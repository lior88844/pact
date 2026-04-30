# Pact

Pact is a Flutter app for daily accountability between two people.

It focuses on a clean "today-first" workflow where you can track mood, complete tasks, and compare progress between "You" and your partner.

## Features

- Today view with date navigation (up to 7 days back)
- You/Partner toggle for side-by-side accountability context
- Editable daily tasks for your side, read-only partner demo data
- Mood selection and completion progress indicators
- History and settings tabs with a floating bottom navigation
- Polished motion and visual styling using a tokenized theme

## Tech Stack

- Flutter + Dart
- `provider` for app state management
- `google_fonts` for typography
- `flutter_animate` for lightweight UI animations
- `lucide_icons_flutter` for iconography

## Requirements

- Flutter SDK (see `pubspec.yaml` for the currently pinned Dart/SDK range)
- Xcode (for iOS/macOS builds) or Android Studio (for Android builds)

## Getting Started

1. Install dependencies:

   ```bash
   flutter pub get
   ```

2. Run the app:

   ```bash
   flutter run
   ```

3. Run tests:

   ```bash
   flutter test
   ```

4. Provide Firebase config via `--dart-define` values (recommended for release/CI).
   Example:

   ```bash
   flutter run \
     --dart-define=FIREBASE_WEB_API_KEY=... \
     --dart-define=FIREBASE_WEB_APP_ID=... \
     --dart-define=FIREBASE_ANDROID_API_KEY=... \
     --dart-define=FIREBASE_ANDROID_APP_ID=... \
     --dart-define=FIREBASE_IOS_API_KEY=... \
     --dart-define=FIREBASE_IOS_APP_ID=... \
     --dart-define=FIREBASE_MACOS_API_KEY=... \
     --dart-define=FIREBASE_MACOS_APP_ID=... \
     --dart-define=FIREBASE_MESSAGING_SENDER_ID=... \
     --dart-define=FIREBASE_PROJECT_ID=... \
     --dart-define=FIREBASE_AUTH_DOMAIN=... \
     --dart-define=FIREBASE_STORAGE_BUCKET=... \
     --dart-define=FIREBASE_MEASUREMENT_ID=... \
     --dart-define=FIREBASE_IOS_BUNDLE_ID=... \
     --dart-define=FIREBASE_MACOS_BUNDLE_ID=...
   ```

## Project Structure

```text
lib/
  app.dart                # App shell, theme, navigation
  main.dart               # Entry point + system UI setup
  models/                 # Domain models and sample day data
  screens/                # Today, History, Settings screens
  state/                  # PactState (ChangeNotifier)
  theme/                  # Colors, text styles, shadows, spacing tokens
  widgets/                # Reusable UI components
```

## Notes

- The app is currently portrait-oriented.
- Some partner/history data is demo/static to support UI and interaction flows.
- Keep privileged secrets on your backend. Any value in a mobile/web client should be treated as potentially exposed.
