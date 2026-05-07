import 'package:flutter_test/flutter_test.dart';
import 'package:isango_app/core/utils/validators.dart';

void main() {
  group('universityEmail', () {
    test('rejects empty', () {
      expect(AuthValidators.universityEmail(''), isNotNull);
      expect(AuthValidators.universityEmail(null), isNotNull);
    });

    test('rejects malformed', () {
      expect(AuthValidators.universityEmail('not-an-email'), isNotNull);
      expect(AuthValidators.universityEmail('a@b'), isNotNull);
    });

    test('rejects non-university domains', () {
      expect(AuthValidators.universityEmail('foo@gmail.com'), isNotNull);
      expect(AuthValidators.universityEmail('foo@example.com'), isNotNull);
    });

    test('accepts university domains', () {
      expect(AuthValidators.universityEmail('a@university.edu'), isNull);
      expect(AuthValidators.universityEmail('a@stud.ur.ac.rw'), isNull);
      expect(AuthValidators.universityEmail('a@cam.ac.uk'), isNull);
    });

    test('rejects > 254 chars', () {
      final long = '${'a' * 250}@x.edu';
      expect(AuthValidators.universityEmail(long), isNotNull);
    });
  });

  group('passwordRules', () {
    test('all unmet on empty', () {
      final r = AuthValidators.passwordRules('');
      expect(r.hasMinLength, isFalse);
      expect(r.hasUppercase, isFalse);
      expect(r.hasSymbol, isFalse);
      expect(r.strength, PasswordStrength.empty);
    });

    test('all met for strong password', () {
      final r = AuthValidators.passwordRules('Strong!Pass');
      expect(r.hasMinLength, isTrue);
      expect(r.hasUppercase, isTrue);
      expect(r.hasSymbol, isTrue);
      expect(r.strength, PasswordStrength.strong);
    });

    test('partial → medium', () {
      final r = AuthValidators.passwordRules('longenough');
      expect(r.hasMinLength, isTrue);
      expect(r.hasUppercase, isFalse);
      expect(r.hasSymbol, isFalse);
      expect(r.strength, PasswordStrength.weak);
    });
  });

  group('signUpPassword', () {
    test('rejects weak passwords', () {
      expect(AuthValidators.signUpPassword(''), isNotNull);
      expect(AuthValidators.signUpPassword('short'), isNotNull);
      expect(AuthValidators.signUpPassword('alllowercase!'), isNotNull);
      expect(AuthValidators.signUpPassword('NoSymbolHere'), isNotNull);
    });

    test('accepts strong passwords', () {
      expect(AuthValidators.signUpPassword('Strong!Pass1'), isNull);
    });
  });

  group('fullName', () {
    test('rejects empty / too short', () {
      expect(AuthValidators.fullName(''), isNotNull);
      expect(AuthValidators.fullName('A'), isNotNull);
    });

    test('rejects digits / weird chars', () {
      expect(AuthValidators.fullName('John 123'), isNotNull);
      expect(AuthValidators.fullName('John<script>'), isNotNull);
    });

    test('accepts valid names', () {
      expect(AuthValidators.fullName('Mugabo Sam'), isNull);
      expect(AuthValidators.fullName("O'Brien"), isNull);
      expect(AuthValidators.fullName('Anne-Marie'), isNull);
    });
  });
}
