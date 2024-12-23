//we are going to abstract the firebase auth into the own provider
// out firebase_auth_provider is going to be the concrete implementation of the file auth_provider
// this file or class is going to return a instances of the abstract class in the auth_provider
import 'package:firebase_core/firebase_core.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_exception.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException;

class FirebaseAuthProvider implements AuthProvider {
  
   @override
  Future<void> initialize() async {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw WeakPasswordAuthException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
   Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInException();
      }
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      if (e.code == 'invalid-credential'){
          throw UserNotFoundAuthException();
      }else if (e.code== 'wrong-password'){
          throw WrongPasswordAuthException();
      }else {
          throw GenericAuthException();
      }
    } catch (_) {
          throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    final user =FirebaseAuth.instance.currentUser;
    if(user != null){
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInException();
    }
  }
}
//auth service is also going to implement auth_provider 
//auth services expose all the functionalities of the provider to the UI,
// we are doing this so the service and the provider both can fucntion together and provide go ui fucntionality.

