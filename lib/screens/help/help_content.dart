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
    id: 'songbook',
    title: 'Your songbook',
    icon: Icons.library_music_outlined,
    summary: 'Find, star, copy and remove songs',
    intro:
        'The home screen is your songbook. It has two tabs — Songs and '
        'Setlists. The Songs tab holds everything you have written or brought '
        'in, with the most recently changed song at the top.',
    sections: [
      HelpSection(
        heading: 'Add a song',
        points: [
          'Tap the + button at the bottom right to write a new one.',
          'Or bring songs in from a file — see the Import topic.',
          'A new install already has three sample songs and one setlist, so '
              'you can try everything before typing anything.',
        ],
      ),
      HelpSection(
        heading: 'Find a song',
        points: [
          'Type in the search box at the top. It looks in the title, the '
              'artist and the words, so half a remembered line is enough.',
          'Tap the X in the box to clear the search.',
          'Below it are two chips, "All Songs" and "Starred", each with a '
              'count of how many songs it holds.',
          'Tap the star on a song to put it in Starred. Tap it again to take '
              'it out.',
        ],
      ),
      HelpSection(
        heading: 'What a song card shows',
        points: [
          'The title and the artist.',
          'The key, such as C or Am, and the tempo, such as 120 BPM, when the '
              'song has them.',
          'A star, a copy button and a delete button.',
        ],
      ),
      HelpSection(
        heading: 'Copy or delete one song',
        points: [
          'Copy makes a second, separate song named "<Title> (Copy)". Handy '
              'for a different arrangement of the same song.',
          'Delete asks first, then takes the song out of your library and out '
              'of every setlist that held it.',
          'To act on several songs at once, see the Select Songs topic.',
        ],
      ),
      HelpSection(
        heading: 'On a tablet',
        points: [
          'A wide screen shows the list on the left and the song on the '
              'right, so picking a song does not hide the list.',
          'Full screen is not offered in that right-hand half, because it '
              'would fill only that half and not the whole screen.',
        ],
      ),
    ],
  ),
  HelpTopic(
    id: 'editor',
    title: 'Write a song',
    icon: Icons.edit_note,
    summary: 'Type the words, put chords over them, save',
    intro:
        'The editor is one plain box for the words, with a few fields above it '
        'for the title, artist, key and tempo. Chords go inside the words in '
        'square brackets.',
    sections: [
      HelpSection(
        heading: 'Chords in the words',
        points: [
          'Put the chord in square brackets right before the syllable it '
              'falls on: [G]Amazing [C]grace.',
          'On the song screen that chord is drawn floating above the '
              'syllable. The brackets are never shown.',
          'This is standard ChordPro, so a file written in another app reads '
              'the same way here.',
        ],
      ),
      HelpSection(
        heading: 'The chord bar above the keyboard',
        points: [
          'While you are typing the words, a row of chord buttons sits just '
              'above the keyboard.',
          'The chords offered are the ones that usually belong to the key you '
              'picked — I, ii, iii, IV, V, vi and so on.',
          'Tap one and it goes in at the cursor, brackets and all.',
          'If the key is blank or cannot be read, the bar quietly falls back '
              'to the key of C rather than showing nothing.',
          'Your own chords come after those. Tap "Custom" to add one on the '
              'spot, or keep the whole list in Settings → Chords.',
          'A custom chord can be up to 12 characters, and the same one is '
              'never stored twice.',
        ],
      ),
      HelpSection(
        heading: 'The fields at the top',
        points: [
          'Title, and Artist / Band.',
          'Notation: Western, Carnatic or Hindustani. Western shows an '
              '"Original key" box; either Indian choice replaces it with Raga '
              'and Tala — see the Carnatic & Hindustani topic.',
          'Tempo (BPM) drives the metronome and the Tempo auto-scroll.',
          '"Add to Setlist" drops the song into a setlist as you save it.',
          'The fields fold into a one-line summary as soon as you tap into '
              'the words, so the words get the screen. Tap the summary to open '
              'them again.',
        ],
      ),
      HelpSection(
        heading: 'Undo, save and copy',
        points: [
          'The undo and redo arrows in the top bar step back and forward '
              'through your typing.',
          'Save keeps the song and closes the editor.',
          'More options → "Save as copy" saves what is on screen right now, '
              'including edits you have not saved yet, as a brand-new song. '
              'The original is left as it was.',
          'Leaving with unsaved edits asks first, so a stray back gesture '
              'cannot throw your work away. With nothing changed it just '
              'closes.',
        ],
      ),
      HelpSection(
        heading: 'More options',
        points: [
          'Melody keypad — tap out a tune instead of typing it. See the '
              'Melody Lines topic.',
          'Paste Carnatic notation — turn a block of published notation into '
              'melody lines. See the Carnatic & Hindustani topic.',
        ],
      ),
    ],
  ),
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
    id: 'transpose',
    title: 'Transpose & chord shapes',
    icon: Icons.tune,
    summary: 'Change the key, hide chords, see the shapes',
    intro:
        'Transposing moves every chord in the song up or down by the same '
        'amount, so you can play in a key that suits the singer without '
        'rewriting anything.',
    sections: [
      HelpSection(
        heading: 'Change the key',
        points: [
          'Open the song, then the top-bar menu (More options) → "Performance '
              'controls".',
          'Use - and + to move down or up one semitone at a time.',
          'The key the sheet now sounds in is shown between the two buttons.',
          'The line under the controls row says how far you have moved, like '
              '"Key A (+2)".',
          '"Reset" puts the song back to its written key.',
          'The range is 11 semitones down to 11 semitones up. A full 12 would '
              'only land on the same key again.',
        ],
      ),
      HelpSection(
        heading: 'What it changes',
        points: [
          'Slash chords move too: C/E shifted up 2 becomes D/F#.',
          'Sharps or flats are chosen to suit the new key, so you get Bb and '
              'not A#.',
          'The change belongs to this sheet only — it is never written back '
              'into the song.',
          'Export and Share simply use the key you are looking at, so a '
              'transposed song goes out transposed.',
          'A Carnatic or Hindustani song has no transpose control, because '
              'swaras are named relative to Sa and do not move.',
        ],
      ),
      HelpSection(
        heading: 'Hide the chords',
        points: [
          'The same Performance controls sheet has a "Show chords" switch.',
          'Turning it off leaves clean words only, which is usually what a '
              'singer wants.',
          'The music note button in the row above the song does the same in '
              'one tap.',
        ],
      ),
      HelpSection(
        heading: 'Chord Reference Guide',
        points: [
          'Top-bar menu → "Chord Reference Guide" lists every chord used in '
              'the song, already moved to the key you are playing in.',
          'Each chord is drawn two ways: a six-string guitar fretboard with '
              'finger dots and O and X marks for open and muted strings, and a '
              'harmonium or piano keyboard with the notes lit up.',
          'The root note is one colour; the bass note of a slash chord, such '
              'as the E in C/E, is another.',
          'It knows the common open shapes and works out movable barre shapes '
              'for everything else.',
          'On a Carnatic or Hindustani song this becomes "Swara Reference" '
              'and shows where each swara sits on the keyboard, low to high, '
              'instead of chord shapes.',
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
              '2.00x. Change it by double-tapping the sheet; each tap changes '
              'it by 0.05x.',
          'A song remembers the speed you set for it. A song you have never '
              'set a speed for opens at the starting speed in Settings → '
              'General → Auto-scroll.',
          'Tempo works out how long the song lasts and paces the scroll to '
              'finish exactly at the end of the song.',
        ],
      ),
      HelpSection(
        heading: 'What "bars" means',
        points: [
          'A bar (also called a measure) is a musical unit of time.',
          'A song that names no tala uses common 4/4 time, so one bar is 4 '
              'beats.',
          "A song with a {tala} line counts that tala's own beats instead, so "
              'a misra chapu song has 7 beats to the bar.',
          'Songs open at 32 bars. Change the count by double-tapping the '
              'sheet — each double-tap adds or removes 4 bars.',
          'The count can go from 1 bar up to 512.',
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
        heading: 'Changing the speed by tapping',
        gestureItems: [
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
        ],
        points: [
          'The same taps work here and in full screen, so there is only one '
              'thing to remember.',
          'In Tempo mode the same double-taps add or remove bars instead.',
          'The new value flashes big in the middle of the screen, so you can '
              'read it from a stand.',
          'This speed is only used while auto-scroll is playing. It never '
              'changes how the sheet moves when you drag it with a finger.',
          'One finger still scrolls and two fingers still pinch to change the '
              'text size.',
        ],
      ),
      HelpSection(
        heading: 'Start and stop',
        points: [
          'Tap the sheet with two fingers to start and stop the scroll. There '
              'is no play button on this screen any more.',
          'In full screen the control bar still has a play button as well.',
          'In Tempo mode the scroll stops on its own at the end of the song.',
        ],
      ),
      HelpSection(
        heading: 'Moving the sheet by hand',
        points: [
          'You can drag the sheet with one finger at any time, even while '
              'auto-scroll is playing.',
          'Auto-scroll waits while your finger is down and carries on from '
              'wherever you let go, so you never have to stop and start again '
              'to fix your place.',
          'A fast flick stops where you lift your finger rather than coasting '
              'on, because auto-scroll takes over again straight away.',
        ],
      ),
      HelpSection(
        heading: 'The row above the song',
        points: [
          'M and T pick the mode; the arrows icon goes full screen.',
          'The speed, such as "0.40x", is shown on the right in Manual mode. '
              'It is a read-out — double-tap the sheet to change it.',
          'The music note icon hides and shows the chords.',
          'The piano icon hides and shows the melody rows. It is only there '
              'for a song that has a tune written in it.',
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
        heading: 'The buttons in the bar',
        points: [
          'Exit (the shrink icon) leaves full screen.',
          'The padlock locks the screen — see below.',
          'The bell turns Stage Quiet Mode on and off — see below.',
          'M and T pick Manual or Tempo, and the round button plays or pauses.',
          'The bars icon opens the pitch pipe and shruti box.',
          'The - and + at the end change the speed in Manual mode and the bar '
              'count in Tempo mode, the same as the double-taps.',
          'The line under the buttons repeats the key, the BPM and, in Tempo '
              'mode, the length.',
        ],
      ),
      HelpSection(
        heading: 'Lock the screen',
        points: [
          'Tap the padlock to lock Stage View. The tap controls are then '
              'switched off, so a sleeve or a stray hand cannot change your '
              'speed or pause you mid-song.',
          'The control bar hides and a small "Stage Locked" chip appears in '
              'the top right.',
          'Tap that chip, or press Back, to unlock. It asks for your '
              'fingerprint, or the PIN, pattern or password the phone already '
              'uses.',
          'On a phone with no screen lock set up there is nothing to check '
              'against, so it simply unlocks.',
        ],
      ),
      HelpSection(
        heading: 'Stage Quiet Mode',
        points: [
          'Tap the bell to mute the ringer and notification alerts while you '
              'play, so a call cannot chime through the PA.',
          "The app's own sound is left alone — the metronome click, the pitch "
              'cue and the drone all keep working.',
          'The icon turns red while it is on. Tap it again, or leave full '
              'screen, and your normal ringer setting comes back.',
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
        heading: 'Pitch Cue (called Chord Cue in Western)',
        points: [
          'Tap "Pitch Cue" to hear a 2-second reference note. It is a digital '
              'pitch pipe: it sounds your Sa (or the key you picked), then '
              'stops on its own.',
          'Use it to find your starting note before you begin singing.',
          'In Western mode the same button is named "Chord Cue" and plays the '
              'whole chord — bass, root, third and fifth — because Western '
              'players want the chord, not one note. Major or minor follows '
              'the quality you picked.',
          'The length is fixed at 2 seconds and there is no setting for it. '
              'That is long enough to hear the pitch clearly and short enough '
              'not to get in the way. The button says "(2s)" so you know what '
              'you will get before you tap it.',
          'If you want a tone that lasts longer, use the Shruti Drone instead. '
              'That is what it is for.',
        ],
      ),
      HelpSection(
        heading: 'Cue or drone — which one?',
        points: [
          'Cue: one short sound that stops by itself. For finding the note '
              'before you start.',
          'Drone: keeps sounding until you stop it. For singing against while '
              'you practise or perform.',
          'Both are built inside the app the moment you press the button. '
              'Nothing is downloaded and no sound files ship with the app.',
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
        heading: 'Text size for the stage',
        points: [
          'The same sheet is read on a phone in your hand and on a stand two '
              'steps away, so the pitch sheet carries a text size setting.',
          'Pick one of five sizes — 85%, 95%, 100%, 115% or 130% — from the '
              'chips at the bottom of the pitch sheet.',
          'Settings → General → Pitch Pipe & Shruti Box has the same chips, so '
              'you can set it before a gig.',
          'It multiplies the sheet text size everywhere, not only in full '
              'screen.',
          'Pinching the sheet with two fingers still works and is the quicker '
              'way to nudge one song.',
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
          'You do not have to type it. In the editor, More options → "Melody '
              'keypad" gives you a pad of all sixteen swaras and every mark, '
              'draws the beats as you tap, and counts "6 of 8 beats" until the '
              'line fills the tala.',
          'With the cursor already on a {melody} line, the keypad loads that '
              'line so you can fix it instead of deleting it first.',
          'A block of published Carnatic notation can be turned into melody '
              'lines in one go — see the Carnatic & Hindustani topic.',
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
          'To read the words without the tune rows, open the overflow menu → '
              'Performance controls and turn Show melody off. Full screen '
              'never draws the melody rows.',
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
  HelpTopic(
    id: 'indian-songs',
    title: 'Carnatic & Hindustani songs',
    icon: Icons.temple_hindu_outlined,
    summary: 'Swaras, raga, tala, and where your Sa is',
    intro:
        'An Indian song is written in swaras — Sa Re Ga Ma Pa Dha Ni — not in '
        'chords, and those names are relative to Sa rather than to a fixed '
        'pitch. The app treats such a song differently all the way through.',
    sections: [
      HelpSection(
        heading: 'Mark the song as Indian',
        points: [
          'In the editor, set "Notation" to Carnatic or Hindustani.',
          'The "Original key" box is replaced by Raga and Tala, because an '
              'Indian sheet has no key to transpose.',
          'Switching back to Western clears the raga and tala, so an old '
              'value can never make the song look Indian again.',
        ],
      ),
      HelpSection(
        heading: 'The note under the Tala box',
        points: [
          'Typing a tala that belongs to the other tradition — Keherwa on a '
              'Carnatic song, say — shows a short note under the box.',
          'It is advice only. It never stops you saving. The app knows a '
              'fixed list of tala names and yours may simply not be on it.',
          'The tala also decides how many beats are in a bar for Tempo '
              'auto-scroll and for the beat grid under a melody line.',
        ],
      ),
      HelpSection(
        heading: 'What changes on the song screen',
        points: [
          'No Western letter is shown. The status line reads "Auto-scroll · '
              '120 BPM", with the raga and tala on the line below it.',
          'There is no transpose control, because a swara does not move.',
          'The menu offers "Swara Reference" in place of the Chord Reference '
              'Guide.',
          'The pitch sheet opens on your saved Sa instead of a song key, and '
              'names it the Indian way — "5 kattai" for Carnatic, "safed 5" '
              'for Hindustani.',
        ],
      ),
      HelpSection(
        heading: 'Lines you can put in the words',
        points: [
          '{tonic: 1 kattai} says where your Sa really is. A melody line '
              'cannot be played without it.',
          '{tala: misra chapu} groups the beats.',
          '{sruti: madhyama} marks a song sung with the drone\'s Pa string '
              'dropped to shuddha madhyamam, as Yamunakalyani usually is. The '
              'written Sa then sounds a fourth higher.',
          '{melody} lines hold the tune — see the Melody Lines topic.',
          'All of these live in the song text, so import and export carry '
              'them through unchanged.',
        ],
      ),
      HelpSection(
        heading: 'Paste published notation',
        points: [
          'In the editor, More options → "Paste Carnatic notation" takes a '
              'block copied from a book or a page and turns it into {melody} '
              'lines.',
          'Published notation has no single standard: on some pages a capital '
              'letter means a longer note, on others it means a higher octave.',
          'So the app reads the block both ways, checks each against the '
              "song's tala, and tells you which one fitted and by how much — "
              'like "1 of 1 cycles fit, read with case means note length".',
          'Where the two ways tie it says so instead of guessing.',
          'It will not choose between the two Ma-s on its own. That is raga '
              'grammar, not arithmetic — but it points out the phrase that '
              'decides it.',
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
    id: 'import',
    title: 'Import',
    icon: Icons.file_open_outlined,
    summary: 'Bring songs into the app',
    intro:
        'Import adds songs from ChordPro or plain text files into your library. '
        'Reading is defensive — broken or unreadable files are skipped safely and '
        'never break the app.',
    sections: [
      HelpSection(
        heading: 'Supported file types',
        points: [
          'You can pick files ending in .cho, .pro, .chordpro, or .txt.',
          'ChordPro files are plain text files that use simple tags for chords and headers.',
          'You can pick one file or multiple files at the same time.',
        ],
      ),
      HelpSection(
        heading: 'Multiple songs in one file',
        points: [
          'A single file can contain many songs.',
          'Put {new_song} or {ns} on its own line between songs to separate them. '
              'This is the same separator used when you export your whole songbook.',
          'You can also separate songs by starting a new {title: ...} or {t: ...} tag. '
              'The app automatically detects where the new song begins.',
        ],
      ),
      HelpSection(
        heading: 'Text files without tags',
        points: [
          'A plain text file with no tags is imported safely as one song.',
          'The app gives it the name "Untitled Song" and key C.',
          'You can open and edit its title, chords, key, and tempo at any time.',
        ],
      ),
      HelpSection(
        heading: 'Duplicate songs',
        points: [
          'If a song has the same title as one in your library, the app follows '
              'your duplicate setting.',
          'You can choose to overwrite the existing song, rename the new one, '
              'rename the old one, or ask for a title each time.',
          'Set this in Settings → General → Import Settings.',
        ],
      ),
      HelpSection(
        heading: 'Check before it is saved',
        points: [
          'Every import stops at a preview screen first.',
          'You can read the titles, artists, keys and words that were found, '
              'and fix a title before anything is written.',
          'Nothing reaches your library until you confirm.',
        ],
      ),
      HelpSection(
        heading: 'Other ways songs come in',
        points: [
          'Opening a ChordPro file from a file manager, an email or a chat app '
              'hands it to LyricChord and opens the same preview.',
          'A bandmate standing next to you can send songs with no file at all '
              '— see the AirQR topic.',
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
        'Export saves songs as a file you choose the place for. Share hands the '
        'same file straight to another app. Everything stays offline — nothing '
        'is uploaded, and the system file picker or share sheet does the work.',
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
        heading: 'Export one song',
        points: [
          'Open the song, then the top-bar menu (More options) → "Export".',
          'Choose ChordPro (.chordpro) or PDF (.pdf), then tap Export.',
          'The system file saver opens so you can pick where it goes.',
          'Whatever you export uses the key you are looking at, so a song you '
              'have transposed is saved in that key.',
        ],
      ),
      HelpSection(
        heading: 'What a PDF looks like',
        points: [
          'Title, artist, key and BPM at the top, guitar chord diagrams under '
              'that, then the words with the chords above them.',
          'The words use the lyric font you picked in Settings → Fonts, so '
              'Malayalam is shaped correctly and the text stays selectable.',
          'The page is only as wide as the song needs — a song with short '
              'lines gets a narrow, tall page that fills a phone screen better '
              '— up to A4 width at the most.',
          'If a line is still too long, the font is stepped down (never below '
              '9 pt) so it does not wrap in the middle.',
        ],
      ),
      HelpSection(
        heading: 'Share instead of save',
        points: [
          'The top-bar menu also has "Share", which opens the system share '
              'sheet instead of the file saver.',
          'You can share as ChordPro, as PDF, or as an AirQR stream — see the '
              'AirQR topic.',
          'Selecting several songs on the Songs list gives you the same share '
              'choice for the whole set.',
        ],
      ),
    ],
  ),
  HelpTopic(
    id: 'airqr',
    title: 'AirQR — songs screen to screen',
    icon: Icons.qr_code_2_rounded,
    summary: 'Pass songs to another phone with the camera',
    intro:
        'AirQR moves songs from one phone to another by flashing a run of QR '
        'codes on one screen while the other phone watches with its camera. No '
        'internet, no Bluetooth, no Wi-Fi, no cable and no account — just two '
        'screens facing each other.',
    sections: [
      HelpSection(
        heading: 'Send one song',
        points: [
          'Open the song, then the top-bar menu → "Share".',
          'Pick "AirQR Stream (Animated QR)" and tap Share.',
          'The codes start flashing straight away. Hold the phone still and '
              'let the other one read it.',
          'What goes across is the song as you are looking at it, so a key '
              'you have transposed to travels with it.',
        ],
      ),
      HelpSection(
        heading: 'Send several songs',
        points: [
          'Settings → General → Import → "Export all songs via AirQR Stream" '
              'sends the whole songbook.',
          'Or long-press on the Songs list to select some songs and tap the '
              'QR icon in the top bar.',
        ],
      ),
      HelpSection(
        heading: 'Receive',
        points: [
          'On the receiving phone, tap the scan icon in the songbook top bar, '
              'or go to Settings → General → Import → "AirQR Scan Import".',
          'Point the camera at the sending screen and wait. The panel counts '
              'the pieces as they arrive.',
          'When it has everything the phone buzzes and the import preview '
              'opens, so you can check the songs before they are saved.',
          'The gallery icon reads a photo of a code instead of the live '
              'camera, for a code someone sent you as a picture.',
        ],
      ),
      HelpSection(
        heading: 'Getting a clean read',
        points: [
          'The song is cut into small pieces shown one after another, with '
              'spare repair pieces mixed in, so a frame the camera misses is '
              'filled in instead of starting again.',
          'The "Stream Speed" slider on the sending phone runs from 5 to 25 '
              'frames a second and starts at 10.',
          'An older phone or a dim screen reads better slower. Turn the speed '
              'down if the count stops moving.',
          'Keep both screens still and bright, roughly a hand-span apart.',
        ],
      ),
    ],
  ),
  HelpTopic(
    id: 'appearance',
    title: 'Themes, fonts & text size',
    icon: Icons.palette_outlined,
    summary: 'Make the sheet easy to read',
    intro:
        'A sheet read on a dark stage and a sheet read at a desk are not the '
        'same job. Three settings cover it: the theme, the lyric font, and how '
        'big the text is.',
    sections: [
      HelpSection(
        heading: 'Theme',
        points: [
          'Settings → Themes offers System theme, Light theme and Dark theme.',
          'System follows whatever the phone is set to.',
          'Dark is easier on the eyes on a stage and easier on the battery.',
          'The choice is saved and takes effect at once.',
        ],
      ),
      HelpSection(
        heading: 'Lyric font',
        points: [
          'Settings → Fonts picks the font the words are drawn in: System '
              'default, Noto Sans Malayalam, Noto Serif Malayalam, Manjari or '
              'Gayathri.',
          'Each choice shows a live sample in English and in Malayalam, so '
              'you can see the letter shapes before you pick.',
          'The Malayalam fonts shape chillu, conjuncts and vowel signs '
              'properly. The system font often does not.',
          'One choice covers the whole app, and the exported PDF uses the '
              'same font.',
          'The fonts are bundled with the app under an open licence and are '
              'listed on the licences page in About.',
        ],
      ),
      HelpSection(
        heading: 'Text size',
        points: [
          'Pinch the words with two fingers to make the text bigger or '
              'smaller, from 10 up to 32.',
          'It works on the ordinary song screen and in full screen, and it '
              'does not disturb the scrolling.',
          'The pitch sheet also has five fixed sizes — 85%, 95%, 100%, 115% '
              'and 130% — which multiply whatever the pinch has set. Use those '
              'to set a stage size once and keep it.',
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
