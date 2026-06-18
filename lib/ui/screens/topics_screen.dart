import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/project.dart';
import '../../state/providers.dart';
import '../../state/repository_provider.dart';
import '../widgets/add_rename_dialog.dart';
import '../widgets/detail_header.dart';
import '../widgets/list_helpers.dart';
import 'notes_screen.dart';

/// Project detail: the project name, an optional description, then a
/// "Topics" header above the topic list.
class TopicsScreen extends ConsumerWidget {
  final Project project;

  const TopicsScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topics = ref.watch(topicsProvider(project));
    final description = ref.watch(descriptionProvider(project.path)).value ?? '';
    final repo = ref.read(noteRepositoryProvider);

    Future<void> editDescription() async {
      final text = await showDescriptionDialog(context, initialValue: description);
      if (text != null) {
        await repo.writeDescription(project.path, text);
        ref.invalidate(descriptionProvider(project.path));
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
                        child: Text('No topics yet. Tap + to create one.'),
                      ),
                  ],
                );
              }
              final topic = items[i - 1];
              return ListTile(
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
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final details = await showItemDialog(context, title: 'New topic');
          if (details != null) {
            await repo.createTopic(project, details.name,
                description: details.description);
            ref.invalidate(topicsProvider(project));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
