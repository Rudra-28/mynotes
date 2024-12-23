import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:mynotes/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  AuthService(this.provider);

  // FirebaseAuthProvider() creates an instance of the FirebaseAuthProvider class. 
  //This is the concrete authentication provider that implements the AuthProvider interface using Firebase.
  factory AuthService.firebase()=> AuthService(FirebaseAuthProvider(),);
  //FirebaseAuthProvider instance is passed as an argument to the main AuthService constructor:

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  })=> provider.createUser(email: email, password: password,);

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) => provider.logIn(email: email, password: password,);

  @override
  Future<void> logOut()=> provider.logOut();
   
  @override
  Future<void> sendEmailVerification()=> provider.sendEmailVerification();
  
  @override
  Future<void> initialize()=> provider.initialize();
}