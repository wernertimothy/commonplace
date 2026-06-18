import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project.dart';
import 'repository_provider.dart';

/// All projects. Invalidate to refresh after a mutation.
final projectsProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(noteRepositoryProvider).listProjects();
});

/// Topics within a given project.
final topicsProvider = FutureProvider.autoDispose.family((ref, Project project) {
  return ref.watch(noteRepositoryProvider).listTopics(project);
});

/// Notes inside a given folder (a topic folder, or a project folder directly).
final notesProvider = FutureProvider.autoDispose.family((ref, String folderPath) {
  return ref.watch(noteRepositoryProvider).listNotes(folderPath);
});

/// Optional description for a project/topic folder, keyed by folder path.
final descriptionProvider =
    FutureProvider.autoDispose.family((ref, String folderPath) {
  return ref.watch(noteRepositoryProvider).readDescription(folderPath);
});
