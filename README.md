# Commonplace

A Markdown note-taking app for Android, built with Flutter. Notes are organized as a
simple tree — **Projects → Topics → Notes** — where every note is a real Markdown file.
Each note opens in a clean rendered view and toggles into a raw Markdown editor, the way
notes render on GitHub or in VS Code.

## Features

- **Hierarchy:** Projects contain Topics and/or Notes; Topics contain Notes. One note =
  one `.md` file. **Topics are optional** — a note can live directly in a project.
- **Move notes** between projects and topics at any time.
- **View ↔ edit:** notes render as formatted Markdown by default and switch to a plain-text
  editor with a single tap.
- **Optional descriptions** on projects and topics, editable any time.
- **Theme:** Light / Dark / System (default System), remembered across launches.
- **Lora serif** for note content (Claude-style split: serif for reading, sans for UI chrome),
  bundled as an asset so it works fully offline.
- **Private & offline:** the release build ships with **no device permissions** (no internet,
  storage, location, etc.). Notes live only in the app's private storage and never leave the device.

## Architecture

- **Files as source of truth.** Notes are real `.md` files under the app's private
  documents directory — in a topic (`<app>/commonplace/<Project>/<Topic>/<note>.md`) or
  directly in a project (`<app>/commonplace/<Project>/<note>.md`). Moving a note just
  relocates the file. Project/topic descriptions are stored in a hidden `.description.md`
  per folder.
- **Repository seam.** All storage goes through the `NoteRepository` interface
  (`lib/data/note_repository.dart`), implemented today by `FileNoteRepository`
  (`lib/data/file_note_repository.dart`). This keeps the UI independent of storage, so a synced
  backend (or a search index) can be added later as a new implementation without touching the UI.
- **State** is managed with [Riverpod](https://riverpod.dev) (`lib/state/`).

```
lib/
  data/      NoteRepository interface + filesystem implementation
  models/    Project, Topic, Note
  state/     Riverpod providers (repository, lists, descriptions, theme)
  ui/
    screens/   projects, topics (project detail), notes (topic detail), note (view/edit), settings
    widgets/   reusable dialogs, list helpers, detail header
```

Search and AI summarization are intentionally out of scope for now but the design leaves room
for both: a SQLite full-text index rebuilt from the files, and reading note text into an LLM API.

## Getting started

```bash
flutter pub get
flutter run                       # run on a connected device or emulator
```

To install a release build directly on a connected device:

```bash
flutter run --release -d <device-id>   # see `flutter devices` for ids
```

## Status

Personal project, Android-first. The release build is currently debug-signed (fine for
sideloading to your own device; not for the Play Store). Desktop and cross-device sync are
possible future directions thanks to the repository seam.
