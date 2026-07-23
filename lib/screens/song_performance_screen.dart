import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:lyriccord/models/lyric_font.dart';
import 'package:lyriccord/models/song_note.dart';
import 'package:lyriccord/providers/auto_scroll_provider.dart';
import 'package:lyriccord/providers/lyric_font_provider.dart';
import 'package:lyriccord/providers/performance_provider.dart';
import 'package:lyriccord/providers/song_list_provider.dart';
import 'package:lyriccord/services/auto_scroll_calculator.dart';
import 'package:lyriccord/services/chord_pro_service.dart';
import 'package:lyriccord/services/chord_sheet_parser.dart';
import 'package:lyriccord/services/chord_transposer.dart';
import 'package:lyriccord/services/pdf_export_service.dart';
import 'package:lyriccord/widgets/chord_reference_dialog.dart';
import 'package:lyriccord/widgets/chord_sheet_view.dart';
import 'package:lyriccord/widgets/performance_controls.dart';
import 'package:lyriccord/widgets/transpose_sheet.dart';

/// Read and perform a song: the chord sheet plus the Performance Controls.
///
/// Swiping left or right moves to the next or previous song in the list as it
/// is currently filtered, which is why the pager reads
/// [filteredSongsProvider] rather than the whole songbook.
class SongPerformanceScreen extends ConsumerStatefulWidget {
  const SongPerformanceScreen({
    super.key,
    required this.songId,
    this.embedded = false,
  });

  /// The song to open. `null` means the link had no usable id.
  final int? songId;

  /// True when shown as the tablet's right pane, where the list is still on
  /// screen so there is nothing to go back to.
  final bool embedded;

  @override
  ConsumerState<SongPerformanceScreen> createState() =>
      _SongPerformanceScreenState();
}

class _SongPerformanceScreenState extends ConsumerState<SongPerformanceScreen>
    with WidgetsBindingObserver {
  PageController? _controller;

  /// The song actually on screen — it changes as the user swipes.
  int? _currentId;

  /// The song order the pager was built from. Kept so a list change (a delete,
  /// a new search) can rebuild the pager instead of leaving it on a stale page.
  List<int> _pagerIds = const [];

  @override
  void initState() {
    super.initState();
    _currentId = widget.songId;
    // Keep the screen on while a song is open to perform, so the phone does not
    // dim or lock mid-song. Released again in [dispose].
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // The OS clears the wake-lock when the app leaves the foreground, so
    // re-enable it on resume while this screen is still on show.
    if (state == AppLifecycleState.resumed) {
      WakelockPlus.enable();
    }
  }

  @override
  void didUpdateWidget(SongPerformanceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // On a tablet the pane is reused: picking another song changes songId.
    if (widget.songId != oldWidget.songId && widget.songId != _currentId) {
      _currentId = widget.songId;
      _jumpToCurrent();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Give the screen back to the phone's normal timeout when leaving.
    WakelockPlus.disable();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final songs = ref.watch(filteredSongsProvider);
    final ids = songs.map((s) => s.id).toList(growable: false);
    _syncPager(ids);

    final id = _currentId;
    if (id == null) return _shell(context, body: const _MissingSong());

    final index = ids.indexOf(id);
    // A song that is not in the current list (deep link, or filtered out) still
    // opens — it just cannot be swiped away from.
    final body = index < 0
        ? _SongPage(songId: id, active: true)
        : PageView.builder(
            controller: _controller,
            itemCount: ids.length,
            onPageChanged: _onPageChanged,
            // Only the song on screen drives auto-scroll; the pre-built
            // neighbours stay put until they become current.
            itemBuilder: (context, i) =>
                _SongPage(songId: ids[i], active: ids[i] == _currentId),
          );

    return _shell(context, body: body);
  }

  /// Keeps the pager and the list agreeing about which song is where.
  ///
  /// When the list order changes under a live pager (saving a song bumps its
  /// timestamp and moves it to the top), the scroll position does not move on
  /// its own — the pager would keep showing whatever song now sits at the old
  /// index. So after the frame settles, jump back to the current song's new
  /// index.
  void _syncPager(List<int> ids) {
    if (_controller != null && _listEquals(ids, _pagerIds)) return;

    _pagerIds = ids;
    final index = _currentId == null ? -1 : ids.indexOf(_currentId!);

    if (_controller == null) {
      _controller = PageController(initialPage: index < 0 ? 0 : index);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = _controller;
      if (controller == null || !controller.hasClients) return;
      final target = _currentId == null ? -1 : _pagerIds.indexOf(_currentId!);
      if (target >= 0 && controller.page?.round() != target) {
        controller.jumpToPage(target);
      }
    });
  }

  void _onPageChanged(int index) {
    if (index < 0 || index >= _pagerIds.length) return;
    final id = _pagerIds[index];
    if (id == _currentId) return;

    setState(() => _currentId = id);
    // A new song starts in its own key, at the default size, and paused at the
    // top.
    ref.read(performanceSettingsProvider.notifier).resetAll();
    ref.read(autoScrollProvider.notifier).resetAll();
    // Keep the tablet list highlight on the song being performed.
    ref.read(selectedSongIdProvider.notifier).select(id);
  }

  void _jumpToCurrent() {
    final index = _currentId == null ? -1 : _pagerIds.indexOf(_currentId!);
    final controller = _controller;
    if (index < 0 || controller == null || !controller.hasClients) return;
    controller.jumpToPage(index);
    ref.read(performanceSettingsProvider.notifier).resetAll();
    ref.read(autoScrollProvider.notifier).resetAll();
  }

  /// The screen frame: top bar plus [body].
  Widget _shell(BuildContext context, {required Widget body}) {
    final id = _currentId;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: id == null ? const Text('Song') : _AppBarTitle(songId: id),
        actions: [
          if (id != null)
            IconButton(
              tooltip: 'Edit song',
              onPressed: () => context.push('/song/$id/edit'),
              icon: const Icon(Icons.edit_outlined),
            ),
          _OverflowMenu(songId: id),
        ],
      ),
      body: body,
    );
  }
}

