import 'package:cloud_firestore/cloud_firestore.dart';

/// AppUser model for Firestore - represents a user's profile
/// Stores user information like username, email, reading stats
class AppUser {
  final String id;              // Firebase Auth user ID
  final String email;           // User's email
  final String username;        // Display name
  final String? photoUrl;       // Profile photo URL (optional)
  final String? bio;            // User bio/description (optional)
  final DateTime? dateOfBirth;  // Birthday (optional)
  final String? gender;         // Gender (optional)
  final int booksRead;          // Total books finished
  final int pagesRead;          // Total pages read
  final int readingStreak;      // Days in a row reading
  final List<String> rosettes;  // Achievement badges
  final DateTime createdAt;     // When account was created

  AppUser({
    required this.id,
    required this.email,
    required this.username,
    this.photoUrl,
    this.bio,
    this.dateOfBirth,
    this.gender,
    this.booksRead = 0,
    this.pagesRead = 0,
    this.readingStreak = 0,
    this.rosettes = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert Firestore document to AppUser object
  /// This is called when we READ data FROM Firebase
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      photoUrl: data['photoUrl'],
      bio: data['bio'],
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      gender: data['gender'],
      booksRead: data['booksRead'] ?? 0,
      pagesRead: data['pagesRead'] ?? 0,
      readingStreak: data['readingStreak'] ?? 0,
      rosettes: List<String>.from(data['rosettes'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert AppUser object to Firestore map
  /// This is called when we WRITE data TO Firebase
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      'photoUrl': photoUrl,
      'bio': bio,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'gender': gender,
      'booksRead': booksRead,
      'pagesRead': pagesRead,
      'readingStreak': readingStreak,
      'rosettes': rosettes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create a copy of this user with some fields changed
  AppUser copyWith({
    String? id,
    String? email,
    String? username,
    String? photoUrl,
    String? bio,
    DateTime? dateOfBirth,
    String? gender,
    int? booksRead,
    int? pagesRead,
    int? readingStreak,
    List<String>? rosettes,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      booksRead: booksRead ?? this.booksRead,
      pagesRead: pagesRead ?? this.pagesRead,
      readingStreak: readingStreak ?? this.readingStreak,
      rosettes: rosettes ?? this.rosettes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}