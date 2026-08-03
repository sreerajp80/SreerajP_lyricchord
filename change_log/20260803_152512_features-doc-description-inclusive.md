# Change log: features.md App Description made inclusive

Implements: `plans/20260803_152512_features-doc-description-inclusive.md`

## What changed

`docs/features.md`, Section 1 ("App Description") only:

1. Workflow bullet 1 now mentions search, starred favorites, song
   duplication, and multi-selection bulk export/share/delete — these were
   already documented in the feature matrix (§2.1) but missing from the
   top-level description.
2. Added a new paragraph after the three numbered workflows describing the
   Settings hub (custom chord shortcuts, font choice, theme, metronome) and
   the in-app Help Center.
3. The typography bullet under "Key Architecture, Technical & Security
   Attributes" now calls out the System/Light/Dark theme modes, so theming
   reads as a user feature and not just a palette hex-code detail.

## Why

A codebase audit (screens, widgets, providers, services, router, config,
pubspec, manifest, tests) confirmed the feature matrix in Section 2 was
already accurate and complete — no missing or wrong features found there.
The only gap was that the narrative App Description undersold the app: it
did not mention Themes, the Help Center, the Settings/customization hub,
search/favorites, bulk actions, or song duplication, even though the matrix
documents all of them in full.

## Scope

Section 2 (the feature matrix) was not touched — the audit found it already
complete and correct.
