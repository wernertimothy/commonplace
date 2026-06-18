/// A note is a single `.md` file inside a topic.
class Note {
  /// Display title (the file name without the `.md` extension).
  final String title;

  /// Absolute filesystem path to the `.md` file.
  final String path;

  const Note({required this.title, required this.path});
}
