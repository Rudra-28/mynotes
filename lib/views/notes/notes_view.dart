import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {

  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;
  
  @override
  void initState() {
    _notesService=NotesService();
    _notesService.open();
    super.initState();
  }

  @override
  void dispose() {
    _notesService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: (){
              Navigator.of(context).pushNamed(newNoteRoute);
            }, icon: const Icon(Icons.add)),
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
      //a snapshot is an instance of the AsyncSnapshot class that contains the state and result of a Future or Stream operation
      body: FutureBuilder(
      future: _notesService.getOrCreateUser(email: userEmail),
      builder: (context, snapshot){
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return StreamBuilder(
              //at the beginning there are no notes so the stream is empty(null) due to which it is in the state of waiting 
              //but as soon as there is atleast one note we have only condition for empty ie is waiting,
              // we need to add the case of active also, for present we were showing circularprogressindicator.
              stream: _notesService.allNotes, 
              builder: (context, snapshot){
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.active://here we are implicitly following through
                    return const Text("Waiting for all notes");
                  default: 
                    return CircularProgressIndicator();
                }
              }
            );
          default:
            return CircularProgressIndicator();
        }
       },
      )
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

