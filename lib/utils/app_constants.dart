class AppConstants {
  // App info
  static const String appName = 'BookMate';
  static const String appVersion = '1.0.0';

  // SharedPreferences keys
  static const String keyIsFirstTime = 'isFirstTime';
  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyUserId = 'userId';
  static const String keyUsername = 'username';

  // Validation
  static const int minPasswordLength = 6;
  static const int minUsernameLength = 3;

  // UI Constants
  static const int maxOnboardingPages = 6;
  static const double avatarSize = 40.0;
  static const double largeAvatarSize = 80.0;
  static const double bookCoverWidth = 60.0;
  static const double bookCoverHeight = 90.0;

  // Chart constants
  static const int maxChartPoints = 12;
  static const double chartHeight = 200.0;

  // Timeouts
  static const int apiTimeout = 30; // seconds
  static const int splashDuration = 2; // seconds

  // Error messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'No internet connection.';
  static const String errorInvalidEmail = 'Please enter a valid email address.';
  static const String errorPasswordTooShort = 'Password must be at least 6 characters.';
  static const String errorFieldRequired = 'This field is required.';

  // Success messages
  static const String successLogin = 'Login successful!';
  static const String successSignup = 'Account created successfully!';
  static const String successBookAdded = 'Book added to library.';
  static const String successBookRemoved = 'Book removed from library.';
}
