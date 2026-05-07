import 'package:flutter_test/flutter_test.dart';
import 'package:isango_app/core/auth/auth_exception.dart';
import 'package:isango_app/core/auth/mock_auth_repository.dart';

void main() {
  final repo = MockAuthRepository.instance;

  setUp(() async {
    await repo.signOut();
  });

  test('signUp registers a new user and signs them in', () async {
    final email = 'new${DateTime.now().microsecondsSinceEpoch}@university.edu';
    final user = await repo.signUp(
      fullName: 'Test User',
      email: email,
      password: 'Strong!Pass1',
    );
    expect(user.email, email);
    expect(repo.isSignedIn, isTrue);
  });

  test('signUp twice with same email throws EmailAlreadyInUse', () async {
    final email = 'dup${DateTime.now().microsecondsSinceEpoch}@university.edu';
    await repo.signUp(
      fullName: 'A',
      email: email,
      password: 'Strong!Pass1',
    );
    expect(
      () => repo.signUp(
        fullName: 'A',
        email: email,
        password: 'Strong!Pass1',
      ),
      throwsA(isA<EmailAlreadyInUseException>()),
    );
  });

  test('signIn for unknown email throws UserNotFound', () async {
    expect(
      () => repo.signIn(
        email: 'unknown${DateTime.now().microsecondsSinceEpoch}@university.edu',
        password: 'whatever',
      ),
      throwsA(isA<UserNotFoundException>()),
    );
  });

  test('signIn with wrong password throws InvalidCredentials', () async {
    final email = 'wrong${DateTime.now().microsecondsSinceEpoch}@university.edu';
    await repo.signUp(
      fullName: 'A',
      email: email,
      password: 'Strong!Pass1',
    );
    await repo.signOut();
    expect(
      () => repo.signIn(email: email, password: 'WrongPass!1'),
      throwsA(isA<InvalidCredentialsException>()),
    );
  });

  test('signIn succeeds with correct credentials', () async {
    final email = 'ok${DateTime.now().microsecondsSinceEpoch}@university.edu';
    await repo.signUp(
      fullName: 'A',
      email: email,
      password: 'Strong!Pass1',
    );
    await repo.signOut();
    final user = await repo.signIn(email: email, password: 'Strong!Pass1');
    expect(user.email, email);
    expect(repo.isSignedIn, isTrue);
  });

  test('lockout kicks in after 5 failed attempts', () async {
    final email = 'lock${DateTime.now().microsecondsSinceEpoch}@university.edu';
    await repo.signUp(
      fullName: 'A',
      email: email,
      password: 'Strong!Pass1',
    );
    await repo.signOut();

    for (var i = 0; i < 4; i++) {
      try {
        await repo.signIn(email: email, password: 'WrongPass!1');
      } on InvalidCredentialsException {
        // expected
      }
    }
    expect(
      () => repo.signIn(email: email, password: 'WrongPass!1'),
      throwsA(isA<AccountLockedException>()),
    );
  });
}
