import '../models/note.dart';
import '../models/project.dart';
import '../models/topic.dart';

/// The single boundary between the app and where notes are stored.
///
/// The UI and state layers depend only on this interface, never on the
/// filesystem directly. This is what makes future storage changes (e.g. a
/// synced backend for desktop access) an additive change: provide a new
/// implementation, leave everything else untouched.
abstract class NoteRepository {
  // Projects.
  Future<List<Project>> listProjects();
  Future<Project> createProject(String name, {String? description});
  Future<Project> renameProject(Project project, String newName);
  Future<void> deleteProject(Project project);

  // Topics within a project.
  Future<List<Topic>> listTopics(Project project);
  Future<Topic> createTopic(Project project, String name, {String? description});
  Future<Topic> renameTopic(Topic topic, String newName);
  Future<void> deleteTopic(Topic topic);

  // Notes. A note is a `.md` file inside any folder — either a topic folder
  // or, since topics are optional, directly inside a project folder. Notes are
  // therefore addressed by their containing folder path.
  Future<List<Note>> listNotes(String folderPath);
  Future<Note> createNote(String folderPath, String title);
  Future<Note> renameNote(Note note, String newTitle);
  Future<void> deleteNote(Note note);

  /// Moves a note into [destFolderPath] (a project or topic folder),
  /// choosing a non-colliding file name if needed. Returns the relocated note.
  Future<Note> moveNote(Note note, String destFolderPath);

  // Note content.
  Future<String> readNote(Note note);
  Future<void> writeNote(Note note, String content);

  /// Reads the optional description stored alongside a project/topic folder.
  /// Returns an empty string when none exists.
  Future<String> readDescription(String folderPath);

  /// Writes (or clears) the description for a project/topic folder.
  Future<void> writeDescription(String folderPath, String description);
}
