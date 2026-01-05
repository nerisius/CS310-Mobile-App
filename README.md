# BookMate

A Flutter mobile application for book tracking and social reading. Users can share their reading progress, discover what others are reading, and maintain their personal book library.

**Course Project:** CS310 - Project Step 4
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

## Firebase Configuration

This app uses Firebase for authentication and database. Follow these steps to configure Firebase:

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Use existing project: `bookmate-2c581` (or create a new project)
3. Enable **Authentication** with Email/Password provider
4. Create **Cloud Firestore** database in production mode

### 2. Android Configuration

1. In Firebase Console, download `google-services.json` for your Android app
2. Place it in: `android/app/google-services.json`
3. The file is already in `.gitignore` for security

### 3. iOS Configuration

1. In Firebase Console, download `GoogleService-Info.plist` for your iOS app
2. Place it in: `ios/Runner/GoogleService-Info.plist`
3. The file is already in `.gitignore` for security

### 4. Web Configuration

Firebase options are auto-configured in `lib/firebase_options.dart` (generated via FlutterFire CLI)

### 5. Firestore Database Structure

The app uses the following Firestore collections:

```
users/{userId}
├── Field: email, username, photoUrl, bio, etc.
└── Subcollection: books/{bookId}
    └── Field: title, author, coverUrl, totalPages, readPages, status, etc.

posts/{postId}
└── Field: userId, username, content, bookTitle, likes[], commentCount, etc.

comments/{commentId}
└── Field: postId, userId, username, content, createdAt, etc.
```

### 6. Firebase Security Rules

Ensure proper security rules are set in Firebase Console:
- Users can only read/write their own data
- Posts are publicly readable but only editable by their creators
- Comments are publicly readable but only editable by their creators

### 7. Environment Variables

No additional environment variables are required. Firebase configuration is handled via `lib/firebase_options.dart`.

### Firebase Services Used

- **Firebase Authentication**: Email/Password sign up and sign in
- **Cloud Firestore**: Real-time database for users, books, posts, and comments
- **Firebase Storage**: (Optional) For book covers and user profile photos

## Testing

This project includes comprehensive unit tests and widget tests to ensure code quality and functionality.

### Running Tests

To run all tests:
```bash
flutter test
```

To run tests with coverage:
```bash
flutter test --coverage
```

To run specific test file:
```bash
flutter test test/unit/book_model_test.dart
flutter test test/widget/login_screen_test.dart
```

### Test Coverage

#### Unit Tests (31 tests)

**Book Model Tests** (`test/unit/book_model_test.dart` - 16 tests)
- Tests book progress calculation (currentPage/totalPages ratio)
- Tests book percentage completion (0-100%)
- Tests Firestore serialization (toFirestore method)
- Validates book model data integrity
- Tests copyWith functionality for updating book data
- Tests isFinished status logic
- Tests default values and edge cases

**Post Model Tests** (`test/unit/post_model_test.dart` - 15 tests)
- Tests like counting functionality (likeCount getter)
- Tests user like detection (isLikedBy method)
- Tests Firestore serialization (toFirestore method)
- Tests different activity types (finished, started, quote, progress)
- Tests copyWith functionality for updating posts
- Tests comment count tracking
- Tests default values and null handling

#### Widget Tests (16 tests)

**Login Screen Tests** (`test/widget/login_screen_test.dart` - 16 tests)
- Tests UI element rendering (welcome message, app icon, form fields)
- Tests form validation (email format, password length)
- Validates error message display
- Tests password visibility toggle
- Tests user input handling
- Tests forgot password snackbar
- Tests edge cases for email and password validation

### Expected Test Results

All tests should pass successfully. Run `flutter test` to verify:
```
00:05 +47: All tests passed!
```

**Test Statistics:**
- Total Tests: 47
- Unit Tests: 31 (2 files)
- Widget Tests: 16 (1 file)
- Pass Rate: 100%

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

## Known Issues / Limitations

### Google Books API
- Search functionality depends on Google Books API availability
- Rate limits may apply for excessive searches
- Some books may not have cover images available

### Image Loading
- Book cover images from external URLs may fail to load if the source is unavailable
- Placeholder images are shown as fallback
- Network connectivity required for loading remote images

### Offline Mode
- The app requires internet connection for Firebase operations (authentication, database sync)
- Offline persistence for Firestore is not yet implemented
- Users must be online to sign in, load books, or interact with posts

### Testing
- Tests cover core functionality but are not comprehensive
- Widget tests avoid Firebase integration to prevent test failures
- More integration tests could be added in future iterations

### Known Bugs
- Post model has a bug in `isLikedBy()` method (uses wrong parameter)
- Deprecated API warnings for `.withOpacity()` in Flutter 3.33+ (non-critical)

### Troubleshooting

If you encounter issues, please check:

1. **Firebase configuration is correct**
   - Ensure `google-services.json` is in `android/app/`
   - Ensure `GoogleService-Info.plist` is in `ios/Runner/`
   - Verify Firebase project settings in Console

2. **Internet connection is active**
   - Required for Firebase Authentication
   - Required for Firestore database operations
   - Required for Google Books API searches

3. **Flutter SDK version matches requirements**
   - Minimum: Flutter 3.0.0
   - Recommended: Flutter 3.5.0 or higher
   - Run `flutter doctor` to verify setup

4. **Dependencies are installed**
   - Run `flutter pub get` after cloning
   - Check for dependency conflicts with `flutter pub outdated`

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

### Tech Stack
- Flutter & Dart
- Firebase Auth & Firestore
- Provider for state management
- SharedPreferences

### Team
- CS310 Mobile Application Development
- Sabanci University - Fall 2025
