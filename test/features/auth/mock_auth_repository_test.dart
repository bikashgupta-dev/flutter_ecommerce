import 'package:flutter_ecommerce/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:flutter_ecommerce/features/auth/data/repositories/mock_auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late AuthLocalDataSource dataSource;
  late MockAuthRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    dataSource = AuthLocalDataSourceImpl(prefs: prefs);
    repository = MockAuthRepositoryImpl(localDataSource: dataSource);
  });

  group('MockAuthRepositoryImpl', () {
    test('Password hashing produces deterministic, non-plaintext digests', () {
      const salt = 'salt_123';
      final hash1 = MockAuthRepositoryImpl.hashPassword('Password123', salt);
      final hash2 = MockAuthRepositoryImpl.hashPassword('Password123', salt);
      final differentSaltHash = MockAuthRepositoryImpl.hashPassword(
        'Password123',
        'other_salt',
      );

      expect(hash1, equals(hash2));
      expect(hash1, isNot(contains('Password123')));
      expect(hash1, isNot(equals(differentSaltHash)));
    });

    test('Login with seeded demo account succeeds', () async {
      final user = await repository.login(
        email: MockAuthRepositoryImpl.demoEmail,
        password: MockAuthRepositoryImpl.demoPassword,
      );

      expect(user.email, MockAuthRepositoryImpl.demoEmail);
      expect(user.name, MockAuthRepositoryImpl.demoName);

      // Verify persistent session was saved
      final session = await dataSource.getPersistedSession();
      expect(session, isNotNull);
      expect(session!.email, MockAuthRepositoryImpl.demoEmail);
    });

    test('Login is case-insensitive for email', () async {
      final user = await repository.login(
        email: MockAuthRepositoryImpl.demoEmail.toUpperCase(),
        password: MockAuthRepositoryImpl.demoPassword,
      );

      expect(user.email, MockAuthRepositoryImpl.demoEmail);
    });

    test('Login fails with incorrect password', () async {
      expect(
        () => repository.login(
          email: MockAuthRepositoryImpl.demoEmail,
          password: 'WrongPassword',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid email or password'),
          ),
        ),
      );
    });

    test('Login fails for non-existent email', () async {
      expect(
        () => repository.login(
          email: 'unknown@example.com',
          password: 'AnyPassword123',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid email or password'),
          ),
        ),
      );
    });

    test('Register new account succeeds and creates session', () async {
      final newUser = await repository.register(
        name: 'Sneha Rao',
        email: 'sneha@example.com',
        password: 'Password999',
        phoneNumber: '9876501234',
      );

      expect(newUser.name, 'Sneha Rao');
      expect(newUser.email, 'sneha@example.com');
      expect(newUser.phoneNumber, '9876501234');
      expect(newUser.id, startsWith('usr_'));

      // Check user can immediately log in with these credentials
      await repository.logout();
      final loggedIn = await repository.login(
        email: 'sneha@example.com',
        password: 'Password999',
      );
      expect(loggedIn.id, newUser.id);
    });

    test('Register duplicate email throws clear error', () async {
      // Demo email already exists
      expect(
        () => repository.register(
          name: 'Imposter',
          email: MockAuthRepositoryImpl.demoEmail,
          password: 'Password123',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('already exists'),
          ),
        ),
      );
    });

    test('Restore session returns active user from local storage', () async {
      // Login first
      await repository.login(
        email: MockAuthRepositoryImpl.demoEmail,
        password: MockAuthRepositoryImpl.demoPassword,
      );

      // Create new repo instance to simulate application restart
      final newRepo = MockAuthRepositoryImpl(localDataSource: dataSource);
      final restored = await newRepo.restoreSession();

      expect(restored, isNotNull);
      expect(restored!.email, MockAuthRepositoryImpl.demoEmail);
    });

    test('Logout clears in-memory and persisted session', () async {
      await repository.login(
        email: MockAuthRepositoryImpl.demoEmail,
        password: MockAuthRepositoryImpl.demoPassword,
      );

      await repository.logout();

      expect(await repository.getCurrentUser(), isNull);
      expect(await dataSource.getPersistedSession(), isNull);
    });

    test(
      'Update profile modifies allowed fields and updates session',
      () async {
        final user = await repository.login(
          email: MockAuthRepositoryImpl.demoEmail,
          password: MockAuthRepositoryImpl.demoPassword,
        );

        final updated = await repository.updateProfile(
          name: 'Alex M. Updated',
          phoneNumber: '9123456789',
          avatarUrl: 'https://example.com/new_pic.jpg',
        );

        expect(updated.id, user.id);
        expect(updated.email, user.email); // email remains unchanged
        expect(updated.name, 'Alex M. Updated');
        expect(updated.phoneNumber, '9123456789');
        expect(updated.avatarUrl, 'https://example.com/new_pic.jpg');
        expect(updated.updatedAt, isNotNull);

        // Verify persisted session matches
        final currentSession = await dataSource.getPersistedSession();
        expect(currentSession?.name, 'Alex M. Updated');
      },
    );
  });
}
