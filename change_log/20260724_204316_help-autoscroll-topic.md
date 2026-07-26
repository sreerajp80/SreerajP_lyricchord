# Change log — Add an "Auto-scroll" help topic

Implements plan: `plans/20260724_204316_help-autoscroll-topic.md`

## What changed

- `lib/screens/help/help_content.dart` — added one new `HelpTopic`
  (`id: 'auto-scroll'`, title "Auto-scroll", icon `Icons.swap_vert`) to the
  `helpTopics` list, placed between "Metronome" and "Select Songs".

The new topic explains auto-scroll during a performance, with four sections:

1. **Two modes** — Manual (fixed speed 0.5x / 1x / 2x) vs Tempo (paced to end at
   song end).
2. **What "bars" means** — a bar/measure is 4 beats in 4/4 time; songs open at
   32 bars; the stepper changes the count 4 at a time.
3. **How Tempo sets the speed** — length comes from bars and BPM; more bars or
   slower BPM = slower scroll; the status line shows bars and length.
4. **Start and stop** — play/pause in the performance controls; Tempo mode stops
   on its own at the song end.

No other files changed. The Help hub and detail page already loop over
`helpTopics`, so the new topic and its route (`/settings/help/auto-scroll`) work
without further edits.

## Verification

- `dart format lib/screens/help/help_content.dart` — no changes needed.
- `flutter analyze lib/screens/help/help_content.dart` — no issues found.
