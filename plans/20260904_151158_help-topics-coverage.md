# Help section — full topic coverage and fixes

**Status:** completed

## Files to be changed

- `lib/screens/help/help_content.dart` — the only content file. Add new topics, fix wrong text in existing ones.
- `test/screens/help_content_test.dart` (new, if no test exists) — a small test that every topic has a unique id, a title, a summary and at least one section.
- `docs/features.md` §2.11 — the line that says the Help Center covers 7 topics needs the new count and names.

No other file changes. The Help hub and detail screen already build themselves from `helpTopics`, so adding a topic needs no screen change.

## The issue

### 1. Missing topics

The app has grown a lot, but Help still has only 9 topics. These shipped features have **no help at all**:

- **The songbook itself** — search, the Starred filter with counts, the Songs / Setlists tabs, duplicating a song, deleting one song, the tablet split view.
- **Writing and editing a song** — the editor, `[C]word` brackets, title/artist/key/BPM fields, the key-aware chord bar, custom chord shortcuts, undo/redo, "Save as copy", the discard-changes guard.
- **Transpose and the chord reference** — the Performance controls sheet (−/+/Reset, −11 to +11), Show chords, and the Chord Reference Guide with guitar and harmonium diagrams (Swara Reference on an Indian song).
- **AirQR** — sending and receiving songs as an animated QR stream between two phones with no internet, Bluetooth or Wi-Fi. It appears in five places (songbook top bar, Share dialog, Import & Export screen both ways) and is explained nowhere.
- **Indian songs (Carnatic / Hindustani)** — the notation picker, Raga and Tala fields, the tala mismatch note, `{tonic:}`, `{sruti: madhyama}`, Swara Reference, and "Paste Carnatic notation" in the editor.
- **Look and feel** — Themes (System / Light / Dark), the lyric font picker with English and Malayalam previews, pinch to change text size, and the Stage Text Scale chips.
- **Stage Lock and Stage Quiet Mode** — two buttons in the full-screen bar. Lock needs the phone's fingerprint or PIN to leave; Quiet Mode mutes the ringer and alerts but keeps the app's own sound. Neither is mentioned.

### 2. Errors in the topics that exist

- **Pitch Pipe & Shruti Box → "5-Tier Stage Font Scaling".** Wrong twice. There is no font scale icon in the Stage bar; the size is picked from five per-cent chips in the Pitch sheet and in Settings. And the scale is not stage-only — it multiplies the sheet text size everywhere (`song_performance_screen.dart:913`). The section title is also jargon, against the simple-English rule.
- **Auto-scroll → "What 'bars' means".** It says "The app uses common 4/4 time, so one bar is 4 beats". That is only true for a song with no tala. `AutoScrollSettings.beatsPerMeasure` is taken from the song's `{tala}`, so a misra chapu song counts 7 beats to the bar.
- **Export → "Export one song as PDF".** There is no "Export as PDF" menu item. The menu item is "Export", which then asks ChordPro or PDF. The topic also never mentions Share (a separate menu item) or that PDF page width now follows the song's longest line.
- **Export / Import.** Neither mentions AirQR, although both screens offer it.
- **Full screen → "The gestures".** Correct as far as it goes, but the control bar list is missing the Exit, Lock, Quiet, M/T, pitch and stepper buttons that are actually on it.
- **Melody → "Hearing it".** Fine, but "More options → Melody keypad" and "Paste Carnatic notation" (both in the *editor's* menu, not the performance menu) are never pointed at from Help.

## The plan for the fix

### A. Fix the existing topics

1. `pitch-pipe-drone`: replace the "5-Tier Stage Font Scaling" section with a plain-English **"Text size on stage"** section — five sizes from 85% to 130%, picked as chips in the Pitch sheet or in Settings → General → Pitch Pipe & Shruti Box, and it applies to the sheet everywhere, not only full screen.
2. `auto-scroll`: in "What 'bars' means", say a bar is 4 beats for an ordinary song, and that a song with a `{tala}` counts the tala's own beats instead.
3. `export`: rename the PDF steps to match the real menu ("Export" → pick PDF), add a **Share** section (ChordPro, PDF, or AirQR), add bulk share from the songbook, and note the PDF page is only as wide as the song needs.
4. `import`: add a short section pointing at the new AirQR topic.
5. `full-screen`: add a **"The buttons in the bar"** section listing Exit, Lock, Quiet, M / T, Play, Pitch, and the −/+ stepper.
6. `melody`: add one line in "Writing one" pointing at the Melody keypad, and one in a new closing section pointing at the Indian-songs topic for pasting published notation.

### B. Add six new topics

Order on the hub, easiest first:

1. `songbook` — **Your songbook**: search, Starred, tabs, new song, duplicate, delete, tablet split view, newest-first order.
2. `editor` — **Write a song**: brackets, metadata, chord bar, custom chords, undo/redo, Save as copy, discard guard.
3. `transpose` — **Transpose & chord shapes**: the Performance controls sheet, ±11 semitones, Reset, Show chords, Chord Reference Guide, guitar and harmonium diagrams, Swara Reference.
4. `indian-songs` — **Carnatic & Hindustani songs**: notation picker, Raga and Tala, the tala note, `{tonic:}`, `{sruti: madhyama}`, Paste Carnatic notation, Swara Reference, and that swaras are never transposed.
5. `airqr` — **AirQR (send songs screen to screen)**: what it is, sending one song, sending the whole book, receiving by camera or from a photo, the FPS slider, and that it needs no internet, Bluetooth or Wi-Fi.
6. `appearance` — **Themes, fonts & text size**: theme modes, the lyric font picker (English and Malayalam previews), pinch to zoom, the five stage text sizes, and that the chosen font is used in the PDF too.

Existing topic ids are not changed, so any saved link keeps working.

### C. Keep it honest and simple

Every new line is checked against the code before it is written. Short sentences, common words, jargon explained — as the project rules require.

### D. After the change

- `flutter analyze` must be clean.
- `flutter test` must pass.
- `dart format .`
- Write the change log in `change_log/`.
