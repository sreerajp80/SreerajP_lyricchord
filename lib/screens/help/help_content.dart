import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/l10n/app_localizations.dart';

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
/// Plain content — no logic, no state. The words live in `app_en.arb`
/// (the `help…` keys); this list only puts them in order with their ids
/// and icons. The text matches the real behaviour of the app.
List<HelpTopic> helpTopics(AppLocalizations l10n) => [
  HelpTopic(
    id: 'songbook',
    title: l10n.titleHelpSongbook,
    icon: Icons.library_music_outlined,
    summary: l10n.helpSongbookSummary,
    intro: l10n.helpSongbookIntro,
    sections: [
      HelpSection(
        heading: l10n.helpSongbookS1Heading,
        points: [
          l10n.helpSongbookS1P1,
          l10n.helpSongbookS1P2,
          l10n.helpSongbookS1P3,
        ],
      ),
      HelpSection(
        heading: l10n.helpSongbookS2Heading,
        points: [
          l10n.helpSongbookS2P1,
          l10n.helpSongbookS2P2,
          l10n.helpSongbookS2P3,
          l10n.helpSongbookS2P4,
        ],
      ),
      HelpSection(
        heading: l10n.helpSongbookS3Heading,
        points: [
          l10n.helpSongbookS3P1,
          l10n.helpSongbookS3P2,
          l10n.helpSongbookS3P3,
        ],
      ),
      HelpSection(
        heading: l10n.helpSongbookS4Heading,
        points: [
          l10n.helpSongbookS4P1,
          l10n.helpSongbookS4P2,
          l10n.helpSongbookS4P3,
        ],
      ),
      HelpSection(
        heading: l10n.helpSongbookS5Heading,
        points: [l10n.helpSongbookS5P1, l10n.helpSongbookS5P2],
      ),
      HelpSection(
        heading: l10n.helpSongbookS6Heading,
        points: [
          l10n.helpSongbookS6P1,
          l10n.helpSongbookS6P2,
          l10n.helpSongbookS6P3,
        ],
      ),
    ],
  ),
  HelpTopic(
    id: 'editor',
    title: l10n.titleHelpEditor,
    icon: Icons.edit_note,
    summary: l10n.helpEditorSummary,
    intro: l10n.helpEditorIntro,
    sections: [
      HelpSection(
        heading: l10n.helpEditorS1Heading,
        points: [l10n.helpEditorS1P1, l10n.helpEditorS1P2, l10n.helpEditorS1P3],
      ),
      HelpSection(
        heading: l10n.helpEditorS2Heading,
        points: [
          l10n.helpEditorS2P1,
          l10n.helpEditorS2P2,
          l10n.helpEditorS2P3,
          l10n.helpEditorS2P4,
          l10n.helpEditorS2P5,
          l10n.helpEditorS2P6,
        ],
      ),
      HelpSection(
        heading: l10n.helpEditorS3Heading,
        points: [
          l10n.helpEditorS3P1,
          l10n.helpEditorS3P2,
          l10n.helpEditorS3P3,
          l10n.helpEditorS3P4,
          l10n.helpEditorS3P5,
        ],
      ),
      HelpSection(
        heading: l10n.helpEditorS4Heading,
        points: [
          l10n.helpEditorS4P1,
          l10n.helpEditorS4P2,
          l10n.helpEditorS4P3,
          l10n.helpEditorS4P4,
        ],
      ),
      HelpSection(
        heading: l10n.helpEditorS5Heading,
        points: [l10n.helpEditorS5P1, l10n.helpEditorS5P2],
      ),
    ],
  ),
  HelpTopic(
    id: 'setlists',
    title: l10n.titleHelpSetlists,
    icon: Icons.playlist_play,
    summary: l10n.helpSetlistsSummary,
    intro: l10n.helpSetlistsIntro,
    sections: [
      HelpSection(
        heading: l10n.helpSetlistsS1Heading,
        points: [
          l10n.helpSetlistsS1P1,
          l10n.helpSetlistsS1P2,
          l10n.helpSetlistsS1P3,
        ],
      ),
      HelpSection(
        heading: l10n.helpSetlistsS2Heading,
        points: [
          l10n.helpSetlistsS2P1,
          l10n.helpSetlistsS2P2,
          l10n.helpSetlistsS2P3,
          l10n.helpSetlistsS2P4,
        ],
      ),
      HelpSection(
        heading: l10n.helpSetlistsS3Heading,
        points: [
          l10n.helpSetlistsS3P1,
          l10n.helpSetlistsS3P2,
          l10n.helpSetlistsS3P3,
        ],
      ),
      HelpSection(
        heading: l10n.helpSetlistsS4Heading,
        points: [l10n.helpSetlistsS4P1, l10n.helpSetlistsS4P2],
      ),
    ],
  ),
  HelpTopic(
    id: 'transpose',
    title: l10n.titleHelpTranspose,
    icon: Icons.tune,
    summary: l10n.helpTransposeSummary,
    intro: l10n.helpTransposeIntro,
    sections: [
      HelpSection(
        heading: l10n.helpTransposeS1Heading,
        points: [
          l10n.helpTransposeS1P1,
          l10n.helpTransposeS1P2,
          l10n.helpTransposeS1P3,
          l10n.helpTransposeS1P4,
          l10n.helpTransposeS1P5,
          l10n.helpTransposeS1P6,
        ],
      ),
      HelpSection(
        heading: l10n.helpTransposeS2Heading,
        points: [
          l10n.helpTransposeS2P1,
          l10n.helpTransposeS2P2,
          l10n.helpTransposeS2P3,
          l10n.helpTransposeS2P4,
          l10n.helpTransposeS2P5,
        ],
      ),
      HelpSection(
        heading: l10n.helpTransposeS3Heading,
        points: [
          l10n.helpTransposeS3P1,
          l10n.helpTransposeS3P2,
          l10n.helpTransposeS3P3,
        ],
      ),
      HelpSection(
        heading: l10n.helpTransposeS4Heading,
        points: [
          l10n.helpTransposeS4P1,
          l10n.helpTransposeS4P2,
          l10n.helpTransposeS4P3,
          l10n.helpTransposeS4P4,
          l10n.helpTransposeS4P5,
        ],
      ),
    ],
  ),
  HelpTopic(
    id: 'auto-scroll',
    title: l10n.titleHelpAutoScroll,
    icon: Icons.swap_vert,
    summary: l10n.helpAutoScrollSummary,
    intro: l10n.helpAutoScrollIntro,
    sections: [
      HelpSection(
        heading: l10n.helpAutoScrollS1Heading,
        points: [
          l10n.helpAutoScrollS1P1,
          l10n.helpAutoScrollS1P2,
          l10n.helpAutoScrollS1P3,
        ],
      ),
      HelpSection(
        heading: l10n.helpAutoScrollS2Heading,
        points: [
          l10n.helpAutoScrollS2P1,
          l10n.helpAutoScrollS2P2,
          l10n.helpAutoScrollS2P3,
          l10n.helpAutoScrollS2P4,
          l10n.helpAutoScrollS2P5,
        ],
      ),
      HelpSection(
        heading: l10n.helpAutoScrollS3Heading,
        points: [
          l10n.helpAutoScrollS3P1,
          l10n.helpAutoScrollS3P2,
          l10n.helpAutoScrollS3P3,
          l10n.helpAutoScrollS3P4,
        ],
      ),
      HelpSection(
        heading: l10n.helpAutoScrollS4Heading,
        gestureItems: [
          GestureHelpItem(
            icon: Icons.keyboard_double_arrow_up,
            title: l10n.helpAutoScrollS4G1Title,
            description: l10n.helpAutoScrollS4G1Description,
          ),
          GestureHelpItem(
            icon: Icons.keyboard_double_arrow_down,
            title: l10n.helpAutoScrollS4G2Title,
            description: l10n.helpAutoScrollS4G2Description,
          ),
          GestureHelpItem(
            icon: Icons.pan_tool_outlined,
            title: l10n.helpAutoScrollS4G3Title,
            description: l10n.helpAutoScrollS4G3Description,
          ),
        ],
        points: [
          l10n.helpAutoScrollS4P1,
          l10n.helpAutoScrollS4P2,
          l10n.helpAutoScrollS4P3,
          l10n.helpAutoScrollS4P4,
          l10n.helpAutoScrollS4P5,
        ],
      ),
      HelpSection(
        heading: l10n.helpAutoScrollS5Heading,
        points: [
          l10n.helpAutoScrollS5P1,
          l10n.helpAutoScrollS5P2,
          l10n.helpAutoScrollS5P3,
        ],
      ),
      HelpSection(
        heading: l10n.helpAutoScrollS6Heading,
        points: [
          l10n.helpAutoScrollS6P1,
          l10n.helpAutoScrollS6P2,
          l10n.helpAutoScrollS6P3,
        ],
      ),
      HelpSection(
        heading: l10n.helpAutoScrollS7Heading,
        points: [
          l10n.helpAutoScrollS7P1,
          l10n.helpAutoScrollS7P2,
          l10n.helpAutoScrollS7P3,
          l10n.helpAutoScrollS7P4,
        ],
      ),
    ],
  ),
  HelpTopic(
    id: 'full-screen',
    title: l10n.titleHelpFullScreen,
    icon: Icons.fullscreen,
    summary: l10n.helpFullScreenSummary,
    intro: l10n.helpFullScreenIntro,
    sections: [
      HelpSection(
        heading: l10n.helpFullScreenS1Heading,
        points: [
          l10n.helpFullScreenS1P1,
          l10n.helpFullScreenS1P2,
          l10n.helpFullScreenS1P3,
        ],
      ),
      HelpSection(
        heading: l10n.helpFullScreenS2Heading,
        gestureItems: [
          GestureHelpItem(
            icon: Icons.touch_app_outlined,
            title: l10n.helpFullScreenS2G1Title,
            description: l10n.helpFullScreenS2G1Description,
          ),
          GestureHelpItem(
            icon: Icons.keyboard_double_arrow_up,
            title: l10n.helpFullScreenS2G2Title,
            description: l10n.helpFullScreenS2G2Description,
          ),
          GestureHelpItem(
            icon: Icons.keyboard_double_arrow_down,
            title: l10n.helpFullScreenS2G3Title,
            description: l10n.helpFullScreenS2G3Description,
          ),
          GestureHelpItem(
            icon: Icons.pan_tool_outlined,
            title: l10n.helpFullScreenS2G4Title,
            description: l10n.helpFullScreenS2G4Description,
          ),
          GestureHelpItem(
            icon: Icons.zoom_out_map,
            title: l10n.helpFullScreenS2G5Title,
            description: l10n.helpFullScreenS2G5Description,
          ),
          GestureHelpItem(
            icon: Icons.arrow_back,
            title: l10n.helpFullScreenS2G6Title,
            description: l10n.helpFullScreenS2G6Description,
          ),
        ],
        points: [
          l10n.helpFullScreenS2P1,
          l10n.helpFullScreenS2P2,
          l10n.helpFullScreenS2P3,
          l10n.helpFullScreenS2P4,
          l10n.helpFullScreenS2P5,
        ],
      ),
      HelpSection(
        heading: l10n.helpFullScreenS3Heading,
        points: [
          l10n.helpFullScreenS3P1,
          l10n.helpFullScreenS3P2,
          l10n.helpFullScreenS3P3,
          l10n.helpFullScreenS3P4,
          l10n.helpFullScreenS3P5,
          l10n.helpFullScreenS3P6,
          l10n.helpFullScreenS3P7,
        ],
      ),
      HelpSection(
        heading: l10n.helpFullScreenS4Heading,
        points: [
          l10n.helpFullScreenS4P1,
          l10n.helpFullScreenS4P2,
          l10n.helpFullScreenS4P3,
          l10n.helpFullScreenS4P4,
          l10n.helpFullScreenS4P5,
        ],
      ),
      HelpSection(
        heading: l10n.helpFullScreenS5Heading,
        points: [
          l10n.helpFullScreenS5P1,
          l10n.helpFullScreenS5P2,
          l10n.helpFullScreenS5P3,
          l10n.helpFullScreenS5P4,
          l10n.helpFullScreenS5P5,
        ],
      ),
      HelpSection(
        heading: l10n.helpFullScreenS6Heading,
        points: [
          l10n.helpFullScreenS6P1,
          l10n.helpFullScreenS6P2,
          l10n.helpFullScreenS6P3,
        ],
      ),
    ],
  ),
  HelpTopic(
    id: 'metronome',
    title: l10n.titleHelpMetronome,
    icon: Icons.av_timer,
    summary: l10n.helpMetronomeSummary,
    intro: l10n.helpMetronomeIntro,
    sections: [
      HelpSection(
        heading: l10n.helpMetronomeS1Heading,
        points: [
          l10n.helpMetronomeS1P1,
          l10n.helpMetronomeS1P2,
          l10n.helpMetronomeS1P3,
        ],
      ),
      HelpSection(
        heading: l10n.helpMetronomeS2Heading,
        points: [
          l10n.helpMetronomeS2P1,
          l10n.helpMetronomeS2P2,
          l10n.helpMetronomeS2P3,
          l10n.helpMetronomeS2P4,
          l10n.helpMetronomeS2P5,
          l10n.helpMetronomeS2P6,
        ],
      ),
      HelpSection(
        heading: l10n.helpMetronomeS3Heading,
        points: [
          l10n.helpMetronomeS3P1,
          l10n.helpMetronomeS3P2,
          l10n.helpMetronomeS3P3,
        ],
      ),
      HelpSection(
        heading: l10n.helpMetronomeS4Heading,
        points: [
          l10n.helpMetronomeS4P1,
          l10n.helpMetronomeS4P2,
          l10n.helpMetronomeS4P3,
          l10n.helpMetronomeS4P4,
          l10n.helpMetronomeS4P5,
        ],
      ),
    ],
  ),
  HelpTopic(
    id: 'pitch-pipe-drone',
    title: l10n.titleHelpPitchPipeDrone,
    icon: Icons.graphic_eq,
    summary: l10n.helpPitchPipeDroneSummary,
    intro: l10n.helpPitchPipeDroneIntro,
    sections: [
      HelpSection(
        heading: l10n.helpPitchPipeDroneS1Heading,
        points: [
          l10n.helpPitchPipeDroneS1P1,
          l10n.helpPitchPipeDroneS1P2,
          l10n.helpPitchPipeDroneS1P3,
        ],
      ),
      HelpSection(
        heading: l10n.helpPitchPipeDroneS2Heading,
        points: [
          l10n.helpPitchPipeDroneS2P1,
          l10n.helpPitchPipeDroneS2P2,
          l10n.helpPitchPipeDroneS2P3,
        ],
      ),
      HelpSection(
        heading: l10n.helpPitchPipeDroneS3Heading,
        points: [
          l10n.helpPitchPipeDroneS3P1,
          l10n.helpPitchPipeDroneS3P2,
          l10n.helpPitchPipeDroneS3P3,
          l10n.helpPitchPipeDroneS3P4,
          l10n.helpPitchPipeDroneS3P5,
        ],
      ),
      HelpSection(
        heading: l10n.helpPitchPipeDroneS4Heading,
        points: [
          l10n.helpPitchPipeDroneS4P1,
          l10n.helpPitchPipeDroneS4P2,
          l10n.helpPitchPipeDroneS4P3,
        ],
      ),
      HelpSection(
        heading: l10n.helpPitchPipeDroneS5Heading,
        points: [
          l10n.helpPitchPipeDroneS5P1,
          l10n.helpPitchPipeDroneS5P2,
          l10n.helpPitchPipeDroneS5P3,
          l10n.helpPitchPipeDroneS5P4,
        ],
      ),
      HelpSection(
        heading: l10n.helpPitchPipeDroneS6Heading,
        points: [
          l10n.helpPitchPipeDroneS6P1,
          l10n.helpPitchPipeDroneS6P2,
          l10n.helpPitchPipeDroneS6P3,
          l10n.helpPitchPipeDroneS6P4,
        ],
      ),
      HelpSection(
        heading: l10n.helpPitchPipeDroneS7Heading,
        points: [
          l10n.helpPitchPipeDroneS7P1,
          l10n.helpPitchPipeDroneS7P2,
          l10n.helpPitchPipeDroneS7P3,
          l10n.helpPitchPipeDroneS7P4,
          l10n.helpPitchPipeDroneS7P5,
        ],
      ),
    ],
  ),
  HelpTopic(
    id: 'melody',
    title: l10n.titleHelpMelody,
    icon: Icons.graphic_eq,
    summary: l10n.helpMelodySummary,
    intro: l10n.helpMelodyIntro,
    sections: [
      HelpSection(
        heading: l10n.helpMelodyS1Heading,
        points: [
          l10n.helpMelodyS1P1,
          l10n.helpMelodyS1P2,
          l10n.helpMelodyS1P3,
          l10n.helpMelodyS1P4,
          l10n.helpMelodyS1P5,
          l10n.helpMelodyS1P6,
          l10n.helpMelodyS1P7,
        ],
      ),
      HelpSection(
        heading: l10n.helpMelodyS2Heading,
        points: [
          l10n.helpMelodyS2P1,
          l10n.helpMelodyS2P2,
          l10n.helpMelodyS2P3,
          l10n.helpMelodyS2P4,
          l10n.helpMelodyS2P5,
        ],
      ),
      HelpSection(
        heading: l10n.helpMelodyS3Heading,
        points: [
          l10n.helpMelodyS3P1,
          l10n.helpMelodyS3P2,
          l10n.helpMelodyS3P3,
          l10n.helpMelodyS3P4,
          l10n.helpMelodyS3P5,
        ],
      ),
      HelpSection(
        heading: l10n.helpMelodyS4Heading,
        points: [
          l10n.helpMelodyS4P1,
          l10n.helpMelodyS4P2,
          l10n.helpMelodyS4P3,
          l10n.helpMelodyS4P4,
          l10n.helpMelodyS4P5,
          l10n.helpMelodyS4P6,
          l10n.helpMelodyS4P7,
        ],
      ),
      HelpSection(
        heading: l10n.helpMelodyS5Heading,
        points: [l10n.helpMelodyS5P1, l10n.helpMelodyS5P2, l10n.helpMelodyS5P3],
      ),
    ],
  ),
  HelpTopic(
    id: 'indian-songs',
    title: l10n.titleHelpIndianSongs,
    icon: Icons.temple_hindu_outlined,
    summary: l10n.helpIndianSongsSummary,
    intro: l10n.helpIndianSongsIntro,
    sections: [
      HelpSection(
        heading: l10n.helpIndianSongsS1Heading,
        points: [
          l10n.helpIndianSongsS1P1,
          l10n.helpIndianSongsS1P2,
          l10n.helpIndianSongsS1P3,
        ],
      ),
      HelpSection(
        heading: l10n.helpIndianSongsS2Heading,
        points: [
          l10n.helpIndianSongsS2P1,
          l10n.helpIndianSongsS2P2,
          l10n.helpIndianSongsS2P3,
        ],
      ),
      HelpSection(
        heading: l10n.helpIndianSongsS3Heading,
        points: [
          l10n.helpIndianSongsS3P1,
          l10n.helpIndianSongsS3P2,
          l10n.helpIndianSongsS3P3,
          l10n.helpIndianSongsS3P4,
        ],
      ),
      HelpSection(
        heading: l10n.helpIndianSongsS4Heading,
        points: [
          l10n.helpIndianSongsS4P1,
          l10n.helpIndianSongsS4P2,
          l10n.helpIndianSongsS4P3,
          l10n.helpIndianSongsS4P4,
          l10n.helpIndianSongsS4P5,
        ],
      ),
      HelpSection(
        heading: l10n.helpIndianSongsS5Heading,
        points: [
          l10n.helpIndianSongsS5P1,
          l10n.helpIndianSongsS5P2,
          l10n.helpIndianSongsS5P3,
          l10n.helpIndianSongsS5P4,
          l10n.helpIndianSongsS5P5,
        ],
      ),
    ],
  ),
  HelpTopic(
    id: 'select-songs',
    title: l10n.titleHelpSelectSongs,
    icon: Icons.checklist,
    summary: l10n.helpSelectSongsSummary,
    intro: l10n.helpSelectSongsIntro,
    sections: [
      HelpSection(
        heading: l10n.helpSelectSongsS1Heading,
        points: [
          l10n.helpSelectSongsS1P1,
          l10n.helpSelectSongsS1P2,
          l10n.helpSelectSongsS1P3,
        ],
      ),
      HelpSection(
        heading: l10n.helpSelectSongsS2Heading,
        points: [l10n.helpSelectSongsS2P1, l10n.helpSelectSongsS2P2],
      ),
      HelpSection(
        heading: l10n.helpSelectSongsS3Heading,
        points: [
          l10n.helpSelectSongsS3P1,
          l10n.helpSelectSongsS3P2,
          l10n.helpSelectSongsS3P3,
        ],
      ),
    ],
  ),
  HelpTopic(
    id: 'import',
    title: l10n.titleHelpImport,
    icon: Icons.file_open_outlined,
    summary: l10n.helpImportSummary,
    intro: l10n.helpImportIntro,
    sections: [
      HelpSection(
        heading: l10n.helpImportS1Heading,
        points: [l10n.helpImportS1P1, l10n.helpImportS1P2, l10n.helpImportS1P3],
      ),
      HelpSection(
        heading: l10n.helpImportS2Heading,
        points: [l10n.helpImportS2P1, l10n.helpImportS2P2, l10n.helpImportS2P3],
      ),
      HelpSection(
        heading: l10n.helpImportS3Heading,
        points: [l10n.helpImportS3P1, l10n.helpImportS3P2, l10n.helpImportS3P3],
      ),
      HelpSection(
        heading: l10n.helpImportS4Heading,
        points: [l10n.helpImportS4P1, l10n.helpImportS4P2, l10n.helpImportS4P3],
      ),
      HelpSection(
        heading: l10n.helpImportS5Heading,
        points: [l10n.helpImportS5P1, l10n.helpImportS5P2, l10n.helpImportS5P3],
      ),
      HelpSection(
        heading: l10n.helpImportS6Heading,
        points: [l10n.helpImportS6P1, l10n.helpImportS6P2],
      ),
    ],
  ),
  HelpTopic(
    id: 'export',
    title: l10n.titleHelpExport,
    icon: Icons.output_rounded,
    summary: l10n.helpExportSummary,
    intro: l10n.helpExportIntro,
    sections: [
      HelpSection(
        heading: l10n.helpExportS1Heading,
        points: [l10n.helpExportS1P1, l10n.helpExportS1P2, l10n.helpExportS1P3],
      ),
      HelpSection(
        heading: l10n.helpExportS2Heading,
        points: [l10n.helpExportS2P1, l10n.helpExportS2P2, l10n.helpExportS2P3],
      ),
      HelpSection(
        heading: l10n.helpExportS3Heading,
        points: [
          l10n.helpExportS3P1,
          l10n.helpExportS3P2,
          l10n.helpExportS3P3,
          l10n.helpExportS3P4,
        ],
      ),
      HelpSection(
        heading: l10n.helpExportS4Heading,
        points: [
          l10n.helpExportS4P1,
          l10n.helpExportS4P2,
          l10n.helpExportS4P3,
          l10n.helpExportS4P4,
        ],
      ),
      HelpSection(
        heading: l10n.helpExportS5Heading,
        points: [l10n.helpExportS5P1, l10n.helpExportS5P2, l10n.helpExportS5P3],
      ),
    ],
  ),
  HelpTopic(
    id: 'airqr',
    title: l10n.titleHelpAirqr,
    icon: Icons.qr_code_2_rounded,
    summary: l10n.helpAirqrSummary,
    intro: l10n.helpAirqrIntro,
    sections: [
      HelpSection(
        heading: l10n.helpAirqrS1Heading,
        points: [
          l10n.helpAirqrS1P1,
          l10n.helpAirqrS1P2,
          l10n.helpAirqrS1P3,
          l10n.helpAirqrS1P4,
        ],
      ),
      HelpSection(
        heading: l10n.helpAirqrS2Heading,
        points: [l10n.helpAirqrS2P1, l10n.helpAirqrS2P2],
      ),
      HelpSection(
        heading: l10n.helpAirqrS3Heading,
        points: [
          l10n.helpAirqrS3P1,
          l10n.helpAirqrS3P2,
          l10n.helpAirqrS3P3,
          l10n.helpAirqrS3P4,
        ],
      ),
      HelpSection(
        heading: l10n.helpAirqrS4Heading,
        points: [
          l10n.helpAirqrS4P1,
          l10n.helpAirqrS4P2,
          l10n.helpAirqrS4P3,
          l10n.helpAirqrS4P4,
        ],
      ),
    ],
  ),
  HelpTopic(
    id: 'appearance',
    title: l10n.titleHelpAppearance,
    icon: Icons.palette_outlined,
    summary: l10n.helpAppearanceSummary,
    intro: l10n.helpAppearanceIntro,
    sections: [
      HelpSection(
        heading: l10n.helpAppearanceS1Heading,
        points: [
          l10n.helpAppearanceS1P1,
          l10n.helpAppearanceS1P2,
          l10n.helpAppearanceS1P3,
          l10n.helpAppearanceS1P4,
        ],
      ),
      HelpSection(
        heading: l10n.helpAppearanceS2Heading,
        points: [
          l10n.helpAppearanceS2P1,
          l10n.helpAppearanceS2P2,
          l10n.helpAppearanceS2P3,
          l10n.helpAppearanceS2P4,
          l10n.helpAppearanceS2P5,
        ],
      ),
      HelpSection(
        heading: l10n.helpAppearanceS3Heading,
        points: [
          l10n.helpAppearanceS3P1,
          l10n.helpAppearanceS3P2,
          l10n.helpAppearanceS3P3,
        ],
      ),
    ],
  ),
];

/// Finds a topic by its [id]. Returns null when the id is unknown, so a bad
/// link shows a safe message instead of crashing.
HelpTopic? helpTopicById(AppLocalizations l10n, String id) {
  for (final topic in helpTopics(l10n)) {
    if (topic.id == id) return topic;
  }
  return null;
}
