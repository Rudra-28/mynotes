import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:mynotes/constants/routes.dart';

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
    _email = TextEditingController();
    _password = TextEditingController();
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
      appBar: AppBar(
        title: Text("Register"),
      ),
      body: Column(
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
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                // ignore: unused_local_variable
                try {
                 
                  final userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                  devtools.log(userCredential.toString());
                } on FirebaseAuthException catch (e) {
                    devtools.log(e.code);
                  if (e.code == 'weak-password') {
                    devtools.log("password too weak");
                  } else if (e.code == 'email-already-in-use') {
                   devtools.log('have different user email');
                  } else if (e.code == 'invalid-email') {
                    devtools.log('please enter valid email address');
                  }
                }
              },
              child: const Text('Register')),
          TextButton(
            onPressed: () => {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(loginRoute, (route) => false),
            },
            child: const Text("Already Registered! so login"),
          )
        ],
      ),
    );
  }
}
