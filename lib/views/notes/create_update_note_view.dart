import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utilities/generics/get_arguments.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
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

  void _textControllerListener() async {
    final note= _note;
    if(note==null){
      return;
    }
    final text= _textEditingController.text;
    await _notesService.updateNote(note: note, text: text,);
  }

  void _setupTextControllerListener(){
    _textEditingController.removeListener(_textControllerListener);
    _textEditingController.addListener(_textControllerListener);
  }

  Future<DatabaseNote> createOrGetExistingNote(BuildContext)async {

    final WidgetNote = context.getArguments<DatabaseNote>();

    if(WidgetNote!=null){
      _note=WidgetNote;
      _textEditingController.text=WidgetNote.text;
      return WidgetNote;
    }    
    final existingNote= _note;
    if(existingNote!=null){
      print('createNewNote() started'); 
      return existingNote;
    }
    final currentUser= AuthService.firebase().currentUser!;
    final email=currentUser.email!;
    print('Current user email: $email');
    final owner= await _notesService.getUser(email: email);
    print('Owner retrieved: $owner');
    final newNote= await _notesService.createNote(owner: owner);
    _note = newNote;
    print("returning new note");
    return newNote;
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
    body:FutureBuilder(
    future: createOrGetExistingNote(context), 
    builder: (context, snapshot){
      switch (snapshot.connectionState) {
        case ConnectionState.done:
          _setupTextControllerListener();
          return TextField(
            controller: _textEditingController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: "start typing in here",
            ),
          );
        default:
        return const CircularProgressIndicator(); //when the createNewNote future completes then only we are able to see done
      }
    }
   )
    );
  }
}
