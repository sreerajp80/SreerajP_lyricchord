# Fix docs/features.md: Stage Mode is not offered in tablet split view

**Status:** completed

## Files to be changed

- `docs/features.md` (documentation only, no code)

## The issue

I did a fresh critical read of `docs/features.md` against the current code
(including the still-uncommitted changes on this branch) and against every
change log entry, since this document has already been through four audit
passes earlier today (see `change_log/20260803_130800_*`,
`20260803_140400_*`, `20260803_143851_*`, `20260803_151039_*`).

Everything checked out except one real gap:

- **Stage Mode (full screen) is hidden on the tablet's split-view pane.**
  In `lib/screens/song_performance_screen.dart:745` the full-screen button is
  built with `showFullScreenButton: !widget.embedded`. `embedded` is true only
  when the performance screen is shown as the right-hand pane of the tablet
  dual-pane shell (`home_shell.dart`). The code comment explains why: "Stage
  Mode is not offered because it would only fill the pane, not the screen."
  This is also wired through `auto_scroll_controls.dart` and
  `performance_controls.dart` (`showFullScreenButton` parameter on both).

  `docs/features.md` §2.1 ("Dual-Pane Tablet Split View") and §2.4 ("Stage
  Mode") both describe these two features but never mention that Stage Mode
  is phone-only / single-pane-only. A reader would reasonably expect Stage
  Mode to work identically on a tablet.

No other gaps were found. I checked:
- All files with uncommitted changes (`git diff --stat`) against the doc.
- Every change log dated 2026-07-20 through 2026-08-03.
- The 7 in-app Help topics (doc says 7, code has exactly 7, including the new
  "Full screen" topic).
- `pubspec.yaml` dependency versions and pinning claims.
- `assets/config/app_config.json` (About screen fields, email address).

## The plan for the fix

Add one short sentence to `docs/features.md`:

1. In §2.4 "Stage Mode (Full-Screen View)", add a bullet noting Stage Mode is
   only offered in the single-pane (phone, or tablet non-split) view — not in
   the tablet's dual-pane split view, since full screen there would only fill
   the right-hand pane rather than covering the whole device screen.
2. In §2.1 "Dual-Pane Tablet Split View", add a short cross-reference noting
   the same limitation, so a reader landing on either section sees it.

No code changes. After editing, write a change log in `change_log/`
referencing this plan.
