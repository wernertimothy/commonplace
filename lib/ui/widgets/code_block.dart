import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

/// Renders fenced Markdown code blocks as a GitHub-style box with
/// language-aware syntax highlighting that follows light/dark mode.
///
/// Registered for the `pre` element. We suppress the package's default code
/// rendering ([visitText] returns null) and draw our own box in
/// [visitElementAfterWithContext]. The package still wraps our widget in a
/// `Container(decoration: codeblockDecoration)`, so the caller must blank that
/// decoration out (see `note_screen.dart`) to avoid a double border.
class CodeBlockBuilder extends MarkdownElementBuilder {
  CodeBlockBuilder({required this.isDark, required this.fontSize});

  final bool isDark;
  final double fontSize;

  @override
  bool isBlockElement() => true;

  // Suppress the default scrollable rich-text rendering for `pre` contents.
  @override
  Widget? visitText(md.Text text, TextStyle? preferredStyle) => null;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    // A fenced block is <pre><code class="language-xxx">…</code></pre>.
    final code = element.children?.whereType<md.Element>().firstWhere(
          (e) => e.tag == 'code',
          orElse: () => element,
        );
    final className = code?.attributes['class'] ?? '';
    final language = className.startsWith('language-')
        ? className.substring('language-'.length)
        : '';

    // Trim the single trailing newline the parser keeps on block contents.
    var source = code?.textContent ?? element.textContent;
    if (source.endsWith('\n')) {
      source = source.substring(0, source.length - 1);
    }

    return _CodeBlock(
      source: source,
      language: language.isEmpty ? 'plaintext' : language,
      isDark: isDark,
      fontSize: fontSize,
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({
    required this.source,
    required this.language,
    required this.isDark,
    required this.fontSize,
  });

  final String source;
  final String language;
  final bool isDark;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    // GitHub code-surface colours.
    final background =
        isDark ? const Color(0xFF161B22) : const Color(0xFFF6F8FA);
    final border = isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: HighlightView(
          source,
          language: language,
          theme: isDark ? _githubDarkTheme : githubTheme,
          padding: const EdgeInsets.all(12),
          textStyle: TextStyle(
            fontFamily: 'monospace',
            fontSize: fontSize,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

/// GitHub-Dark token colours. flutter_highlight ships a light `github` theme
/// but no dark counterpart, so we define a compact one here. Background is left
/// transparent — the surrounding box paints it.
const _githubDarkTheme = <String, TextStyle>{
  'root': TextStyle(color: Color(0xFFC9D1D9), backgroundColor: Colors.transparent),
  'comment': TextStyle(color: Color(0xFF8B949E), fontStyle: FontStyle.italic),
  'quote': TextStyle(color: Color(0xFF8B949E), fontStyle: FontStyle.italic),
  'keyword': TextStyle(color: Color(0xFFFF7B72)),
  'selector-tag': TextStyle(color: Color(0xFFFF7B72)),
  'built_in': TextStyle(color: Color(0xFFFFA657)),
  'type': TextStyle(color: Color(0xFFFFA657)),
  'literal': TextStyle(color: Color(0xFF79C0FF)),
  'number': TextStyle(color: Color(0xFF79C0FF)),
  'symbol': TextStyle(color: Color(0xFF79C0FF)),
  'string': TextStyle(color: Color(0xFFA5D6FF)),
  'regexp': TextStyle(color: Color(0xFFA5D6FF)),
  'meta': TextStyle(color: Color(0xFF79C0FF)),
  'title': TextStyle(color: Color(0xFFD2A8FF)),
  'section': TextStyle(color: Color(0xFFD2A8FF)),
  'function': TextStyle(color: Color(0xFFD2A8FF)),
  'name': TextStyle(color: Color(0xFF7EE787)),
  'attr': TextStyle(color: Color(0xFF79C0FF)),
  'attribute': TextStyle(color: Color(0xFF79C0FF)),
  'variable': TextStyle(color: Color(0xFFFFA657)),
  'template-variable': TextStyle(color: Color(0xFFFFA657)),
  'tag': TextStyle(color: Color(0xFF7EE787)),
  'bullet': TextStyle(color: Color(0xFFF2CC60)),
  'link': TextStyle(color: Color(0xFFA5D6FF), decoration: TextDecoration.underline),
  'emphasis': TextStyle(fontStyle: FontStyle.italic),
  'strong': TextStyle(fontWeight: FontWeight.bold),
  'deletion': TextStyle(color: Color(0xFFFFDCD7), backgroundColor: Color(0xFF67060C)),
  'addition': TextStyle(color: Color(0xFFAFF5B4), backgroundColor: Color(0xFF033A16)),
};
