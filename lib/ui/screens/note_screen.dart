import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/note.dart';
import '../../state/note_font_provider.dart';
import '../../state/repository_provider.dart';
import '../widgets/code_block.dart';

/// Displays a single note. Defaults to a rendered Markdown view and toggles
/// into a raw-text editor. Edits are written back to the `.md` file when
/// leaving edit mode or the screen.
class NoteScreen extends ConsumerStatefulWidget {
  final Note note;
  final String projectName;

  const NoteScreen({
    super.key,
    required this.note,
    required this.projectName,
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
    final fontSize = ref.watch(noteFontSizeProvider);
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
                  // Breadcrumb: the containing project (sans, muted).
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text(
                      widget.projectName,
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
                            fontSize: fontSize,
                          )
                        : _Preview(
                            text: _controller.text,
                            fontSize: fontSize,
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Raw Markdown text editor (default app font, matching the rendered view).
class _Editor extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
  final double fontSize;

  const _Editor({
    required this.controller,
    required this.onChanged,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (_) => onChanged(),
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      autofocus: true,
      style: TextStyle(
        fontSize: fontSize,
        height: 1.5,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(16),
        hintText: '# Start writing Markdown…',
      ),
    );
  }
}

/// Rendered Markdown view, styled with the default app font.
class _Preview extends StatelessWidget {
  final String text;
  final double fontSize;

  const _Preview({required this.text, required this.fontSize});

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
    final isDark = theme.brightness == Brightness.dark;
    // Scale the whole text theme so headings/lists grow with the body text.
    // Material's default body size is 14, so that's our reference point.
    final scaled = theme.copyWith(
      textTheme: theme.textTheme.apply(fontSizeFactor: fontSize / 14.0),
    );
    // Inline-code highlight: warm in dark mode, soft indigo tint in light mode.
    final highlightBg =
        isDark ? const Color(0xFF3A302B) : const Color(0xFFE8EAF6);
    final highlightFg =
        isDark ? const Color(0xFFE5895B) : const Color(0xFF3949AB);
    return Markdown(
      data: text,
      selectable: true,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      styleSheet: MarkdownStyleSheet.fromTheme(scaled).copyWith(
        // Wider gap between paragraphs and other block elements.
        blockSpacing: 16,
        // Blank out the default code box; CodeBlockBuilder draws its own.
        codeblockDecoration: const BoxDecoration(),
        // Inline code: monospace at body size, with a flat highlight + colour.
        code: scaled.textTheme.bodyMedium?.copyWith(
          fontFamily: 'monospace',
          backgroundColor: highlightBg,
          color: highlightFg,
        ),
      ),
      builders: {
        'pre': CodeBlockBuilder(isDark: isDark, fontSize: fontSize),
      },
    );
  }
}
