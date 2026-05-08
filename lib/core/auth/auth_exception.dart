sealed class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class UserNotFoundException extends AuthException {
  const UserNotFoundException()
      : super("No account found for this email — please sign up first.");
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException()
      : super('Incorrect email or password.');
}

class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException()
      : super('An account with this email already exists. Try signing in.');
}

class AccountLockedException extends AuthException {
  const AccountLockedException(this.retryInSeconds)
      : super(
          'Too many failed attempts. Try again shortly.',
        );

  final int retryInSeconds;
}

class InvalidResetCodeException extends AuthException {
  const InvalidResetCodeException()
      : super('That code is incorrect or has expired.');
}
