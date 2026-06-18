import 'package:flutter/material.dart';

/// Lora serif — used for note reading & editing content (the Claude-style
/// split: serif for body text, default sans for UI chrome). The font is
/// bundled as an app asset (see pubspec `fonts:`), so it works fully offline.
TextStyle serif(BuildContext context, {double? fontSize, double height = 1.5}) {
  return TextStyle(
    fontFamily: 'Lora',
    fontSize: fontSize,
    height: height,
    color: Theme.of(context).colorScheme.onSurface,
  );
}
