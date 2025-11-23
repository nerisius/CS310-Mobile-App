# BookMate

A Flutter mobile application for book tracking and social reading. Users can share their reading progress, discover what others are reading, and maintain their personal book library.

**Course Project:** CS310 - Step 2
**Tech Stack:** Flutter, Dart

## Current Features

- User onboarding flow for first-time users
- Authentication screens (login and signup)
- Social feed displaying reading activities
- Navigation system with bottom tab bar (Home, Library, Search, Stats, Profile)

**Note:** Authentication is currently mock implementation. Backend integration is pending.

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>=3.0.0 <4.0.0)
- Dart SDK (comes with Flutter)
- iOS Simulator / Android Emulator / Physical device
- Xcode (for iOS development on macOS)
- Android Studio or Android SDK (for Android development)

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd cs310_mobile_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Verify Flutter setup:
```bash
flutter doctor
```

## Running the App

### On Any Available Device
```bash
flutter run
```

### On Specific Device
```bash
# List connected devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

### Platform-Specific

**Android:**
```bash
flutter run -d android
```

**iOS (macOS only):**
```bash
flutter run -d ios
```

**Chrome (web):**
```bash
flutter run -d chrome
```

## Building

**Android APK:**
```bash
flutter build apk
```

**Android App Bundle:**
```bash
flutter build appbundle
```

**iOS:**
```bash
flutter build ios
```

## Testing

Run all tests:
```bash
flutter test
```

Run specific test file:
```bash
flutter test test/widget_test.dart
```

## Project Structure

```
lib/
├── main.dart                    # App entry point and route configuration
├── screens/                     # All UI screens
│   ├── decider_screen.dart     # Initial router (decides onboarding/login/home)
│   ├── onboarding_screen.dart  # Multi-page onboarding
│   ├── login_screen.dart       # Login form
│   ├── signup.dart             # Registration form
│   └── home_screen.dart        # Main feed
└── utils/                       # Shared resources
    ├── login_styling.dart      # App-wide colors, text styles, spacing
    ├── circular_logo.png
    ├── MomoSignature-Regular.ttf
    └── Inter-VariableFont_opsz,wght.ttf
```

## Application Flow

1. **App Launch** → DeciderScreen checks user state via SharedPreferences
2. **First-time user** → OnboardingScreen (6 pages) → LoginScreen
3. **Returning user (not logged in)** → LoginScreen → HomeScreen
4. **Logged-in user** → HomeScreen directly

Users can navigate to SignupScreen from LoginScreen.

## Key Dependencies

- `shared_preferences: ^2.2.2` - Local storage for user preferences
- `cupertino_icons: ^1.0.8` - iOS-style icons

## Development Notes

### Current State
- Mock authentication (accepts any credentials)
- Hardcoded sample data in social feed
- Bottom navigation tabs are placeholders
- No backend API integration

### Shared Preferences Keys
- `isFirstTime` - Boolean tracking onboarding completion
- `isLoggedIn` - Boolean tracking authentication state

## Code Quality

**Analyze code:**
```bash
flutter analyze
```

**Format code:**
```bash
dart format .
```

**Check dependencies:**
```bash
flutter pub outdated
```

## Clean Build

If you encounter build issues:
```bash
flutter clean
flutter pub get
flutter run
```

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
