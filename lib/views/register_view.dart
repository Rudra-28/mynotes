import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
      appBar: AppBar(title: const Text('Registration'),
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
                // ignore: unused_local_variable
                try{
                  // ignore: unused_local_variable
                  final useCredential= await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                print(UserCredential);
                }
                on FirebaseAuthException catch(e){
                  print(e.code);
                  if(e.code == 'weak-password'){
                    print("password too weak");
                  }
                  else if(e.code == 'email-already-in-use'){
                    print('have different user email');
                  }
                  else if(e.code =='invalid-email'){
                    print('please enter valid email address');
                  }
                }     
              },
            child:const Text('Register')
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

