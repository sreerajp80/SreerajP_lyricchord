# LyricCord — Product Idea & Requirements

This document explains **what** LyricCord is and **why** it exists. It is the
starting point for building the Flutter version of the app. Read it before
writing any Flutter code, so the app you build matches the product intent.

LyricCord already exists as an Android app (Jetpack Compose + Room) at
`L:\Android\lyriccord`. This document captures that app's concept and behaviour
so it can be rebuilt in Flutter with the same experience.

**Read first**

- [../CLAUDE.md](../CLAUDE.md) — the plan-before-changing and log-after-changing
  rules for this project.
- [GUIDELINES_MANIFEST.md](GUIDELINES_MANIFEST.md) — the shared Flutter
  guideline set (submodule under `guidelines/`).
- [guidelines/architecture.md](guidelines/architecture.md) — the architecture
  blueprint to fill in next, after this idea doc is agreed.

---

## 1. Core concept

LyricCord is a **lyrics and chords notebook for musicians**. It lets a
singer or player keep their own songbook, and then use it hands-free while
performing.

- **Who it is for:** guitar players, keyboard/harmonium players, worship teams,
  buskers, and songwriters who want their own chord sheets on their phone or
  tablet.
- **The one-line pitch:** "A beautiful song lyrics and chords editor with
  built-in transposition, auto-scroll, and chord charts."
- **The two jobs it does:**
  1. **Write** — type lyrics and drop chords inline where you strum them.
  2. **Perform** — open a song, transpose it to your voice, and let it
     auto-scroll while you play.

Chords are stored **inline** inside the lyrics using square brackets, for
example:

```text
[G]Amazing [G7]Grace, how [C]sweet the [G]sound
```

The bracket sits immediately before the syllable where the chord is played. The
app renders the chord as a small badge floating above that syllable.

### Why convert to Flutter

- **One codebase, more platforms.** The Android app is Compose-only. Flutter
  lets the same app run on Android, iOS, and (optionally) desktop.
- **Keep the exact experience.** This is a re-implementation, not a redesign.
  The Flutter app should feel the same as the Android app described here.

---

## 2. Feature set (carried over from the Android app)

Grouped by area. Everything here already works in the Android app and must be
reproduced in Flutter.

### Songbook

- Local list of songs, newest activity first.
- **Search** across title, artist, and lyrics text.
- **Favorites** — star a song; filter to "Starred" vs "All Songs" with live
  counts.
- Each list card shows title, artist, the song **key** badge, and **BPM** badge.
- Delete a song from its card.
- The app ships **seeded** with three classic songs (Amazing Grace, House of
  the Rising Sun, Jingle Bells) so a new user sees content immediately.

### Editor

- Fields: **Title**, **Artist/Band**, **Original Key**, **Tempo (BPM)**.
- A large, distraction-free **lyrics text area** (no visible borders).
- **Quick Chord Inserter** toolbar above the keyboard:
  - Shows **key-aware chord suggestions** — for the entered key it offers the
    common chords of that major or minor key (I, ii, iii, IV, V, vi, V7, ♭VII,
    etc.).
  - Tapping a chord inserts `[Chord]` at the cursor position.
  - **Custom chord** button to add any notation (e.g. `F#m7`, `Cmaj7`, `D/F#`)
    to the toolbar.
- Save or cancel from the top bar.

### Performance view (song detail)

- Clean lyric sheet with chord badges above the words.
- **Performance Controls** panel (collapsible) with:
  - **Transpose** up/down by semitone, with the live resulting key shown and a
    **Reset** action. Transposition is slash-chord aware (`C/E` → both parts
    move) and picks sharp/flat spelling sensibly.
  - **Show Chords** toggle (hide chords to read lyrics only).
  - **Font size** decrease/increase (10–32 sp).
  - **Auto-scroll**, with two modes:
    - **Manual Speed** — play/pause plus 0.5x / 1x / 2x speed.
    - **Tempo Auto** — set BPM and length in measures; the app computes the
      total duration and scroll speed so the sheet **ends exactly at the end of
      the song**. It shows the computed duration and px/second.
  - Auto-scroll stops itself when it reaches the bottom.
- **Swipe** left/right to move to the previous/next song in the current list
  (a horizontal pager).

### Chord reference

- A **Chord Reference Guide** dialog listing the song's chords (transposed to
  the current key), with two tabs:
  - **Guitar** — fretboard diagrams (fingering, open/muted strings, base fret).
  - **Harmonium** — keyboard-style diagrams.

### Import / export

- **ChordPro import** — open a `.chordpro` / text file; directives like
  `{title}`, `{artist}`, `{key}`, `{bpm}`, and chorus/verse markers are parsed.
- **ChordPro export** — save the song back out (with transposed chords if a
  transpose is active).
- **PDF export** — an A4 sheet with title/artist/key/BPM, guitar chord diagrams
  for the chords used, and the lyrics with chords; multi-page aware.

### Appearance

- **Theme mode**: System default / Light / Dark, remembered between launches.

---

## 3. Experience / UX

The app has three main experiences. On a phone they are separate screens; on a
tablet the list and the detail/editor sit side by side.

### 3.1 List experience

- Top bar with the "LyricCord" wordmark and subtitle "Lyrics & Chords Notebook".
- Overflow menu: **Import ChordPro** and **theme** choices.
- Search field, then the **All Songs / Starred** filter row.
- Scrollable list of song cards.
- Floating **+** button to write a new song.
- Empty state with a friendly "write your first lyric chord sheet" message.

