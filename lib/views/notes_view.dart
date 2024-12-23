import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'package:mynotes/services/auth/auth_service.dart';

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
                  await AuthService.firebase().logOut();
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

