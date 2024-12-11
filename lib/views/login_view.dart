// ignore_for_file: unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key, required String title});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
 late final TextEditingController _email;
  late final TextEditingController _password; 

  @override
  void initState() {
    _email=TextEditingController();
    _password=TextEditingController();
    super.initState();
  }
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LOGIN'),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
                options: DefaultFirebaseOptions.currentPlatform,
                ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Column(
          children: [
              TextField(
              controller: _email,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Enter your email here: ",
              ),
            ),
            TextField(
              controller: _password,
              enableSuggestions: false,
              autocorrect: false,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                hintText: "Enter your Password here: ",
              ),
            ),
            TextButton(
              onPressed: (
              ) async{
                final email=_email.text;
                final password=_password.text;
               try{ final userCredential= await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                print("Login successful! User: ${userCredential.user}");
               }
                on FirebaseAuthException catch (e){
                  print("Code: ${e.code}");
                  print("Message: ${e.message}");
                  print("Full Exception: $e");
                  
                   if (e.code == 'invalid-credential') {
                     print("User not found");
                   } else if  (e.code== 'wrong-password'){
                    print('wrong password');
                   }
               }
              },
            child:const Text('login')
            ),
          ],
        );
        default:
        return const Text("loading....");
          }
       }, 
      ),
    );
  }
}  