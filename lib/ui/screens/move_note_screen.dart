import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/note.dart';
import '../../state/repository_provider.dart';

/// A place a note can be moved to: a project folder.
class _Destination {
  final String label; // project name
  final String path; // destination folder path

  const _Destination(this.label, this.path);
}

/// Picker that lists every project as a move destination.
/// Pops with the chosen destination folder path (String), or null if cancelled.
class MoveNoteScreen extends ConsumerStatefulWidget {
  final Note note;

  const MoveNoteScreen({super.key, required this.note});

  @override
  ConsumerState<MoveNoteScreen> createState() => _MoveNoteScreenState();
}

class _MoveNoteScreenState extends ConsumerState<MoveNoteScreen> {
  List<_Destination>? _destinations;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(noteRepositoryProvider);
    final currentFolder = _parentPath(widget.note.path);
    final dests = <_Destination>[];
    for (final project in await repo.listProjects()) {
      dests.add(_Destination(project.name, project.path));
    }
    // Don't offer the note's current location.
    dests.removeWhere((d) => d.path == currentFolder);
    if (!mounted) return;
    setState(() => _destinations = dests);
  }

  String _parentPath(String filePath) {
    final i = filePath.lastIndexOf('/');
    return i <= 0 ? filePath : filePath.substring(0, i);
  }

  @override
  Widget build(BuildContext context) {
    final dests = _destinations;
    return Scaffold(
      appBar: AppBar(title: Text('Move "${widget.note.title}"')),
      body: dests == null
          ? const Center(child: CircularProgressIndicator())
          : dests.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Nowhere else to move this note yet.\n'
                      'Create another project first.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: dests.length,
                  itemBuilder: (context, i) {
                    final d = dests[i];
                    return ListTile(
                      title: Text(d.label),
                      onTap: () => Navigator.pop(context, d.path),
                    );
                  },
                ),
    );
  }
}
