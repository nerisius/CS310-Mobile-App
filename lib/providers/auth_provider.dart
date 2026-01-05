import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/preferences_service.dart';

/// Possible states for authentication
enum AuthState {
  initial,        // App just started, checking auth status
  loading,        // Currently signing in/up
  authenticated,  // User is logged in
  unauthenticated, // User is not logged in
  error,          // Something went wrong
}

/// AuthProvider - Manages authentication state for the entire app
///
/// This provider:
/// - Tracks if user is logged in or not
/// - Handles sign up, sign in, sign out
/// - Stores user profile information
/// - Notifies the app when auth state changes
///
/// Uses ChangeNotifier so widgets automatically rebuild when state changes
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final PreferencesService _prefsService = PreferencesService();

  // Current state
  AuthState _state = AuthState.initial;

  // Firebase user (contains email, uid)
  User? _firebaseUser;

  // App user profile (contains username, stats, etc.)
  AppUser? _appUser;

  // Error message if something goes wrong
  String? _errorMessage;

  // Stream subscription to listen for auth changes
  StreamSubscription<User?>? _authSubscription;

  // ==================== GETTERS ====================
  // These let other parts of the app read the current state

  AuthState get state => _state;
  User? get firebaseUser => _firebaseUser;
  AppUser? get appUser => _appUser;
  String? get errorMessage => _errorMessage;

  /// Check if user is currently authenticated
  bool get isAuthenticated => _state == AuthState.authenticated && _firebaseUser != null;

  /// Check if currently loading
  bool get isLoading => _state == AuthState.loading;

  /// Get current user's ID (or null if not logged in)
  String? get userId => _firebaseUser?.uid;

  /// Get current user's username
  String get username => _appUser?.username ?? '';

  // ==================== CONSTRUCTOR ====================

  AuthProvider() {
    _initialize();
  }

  /// Initialize the provider - start listening to auth changes
  Future<void> _initialize() async {
    await _prefsService.init();

    // Listen to Firebase auth state changes
    // This fires whenever user logs in or out
    _authSubscription = _authService.authStateChanges.listen((User? user) async {
      _firebaseUser = user;

      if (user != null) {
        // User is logged in - fetch their profile
        await _fetchUserProfile(user.uid);
        _state = AuthState.authenticated;

        // Save login status locally
        await _prefsService.setLoggedIn(true);
        await _prefsService.setUserId(user.uid);
      } else {
        // User is not logged in
        _appUser = null;
        _state = AuthState.unauthenticated;

        // Clear local login status
        await _prefsService.setLoggedIn(false);
        await _prefsService.setUserId(null);
      }

      // Notify all listening widgets to rebuild
      notifyListeners();
    });
  }

  /// Fetch user profile from Firestore
  Future<void> _fetchUserProfile(String userId) async {
    try {
      _appUser = await _authService.getUserProfile(userId);
      if (_appUser != null) {
        await _prefsService.setUsername(_appUser!.username);
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  // ==================== SIGN UP ====================

  /// Create a new user account
  ///
  /// Returns true if successful, false if failed
  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    try {
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      final userId = await _authService.signUp(
        email: email,
        password: password,
        username: username,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );

      if (userId != null) {
        // Success! Auth state listener will handle the rest
        return true;
      } else {
        _state = AuthState.error;
        _errorMessage = 'Failed to create account';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== SIGN IN ====================

  /// Sign in an existing user
  ///
  /// Returns true if successful, false if failed
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      final userId = await _authService.signIn(
        email: email,
        password: password,
      );

      if (userId != null) {
        // Success! Auth state listener will handle the rest
        return true;
      } else {
        _state = AuthState.error;
        _errorMessage = 'Failed to sign in';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== SIGN OUT ====================

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      await _prefsService.clearUserData();
      // Auth state listener will handle updating the state
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // ==================== UPDATE PROFILE ====================

  /// Update user profile
  Future<void> updateProfile(AppUser updatedUser) async {
    try {
      await _authService.updateUserProfile(updatedUser);
      _appUser = updatedUser;
      notifyListeners();
    } catch (e) {
      print('Error updating profile: $e');
    }
  }

  /// Refresh user profile from database
  Future<void> refreshProfile() async {
    if (_firebaseUser != null) {
      await _fetchUserProfile(_firebaseUser!.uid);
      notifyListeners();
    }
  }

  // ==================== PASSWORD RESET ====================

  /// Send password reset email
  Future<bool> sendPasswordReset(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== CLEANUP ====================

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}