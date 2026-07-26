# Fix: PDF export puts each lyric word on its own line

**Status:** completed

## The issue

In the exported PDF, the lyrics do not flow across the page. Every word sits
on its own line (see the Jingle Bells export). The song becomes a very long,
unreadable list of single words.

## Root cause

In `PdfExportService._segment`, each word piece is a small column: a chord
slot on top and the word below. The chord slot is:

```dart
pw.Container(height: 11, child: null)   // when the word has no chord
```

In the `pdf` package (v3.12.0), a `Container` with **no child** and
**not-fully-tight constraints** (here only the height is set, the width is
open) expands to fill **all available width**
(`container.dart`, lines 102–108 of the package).

So every word without a chord becomes as wide as the whole page. The `Wrap`
then has room for only one piece per line, and each word lands on its own
line.

The app screen does not have this bug because Flutter's own `Container`
behaves differently inside the widget it uses there.

## Files to change

- `lib/services/pdf_export_service.dart` — one small change in `_segment`.

## The fix

In `_segment`, stop using an empty `Container` as the chord spacer. Use a
zero-width box instead:

- When the segment **has no chord**: use `pw.SizedBox(width: 0, height: 11)`.
  With both width and height set, the constraints are fully tight, so the box
  stays 0 wide and 11 tall — it only reserves vertical space.
- When the segment **has a chord**: keep the `Container(height: 11)` with the
  chord `Text` as its child (a container *with* a child sizes to the child's
  width, so this case was never broken).

## Test plan

- Add a widget-free unit check is not practical for PDF layout, so verify by:
  - `flutter analyze` — must stay clean.
  - `flutter test` — all existing tests must pass.
  - Rebuild the Jingle Bells PDF (manual check by the user) — lyrics should
    now flow across the page and wrap between words, with chords above the
    right words.
