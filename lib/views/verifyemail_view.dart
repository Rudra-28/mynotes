import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify email")),
      body: Column(
        children: [
          const Text("We have sent you and email verify verification link please open it to verify accout."),
          SizedBox(height: 10,),
          const Text("If you haven't receieved a verification email please enter below"),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().sendEmailVerification();
            },
            child: Text("Send email verification"),
          ),
          TextButton(
            onPressed: () async{
              await AuthService.firebase().logOut();
              Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route)=>false,);
          },
           child: const Text("Restart")),
        ],
      ),
    );
  }
}
