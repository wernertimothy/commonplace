import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/note.dart';
import '../models/project.dart';
import '../models/topic.dart';
import 'note_repository.dart';

/// Reserved file name holding a project/topic's optional description.
/// Hidden (dot-prefixed) and excluded from note listings.
const kDescriptionFile = '.description.md';

/// Stores the note tree as real folders and `.md` files under the app's
/// documents directory:
///
///   `<documents>/commonplace/<Project>/<Topic>/<note>.md`
class FileNoteRepository implements NoteRepository {
  Directory? _root;

  /// Lazily resolves and creates the root `commonplace` directory.
  Future<Directory> _rootDir() async {
    var root = _root;
    if (root != null) return root;
    final docs = await getApplicationDocumentsDirectory();
    root = Directory(p.join(docs.path, 'commonplace'));
    if (!await root.exists()) {
      await root.create(recursive: true);
    }
    _root = root;
    return root;
  }

  /// Turns a user-entered name into a safe folder/file name, stripping
  /// characters that are illegal in paths and collapsing whitespace.
  String _sanitize(String name) {
    final cleaned = name
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return cleaned.isEmpty ? 'Untitled' : cleaned;
  }

  /// Lists immediate subdirectory names in [dir], sorted case-insensitively.
  Future<List<Directory>> _listDirs(Directory dir) async {
    if (!await dir.exists()) return [];
    final entries = await dir.list().toList();
    final dirs = entries.whereType<Directory>().toList()
      ..sort((a, b) => p
          .basename(a.path)
          .toLowerCase()
          .compareTo(p.basename(b.path).toLowerCase()));
    return dirs;
  }

  // --- Projects -----------------------------------------------------------

  @override
  Future<List<Project>> listProjects() async {
    final root = await _rootDir();
    final dirs = await _listDirs(root);
    return dirs
        .map((d) => Project(name: p.basename(d.path), path: d.path))
        .toList();
  }

  @override
  Future<Project> createProject(String name, {String? description}) async {
    final root = await _rootDir();
    final safe = _sanitize(name);
    final dir = Directory(p.join(root.path, safe));
    await dir.create(recursive: true);
    await _writeDescriptionIfPresent(dir.path, description);
    return Project(name: safe, path: dir.path);
  }

  @override
  Future<Project> renameProject(Project project, String newName) async {
    final safe = _sanitize(newName);
    final newPath = p.join(p.dirname(project.path), safe);
    await Directory(project.path).rename(newPath);
    return Project(name: safe, path: newPath);
  }

  @override
  Future<void> deleteProject(Project project) async {
    await Directory(project.path).delete(recursive: true);
  }

  // --- Topics -------------------------------------------------------------

  @override
  Future<List<Topic>> listTopics(Project project) async {
    final dirs = await _listDirs(Directory(project.path));
    return dirs
        .map((d) => Topic(name: p.basename(d.path), path: d.path))
        .toList();
  }

  @override
  Future<Topic> createTopic(Project project, String name,
      {String? description}) async {
    final safe = _sanitize(name);
    final dir = Directory(p.join(project.path, safe));
    await dir.create(recursive: true);
    await _writeDescriptionIfPresent(dir.path, description);
    return Topic(name: safe, path: dir.path);
  }

  @override
  Future<Topic> renameTopic(Topic topic, String newName) async {
    final safe = _sanitize(newName);
    final newPath = p.join(p.dirname(topic.path), safe);
    await Directory(topic.path).rename(newPath);
    return Topic(name: safe, path: newPath);
  }

  @override
  Future<void> deleteTopic(Topic topic) async {
    await Directory(topic.path).delete(recursive: true);
  }

  // --- Notes --------------------------------------------------------------

  @override
  Future<List<Note>> listNotes(Topic topic) async {
    final dir = Directory(topic.path);
    if (!await dir.exists()) return [];
    final entries = await dir.list().toList();
    final files = entries
        .whereType<File>()
        .where((f) => p.extension(f.path).toLowerCase() == '.md')
        .where((f) => p.basename(f.path) != kDescriptionFile)
        .toList()
      ..sort((a, b) => p
          .basename(a.path)
          .toLowerCase()
          .compareTo(p.basename(b.path).toLowerCase()));
    return files
        .map((f) => Note(title: p.basenameWithoutExtension(f.path), path: f.path))
        .toList();
  }

  @override
  Future<Note> createNote(Topic topic, String title) async {
    final safe = _sanitize(title);
    final file = File(p.join(topic.path, '$safe.md'));
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    return Note(title: safe, path: file.path);
  }

  @override
  Future<Note> renameNote(Note note, String newTitle) async {
    final safe = _sanitize(newTitle);
    final newPath = p.join(p.dirname(note.path), '$safe.md');
    await File(note.path).rename(newPath);
    return Note(title: safe, path: newPath);
  }

  @override
  Future<void> deleteNote(Note note) async {
    await File(note.path).delete();
  }

  // --- Note content -------------------------------------------------------

  @override
  Future<String> readNote(Note note) async {
    final file = File(note.path);
    if (!await file.exists()) return '';
    return file.readAsString();
  }

  @override
  Future<void> writeNote(Note note, String content) async {
    await File(note.path).writeAsString(content);
  }

  // --- Descriptions -------------------------------------------------------

  @override
  Future<String> readDescription(String folderPath) async {
    final file = File(p.join(folderPath, kDescriptionFile));
    if (!await file.exists()) return '';
    return file.readAsString();
  }

  @override
  Future<void> writeDescription(String folderPath, String description) async {
    final file = File(p.join(folderPath, kDescriptionFile));
    if (description.trim().isEmpty) {
      if (await file.exists()) await file.delete();
      return;
    }
    await file.writeAsString(description);
  }

  /// Writes a description on creation only when a non-empty one is supplied.
  Future<void> _writeDescriptionIfPresent(
      String folderPath, String? description) async {
    if (description != null && description.trim().isNotEmpty) {
      await writeDescription(folderPath, description);
    }
  }
}
