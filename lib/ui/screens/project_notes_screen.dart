import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/project.dart';
import '../../state/providers.dart';
import '../../state/repository_provider.dart';
import '../widgets/add_rename_dialog.dart';
import '../widgets/detail_header.dart';
import '../widgets/note_tile.dart';

/// Project detail: the project name, an optional description, and the list of
/// notes that live directly in the project.
class ProjectNotesScreen extends ConsumerWidget {
  final Project project;

  const ProjectNotesScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider(project.path));
    final description = ref.watch(descriptionProvider(project.path)).value ?? '';
    final repo = ref.read(noteRepositoryProvider);

    Future<void> editDescription() async {
      final text = await showDescriptionDialog(context, initialValue: description);
      if (text != null) {
        await repo.writeDescription(project.path, text);
        ref.invalidate(descriptionProvider(project.path));
      }
    }

    Future<void> addNote() async {
      final title = await showNameDialog(
        context,
        title: 'New note',
        confirmLabel: 'Create',
      );
      if (title != null) {
        await repo.createNote(project.path, title);
        ref.invalidate(notesProvider(project.path));
      }
    }

    final header = DetailHeader(
      title: project.name,
      description: description,
      sectionLabel: 'Notes',
      onEditDescription: editDescription,
    );

    return Scaffold(
      appBar: AppBar(title: Text(project.name)),
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
                  child: Text('No notes yet. Tap + New Note to create one.'),
                ),
              for (final note in items)
                NoteTile(
                  note: note,
                  folderPath: project.path,
                  projectName: project.name,
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addNote,
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ),
    );
  }
}
