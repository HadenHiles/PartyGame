# partygames

A Flutter party game app.

## Supported platforms

- Android
- iOS
- Web

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Run

- Android: `flutter run -d android`
- iOS (requires Xcode): `flutter run -d ios`
- Web (Chrome): `flutter run -d chrome`

## Firebase setup

This app uses Firebase (Auth + Firestore). Project: `party-games-canada`.

1. Enable Anonymous Auth

- In Firebase Console → Authentication → Sign-in method → enable Anonymous.

2. Select project and deploy Firestore rules

These were run once from the repo root to set the active project and deploy rules:

```sh
# Ensure Firebase CLI is installed
firebase --version

# Select project
firebase use party-games-canada

# Deploy Firestore rules
firebase deploy --only firestore:rules
```

Notes

- FlutterFire has already been configured for Android, iOS, and Web (see `lib/firebase_options.dart`).
- Current client flows require authentication and allow:
  - Creating a room by the authenticated user (host)
  - Players writing only their own player document under `rooms/{code}/players/{uid}`
  - Host-only updates to room phase/status fields
- Emulators are not required for now; we can wire them later if desired.
