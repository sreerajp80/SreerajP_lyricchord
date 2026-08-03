# Change log: document Stage Mode's tablet split-view limitation

Implements: `plans/20260803_152203_features-doc-stage-mode-tablet-gap.md`

## What changed

**`docs/features.md`**

- §2.1 "Dual-Pane Tablet Split View": added a sentence noting Stage Mode is
  not offered in the tablet's right-hand split-view pane, with a pointer to
  §2.4 for the reason.
- §2.4 "Stage Mode (Full-Screen View)": added a bullet, "Phone / Single-Pane
  Only," stating that the full-screen button is hidden when the performance
  view is embedded in the tablet's split-view pane, since full screen there
  would only fill the pane rather than the whole device screen.

## Why

A critical re-read of `docs/features.md` against the current code (in
`lib/screens/song_performance_screen.dart`, `lib/widgets/auto_scroll_controls.dart`,
and `lib/widgets/performance_controls.dart`, all using the `embedded` /
`showFullScreenButton` flag) found this was the only real gap left after four
earlier documentation-only audit passes today. Everything else in the doc —
dependency versions, in-app Help topic count, About screen config, and every
change log from 2026-07-20 onward — already matched the code.

No app code (`lib/`, `android/`) was touched. `flutter analyze` / `flutter
test` are unaffected.