### 3.2 Performance experience

- Top bar: back (phone only), song title + artist, **edit** button, and an
  overflow menu (**Chord Reference Guide**, **Export as PDF**, **Export as
  ChordPro**, theme).
- Collapsible **Performance Controls** card (see §2).
- The scrolling lyric sheet fills the rest of the screen.

### 3.3 Editor experience

- Top bar: cancel (X), title ("New Song Note" / "Edit Song Note"), and **save**.
- Meta fields (title, artist, key, BPM), then the chord toolbar, then the lyrics
  editor.
- Goal: writing lyrics should feel like a plain notepad, with chords one tap
  away.

---

## 4. Design system

- **Framework look:** Material 3.
- **Palette:** a violet "High Density" theme.
  - Primary (light): `#6750A4`; primary (dark): `#D0BCFF`.
  - Light background `#FDF8FD`, dark background `#141218`.
  - Chord badges use the theme **secondary** colour so they stand out over
    lyric text.
- **Light and dark** are both first-class; the choice follows the theme-mode
  setting (system/light/dark).
- **Typography:** standard Material type scale for UI; chord badges are **bold
  monospace** so chords line up and read clearly.
- **Responsive layout:**
  - **Phone (< 600 dp wide):** one screen at a time — list, or detail, or
    editor.
  - **Tablet (≥ 600 dp wide):** **dual pane** — song list on the left (~38%),
    detail or editor on the right (~62%), with an "empty detail" welcome state
    when nothing is selected.

> When rebuilding in Flutter, match these colours and the 600 dp breakpoint so
> the app looks the same across devices. Prefer Flutter's Material 3
> (`ColorScheme`) with these seed/role colours rather than re-inventing them.

---

## 5. Navigation & screen map

There is no deep navigation stack; the app is driven by a small amount of state
(selected song, editing on/off).

```text
List  ──tap song──▶  Performance (detail)  ──edit──▶  Editor
  ▲                        │  ▲                          │
  └────────back────────────┘  └───────save / cancel──────┘
  │
  └──+ (new song)──▶ Editor (blank)

Performance ──swipe◀▶── previous / next song in the list
Performance ──menu──▶ Chord Reference Guide (dialog: Guitar | Harmonium)
```

- On tablet, "List" and "Performance/Editor" are shown together instead of
  replacing each other.
- Import and theme are actions from menus, not separate screens.

---

## 6. Data model & storage

- Storage is **fully local** (an on-device database). No account, no cloud sync.
- One entity, the song note:

| Field | Type | Meaning |
| --- | --- | --- |
| `id` | int (auto) | Primary key |
| `title` | text | Song title |
| `artist` | text | Artist / band (may be blank) |
| `lyrics` | text | Lyrics with inline `[Chord]` markers |
| `key` | text | Original key (e.g. `C`, `Am`) |
| `bpm` | int | Tempo in beats per minute |
| `favorite` | bool | Starred or not |
| `timestamp` | long | Last-modified time (ms) |

- **Settings** (theme mode) are stored as a simple key–value preference, not in
  the song database.
- The Flutter version should use a local database (for example `sqflite` or
  `drift`) and a key–value store (for example `shared_preferences`), matching
  this shape. Final choices belong in `architecture.md`.

---

## 7. Import / export formats

- **ChordPro** is the interchange format.
  - **Import** understands `{title|t}`, `{artist|a}`, `{key|k}`,
    `{bpm|tempo}`, `{comment|c}`, and start/end of chorus/verse directives;
    everything else is treated as a lyric line.
  - **Export** writes those directives back plus the lyrics, applying the
    current transpose if one is active.
- **PDF** is an output-only format for printing/sharing a clean sheet (title,
  artist, key/BPM, guitar diagrams, and chorded lyrics; A4; multi-page).

---

## 8. Out of scope / not carried over

- **Gemini / Firebase AI.** The Android project *declares* a Gemini/Firebase AI
  capability in its metadata and build files, but the app code **does not use
  it** — there is no AI feature in the running app. The Flutter conversion does
  **not** include any AI feature. If AI is ever wanted, it is a new project of
  its own.
- **Accounts, cloud sync, sharing services.** The app is single-device and
  offline; none of these exist today and none are in scope for the conversion.
- **Extra instruments beyond guitar and harmonium** diagrams — only these two
  are provided.

---

## 9. Development phases

A suggested order for building the Flutter app. Each phase should end with
something you can run.

1. **Foundation.** Flutter project, Material 3 violet theme (light/dark), local
   database and settings store, the `SongNote` model, and seeded songs.
2. **Songbook.** List screen with search, All/Starred filter, favorite and
   delete, and the responsive phone/tablet layout.
3. **Editor.** Meta fields, distraction-free lyrics editor, and the key-aware
   quick chord inserter (including custom chords). Save/create/cancel.
4. **Performance view.** Chord-over-lyrics renderer, transpose engine (slash
   chords, sharp/flat spelling), show-chords toggle, font sizing, and swipe
   between songs.
5. **Auto-scroll.** Manual speed (0.5x/1x/2x) and Tempo-Auto (BPM + measures,
   ends exactly at song end).
6. **Chord reference.** Guitar and harmonium diagram dialog.
7. **Import / export.** ChordPro import and export, then PDF export.
8. **Polish.** Theme persistence, empty states, tablet dual-pane refinements,
   and accessibility checks per the engineering standard.

The concrete file layout, state-management choice, and package decisions for
these phases are defined in [guidelines/architecture.md](guidelines/architecture.md)
once it is filled in for this app.
