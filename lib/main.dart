import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/verifyemail_view.dart';
// ignore: unused_import
import 'dart:developer' as devtools show log;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: <String, WidgetBuilder>{
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute:(context)=> const NotesView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                if (user.emailVerified) {
                  return const NotesView();
                } else {
                  return const VerifyEmailView();
                }
              } else {
                return const LoginView();
              }
            default:
              return const CircularProgressIndicator();
          }
        });
  }
}

enum MenuAction { logout }

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<MenuAction>(onSelected: (value)async{
            switch (value) {
              case MenuAction.logout:
                final shouldlogout= await showLogOutDisplay(context);
                if(shouldlogout){
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute,
                    (_) => false
                    );
                }
            }
          },
           itemBuilder: (context){
            return const [ PopupMenuItem<MenuAction>(
              value: MenuAction.logout,
              child: Text("Log out"),
              ),
            ];
          },)
        ],
        title: const Text("Your Notes"),
      ),
      body: Text("hello world"),
    );
  }
}

Future<bool> showLogOutDisplay(BuildContext context){
  return showDialog<bool>(
    context:context,
    builder: (context){
      return AlertDialog(
        title: const Text('sign out'),
        content: const Text('are you sure you want to log out'),
        actions: [
          TextButton(onPressed: ()=> {
            Navigator.of(context).pop(false)
          }, child:const Text('Cancel'),),
          TextButton(onPressed: ()=> {
            Navigator.of(context).pop(true)
          }, child: const Text ('Log out'),),
        ],
      );
    },
  ).then((value) => value ?? false );
}

