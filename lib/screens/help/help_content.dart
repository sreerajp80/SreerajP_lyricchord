import 'package:flutter/material.dart';

/// A gesture item with an icon, title, and description.
@immutable
class GestureHelpItem {
  const GestureHelpItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

/// One block of help: a heading and its list of points.
@immutable
class HelpSection {
  const HelpSection({
    required this.heading,
    required this.points,
    this.gestureItems,
  });

  final String heading;
  final List<String> points;
  final List<GestureHelpItem>? gestureItems;
}

/// One help topic shown as a card on the Help hub and its own detail page.
@immutable
class HelpTopic {
  const HelpTopic({
    required this.id,
    required this.title,
    required this.icon,
    required this.summary,
    required this.intro,
    required this.sections,
  });

  /// Stable id used in the route path (`/settings/help/<id>`).
  final String id;
  final String title;
  final IconData icon;

  /// Short line shown under the title on the hub card.
  final String summary;

  /// One-paragraph opening on the detail page.
  final String intro;

  final List<HelpSection> sections;
}

/// All help topics, in the order they appear on the Help hub.
///
/// This is plain, static content — no logic, no state. The text matches the
/// real behaviour of the app.
const List<HelpTopic> helpTopics = [
  HelpTopic(
    id: 'setlists',
    title: 'Setlists',
    icon: Icons.playlist_play,
    summary: 'Group and order songs for a gig or rehearsal',
    intro:
        'A setlist is an ordered group of songs you can play through in one go, '
        'without hunting for each song. Setlists never make copies — they just '
        'point to songs already in your library.',
    sections: [
      HelpSection(
        heading: 'Create a setlist',
        points: [
          'Open the "Setlists" tab on the home screen.',
          'Tap "New Setlist".',
          'Give it a name, and an optional description.',
        ],
      ),
      HelpSection(
        heading: 'Add and arrange songs',
        points: [
          'Inside a setlist, tap "Add Songs" to pick from your library.',
          'Drag the handle on the right to change the order.',
          'Tap the red minus to take a song out of the setlist.',
          'Removing a song from a setlist does not delete it from your library.',
        ],
      ),
      HelpSection(
        heading: 'Perform a setlist',
        points: [
          'Tap "Perform Setlist" to start from the first song.',
          'Or tap any song in the list to start from there.',
          'While performing, move between songs in the setlist order.',
        ],
      ),
      HelpSection(
        heading: 'Delete a setlist',
        points: [
          'Open the setlist and use the delete (trash) icon in the top bar.',
          'This removes only the setlist. The songs stay in your library.',
        ],
      ),
    ],
  ),
  HelpTopic(
    id: 'metronome',
    title: 'Metronome',
    icon: Icons.av_timer,
    summary: 'Keep the beat at the song tempo',
    intro:
        'The metronome keeps time while you perform. Its speed comes from each '
        "song's BPM (beats per minute), which you set in the song editor.",
    sections: [
      HelpSection(
        heading: 'Turn it on',
        points: [
          'Go to Settings > General > Metronome.',
          'Switch on "Enable metronome".',
          'The setting is saved and stays on after you restart the app.',
        ],
      ),
      HelpSection(
        heading: 'Flash and Click',
        points: [
          'Flash blinks on every beat — handy when the sound is muted.',
          'Click plays a short tick on every beat.',
          'You can use either, both, or neither.',
          'Flash and Click stay greyed out until the metronome is enabled.',
          'Click volume sets how loud the tick is. The tick uses the media '
              'volume, so raise the volume buttons while a song is open if you '
              'cannot hear it.',
          'Tap "Test the sound" in Metronome settings to hear one bar without '
              'opening a song.',
        ],
      ),
      HelpSection(
        heading: 'Beats in a bar',
        points: [
          'Pick 2, 3, 4 or 6 beats in a bar in Metronome settings.',
          'With "Accent beat 1" on, the first beat of every bar is louder and '
              'higher, so you can hear where the bar starts.',
          'While the beat runs, the button counts the beat number — 1, 2, 3, 4 '
              '— so you can see your place even with the sound off.',
        ],
      ),
      HelpSection(
        heading: 'Set the tempo',
        points: [
          "By default the beat speed follows the song's BPM.",
          'Change a song\'s BPM by editing the song.',
          'Long press the metronome button to set the speed by hand: use - and '
              '+, drag the slider, or tap "Tap tempo" along with the music.',
          'A tempo you set by hand lasts for this session only. Tap "Use song '
              'tempo" to go back to the song\'s own speed.',
          'A song with no saved BPM still works — the metronome uses the last '
              'speed you used.',
        ],
      ),
    ],
  ),
  HelpTopic(
    id: 'pitch-pipe-drone',
    title: 'Pitch Pipe & Shruti Box',
    icon: Icons.graphic_eq,
    summary: 'Reference pitch cues and a steady shruti box drone',
    intro:
        'A fully offline sound generator: a short reference note to start on, '
        'and a steady shruti box drone to sing against. Nothing is downloaded '
        'and no sound files ship with the app — the tones are built as you '
        'press the button.',
    sections: [
      HelpSection(
        heading: 'What the drone does — and does not do',
        points: [
          'The drone holds ONE steady pair of notes for as long as it is on.',
          'It does NOT follow the tune, the words, or the chords. It never '
              'changes until you change it.',
          'Think of it as a tuning fork that never stops, so your ear stays '
              'anchored while you sing.',
        ],
      ),
      HelpSection(
        heading: 'Where to find it',
        points: [
          'Open a song and tap the pitch button (the bars icon) next to the '
              'metronome.',
          'It is in the Stage Mode bar too, next to the play button.',
          'Settings → General → Pitch Pipe & Shruti Box sets the defaults and '
              'has Test buttons.',
        ],
      ),
      HelpSection(
        heading: 'Pitch cue',
        points: [
          'Tap "Pitch Cue" to hear a 2-second reference note.',
          'Helps singers find their starting note before the song begins.',
        ],
      ),
      HelpSection(
        heading: 'Shruti box drone',
        points: [
          'Tap "Shruti Drone" to start a continuous background hum.',
          'Choose Sa + Pa (the fifth) for most music, or Sa + Ma (the fourth) '
              'for ragas that leave out Pa, such as Malkauns or Marwa.',
          'The two notes are tuned in pure ratios (3:2 and 4:3), the way a real '
              'drone instrument sounds — not in equal temperament.',
          'The drone keeps playing until you stop it, so you can practise '
              'without it cutting out.',
        ],
      ),
      HelpSection(
        heading: 'Indian and Western naming',
        points: [
          'Sa is movable, so the app must know which actual pitch your Sa is. '
              'Set it in Settings → "Your Sa (Shruti)".',
          'A song with a raga is named the Indian way: "5 kattai" for '
              'Carnatic, "safed 5" for Hindustani. The tala decides which. No '
              'Western letters appear on an Indian sheet.',
          'A song without a raga is named the Western way: just "G".',
          'A Western song opens on the song\'s own key. An Indian song opens '
              'on your Sa, because the notation is written relative to Sa.',
        ],
      ),
      HelpSection(
        heading: '5-Tier Stage Font Scaling',
        points: [
          'Dynamic text zoom ranging from 85% up to 130% scale for stage readability.',
          'Tap the font scale icon in Stage HUD to cycle text sizes quickly.',
        ],
      ),
    ],
  ),
  HelpTopic(
    id: 'auto-scroll',
    title: 'Auto-scroll',
    icon: Icons.swap_vert,
    summary: 'Scroll the sheet hands-free while you play',
    intro:
        'Auto-scroll moves the chord sheet up for you while you perform, so you '
        'do not have to touch the screen. There are two modes: Manual and Tempo.',
    sections: [
      HelpSection(
        heading: 'Two modes',
        points: [
          'Manual scrolls at a steady speed you set yourself, from 0.10x up to '
              '2.00x. Use the − and + buttons; each tap changes it by 0.05x.',
          'Tempo works out how long the song lasts and paces the scroll to '
              'finish exactly at the end of the song.',
        ],
      ),
      HelpSection(
        heading: 'What "bars" means',
        points: [
          'A bar (also called a measure) is a musical unit of time.',
          'The app uses common 4/4 time, so one bar is 4 beats.',
          'Songs open at 32 bars. Change the count with the stepper — each tap '
              'adds or removes 4 bars.',
        ],
      ),
      HelpSection(
        heading: 'How Tempo sets the speed',
        points: [
          "Song length comes from the bars and the song's BPM: "
              'bars x 4 beats, at the BPM you set.',
          'More bars or a slower BPM makes a longer, slower scroll.',
          'A higher BPM makes a shorter, faster scroll.',
          'The status line shows the bars and the computed length, like '
              '"32 bars · 1:04".',
        ],
      ),
      HelpSection(
        heading: 'Start and stop',
        points: [
          'Use play and pause in the performance controls to run the scroll.',
          'In Tempo mode the scroll stops on its own at the end of the song.',
        ],
      ),
    ],
  ),
  HelpTopic(
    id: 'full-screen',
    title: 'Full screen',
    icon: Icons.fullscreen,
    summary: 'Just the words, controlled by taps',
    intro:
        'Full screen hides the top bar and the phone\'s own bars, so the song '
        'fills the whole screen. It is made for playing live, where you look at '
        'the screen from a stand and touch it as little as possible.',
    sections: [
      HelpSection(
        heading: 'Going full screen',
        points: [
          'Tap the full screen button in the auto-scroll row.',
          'The song, the key, the text size and the scroll position all stay '
              'as they were.',
          'The screen still stays awake, as it does in the normal song view.',
        ],
      ),
      HelpSection(
        heading: 'The gestures',
        gestureItems: [
          GestureHelpItem(
            icon: Icons.touch_app_outlined,
            title: 'Tap once',
            description: 'Show or hide the controls',
          ),
          GestureHelpItem(
            icon: Icons.keyboard_double_arrow_up,
            title: 'Double-tap up top',
            description: 'Faster',
          ),
          GestureHelpItem(
            icon: Icons.keyboard_double_arrow_down,
            title: 'Double-tap down low',
            description: 'Slower',
          ),
          GestureHelpItem(
            icon: Icons.pan_tool_outlined,
            title: 'Tap with two fingers',
            description: 'Play or pause',
          ),
          GestureHelpItem(
            icon: Icons.zoom_out_map,
            title: 'Pinch',
            description: 'Change the text size',
          ),
          GestureHelpItem(
            icon: Icons.arrow_back,
            title: 'Back',
            description: 'Leave full screen',
          ),
        ],
        points: [
          'Tap once to show or hide the control bar. It slides away again '
              'after a few seconds.',
          'Double-tap the upper half to go faster; double-tap the lower half '
              'to go slower. The new value flashes big on the screen.',
          'In Tempo mode those same double-taps add or remove bars, because '
              'bars are what set the speed there.',
          'Tap with two fingers to play or pause.',
          'Pinch to change the text size, the same as usual.',
        ],
      ),
      HelpSection(
        heading: 'Getting back',
        points: [
          'Press Back, or tap once and use the exit button in the control bar.',
          'That leaves full screen only — you are still on the same song. '
              'Press Back again to return to your songbook.',
          'Swiping sideways does not change the song while you are full '
              'screen, so a stray touch cannot throw the wrong song up mid-song.',
        ],
      ),
    ],
  ),
  HelpTopic(
    id: 'select-songs',
    title: 'Select Songs',
    icon: Icons.checklist,
    summary: 'Act on several songs at once',
    intro:
        'Selection mode lets you choose many songs together and then export or '
        'delete them in one step.',
    sections: [
      HelpSection(
        heading: 'Start selecting',
        points: [
          'On the Songs list, long-press any song to start selection mode.',
          'Tap more songs to add them to the selection.',
          'The top bar shows how many songs are selected.',
        ],
      ),
      HelpSection(
        heading: 'Select all',
        points: [
          'Use the "Select all" icon in the top bar to pick every visible song.',
          'Tap it again ("Deselect all") to clear the selection.',
        ],
      ),
      HelpSection(
        heading: 'What you can do',
        points: [
          'Export the selected songs as one ChordPro file.',
          'Delete the selected songs from your library.',
          'Tap the X on the top-left to leave selection mode without changes.',
        ],
      ),
    ],
  ),
  HelpTopic(
    id: 'export',
    title: 'Export',
    icon: Icons.output_rounded,
    summary: 'Save your songs out of the app',
    intro:
        'Export lets you save songs as files you can back up or share. '
        'Everything is offline — files are saved through the system file picker '
        'or share sheet.',
    sections: [
      HelpSection(
        heading: 'Export all songs (ChordPro)',
        points: [
          'Go to Settings > General > Import.',
          'Tap "Export all songs (ChordPro)".',
          'Your whole songbook is saved as one ChordPro file.',
        ],
      ),
      HelpSection(
        heading: 'Export some songs (ChordPro)',
        points: [
          'On the Songs list, long-press to select the songs you want.',
          'Tap the export icon in the top bar.',
          'The selected songs are saved as one ChordPro file.',
        ],
      ),
      HelpSection(
        heading: 'Export one song as PDF',
        points: [
          'Open a song, then use the menu and pick "Export as PDF".',
          'The PDF keeps the current transpose and the chosen font.',
          'It opens the system share sheet so you can save or share it.',
        ],
      ),
    ],
  ),
  HelpTopic(
    id: 'import',
    title: 'Import',
    icon: Icons.file_open_outlined,
    summary: 'Bring songs into the app',
    intro:
        'Import adds songs from ChordPro or text files into your library. '
        'Reading is defensive — bad or unreadable files are skipped safely and '
        'never break the app.',
    sections: [
      HelpSection(
        heading: 'Import files',
        points: [
          'Go to Settings > General > Import.',
          'Tap "Import ChordPro file(s)".',
          'Pick one or more .cho, .pro, or text files.',
        ],
      ),
      HelpSection(
        heading: 'What happens',
        points: [
          'A file can hold one song or many songs.',
          'All songs found are added to your library.',
          'Importing one song opens it right away.',
          'Importing many songs shows how many were added.',
        ],
      ),
    ],
  ),
  HelpTopic(
    id: 'melody',
    title: 'Melody Lines',
    icon: Icons.graphic_eq,
    summary: 'Write the tune under the words, then hear it.',
    intro:
        'A chord sheet tells you the words and tells the accompanist what to '
        'play. It does not tell you the tune. A melody line adds that. Write '
        '{melody} under a lyric line and the app draws the beats and hums '
        'them back, so you can learn a song you have never heard.',
    sections: [
      HelpSection(
        heading: 'Writing one',
        points: [
          'Put a line starting with {melody} under the lyric line it belongs '
              'to.',
          'Example: {melody} P ,  M2 | M2!G3~ ,  | R2 S',
          'Beats are separated by spaces. One beat, one space.',
          'The words and chords above it do not change at all.',
        ],
      ),
      HelpSection(
        heading: 'The five marks',
        points: [
          'A comma ( , ) holds the note before it for one more beat.',
          'A bar ( | ) shows where a new tala group starts. It takes no time.',
          'A hyphen ( - ) joins notes that share one beat: G3-R2 is half a '
              'beat each.',
          'A bang ( ! ) slides into a note. M2!G3 starts the slide at Ma. A '
              'bare !G3 is a short slide in from just under Ga.',
          'A tilde ( ~ ) shakes the note.',
        ],
      ),
      HelpSection(
        heading: 'Naming the notes',
        points: [
          'A bare name is the note from the plain Sa Re Ga Ma Pa Dha Ni row, '
              'so Ma on its own is Ma1.',
          'A digit names the exact one: Ma2 is the raised Ma, R1 R2 R3 are the '
              'three Ris.',
          'Ma2 and M2 mean the same note. Use full names in chords and short '
              'letters in melody lines, or whichever reads better.',
          'The raga never changes what a name means, so nothing is guessed.',
          'A dot in front drops a note an octave (.N3). An apostrophe after '
              "raises it (S').",
        ],
      ),
      HelpSection(
        heading: 'Hearing it',
        points: [
          'Add {tonic: 1 kattai} so the app knows where your Sa really is. '
              'Without it the beats still draw, but nothing can play.',
          'Add {tala: misra chapu} so the beats are grouped correctly.',
          'The song tempo sets the speed.',
          'Tap the play button beside a melody line to hum it.',
          'Turn on Loop to repeat the line, or Half speed to learn it slowly.',
          'Start the shruti drone first — a tune is much easier to hear '
              'against a drone than on its own.',
        ],
      ),
      HelpSection(
        heading: 'What it can and cannot do',
        points: [
          'It shows you where the notes go and how long each one lasts.',
          'It does not shape them the way a singer does. Listen to a '
              'recording for that.',
          'Every song needs a person who knows the tune to type it in. There '
              'is no shortcut.',
        ],
      ),
    ],
  ),
];

/// Finds a topic by its [id]. Returns null when the id is unknown, so a bad
/// link shows a safe message instead of crashing.
HelpTopic? helpTopicById(String id) {
  for (final topic in helpTopics) {
    if (topic.id == id) return topic;
  }
  return null;
}
