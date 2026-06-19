import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/note.dart';
import '../../state/providers.dart';
import '../../state/repository_provider.dart';
import '../screens/move_note_screen.dart';
import '../screens/note_screen.dart';
import 'add_rename_dialog.dart';
import 'list_helpers.dart';

/// A single note row, shown on the project-detail screen.
/// Handles opening, renaming, deleting and moving the note, refreshing the
/// list it belongs to ([folderPath]) after each change.
class NoteTile extends ConsumerWidget {
  final Note note;
  final String folderPath;
  final String projectName;

  const NoteTile({
    super.key,
    required this.note,
    required this.folderPath,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(noteRepositoryProvider);

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 32, right: 16),
      title: Text(note.title),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NoteScreen(
              note: note,
              projectName: projectName,
            ),
          ),
        );
        // Title may have changed if the note was renamed.
        ref.invalidate(notesProvider(folderPath));
      },
      trailing: PopupMenuButton<String>(
        onSelected: (action) async {
          switch (action) {
            case 'rename':
              final name = await showNameDialog(
                context,
                title: 'Rename note',
                initialValue: note.title,
              );
              if (name != null) {
                await repo.renameNote(note, name);
                ref.invalidate(notesProvider(folderPath));
              }
            case 'move':
              final dest = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (_) => MoveNoteScreen(note: note)),
              );
              if (dest != null) {
                await repo.moveNote(note, dest);
                ref.invalidate(notesProvider(folderPath)); // source list
                ref.invalidate(notesProvider(dest)); // destination list
              }
            case 'delete':
              final ok = await confirmDelete(context, note.title);
              if (ok) {
                await repo.deleteNote(note);
                ref.invalidate(notesProvider(folderPath));
              }
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'rename', child: Text('Rename')),
          PopupMenuItem(value: 'move', child: Text('Move…')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    );
  }
}
