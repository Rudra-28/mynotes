import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/views/utilities/dialogs/delete_dialog.dart';
import 'package:mynotes/views/utilities/dialogs/error_dialog.dart';

typedef DeleteNoteCallBack = void Function(DatabaseNote note);

class NotesListView extends StatelessWidget {
  final List<DatabaseNote> notes;
  final DeleteNoteCallBack onDeleteNote;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
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
