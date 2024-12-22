import 'package:mynotes/services/auth/auth_user.dart';

abstract class AuthProvider {
  AuthUser? get currentUser;
  //Future<AuthUser> method returns a Future that will eventually complete with an AuthUser object. 
  //This indicates that the login operation might take some time (e.g., network request).
  //we are just creating a abstract class but in future(tense) we can implement it in concrete classes. 
  Future<AuthUser> logIn({
    required String email,
    required String password,
  });
  Future<AuthUser> createUser({
    required String email,
    required String password, 
  });
  Future<void> logOut();
  Future<void> sendEmailVerification();
}