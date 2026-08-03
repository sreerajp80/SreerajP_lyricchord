# Make features.md App Description fully inclusive

**Status:** approval_pending

## Files to change

- `docs/features.md` — Section 1 ("App Description") only.

## The issue

I audited `docs/features.md` two ways:

1. A codebase check (screens, widgets, providers, services, router, config,
   pubspec, manifest, tests) against the doc. Result: the **feature matrix**
   (Section 2) is accurate and complete. No missing or incorrect features
   found there.
2. A read of the **App Description narrative** (Section 1) against the matrix
   it summarizes. Result: the narrative undersells the app. Several things the
   matrix documents in full are missing from the description that's supposed
   to introduce the app:
   - Themes (System / Light / Dark) — only appears in §2.9
   - The in-app Help Center (7 topics) — only in §2.9
   - The Settings hub / customization (custom chord shortcuts, font choice,
     metronome toggles) as a user-facing capability — only in §2.6/§2.9
   - Search, starred favorites, and multi-selection bulk actions
     (export/share/delete) — workflow 1 only says "Authoring, organizing, and
     formatting"
   - Song duplication / Save-as-copy — only in §2.1/§2.2
   - Multi-language typography (Malayalam fonts) is described only as a
     technical/architecture attribute, not as a feature a user would notice

## The plan for the fix

Edit only Section 1 of `docs/features.md`. No change to Section 2 (matrix),
since the audit found it already complete.

1. Expand workflow bullet 1 ("Creation, Editing & Library Management") to
   mention search, favorites filtering, multi-selection bulk actions
   (export/share/delete), and song duplication — one added clause, not a full
   list.
2. Add one new sentence after the three numbered workflows covering
   **Discoverability & Customization**: Settings hub (custom chord shortcuts,
   font choice, metronome toggles, theme mode) and the in-app Help Center.
3. Add "Light/Dark/System theme modes" to the existing typography bullet in
   "Key Architecture, Technical & Security Attributes," next to the
   Malayalam font mention, so theming is visible as a feature, not just a
   color-hex technical detail.

No wording will be added to Section 2. No claims will be invented — every
addition points to an already-documented, already-shipped feature in the
matrix.

## Draft of the new text

Replace workflow bullet 1's first sentence:

> 1. **Creation, Editing & Library Management:** Authoring, organizing, and
>    formatting lyric sheets with inline chord bracket syntax (`[Chord]word`),
>    metadata (original key, BPM, artist), custom chord shortcuts, and
>    key-aware scale degree chord suggestions.

with:

> 1. **Creation, Editing & Library Management:** Authoring, organizing, and
>    formatting lyric sheets with inline chord bracket syntax (`[Chord]word`),
>    metadata (original key, BPM, artist), custom chord shortcuts, and
>    key-aware scale degree chord suggestions — with instant search, starred
>    favorites, song duplication, and multi-selection bulk export/share/delete
>    across the library.

Add a new paragraph directly after the three numbered workflows (before
"Songs and setlists move in and out..."):

> The app is fully self-serve: a Settings hub lets a musician define custom
> chord shortcuts, pick a lyric font (including dedicated Malayalam
> typefaces), choose a Light/Dark/System theme, and set up the metronome —
> backed by an in-app Help Center covering setlists, metronome, auto-scroll,
> full screen, selecting songs, export, and import.

Amend the typography bullet under "Key Architecture...":

> using Material 3 design system with a signature High-Density palette
> (`#0052CC` blue Light primary, `#FFD54F` amber Dark primary, with
> `#D0BCFF` used as the floating-action-button accent)...

append at end of that bullet (after the FAB accent clause, before the next
clause about Riverpod):

> — available in System Default, Light, and Dark theme modes —

(placed so the sentence reads naturally; exact insertion point to be
confirmed while editing).

## Not doing

- Not touching Section 2 (matrix) — audit found it complete.
- Not adding a new top-level section for Settings/Help — keeping this as a
  narrative addition to Section 1 only, per the doc's existing structure.
