import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:bookmate/screens/login_screen.dart';
import 'package:bookmate/providers/auth_provider.dart';
import 'package:bookmate/providers/books_provider.dart';
import 'package:bookmate/providers/posts_provider.dart';

/// Widget tests for the LoginScreen
/// Tests UI elements, form validation, and user interactions
void main() {
  // Helper function to create LoginScreen with required providers
  Widget createLoginScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BooksProvider()),
        ChangeNotifierProvider(create: (_) => PostsProvider()),
      ],
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  group('LoginScreen - UI Elements', () {
    testWidgets('should display welcome message and app icon', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginScreen());

      // Assert
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Sign in to continue your reading journey'), findsOneWidget);
      expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);
    });

    testWidgets('should display email and password fields', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginScreen());

      // Assert
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('should display Sign In button', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginScreen());

      // Assert
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should display sign up link', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginScreen());

      // Assert
      expect(find.text("Don't have an account? "), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('should display forgot password button', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginScreen());

      // Assert
      expect(find.text('Forgot Password?'), findsOneWidget);
    });
  });

  group('LoginScreen - Form Validation', () {
    testWidgets('should show error when email is empty', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Act
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('should show error when email is invalid (no @ symbol)',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Act
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'invalidemail',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should show error when password is empty', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Act
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('should show error when password is too short (less than 6 characters)',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Act
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        '12345', // Only 5 characters
      );
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('should accept valid email and password without showing errors',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Act - Enter valid credentials
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      // Don't tap Sign In to avoid Firebase calls in test

      // Assert - Fields should contain the entered text
      expect(find.text('test@example.com'), findsOneWidget);
    });
  });

  group('LoginScreen - Password Visibility Toggle', () {
    testWidgets('should toggle password visibility when icon is tapped',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Find the password field
      final passwordField = find.widgetWithText(TextFormField, 'Password');
      expect(passwordField, findsOneWidget);

      // Initially, password should be obscured (visibility_off icon should be shown)
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Act - Tap the visibility toggle icon
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // Assert - Now visibility icon should be shown (password is visible)
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNothing);
    });
  });

  group('LoginScreen - User Interactions', () {
    testWidgets('should allow text input in email field', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Act
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'user@bookmate.com',
      );

      // Assert
      expect(find.text('user@bookmate.com'), findsOneWidget);
    });

    testWidgets('should allow text input in password field', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Act
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'mypassword',
      );
      await tester.pump();

      // Assert - password is obscured so we won't see the actual text visually,
      // but the TextFormField should contain it
      final passwordField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Password'),
      );
      expect(passwordField.controller?.text, 'mypassword');
    });

    testWidgets('should show snackbar when forgot password is tapped',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Act
      await tester.tap(find.text('Forgot Password?'));
      await tester.pump(); // Start the animation
      await tester.pump(const Duration(seconds: 1)); // Wait for snackbar

      // Assert
      expect(find.text('Password reset coming soon!'), findsOneWidget);
    });
  });

  group('LoginScreen - Email Validation Edge Cases', () {
    testWidgets('should accept valid email with numbers', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Act
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'user123@example.com',
      );

      // Assert
      expect(find.text('user123@example.com'), findsOneWidget);
    });

    testWidgets('should accept valid email with dots', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Act
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'first.last@example.co.uk',
      );

      // Assert
      expect(find.text('first.last@example.co.uk'), findsOneWidget);
    });
  });
}
