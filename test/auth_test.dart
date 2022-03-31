import 'package:flutter_test/flutter_test.dart';
import 'package:my_notes/services/auth/auth_exceptions.dart';
import 'package:my_notes/services/auth/auth_provider.dart';
import 'package:my_notes/services/auth/auth_user.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('Should not be initialized to begin with', () {
      expect(provider.isInitialized, false);
    });

    test('Cannot log out because not initialized', () {
      expect(provider.logOut(),
          throwsA(const TypeMatcher<NotInitializedException>()));
    });

    test('should be able to be initialized', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('user should be null after initialization', () async {
      expect(provider._user, null);
    });

    test('should be initialized in less than 2 seconds', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test('create user should delegate to login function', () async {
      await provider.initialize();
      final badEmailUser =
          provider.createUser(email: 'foo@bar.com', password: 'anyPassword');
      expect(badEmailUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));

      final badPassUser =
          provider.createUser(email: 'any@email.com', password: 'foobar');
      expect(badPassUser,
          throwsA(const TypeMatcher<WrongPasswordAuthException>()));

      final user = await provider.createUser(
          email: 'good@email.com', password: "goodPassword");
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test('logged in user should be able to get verified', () async {
      await provider.initialize();
      await provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('should be able to login and logout', () async {
      await provider.initialize();
      await provider.logOut();
      expect(provider.currentUser, null);
      await provider.logIn(email: 'good@lol.com', password: 'goodPassword');
      expect(provider.currentUser, isNotNull);
      expect(provider.currentUser!.isEmailVerified, false);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;

  bool get isInitialized => _isInitialized;
  @override
  AuthUser? get currentUser => _user;

  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) async {
    if (!_isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 3));
    return logIn(email: email, password: password);
  }

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 3));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn(
      {required String email, required String password}) async {
    if (!_isInitialized) throw NotInitializedException();
    if (email == 'foo@bar.com') throw UserNotFoundAuthException();
    if (password == 'foobar') throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return _user!;
  }

  @override
  Future<void> logOut() async {
    if (!_isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!_isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
  }
}
