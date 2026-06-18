import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/file_note_repository.dart';
import '../data/note_repository.dart';

/// The app-wide repository. Swap this single line to change storage backends
/// (e.g. a synced backend later) without touching the rest of the app.
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return FileNoteRepository();
});
