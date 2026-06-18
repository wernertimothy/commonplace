import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/topic.dart';
import '../../state/providers.dart';
import '../../state/repository_provider.dart';
import '../widgets/add_rename_dialog.dart';
import '../widgets/detail_header.dart';
import '../widgets/note_tile.dart';

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
    final notes = ref.watch(notesProvider(topic.path));
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
          return ListView(
            children: [
              header,
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Text('No notes yet. Tap + to create one.'),
                ),
              for (final note in items)
                NoteTile(
                  note: note,
                  folderPath: topic.path,
                  projectName: projectName,
                  topicName: topic.name,
                ),
            ],
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
            await repo.createNote(topic.path, title);
            ref.invalidate(notesProvider(topic.path));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
