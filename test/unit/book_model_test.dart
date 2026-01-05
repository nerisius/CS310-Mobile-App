import 'package:flutter_test/flutter_test.dart';
import 'package:bookmate/models/book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Unit tests for the Book model
/// Tests business logic, calculations, and data serialization
void main() {
  group('Book Model - Progress Calculations', () {
    test('should calculate progress correctly as decimal', () {
      // Arrange
      final book = Book(
        title: 'Test Book',
        author: 'Test Author',
        totalPages: 100,
        readPages: 50,
        createdBy: 'test_user',
      );

      // Act & Assert
      expect(book.progress, 0.5);
    });

    test('should calculate percentage correctly', () {
      // Arrange
      final book = Book(
        title: 'Test Book',
        author: 'Test Author',
        totalPages: 100,
        readPages: 50,
        createdBy: 'test_user',
      );

      // Act & Assert
      expect(book.percentage, 50);
    });

    test('should return 0 progress when totalPages is 0', () {
      // Arrange
      final book = Book(
        title: 'Test Book',
        author: 'Test Author',
        totalPages: 0,
        readPages: 0,
        createdBy: 'test_user',
      );

      // Act & Assert
      expect(book.progress, 0);
      expect(book.percentage, 0);
    });

    test('should calculate progress correctly at 0%', () {
      // Arrange
      final book = Book(
        title: 'Test Book',
        author: 'Test Author',
        totalPages: 200,
        readPages: 0,
        createdBy: 'test_user',
      );

      // Act & Assert
      expect(book.progress, 0.0);
      expect(book.percentage, 0);
    });

    test('should calculate progress correctly at 100%', () {
      // Arrange
      final book = Book(
        title: 'Test Book',
        author: 'Test Author',
        totalPages: 150,
        readPages: 150,
        createdBy: 'test_user',
      );

      // Act & Assert
      expect(book.progress, 1.0);
      expect(book.percentage, 100);
    });

    test('should calculate progress correctly for partial completion', () {
      // Arrange
      final book = Book(
        title: 'The Midnight Library',
        author: 'Matt Haig',
        totalPages: 304,
        readPages: 152,
        createdBy: 'test_user',
      );

      // Act & Assert
      expect(book.progress, 0.5);
      expect(book.percentage, 50);
    });
  });

  group('Book Model - Finished Status', () {
    test('should return true for isFinished when status is finished', () {
      // Arrange
      final book = Book(
        title: 'Test Book',
        author: 'Test Author',
        totalPages: 100,
        readPages: 100,
        status: 'finished',
        createdBy: 'test_user',
      );

      // Act & Assert
      expect(book.isFinished, true);
    });

    test('should return true for isFinished when readPages >= totalPages', () {
      // Arrange
      final book = Book(
        title: 'Test Book',
        author: 'Test Author',
        totalPages: 100,
        readPages: 100,
        status: 'reading',
        createdBy: 'test_user',
      );

      // Act & Assert
      expect(book.isFinished, true);
    });

    test('should return false for isFinished when book is still being read', () {
      // Arrange
      final book = Book(
        title: 'Test Book',
        author: 'Test Author',
        totalPages: 100,
        readPages: 50,
        status: 'reading',
        createdBy: 'test_user',
      );

      // Act & Assert
      expect(book.isFinished, false);
    });
  });

  group('Book Model - Firestore Serialization', () {
    test('should convert Book to Firestore map correctly', () {
      // Arrange
      final now = DateTime(2026, 1, 5, 12, 0);
      final book = Book(
        id: 'book123',
        title: 'Test Book',
        author: 'Test Author',
        coverUrl: 'https://example.com/cover.jpg',
        totalPages: 300,
        readPages: 150,
        status: 'reading',
        isFavorite: true,
        createdBy: 'user123',
        createdAt: now,
      );

      // Act
      final map = book.toFirestore();

      // Assert
      expect(map['title'], 'Test Book');
      expect(map['author'], 'Test Author');
      expect(map['coverUrl'], 'https://example.com/cover.jpg');
      expect(map['totalPages'], 300);
      expect(map['readPages'], 150);
      expect(map['status'], 'reading');
      expect(map['isFavorite'], true);
      expect(map['createdBy'], 'user123');
      expect(map['createdAt'], isA<Timestamp>());
    });

    test('should handle null coverUrl in Firestore serialization', () {
      // Arrange
      final book = Book(
        title: 'Test Book',
        author: 'Test Author',
        totalPages: 100,
        createdBy: 'user123',
      );

      // Act
      final map = book.toFirestore();

      // Assert
      expect(map['coverUrl'], isNull);
    });
  });

  group('Book Model - Default Values', () {
    test('should have correct default values', () {
      // Arrange & Act
      final book = Book(
        title: 'Test Book',
        author: 'Test Author',
        totalPages: 100,
        createdBy: 'user123',
      );

      // Assert
      expect(book.readPages, 0);
      expect(book.status, 'planning');
      expect(book.isFavorite, false);
      expect(book.createdAt, isA<DateTime>());
      expect(book.updatedAt, isNull);
    });
  });

  group('Book Model - CopyWith', () {
    test('should create a copy with updated readPages', () {
      // Arrange
      final originalBook = Book(
        id: 'book123',
        title: 'Test Book',
        author: 'Test Author',
        totalPages: 100,
        readPages: 50,
        createdBy: 'user123',
      );

      // Act
      final updatedBook = originalBook.copyWith(readPages: 75);

      // Assert
      expect(updatedBook.readPages, 75);
      expect(updatedBook.title, 'Test Book'); // other fields unchanged
      expect(updatedBook.totalPages, 100);
      expect(updatedBook.id, 'book123');
    });

    test('should create a copy with updated status', () {
      // Arrange
      final originalBook = Book(
        title: 'Test Book',
        author: 'Test Author',
        totalPages: 100,
        readPages: 100,
        status: 'reading',
        createdBy: 'user123',
      );

      // Act
      final updatedBook = originalBook.copyWith(status: 'finished');

      // Assert
      expect(updatedBook.status, 'finished');
      expect(updatedBook.readPages, 100);
    });

    test('should create a copy with updated isFavorite', () {
      // Arrange
      final originalBook = Book(
        title: 'Test Book',
        author: 'Test Author',
        totalPages: 100,
        isFavorite: false,
        createdBy: 'user123',
      );

      // Act
      final updatedBook = originalBook.copyWith(isFavorite: true);

      // Assert
      expect(updatedBook.isFavorite, true);
      expect(updatedBook.title, 'Test Book');
    });

    test('should update updatedAt timestamp when copying', () {
      // Arrange
      final originalBook = Book(
        title: 'Test Book',
        author: 'Test Author',
        totalPages: 100,
        createdBy: 'user123',
        updatedAt: null,
      );

      // Act
      final updatedBook = originalBook.copyWith(readPages: 10);

      // Assert
      expect(updatedBook.updatedAt, isA<DateTime>());
      expect(updatedBook.updatedAt, isNotNull);
    });
  });
}
