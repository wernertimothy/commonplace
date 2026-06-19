import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'noteFontSize';

/// Base body font size for note content (the Markdown view & editor).
const double kDefaultNoteFontSize = 18;
const double kMinNoteFontSize = 12;
const double kMaxNoteFontSize = 28;

/// Holds the user's preferred note font size, persisted with shared_preferences.
/// Defaults to [kDefaultNoteFontSize].
class NoteFontSizeNotifier extends Notifier<double> {
  @override
  double build() {
    _load();
    return kDefaultNoteFontSize;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getDouble(_prefsKey);
    if (stored != null) state = stored;
  }

  Future<void> setSize(double size) async {
    state = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefsKey, size);
  }
}

final noteFontSizeProvider =
    NotifierProvider<NoteFontSizeNotifier, double>(NoteFontSizeNotifier.new);
