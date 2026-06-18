import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/note.dart';
import '../../state/repository_provider.dart';
import '../text_styles.dart';

/// Displays a single note. Defaults to a rendered Markdown view and toggles
/// into a raw-text editor. Edits are written back to the `.md` file when
/// leaving edit mode or the screen.
class NoteScreen extends ConsumerStatefulWidget {
  final Note note;
  final String projectName;

  /// Null when the note lives directly in a project (no topic).
  final String? topicName;

  const NoteScreen({
    super.key,
    required this.note,
    required this.projectName,
    this.topicName,
  });

  @override
  ConsumerState<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends ConsumerState<NoteScreen> {
  final _controller = TextEditingController();
  bool _isEditing = false;
  bool _loading = true;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final content = await ref.read(noteRepositoryProvider).readNote(widget.note);
    if (!mounted) return;
    _controller.text = content;
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_dirty) return;
    await ref.read(noteRepositoryProvider).writeNote(widget.note, _controller.text);
    _dirty = false;
  }

  void _toggleMode() async {
    if (_isEditing) {
      // Leaving edit mode: persist changes before rendering.
      await _save();
    }
    setState(() => _isEditing = !_isEditing);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      onPopInvokedWithResult: (didPop, _) => _save(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.note.title),
          actions: [
            IconButton(
              tooltip: _isEditing ? 'Done' : 'Edit',
              icon: Icon(_isEditing ? Icons.check : Icons.edit),
              onPressed: _loading ? null : _toggleMode,
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breadcrumb: "Project" or "Project / Topic" (sans, muted).
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text(
                      widget.topicName == null
                          ? widget.projectName
                          : '${widget.projectName} / ${widget.topicName}',
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                  const Divider(height: 16),
                  Expanded(
                    child: _isEditing
                        ? _Editor(
                            controller: _controller,
                            onChanged: () => _dirty = true,
                          )
                        : _Preview(text: _controller.text),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Raw Markdown text editor (serif body, matching the rendered view).
class _Editor extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _Editor({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (_) => onChanged(),
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      autofocus: true,
      style: serif(context, fontSize: 16, height: 1.5),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(16),
        hintText: '# Start writing Markdown…',
      ),
    );
  }
}

/// Rendered Markdown view, styled with the Lora serif (Claude-like body).
class _Preview extends StatelessWidget {
  final String text;

  const _Preview({required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) {
      return Center(
        child: Text(
          'Empty note.\nTap the pencil to start writing.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).disabledColor),
        ),
      );
    }
    final theme = Theme.of(context);
    final loraTheme = theme.copyWith(
      textTheme: theme.textTheme.apply(fontFamily: 'Lora'),
    );
    return Markdown(
      data: text,
      selectable: true,
      padding: const EdgeInsets.all(16),
      styleSheet: MarkdownStyleSheet.fromTheme(loraTheme),
    );
  }
}
