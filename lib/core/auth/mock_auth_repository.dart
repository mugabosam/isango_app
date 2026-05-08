import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import 'auth_exception.dart';
import 'auth_user.dart';

class MockAuthRepository {
  MockAuthRepository._() {
    _seedDemoUser();
  }
  static final MockAuthRepository instance = MockAuthRepository._();

  static const demoEmail = 'demo@ur.ac.rw';
  static const demoPassword = 'Demo123!';
  static const demoFullName = 'Demo Student';

  void _seedDemoUser() {
    final salt = _newSalt();
    _users[demoEmail] = _StoredUser(
      id: 'demo-user',
      fullName: demoFullName,
      email: demoEmail,
      salt: salt,
      passwordHash: _hash(demoPassword, salt),
    );
  }

  static const int _maxFailedAttempts = 5;
  static const Duration _lockoutWindow = Duration(seconds: 30);
  static const Duration _networkLatency = Duration(milliseconds: 900);

  final Map<String, _StoredUser> _users = {};
  final Map<String, _AttemptTracker> _attempts = {};
  final Map<String, String> _resetCodes = {};
  final Random _random = Random.secure();

  AuthUser? _currentUser;
  AuthUser? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  Future<AuthUser> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_networkLatency);
    final key = _normalizeEmail(email);
    if (_users.containsKey(key)) {
      throw const EmailAlreadyInUseException();
    }
    final salt = _newSalt();
    final user = _StoredUser(
      id: _newId(),
      fullName: fullName.trim(),
      email: key,
      salt: salt,
      passwordHash: _hash(password, salt),
    );
    _users[key] = user;
    _currentUser = user.toAuthUser();
    return _currentUser!;
  }

  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_networkLatency);
    final key = _normalizeEmail(email);
    final tracker = _attempts.putIfAbsent(key, _AttemptTracker.new);

    final retryIn = tracker.retryInSeconds(_lockoutWindow);
    if (retryIn > 0) {
      throw AccountLockedException(retryIn);
    }

    final user = _users[key];
    if (user == null) {
      tracker.register();
      throw const UserNotFoundException();
    }

    if (_hash(password, user.salt) != user.passwordHash) {
      tracker.register();
      if (tracker.failedCount >= _maxFailedAttempts) {
        throw AccountLockedException(_lockoutWindow.inSeconds);
      }
      throw const InvalidCredentialsException();
    }

    tracker.reset();
    _currentUser = user.toAuthUser();
    return _currentUser!;
  }

  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }

  Future<String> sendPasswordResetEmail(String email) async {
    await Future<void>.delayed(_networkLatency);
    final key = _normalizeEmail(email);
    if (!_users.containsKey(key)) {
      throw const UserNotFoundException();
    }
    final code = (_random.nextInt(900000) + 100000).toString();
    _resetCodes[key] = code;
    // ignore: avoid_print
    print('[Isango demo] Reset code for $key: $code');
    return code;
  }

  String? peekResetCodeForDemo(String email) =>
      _resetCodes[_normalizeEmail(email)];

  Future<void> verifyResetCode({
    required String email,
    required String code,
  }) async {
    await Future<void>.delayed(_networkLatency);
    final stored = _resetCodes[_normalizeEmail(email)];
    if (stored == null || stored != code.trim()) {
      throw const InvalidResetCodeException();
    }
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await Future<void>.delayed(_networkLatency);
    final key = _normalizeEmail(email);
    final stored = _resetCodes[key];
    if (stored == null || stored != code.trim()) {
      throw const InvalidResetCodeException();
    }
    final user = _users[key];
    if (user == null) {
      throw const UserNotFoundException();
    }
    final salt = _newSalt();
    _users[key] = _StoredUser(
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      salt: salt,
      passwordHash: _hash(newPassword, salt),
    );
    _resetCodes.remove(key);
    _attempts.remove(key);
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  String _newId() => '${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(1 << 32)}';

  String _newSalt() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return base64Url.encode(bytes);
  }

  String _hash(String password, String salt) {
    final bytes = utf8.encode('$salt::$password');
    return sha256.convert(bytes).toString();
  }
}

class _StoredUser {
  _StoredUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.salt,
    required this.passwordHash,
  });

  final String id;
  final String fullName;
  final String email;
  final String salt;
  final String passwordHash;

  AuthUser toAuthUser() =>
      AuthUser(id: id, fullName: fullName, email: email);
}

class _AttemptTracker {
  int failedCount = 0;
  DateTime? lastFailedAt;

  void register() {
    failedCount += 1;
    lastFailedAt = DateTime.now();
  }

  void reset() {
    failedCount = 0;
    lastFailedAt = null;
  }

  int retryInSeconds(Duration window) {
    if (failedCount < MockAuthRepository._maxFailedAttempts) return 0;
    final last = lastFailedAt;
    if (last == null) return 0;
    final elapsed = DateTime.now().difference(last);
    final remaining = window - elapsed;
    if (remaining.isNegative || remaining == Duration.zero) {
      reset();
      return 0;
    }
    return remaining.inSeconds + 1;
  }
}
