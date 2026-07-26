import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/core/constants/app_constants.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';

/// The user's saved custom chord notations (Settings → Chords).
///
/// Stored in `shared_preferences` as a string list, the same pattern as the
/// theme mode. These chords are always offered in the editor's Quick Chord
/// Inserter, after the key's own chords.
class CustomChordsNotifier extends Notifier<List<String>> {
  /// Longest chord notation accepted, so bad input stays harmless.
  static const int maxChordLength = 12;

  @override
  List<String> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return List.unmodifiable(
      prefs.getStringList(AppConstants.prefCustomChords) ?? const <String>[],
    );
  }

  /// Saves a chord. Returns `false` (and saves nothing) when the trimmed text
  /// is empty, longer than [maxChordLength], or already saved.
  Future<bool> add(String chord) async {
    final clean = chord.trim();
    if (clean.isEmpty || clean.length > maxChordLength) return false;
    if (state.contains(clean)) return false;
    await _save([...state, clean]);
    return true;
  }

  /// Removes a saved chord. Unknown chords are ignored.
  Future<void> remove(String chord) async {
    if (!state.contains(chord)) return;
    await _save(state.where((c) => c != chord).toList());
  }

  Future<void> _save(List<String> chords) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setStringList(AppConstants.prefCustomChords, chords);
    state = List.unmodifiable(chords);
  }
}

/// The saved custom chords, in the order the user added them.
final customChordsProvider =
    NotifierProvider<CustomChordsNotifier, List<String>>(
      CustomChordsNotifier.new,
    );
