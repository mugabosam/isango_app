import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import 'auth_exception.dart';
import 'auth_user.dart';

class MockAuthRepository {
  MockAuthRepository._();
  static final MockAuthRepository instance = MockAuthRepository._();

  static const int _maxFailedAttempts = 5;
  static const Duration _lockoutWindow = Duration(seconds: 30);
  static const Duration _networkLatency = Duration(milliseconds: 900);

  final Map<String, _StoredUser> _users = {};
  final Map<String, _AttemptTracker> _attempts = {};
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

  Future<bool> sendPasswordResetEmail(String email) async {
    await Future<void>.delayed(_networkLatency);
    return _users.containsKey(_normalizeEmail(email));
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
