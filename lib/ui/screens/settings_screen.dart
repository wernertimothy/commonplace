import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: RadioGroup<ThemeMode>(
        groupValue: mode,
        onChanged: (m) {
          if (m != null) notifier.setMode(m);
        },
        child: ListView(
          children: const [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Appearance',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            RadioListTile<ThemeMode>(
              title: Text('System default'),
              value: ThemeMode.system,
            ),
            RadioListTile<ThemeMode>(
              title: Text('Light'),
              value: ThemeMode.light,
            ),
            RadioListTile<ThemeMode>(
              title: Text('Dark'),
              value: ThemeMode.dark,
            ),
          ],
        ),
      ),
    );
  }
}
