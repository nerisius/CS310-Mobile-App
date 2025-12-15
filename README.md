# BookMate

A Flutter mobile application for book tracking and social reading. Users can share their reading progress, discover what others are reading, and maintain their personal book library.

**Course Project:** CS310 - Phase 2.2
**Tech Stack:** Flutter, Dart

## Current Features

### Authentication & Onboarding
- User onboarding flow with 5 feature introduction screens
- Login screen with form validation
- Sign up screen with comprehensive user registration
- Persistent login state management

### Main Navigation (Bottom Tab Bar)
- **Home Tab**: Social feed displaying reading activities and posts
- **Library Tab**: Personal book collection with progress tracking
- **Search Tab**: Search books by title or author with real-time filtering
- **Stats Tab**: Reading statistics with interactive charts
- **Profile Tab**: User profile with rosettes, favourite books, and reading goals

### Profile Features
- User profile display with bio and stats
- Rosettes/achievements system
- Favourite books showcase
- Reading statistics (Read History, Currently Reading, Want to Read)
- Monthly reading goal tracker
- Settings integration

### Additional Screens
- Settings screen with account, notifications, privacy, and support options
- Favourite books detail screen
- Logout functionality

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
├── main.dart                          # App entry point and route configuration
├── models/                            # Data models
│   └── book_item.dart                 # Book model used across the app
├── screens/                           # All UI screens
│   ├── decider_screen.dart            # Initial router (decides onboarding/login/home)
│   ├── onboarding_screen.dart         # Multi-page onboarding (5 screens)
│   ├── login_screen.dart              # Login form with validation
│   ├── signup.dart                    # Registration form
│   ├── main_screen.dart               # Main container with bottom navigation
│   ├── home_screen.dart               # Social feed with posts
│   ├── library_screen.dart            # Personal book library
│   ├── search_screen.dart             # Book search functionality
│   ├── profile_screen.dart            # User profile with rosettes & stats
│   ├── favourite_books_screen.dart    # Favourite books grid view
│   ├── settings_screen.dart           # App settings and preferences
│   └── stats/
│       └── stats_screen.dart          # Reading statistics with charts
└── utils/                             # Shared resources
    ├── app_colors.dart                # App-wide color definitions
    ├── app_text_styles.dart           # Text style definitions
    ├── login_styling.dart             # Login screen styling
    ├── circular_logo.png              # App logo asset
    ├── MomoSignature-Regular.ttf      # Custom font
    └── Inter-VariableFont_opsz,wght.ttf  # Inter font family
```

## Application Flow

1. **App Launch** → DeciderScreen checks user state via SharedPreferences
2. **First-time user** → OnboardingScreen (5 feature screens) → LoginScreen
3. **Returning user (not logged in)** → LoginScreen → MainScreen
4. **Logged-in user** → MainScreen directly (with bottom navigation)

### Navigation Structure
- Users can navigate to SignupScreen from LoginScreen
- MainScreen provides bottom tab navigation to: Home, Library, Search, Stats, Profile
- Profile screen provides access to Settings screen
- Settings screen includes logout functionality

## Key Dependencies

- `shared_preferences: ^2.2.2` - Local storage for user preferences and authentication state
- `cupertino_icons: ^1.0.8` - iOS-style icons
- `fl_chart: ^0.69.0` - Interactive charts for statistics visualization

## Development Notes

### Current State
- Mock authentication (accepts any credentials)
- Sample data for books, posts, and user stats
- Functional UI with navigation between all screens
- Form validation on login and signup screens
- Search functionality with real-time filtering
- Reading statistics with charts and progress tracking
- No backend API integration yet

### Shared Preferences Keys
- `isFirstTime` - Boolean tracking onboarding completion
- `isLoggedIn` - Boolean tracking authentication state

### Recent Updates
- Added search screen with book filtering functionality
- Integrated fl_chart for statistics visualization
- Fixed settings navigation from profile page
- Created shared BookItem model for consistency
- Implemented favourite books grid view

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

## Step 3: Firebase Backend & State Management

### Features Implemented
- Firebase Authentication (Sign up, Login, Logout)
- Cloud Firestore Database
- Provider State Management
- SharedPreferences for local storage
- Google Books API integration
- Real-time data updates
- Security rules for Firestore

### Project Structure
```
lib/
├── models/      # Data models (Book, Post, AppUser)
├── services/    # Firebase & API services
├── providers/   # State management
└── screens/     # UI screens
```
