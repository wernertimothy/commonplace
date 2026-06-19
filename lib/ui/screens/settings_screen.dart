import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/note_font_provider.dart';
import '../../state/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);
    final fontSize = ref.watch(noteFontSizeProvider);
    final fontNotifier = ref.read(noteFontSizeProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: RadioGroup<ThemeMode>(
        groupValue: mode,
        onChanged: (m) {
          if (m != null) notifier.setMode(m);
        },
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Appearance',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const RadioListTile<ThemeMode>(
              title: Text('System default'),
              value: ThemeMode.system,
            ),
            const RadioListTile<ThemeMode>(
              title: Text('Light'),
              value: ThemeMode.light,
            ),
            const RadioListTile<ThemeMode>(
              title: Text('Dark'),
              value: ThemeMode.dark,
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text('Reading',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text('Note font size'),
                  Expanded(
                    child: Slider(
                      value: fontSize,
                      min: kMinNoteFontSize,
                      max: kMaxNoteFontSize,
                      divisions: (kMaxNoteFontSize - kMinNoteFontSize).round(),
                      label: fontSize.round().toString(),
                      onChanged: fontNotifier.setSize,
                    ),
                  ),
                  SizedBox(
                    width: 28,
                    child: Text(
                      fontSize.round().toString(),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
            // Live preview of the chosen size.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'The quick brown fox jumps over the lazy dog.',
                style: TextStyle(fontSize: fontSize, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
