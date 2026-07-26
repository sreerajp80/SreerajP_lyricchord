# Add an "Auto-scroll" help topic

**Status:** completed

## Issue

The Help section has topics for Setlists, Metronome, Select Songs, Export, and
Import. It has nothing that explains **auto-scroll**, and in particular the
**Tempo** mode with its "bars" (measures) setting. Users see a status line like
`Auto-scroll · Key G · 120 BPM · 32 bars · 1:04` with no explanation of what
"bars" means or why it controls the scroll speed.

## Files to change

- `lib/screens/help/help_content.dart` — add one new `HelpTopic` for auto-scroll.

No other files change. The Help hub and detail page already loop over
`helpTopics`, so a new entry shows up automatically. The route uses the topic
`id`, which stays inside the same list.

## The plan for the fix

Add a new `HelpTopic` to the `helpTopics` list. Proposed placement: near the top
(before or after Metronome, since both relate to performing). Content:

- **id:** `auto-scroll`
- **title:** `Auto-scroll`
- **icon:** `Icons.swap_vert` (up/down arrows — matches scrolling)
- **summary:** short line, e.g. "Scroll the sheet hands-free while you play".
- **intro:** one plain paragraph: auto-scroll moves the chord sheet up for you
  during a performance, and there are two modes — Manual and Tempo.

Sections:

1. **Two modes** — Manual scrolls at a fixed speed you pick (0.5×, 1×, 2×);
   Tempo works out the song length and paces the scroll to finish exactly at the
   end of the song.
2. **What "bars" means** — a bar (measure) is a musical unit; the app uses 4/4
   time, so one bar = 4 beats. Songs open at 32 bars. Set the bar count with the
   stepper (4 per tap).
3. **How Tempo sets the speed** — song length = bars × 4 beats ÷ BPM; more bars
   or slower BPM = a longer, slower scroll; higher BPM = faster. The status line
   shows the bars and the computed length (m:ss).
4. **Start and stop** — play/pause from the performance controls; scrolling
   stops on its own at the end of the song.

All text is plain English, matches the real behaviour in
`auto_scroll_calculator.dart` / `auto_scroll_provider.dart`, and follows the
existing tone of the other topics.

## After the change

- Run `flutter analyze` (must stay clean) and `dart format .`.
- Write a change log under `change_log/`.