bool _listEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Title and artist in the top bar, kept live so an edit shows straight away.
class _AppBarTitle extends ConsumerWidget {
  const _AppBarTitle({required this.songId});

  final int songId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final song = ref.watch(songByIdProvider(songId)).value;
    if (song == null) return const Text('Song');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(song.title, overflow: TextOverflow.ellipsis),
        if (song.artist.trim().isNotEmpty)
          Text(
            song.artist,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
      ],
    );
  }
}

/// One page of the pager: the controls card and the scrolling chord sheet for
/// a single song.
///
/// This page owns the [ScrollController] and the [Ticker] that drive
/// auto-scroll. It listens to [autoScrollProvider]: while playing it advances
/// the scroll offset each frame at the speed the calculator works out, and it
/// stops itself at the bottom.
class _SongPage extends ConsumerStatefulWidget {
  const _SongPage({required this.songId, required this.active});

  final int songId;

  /// True when this is the song on screen. Pre-built neighbours in the pager
  /// are inactive, so they never scroll or report their length.
  final bool active;

  @override
  ConsumerState<_SongPage> createState() => _SongPageState();
}

class _SongPageState extends ConsumerState<_SongPage>
    with SingleTickerProviderStateMixin {
  static const ChordSheetParser _parser = ChordSheetParser();
  static const ChordTransposer _transposer = ChordTransposer();
  static const AutoScrollCalculator _calc = AutoScrollCalculator();

  final ScrollController _scrollController = ScrollController();
  late final Ticker _ticker;

  /// Elapsed time at the previous tick, so we can scroll by real time passed.
  Duration _lastElapsed = Duration.zero;

  /// Fingers currently touching the sheet. With two or more, scrolling is
  /// paused so the pinch zoom wins the gesture cleanly.
  int _pointersDown = 0;

  /// The font size when the current pinch began; each update scales from
  /// this base so the zoom never compounds.
  double _pinchStartFontSize = PerformanceSettings.defaultFontSize;

  /// The song's tempo, kept from the last build for the off-build ticker.
  int _bpm = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Starts or stops the ticker to match [AutoScrollSettings.isPlaying].
  void _syncPlaying(bool isPlaying) {
    if (isPlaying && widget.active) {
      if (!_ticker.isActive) {
        _lastElapsed = Duration.zero;
        _ticker.start();
      }
    } else if (_ticker.isActive) {
      _ticker.stop();
    }
  }

  void _onTick(Duration elapsed) {
    if (!widget.active || !_scrollController.hasClients) return;

    final dtSeconds =
        (elapsed - _lastElapsed).inMicroseconds /
        Duration.microsecondsPerSecond;
    _lastElapsed = elapsed;
    if (dtSeconds <= 0) return;

    final position = _scrollController.position;
    final maxExtent = position.maxScrollExtent;
    final pxPerSec = _currentPixelsPerSecond(maxExtent);
    if (pxPerSec <= 0) return;

    final next = position.pixels + pxPerSec * dtSeconds;
    if (next >= maxExtent) {
      _scrollController.jumpTo(maxExtent);
      // Reached the end — stop itself (idea doc §Auto-scroll).
      ref.read(autoScrollProvider.notifier).stop();
    } else {
      _scrollController.jumpTo(next);
    }
  }

  /// The speed to scroll at right now, from the current mode and settings.
  double _currentPixelsPerSecond(double maxExtent) {
    final settings = ref.read(autoScrollProvider);
    if (settings.mode == AutoScrollMode.manual) {
      return _calc.manualPixelsPerSecond(settings.speed);
    }
    final duration = _calc.tempoDuration(_bpm, settings.measures);
    return _calc.tempoPixelsPerSecond(maxExtent, duration);
  }

  /// One finger lifted or was cancelled — never let the count go negative.
  void _releasePointer() {
    setState(() {
      if (_pointersDown > 0) _pointersDown--;
    });
  }

  /// Reports the scroll length to the notifier after layout settles, so the
  /// Tempo-Auto read-out (duration + px/s) reflects the real content height.
  void _reportExtentAfterFrame() {
    if (!widget.active) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      ref
          .read(autoScrollProvider.notifier)
          .reportContentExtent(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Drive the ticker from the play/pause flag.
    ref.listen(autoScrollProvider.select((s) => s.isPlaying), (_, isPlaying) {
      _syncPlaying(isPlaying);
    });

    final songAsync = ref.watch(songByIdProvider(widget.songId));
    final settings = ref.watch(performanceSettingsProvider);

    return songAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const _MissingSong(),
      data: (song) {
        if (song == null) return const _MissingSong();

        _bpm = song.bpm;
        final lyrics = _transposer.transposeLyrics(
          song.lyrics,
          settings.semitones,
          song.key,
        );
        final lines = _parser.parse(lyrics);
        final currentKey = _transposer.transposeKey(
          song.key,
          settings.semitones,
        );

        _reportExtentAfterFrame();

        return Column(
          // Stretch so the scroll view fills the full width. A vertical
          // SingleChildScrollView shrink-wraps its width to its content, and
          // the Column's default centre alignment would then float a short
          // lyric line in the middle of the screen instead of at the left
          // margin.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PerformanceControls(
              currentKey: currentKey,
              bpm: song.bpm,
              active: widget.active,
            ),
            Expanded(
              // Pinch zoom for the lyric text. One finger scrolls as normal;
              // as soon as a second finger touches, scrolling is paused
              // (NeverScrollableScrollPhysics) so the scale gesture owns the
              // pointers. Any pinch direction works — the scale gesture only
              // measures the distance between the fingers, wherever they are.
              child: Listener(
                onPointerDown: (_) => setState(() => _pointersDown++),
                onPointerUp: (_) => _releasePointer(),
                onPointerCancel: (_) => _releasePointer(),
                child: GestureDetector(
                  onScaleStart: (_) => _pinchStartFontSize = ref
                      .read(performanceSettingsProvider)
                      .fontSize,
                  onScaleUpdate: (details) {
                    if (details.pointerCount < 2) return;
                    ref
                        .read(performanceSettingsProvider.notifier)
                        .applyFontScale(_pinchStartFontSize, details.scale);
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: _pointersDown >= 2
                        ? const NeverScrollableScrollPhysics()
                        : null,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
                    child: ChordSheetView(
                      lines: lines,
                      fontSize: settings.fontSize,
                      showChords: settings.showChords,
                      lyricFontFamily: ref.watch(lyricFontProvider).family,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Shown when the link points at a song that is not there any more.
class _MissingSong extends StatelessWidget {
  const _MissingSong();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.music_off_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text('Song not found', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'It may have been deleted from your songbook.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The top-bar overflow menu. Chord Reference (Phase 6) opens the diagrams
/// dialog; the export items (Phase 7) are shown but disabled, the way Import
/// was in Phase 2.
class _OverflowMenu extends ConsumerWidget {
  const _OverflowMenu({required this.songId});

  /// The song on screen, or `null` when the link had no usable id.
  final int? songId;

  static const ChordTransposer _transposer = ChordTransposer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = songId;
    final song = id == null ? null : ref.watch(songByIdProvider(id)).value;
    final semitones = ref.watch(performanceSettingsProvider).semitones;

    return PopupMenuButton<VoidCallback>(
      tooltip: 'More options',
      onSelected: (action) => action(),
      itemBuilder: (menuContext) => [
        PopupMenuItem<VoidCallback>(
          enabled: song != null,
          value: song == null
              ? null
              : () => showTransposeSheet(context, writtenKey: song.key),
          child: const ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.tune),
            title: Text('Performance controls'),
          ),
        ),
        _chordReferenceItem(context, ref),
        PopupMenuItem<VoidCallback>(
          enabled: song != null,
          value: song == null
              ? null
              : () => _exportPdf(
                  context,
                  song,
                  semitones,
                  ref.read(lyricFontProvider),
                ),
          child: const ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.picture_as_pdf_outlined),
            title: Text('Export as PDF'),
          ),
        ),
        PopupMenuItem<VoidCallback>(
          enabled: song != null,
          value: song == null
              ? null
              : () => _exportChordPro(context, song, semitones),
          child: const ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.save_alt_outlined),
            title: Text('Export as ChordPro'),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<VoidCallback>(
          value: () => context.push('/settings'),
          child: const ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.settings_outlined),
            title: Text('Settings'),
          ),
        ),
      ],
    );
  }

  /// The Chord Reference Guide item. It reads the current song and the live
  /// transpose amount, works out the chords in the key the sheet sounds in, and
  /// opens the diagrams dialog. It is disabled when there is no song or the song
  /// has no chords.
  PopupMenuItem<VoidCallback> _chordReferenceItem(
    BuildContext context,
    WidgetRef ref,
  ) {
    final id = songId;
    final song = id == null ? null : ref.watch(songByIdProvider(id)).value;
    final settings = ref.watch(performanceSettingsProvider);
    final chords = song == null
        ? const <String>[]
        : _transposer.chordsUsed(song.lyrics, settings.semitones, song.key);

    return PopupMenuItem<VoidCallback>(
      enabled: chords.isNotEmpty,
      value: () => showChordReferenceDialog(context, chords: chords),
      child: const ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.piano_outlined),
        title: Text('Chord Reference Guide'),
      ),
    );
  }

  /// Builds the PDF for [song] (with the live transpose) and opens the system
  /// share sheet. Sharing is offline — no network is used.
  Future<void> _exportPdf(
    BuildContext context,
    SongNote song,
    int semitones,
    LyricFont font,
  ) async {
    try {
      const service = PdfExportService();
      final bytes = await service.buildPdf(
        song,
        semitones: semitones,
        font: font,
      );
      await Printing.sharePdf(
        bytes: bytes,
        filename: '${_safeFileName(song.title)}.pdf',
      );
    } catch (_) {
      if (context.mounted) _showSnack(context, 'Could not export the PDF.');
    }
  }

  /// Writes [song] out as ChordPro text (with the live transpose) through the
  /// system save dialog. No storage permission is requested (scoped storage).
  Future<void> _exportChordPro(
    BuildContext context,
    SongNote song,
    int semitones,
  ) async {
    try {
      const service = ChordProService();
      final text = service.format(song, semitones: semitones);
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export as ChordPro',
        fileName: '${_safeFileName(song.title)}.chordpro',
        bytes: Uint8List.fromList(utf8.encode(text)),
      );
      if (context.mounted && path != null) {
        _showSnack(context, 'Exported "${song.title}".');
      }
    } catch (_) {
      if (context.mounted) {
        _showSnack(context, 'Could not export the ChordPro file.');
      }
    }
  }

  /// Makes a title safe to use as a file name, so a stray `/` or `:` never
  /// breaks the export path.
  String _safeFileName(String title) {
    final cleaned = title
        .trim()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    return cleaned.isEmpty ? 'song' : cleaned;
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
