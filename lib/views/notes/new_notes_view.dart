import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:sqflite/sqflite.dart';

class NewNotesView extends StatefulWidget {
  const NewNotesView({super.key});

  @override
  State<NewNotesView> createState() => _NewNotesViewState();
}

class _NewNotesViewState extends State<NewNotesView> {
  //when we hot reload, the futurebuilder containing future<createUser> will be called again which will create a new note again
  DatabaseNote? _note;
  
  //we need to keep hold on the noteservice, we will create a private fiela for it 
  late final NotesService _notesService;

  // keep track of the text changes 
  late final TextEditingController _textEditingController; 

  @override
  void initState(){
    _notesService=NotesService();
    _textEditingController=TextEditingController();
    super.initState();
  }

  void _textEditingListener() async {
    final note= _note;
    if(note==null){
      return;
    }
    final text= _textEditingController.text;
    await _notesService.updateNote(note: note, text: text,);
  }

  void _setupTextControllerListener(){
    _textEditingController.removeListener(_textEditingListener);
    _textEditingController.addListener(_textEditingListener);
  }



  Future<DatabaseNote> createNewNote ()async {
    final existingNote= _note;
    if(existingNote!=null){
      return existingNote;
    }
    final currentUser= AuthService.firebase().currentUser;
    final email=currentUser!.email!;
    final owner= await _notesService.getUser(email: email);
    return await _notesService.createNote(owner: owner);
  }

  void _deleteNoteIfTextIsEmpty(){
    final note= _note;
    if(_textEditingController.text.isEmpty && note!=null){
      _notesService.deleteNote(id: note.id);
    }
  }

  Future<void> _saveNoteIfTextNotEmpty() async {
    final note=_note;
    final text= _textEditingController.text;
    if( note!=null &&text.isNotEmpty ){
      await _notesService.updateNote(note: note, text: text,);
    }
    }
    @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textEditingController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Note"),
      ),
    body:FutureBuilder(future: createNewNote(), 
    builder: (context, snapshot){
      switch (snapshot.connectionState) {
        case ConnectionState.done:
          _note= snapshot.data as DatabaseNote;
          _setupTextControllerListener();
          return TextField(
            controller: _textEditingController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: "start typing in here",
            ),
          );
          break;
        default:
        return const CircularProgressIndicator(); //when the createNewNote future completes then only we are able to see done
      }
    }
   )
    );
  }
}
