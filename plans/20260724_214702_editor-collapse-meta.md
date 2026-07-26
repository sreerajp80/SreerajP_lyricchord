# Plan: Collapse meta fields while editing lyrics

**Status:** completed

## The issue

In the Song Editor screen, the whole screen is one `Column`: the meta fields
(Title, Artist, Original key, Tempo, Add to Setlist), then the Quick Chord
Inserter bar, then the lyrics `TextField` inside an `Expanded`.

When the keyboard opens, the Scaffold body shrinks, but the meta fields keep
their full height at the top. That squeezes the lyrics `Expanded` down to a
single visible line above the keyboard. The user can type, but can only see one
line of lyrics — it feels like the lyrics cannot be edited.

## The fix (chosen approach: collapse meta when typing)

Make the meta section collapse when the lyrics field has focus, so the lyrics
area gets the freed-up vertical space. When the user taps out of the lyrics
field (or taps a toggle), the meta section comes back.

Behaviour:

- The editor watches focus on the lyrics field (`_lyricsFocus`).
- When the lyrics field gains focus, the meta section collapses (hidden or a
  short one-line summary header).
- When the lyrics field loses focus, the meta section expands again.
- A small toggle (chevron) lets the user open the meta section back up without
  leaving the lyrics field, in case they need to change the key/tempo while
  writing.
- Collapse/expand uses `AnimatedSize` (or `AnimatedCrossFade`) for a smooth
  transition, not a hard jump.

This keeps the "notepad with chords one tap away" feel: the chord bar stays
visible, and the lyrics area is tall while typing.

## Files to change

1. `lib/screens/song_editor_screen.dart`
   - Add a focus listener on `_lyricsFocus` that drives a `bool _metaCollapsed`
     via `setState`.
   - Add a small collapse/expand toggle (chevron button or a tappable summary
     header) so the user can override the auto-collapse.
   - Wrap `SongMetaFields` in an `AnimatedSize` / `AnimatedCrossFade` driven by
     `_metaCollapsed`.
   - When collapsed, optionally show a compact one-line summary
     (e.g. `Title · Key · BPM`) so the user still knows what song they are on.
   - Wire up / dispose the focus listener correctly in `initState` / `dispose`.

2. `lib/widgets/song_meta_fields.dart` (only if needed)
   - No behaviour change expected. May extract a tiny `MetaSummary` widget for
     the collapsed one-line summary, or that summary can live in the screen.
     Prefer keeping `SongMetaFields` a pure UI block with no new state.

No changes to providers, services, repositories, models, database, or the
chord inserter. This is a layout/UX change only.

## Testing

- `flutter analyze` must stay clean.
- `flutter test` must stay green (no logic changed).
- Manual check on a phone-sized layout:
  - Open an existing song, tap the lyrics: meta collapses, lyrics area is tall,
    can see many lines while typing.
  - Tap out of lyrics: meta expands again.
  - Tap the toggle while typing: meta opens without losing the keyboard.
  - New-song flow still shows the meta fields first (before the lyrics field is
    focused).
- No new widget test is strictly required (pure layout), but a small widget test
  that focusing the lyrics field hides the Title field would guard the
  behaviour. Add it if it is cheap.

## Notes

- Like-for-like port rule: this is a layout fix to make editing usable on a
  phone with the keyboard up. It does not add features or change the palette.
- Keep `main.dart` untouched; all changes stay in the editor screen (and maybe
  the meta widget).
