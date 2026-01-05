import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

/// AuthService - Handles all Firebase Authentication operations
///
/// This service is responsible for:
/// - Signing up new users (creating account)
/// - Signing in existing users (logging in)
/// - Signing out users (logging out)
/// - Getting user profile information
class AuthService {
  // Firebase Auth instance - used for login/signup
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Firestore instance - used to store user profile data
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get the currently logged in user (null if not logged in)
  User? get currentUser => _auth.currentUser;

  /// Stream that notifies when auth state changes (login/logout)
  /// This is used by AuthProvider to know when user logs in or out
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up a new user with email and password
  ///
  /// This does TWO things:
  /// 1. Creates account in Firebase Auth (for login)
  /// 2. Creates user profile in Firestore (for storing user data)
  ///
  /// Returns the new user's ID if successful, null if failed
  Future<String?> signUp({
    required String email,
    required String password,
    required String username,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    try {
      // Step 1: Create account in Firebase Auth
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;
      if (user == null) return null;

      // Step 2: Create user profile in Firestore database
      final AppUser appUser = AppUser(
        id: user.uid,
        email: email,
        username: username,
        gender: gender,
        dateOfBirth: dateOfBirth,
        createdAt: DateTime.now(),
      );

      // Save to Firestore 'users' collection
      await _firestore.collection('users').doc(user.uid).set(appUser.toFirestore());

      return user.uid;
    } on FirebaseAuthException catch (e) {
      // Re-throw with user-friendly message
      throw _handleAuthException(e);
    }
  }

  /// Sign in an existing user with email and password
  ///
  /// Returns the user's ID if successful, null if failed
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user?.uid;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get user profile from Firestore
  ///
  /// This fetches the user's profile data (username, stats, etc.)
  Future<AppUser?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update user profile in Firestore
  Future<void> updateUserProfile(AppUser user) async {
    await _firestore.collection('users').doc(user.id).update(user.toFirestore());
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Convert Firebase Auth errors to user-friendly messages
  ///
  /// Firebase errors are technical, this makes them readable
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}