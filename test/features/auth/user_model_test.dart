import 'package:flutter_ecommerce/features/auth/domain/models/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User Domain Model', () {
    test('Initials are computed properly from full names', () {
      final user2Words = User(
        id: '1',
        name: 'Alex Morgan',
        email: 'alex@example.com',
        createdAt: DateTime.now(),
      );
      expect(user2Words.initials, 'AM');

      final user1Word = User(
        id: '2',
        name: 'Priya',
        email: 'priya@example.com',
        createdAt: DateTime.now(),
      );
      expect(user1Word.initials, 'PR');

      final user3Words = User(
        id: '3',
        name: 'Aarav Kumar Patel',
        email: 'aarav@example.com',
        createdAt: DateTime.now(),
      );
      expect(user3Words.initials, 'AK');

      final userEmpty = User(
        id: '4',
        name: '   ',
        email: 'empty@example.com',
        createdAt: DateTime.now(),
      );
      expect(userEmpty.initials, 'U');
    });

    test('Validates user full name', () {
      expect(User.validateName(null), 'Full name is required');
      expect(User.validateName(''), 'Full name is required');
      expect(User.validateName('A'), 'Name must be at least 2 characters');
      expect(User.validateName('Al'), isNull);
      expect(User.validateName('Alex Morgan'), isNull);
    });

    test('Validates user email', () {
      expect(User.validateEmail(null), 'Email address is required');
      expect(User.validateEmail(''), 'Email address is required');
      expect(
        User.validateEmail('invalid-email'),
        'Enter a valid email address',
      );
      expect(
        User.validateEmail('missing@domain'),
        'Enter a valid email address',
      );
      expect(User.validateEmail('valid.user@example.com'), isNull);
      expect(User.validateEmail('test+alias@domain.co.in'), isNull);
    });

    test('Validates user password', () {
      expect(User.validatePassword(null), 'Password is required');
      expect(User.validatePassword(''), 'Password is required');
      expect(
        User.validatePassword('12345'),
        'Password must be at least 6 characters',
      );
      expect(User.validatePassword('123456'), isNull);
      expect(User.validatePassword('Password123'), isNull);
    });

    test('Validates password confirmation', () {
      expect(
        User.validateConfirmPassword('Password123', null),
        'Please confirm your password',
      );
      expect(
        User.validateConfirmPassword('Password123', ''),
        'Please confirm your password',
      );
      expect(
        User.validateConfirmPassword('Password123', 'Password456'),
        'Passwords do not match',
      );
      expect(
        User.validateConfirmPassword('Password123', 'Password123'),
        isNull,
      );
    });

    test('Validates optional phone number', () {
      expect(User.validatePhoneNumber(null), isNull);
      expect(User.validatePhoneNumber(''), isNull);
      expect(User.validatePhoneNumber('   '), isNull);
      expect(
        User.validatePhoneNumber('12345'),
        'Enter a valid 10-digit Indian phone number',
      );
      expect(
        User.validatePhoneNumber('1234567890'), // Starts with 1
        'Enter a valid 10-digit Indian phone number',
      );
      expect(User.validatePhoneNumber('9876543210'), isNull);
      expect(User.validatePhoneNumber('+91 9876543210'), isNull);
      expect(User.validatePhoneNumber('+91-8765432109'), isNull);
    });

    test(
      'JSON serialization and deserialization roundtrip preserves all fields',
      () {
        final original = User(
          id: 'usr_001',
          name: 'Rohan Sharma',
          email: 'rohan@example.com',
          phoneNumber: '9876543210',
          avatarUrl: 'https://example.com/avatar.jpg',
          createdAt: DateTime(2026, 1, 10, 12, 0),
          updatedAt: DateTime(2026, 2, 1, 15, 30),
        );

        final json = original.toJson();
        final restored = User.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.email, original.email);
        expect(restored.phoneNumber, original.phoneNumber);
        expect(restored.avatarUrl, original.avatarUrl);
        expect(restored.createdAt, original.createdAt);
        expect(restored.updatedAt, original.updatedAt);
        expect(restored, equals(original));
      },
    );

    test('copyWith handles updates and clearing optional fields', () {
      final user = User(
        id: 'usr_001',
        name: 'Initial Name',
        email: 'initial@example.com',
        phoneNumber: '9876543210',
        avatarUrl: 'https://example.com/pic.jpg',
        createdAt: DateTime.now(),
      );

      final updated = user.copyWith(
        name: 'Updated Name',
        clearPhone: true,
        clearAvatar: true,
      );

      expect(updated.name, 'Updated Name');
      expect(updated.email, 'initial@example.com');
      expect(updated.phoneNumber, isNull);
      expect(updated.avatarUrl, isNull);
    });
  });
}
