import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project.dart';
import '../models/topic.dart';
import 'repository_provider.dart';

/// All projects. Invalidate to refresh after a mutation.
final projectsProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(noteRepositoryProvider).listProjects();
});

/// Topics within a given project.
final topicsProvider = FutureProvider.autoDispose.family((ref, Project project) {
  return ref.watch(noteRepositoryProvider).listTopics(project);
});

/// Notes within a given topic.
final notesProvider = FutureProvider.autoDispose.family((ref, Topic topic) {
  return ref.watch(noteRepositoryProvider).listNotes(topic);
});

/// Optional description for a project/topic folder, keyed by folder path.
final descriptionProvider =
    FutureProvider.autoDispose.family((ref, String folderPath) {
  return ref.watch(noteRepositoryProvider).readDescription(folderPath);
});
