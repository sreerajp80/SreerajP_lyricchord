# Add missing file citations to docs/features.md

**Status:** completed

## Files to be changed
- `docs/features.md`

## The issue
An audit compared `docs/features.md` against the actual code. The document is
complete and accurate. Two small things are missing: two source file names are
not mentioned, even though the features they provide are already described in
words.

1. Section 2.3 "Live Performance View" describes the performance screen in
   detail, but never names the files `lib/screens/song_performance_screen.dart`
   and `lib/providers/performance_provider.dart`.
2. Section 2.9 describes the font engine and lists "Fonts" as a Settings Hub
   entry, but never names the file `lib/screens/font_settings_screen.dart` or
   mentions that each font option shows a live English + Malayalam preview.

## The plan for the fix
- In section 2.3, add the two file names (`song_performance_screen.dart`,
  `performance_provider.dart`) to the existing bullet text, so readers can find
  the code behind the described behavior.
- In section 2.9, add the file name `font_settings_screen.dart` next to the
  font engine bullet, and add a short note that each font option shows a live
  preview in both English and Malayalam.

No feature behavior changes. This is a documentation-only edit.
