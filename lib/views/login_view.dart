import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_Exception.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';


class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
        title: const Text("Login"),
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
                try {
                  await AuthService.firebase().logIn(
                    email: email,
                    password: password,
                  );
                  final user = AuthService.firebase().currentUser;
                  if (user?.isEmailVerified ?? false) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      notesRoute,
                      (route) => false,
                    );
                  } else {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      verifyRoutes,
                      (route) => false,
                    );
                  }
                }
                 on UserNotFoundAuthException {
                (
                      context,
                      'User-Not-Found',
                    );
                 }
                 on WrongPasswordAuthException{
                  await showErrorDialog(
                      context,
                      'wrong password',
                    );
                 }
                 on GenericAuthException {
                  await showErrorDialog(
                    context,
                    'Authentication Error', 
                  );
                 }
              },
              child: const Text('login')),
          TextButton(
            onPressed: () => {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(registerRoute, (route) => false)
            },
            child: const Text("Not registered yet? Register here!"),
          )
        ],
      ),
    );
  }
}
