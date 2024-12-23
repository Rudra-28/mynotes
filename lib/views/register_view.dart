import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exception.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';

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
                  await AuthService.firebase().createUser(
                    email: email,
                    password: password,
                  );
                  await AuthService.firebase().sendEmailVerification();
                  Navigator.of(context).pushNamed(verifyRoutes);
                } on WeakPasswordAuthException {
                  await showErrorDialog(
                    context,
                    'Enter Strong Password',
                  );
                } on EmailAlreadyInUseAuthException {
                  await showErrorDialog(
                    context,
                    'Email already in use, Use different email address',
                  );
                } on InvalidEmailAuthException {
                  await showErrorDialog(
                    context,
                    'Please enter valid email address',
                  );
                } on GenericAuthException {
                  await showErrorDialog(
                      context, 'A registeration error occurred');
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
