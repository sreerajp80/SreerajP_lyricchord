# Plan: Clean Up Swaram Lines (Database Schema v6)

**Status:** completed

## Problem Explanation
In LyricChord:
- **Yellow line on top** = Chords written inside brackets `[...]`.
- **White line below** = Song lyrics / text.

In the previous version, chord brackets like `[C]` were placed inside the Swaram lines (e.g. `[C]S - R - G...`). This caused LyricChord to treat `[C]` as a chord and display a yellow `S` on top of the white `S` text below, creating confusing double lines.

## Proposed Fix
1. Remove chord brackets (`[...]`) from the `Swaram:` text lines in the classical seed songs so they render cleanly as single white Swara lines without floating yellow chords above them.
2. Bump database `schemaVersion` from `5` to `6` with an `onUpgrade` (`from < 6`) migration to refresh existing databases.

## Target Files
1. `lib/data/app_database.dart` — Remove chord brackets from Swaram lines in `_seedClassicSongs()`, `_seedMissingClassicSongs()`, and `_updateSwaraNotationWithHyphens()`. Add schema v6 migration.
2. `test/repositories/song_repository_test.dart` — Add unit test for schema v6 migration.

## Verification Plan
- Run `flutter analyze` to verify clean static analysis.
- Run `flutter test` to ensure all tests pass.
