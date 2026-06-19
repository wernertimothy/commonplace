/// A project is a top-level folder containing notes.
class Project {
  /// Display name (the folder name on disk).
  final String name;

  /// Absolute filesystem path to the project's folder.
  final String path;

  const Project({required this.name, required this.path});
}
