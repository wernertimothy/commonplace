import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/theme_provider.dart';
import 'ui/screens/projects_screen.dart';

void main() {
  runApp(const ProviderScope(child: CommonplaceApp()));
}

class CommonplaceApp extends ConsumerWidget {
  const CommonplaceApp({super.key});

  ThemeData _theme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    // Warm dark grey, similar to Claude's dark UI — softer than pure black.
    const darkBackground = Color(0xFF262624);
    // Slightly off-white text in dark mode, softer than pure white.
    const offWhite = Color(0xFFE8E6E1);
    var scheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: brightness,
    );
    scheme = isDark
        // Dark: dark-grey surface, off-white text.
        ? scheme.copyWith(surface: darkBackground, onSurface: offWhite)
        // Light: text uses the dark-mode background colour instead of black.
        : scheme.copyWith(onSurface: darkBackground);
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? darkBackground : null,
      // The + button inverts against the background: dark in light mode,
      // off-white in dark mode.
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: isDark ? offWhite : darkBackground,
        foregroundColor: isDark ? darkBackground : offWhite,
      ),
      useMaterial3: true,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'Commonplace',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      home: const ProjectsScreen(),
    );
  }
}
