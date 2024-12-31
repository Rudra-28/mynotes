import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utilities/dialogs/delete_dialog.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';

typedef noteCallBack = void Function(DatabaseNote note);

class NotesListView extends StatelessWidget {
  final List<DatabaseNote> notes;
  final noteCallBack onDeleteNote;
  final noteCallBack onTap;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: ()=>{
            onTap(note)
          },
          trailing: IconButton(onPressed: () async{
            final shouldDelete = await showDeleteDialog(context);
            if(shouldDelete){
              onDeleteNote(note);
            }
          }, icon: Icon(Icons.delete)),
        );
      },
    );
  }
}
