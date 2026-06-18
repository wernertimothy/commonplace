/// A topic is a subfolder of a project, containing notes.
class Topic {
  /// Display name (the folder name on disk).
  final String name;

  /// Absolute filesystem path to the topic's folder.
  final String path;

  const Topic({required this.name, required this.path});
}
