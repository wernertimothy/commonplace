import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'repository_provider.dart';

/// All projects. Invalidate to refresh after a mutation.
final projectsProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(noteRepositoryProvider).listProjects();
});

/// Notes inside a given project folder.
final notesProvider = FutureProvider.autoDispose.family((ref, String folderPath) {
  return ref.watch(noteRepositoryProvider).listNotes(folderPath);
});

/// Optional description for a project folder, keyed by folder path.
final descriptionProvider =
    FutureProvider.autoDispose.family((ref, String folderPath) {
  return ref.watch(noteRepositoryProvider).readDescription(folderPath);
});
