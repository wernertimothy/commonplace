import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/topic.dart';
import '../../state/providers.dart';
import '../../state/repository_provider.dart';
import '../widgets/add_rename_dialog.dart';
import '../widgets/detail_header.dart';
import '../widgets/list_helpers.dart';
import 'note_screen.dart';

/// Topic detail: the topic name, an optional description, then a "Notes"
/// header above the note list.
class NotesScreen extends ConsumerWidget {
  final Topic topic;
  final String projectName;

  const NotesScreen({
    super.key,
    required this.topic,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider(topic));
    final description = ref.watch(descriptionProvider(topic.path)).value ?? '';
    final repo = ref.read(noteRepositoryProvider);

    Future<void> editDescription() async {
      final text = await showDescriptionDialog(context, initialValue: description);
      if (text != null) {
        await repo.writeDescription(topic.path, text);
        ref.invalidate(descriptionProvider(topic.path));
      }
    }

    final header = DetailHeader(
      title: topic.name,
      description: description,
      sectionLabel: 'Notes',
      onEditDescription: editDescription,
    );

    return Scaffold(
      appBar: AppBar(title: Text(topic.name)),
      body: notes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          return ListView.builder(
            itemCount: items.length + 1,
            itemBuilder: (context, i) {
              if (i == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    header,
                    if (items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Text('No notes yet. Tap + to create one.'),
                      ),
                  ],
                );
              }
              final note = items[i - 1];
              return ListTile(
                title: Text(note.title),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NoteScreen(
                        note: note,
                        projectName: projectName,
                        topicName: topic.name,
                      ),
                    ),
                  );
                  // Title may have changed if the note was renamed.
                  ref.invalidate(notesProvider(topic));
                },
                trailing: PopupMenuButton<String>(
                  onSelected: (action) async {
                    if (action == 'rename') {
                      final name = await showNameDialog(
                        context,
                        title: 'Rename note',
                        initialValue: note.title,
                      );
                      if (name != null) {
                        await repo.renameNote(note, name);
                        ref.invalidate(notesProvider(topic));
                      }
                    } else if (action == 'delete') {
                      final ok = await confirmDelete(context, note.title);
                      if (ok) {
                        await repo.deleteNote(note);
                        ref.invalidate(notesProvider(topic));
                      }
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'rename', child: Text('Rename')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final title = await showNameDialog(
            context,
            title: 'New note',
            confirmLabel: 'Create',
          );
          if (title != null) {
            await repo.createNote(topic, title);
            ref.invalidate(notesProvider(topic));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
