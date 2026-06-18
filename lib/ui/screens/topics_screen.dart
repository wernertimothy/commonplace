import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/project.dart';
import '../../state/providers.dart';
import '../../state/repository_provider.dart';
import '../widgets/add_rename_dialog.dart';
import '../widgets/detail_header.dart';
import '../widgets/list_helpers.dart';
import '../widgets/note_tile.dart';
import 'notes_screen.dart';

/// Project detail: the project name, an optional description, a "Topics"
/// section (optional sub-containers), and a "Notes" section for notes that
/// live directly in the project.
class TopicsScreen extends ConsumerWidget {
  final Project project;

  const TopicsScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topics = ref.watch(topicsProvider(project));
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

    Future<void> addTopic() async {
      final details = await showItemDialog(context, title: 'New topic');
      if (details != null) {
        await repo.createTopic(project, details.name,
            description: details.description);
        ref.invalidate(topicsProvider(project));
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
      sectionLabel: 'Topics',
      onEditDescription: editDescription,
    );

    return Scaffold(
      appBar: AppBar(title: Text(project.name)),
      body: topics.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (topicItems) {
          final noteItems = notes.value ?? const [];
          return ListView(
            children: [
              header,
              if (topicItems.isEmpty)
                const _Hint('No topics yet. Tap + to add one.'),
              for (final topic in topicItems)
                ListTile(
                  title: Text(topic.name),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NotesScreen(
                        topic: topic,
                        projectName: project.name,
                      ),
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) async {
                      if (action == 'rename') {
                        final name = await showNameDialog(
                          context,
                          title: 'Rename topic',
                          initialValue: topic.name,
                        );
                        if (name != null) {
                          await repo.renameTopic(topic, name);
                          ref.invalidate(topicsProvider(project));
                        }
                      } else if (action == 'delete') {
                        final ok = await confirmDelete(context, topic.name);
                        if (ok) {
                          await repo.deleteTopic(topic);
                          ref.invalidate(topicsProvider(project));
                        }
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'rename', child: Text('Rename')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
              const _SectionHeader('Notes'),
              if (noteItems.isEmpty)
                const _Hint('No notes here yet. Tap + to add one.'),
              for (final note in noteItems)
                NoteTile(
                  note: note,
                  folderPath: project.path,
                  projectName: project.name,
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Get the choice first, then act once the sheet has closed —
          // showing a dialog while the sheet is dismissing swallows it.
          final choice = await showModalBottomSheet<String>(
            context: context,
            builder: (sheetContext) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.topic_outlined),
                    title: const Text('New topic'),
                    onTap: () => Navigator.pop(sheetContext, 'topic'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text('New note'),
                    onTap: () => Navigator.pop(sheetContext, 'note'),
                  ),
                ],
              ),
            ),
          );
          if (choice == 'topic') await addTopic();
          if (choice == 'note') await addNote();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Bold section label matching the header's style.
class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// Muted placeholder line for an empty section.
class _Hint extends StatelessWidget {
  final String text;

  const _Hint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Text(
        text,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}
