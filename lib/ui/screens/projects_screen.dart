import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/providers.dart';
import '../../state/repository_provider.dart';
import '../widgets/add_rename_dialog.dart';
import '../widgets/list_helpers.dart';
import 'settings_screen.dart';
import 'topics_screen.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);
    final repo = ref.read(noteRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: projects.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyHint(
              icon: Icons.folder_open,
              message: 'No projects yet.\nTap + to create one.',
            );
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) {
              final project = items[i];
              return ListTile(
                title: Text(project.name),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TopicsScreen(project: project),
                  ),
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (action) async {
                    if (action == 'rename') {
                      final name = await showNameDialog(
                        context,
                        title: 'Rename project',
                        initialValue: project.name,
                      );
                      if (name != null) {
                        await repo.renameProject(project, name);
                        ref.invalidate(projectsProvider);
                      }
                    } else if (action == 'delete') {
                      final ok = await confirmDelete(context, project.name);
                      if (ok) {
                        await repo.deleteProject(project);
                        ref.invalidate(projectsProvider);
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
          final details = await showItemDialog(
            context,
            title: 'New project',
          );
          if (details != null) {
            await repo.createProject(details.name,
                description: details.description);
            ref.invalidate(projectsProvider);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
