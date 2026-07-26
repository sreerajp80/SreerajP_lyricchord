import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:lyricchord/core/utils/safe_file_name.dart';
import 'package:lyricchord/models/setlist.dart';
import 'package:lyricchord/models/lyric_font.dart';
import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/providers/auto_scroll_provider.dart';
import 'package:lyricchord/providers/lyric_font_provider.dart';
import 'package:lyricchord/providers/performance_provider.dart';
import 'package:lyricchord/providers/setlist_provider.dart';
import 'package:lyricchord/providers/song_list_provider.dart';
import 'package:lyricchord/services/auto_scroll_calculator.dart';
import 'package:lyricchord/services/chord_pro_service.dart';
import 'package:lyricchord/services/chord_sheet_parser.dart';
import 'package:lyricchord/services/chord_transposer.dart';
import 'package:lyricchord/services/html_pdf_service.dart';
import 'package:lyricchord/services/pdf_export_service.dart';
import 'package:lyricchord/widgets/chord_reference_dialog.dart';
import 'package:lyricchord/widgets/chord_sheet_view.dart';
import 'package:lyricchord/widgets/performance_controls.dart';
import 'package:lyricchord/widgets/transpose_sheet.dart';

/// Read and perform a song: the chord sheet plus the Performance Controls.
///
/// Swiping left or right moves to the next or previous song in the setlist or
/// songbook list.
class SongPerformanceScreen extends ConsumerStatefulWidget {
  const SongPerformanceScreen({
    super.key,
    required this.songId,
    this.setlistId,
    this.embedded = false,
  });

  /// The song to open. `null` means the link had no usable id.
  final int? songId;

  /// Optional setlist ID if opened from a setlist context.
  final int? setlistId;

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

  /// Track fingers currently touching the screen.
  int _pointersDown = 0;

  /// True when the user is allowed to swipe left/right to change songs.
  /// Set to false during multi-finger pinch zoom or vertical lyric scrolling.
  bool _allowPageSwipe = true;

  /// True once the direction of the current touch drag (vertical vs horizontal)
  /// or gesture mode (multi-finger pinch) has been determined.
  bool _gestureLocked = false;

  /// Touch position when the first finger touched down.
  Offset? _startPosition;

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

  void _onPointerDown(PointerDownEvent event) {
    _pointersDown++;
    if (_pointersDown >= 2) {
      if (_allowPageSwipe) {
        setState(() {
          _allowPageSwipe = false;
          _gestureLocked = true;
        });
      }
    } else if (_pointersDown == 1) {
      _startPosition = event.position;
      _gestureLocked = false;
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_pointersDown == 1 && !_gestureLocked && _startPosition != null) {
      final dx = (event.position.dx - _startPosition!.dx).abs();
      final dy = (event.position.dy - _startPosition!.dy).abs();
      if (dx > 8 || dy > 8) {
        _gestureLocked = true;
        final isVertical = dy >= dx;
        if (isVertical && _allowPageSwipe) {
          setState(() => _allowPageSwipe = false);
        }
      }
    }
  }

  void _onPointerEnded() {
    if (_pointersDown > 0) _pointersDown--;
    if (_pointersDown == 0) {
      _startPosition = null;
      _gestureLocked = false;
      if (!_allowPageSwipe) {
        setState(() => _allowPageSwipe = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final setlistId = widget.setlistId ?? ref.watch(activeSetlistIdProvider);
    final setlist = setlistId != null
        ? ref.watch(setlistByIdProvider(setlistId)).value
        : null;

    final List<int> ids;
    if (setlist != null && setlist.songs.isNotEmpty) {
      ids = setlist.songs.map((s) => s.id).toList(growable: false);
    } else {
      final songs = ref.watch(filteredSongsProvider);
      ids = songs.map((s) => s.id).toList(growable: false);
    }

    _syncPager(ids);

    final id = _currentId;
    if (id == null) return _shell(context, body: const _MissingSong());

    final index = ids.indexOf(id);
    final body = index < 0
        ? _SongPage(songId: id, active: true)
        : Listener(
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            onPointerUp: (_) => _onPointerEnded(),
            onPointerCancel: (_) => _onPointerEnded(),
            child: PageView.builder(
              physics: _allowPageSwipe
                  ? const PageScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              controller: _controller,
              itemCount: ids.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, i) =>
                  _SongPage(songId: ids[i], active: ids[i] == _currentId),
            ),
          );

    return _shell(context, body: body, setlist: setlist, ids: ids);
  }

  /// Keeps the pager and the list agreeing about which song is where.
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
    ref.read(performanceSettingsProvider.notifier).resetAll();
    ref.read(autoScrollProvider.notifier).resetAll();
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
  Widget _shell(
    BuildContext context, {
    required Widget body,
    Setlist? setlist,
    List<int>? ids,
  }) {
    final id = _currentId;
    final currentIndex = (ids != null && id != null) ? ids.indexOf(id) : -1;
    final totalSongs = ids?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: id == null
            ? const Text('Song')
            : _AppBarTitle(
                songId: id,
                setlist: setlist,
                index: currentIndex,
                total: totalSongs,
              ),
        actions: [
          if (setlist != null && setlist.songs.isNotEmpty) ...[
            IconButton(
              tooltip: 'Previous song',
              icon: const Icon(Icons.skip_previous),
              onPressed: currentIndex > 0
                  ? () => _controller?.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    )
                  : null,
            ),
            IconButton(
              tooltip: 'Next song',
              icon: const Icon(Icons.skip_next),
              onPressed: currentIndex >= 0 && currentIndex < totalSongs - 1
                  ? () => _controller?.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    )
                  : null,
            ),
            IconButton(
              tooltip: 'Setlist songs',
              icon: const Icon(Icons.queue_music),
              onPressed: () =>
                  _showQuickSetlistSheet(context, setlist, currentIndex),
            ),
          ],
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

  void _showQuickSetlistSheet(
    BuildContext context,
    Setlist setlist,
    int currentIndex,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.playlist_play),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      setlist.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${setlist.songCount} songs',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: setlist.songs.length,
                itemBuilder: (context, idx) {
                  final song = setlist.songs[idx];
                  final isCurrent = idx == currentIndex;
                  final theme = Theme.of(context);
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 12,
                      backgroundColor: isCurrent
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                      child: Text(
                        '${idx + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isCurrent
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    title: Text(
                      song.title,
                      style: TextStyle(
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: song.artist.isNotEmpty ? Text(song.artist) : null,
                    trailing: Text(
                      song.key,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    selected: isCurrent,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _controller?.animateToPage(
                        idx,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
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
  const _AppBarTitle({
    required this.songId,
    this.setlist,
    this.index = -1,
    this.total = 0,
  });

  final int songId;
  final Setlist? setlist;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final song = ref.watch(songByIdProvider(songId)).value;
    if (song == null) return const Text('Song');

    final String subtitle = (setlist != null && index >= 0 && total > 0)
        ? '${setlist!.name} (${index + 1}/$total)'
        : song.artist;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(song.title, overflow: TextOverflow.ellipsis),
        if (subtitle.trim().isNotEmpty)
          Text(
            subtitle,
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
  ///
  /// Rendering goes through [HtmlPdfService], a native on-window web view that
  /// shapes Malayalam correctly and keeps the text selectable. (The old
  /// `Printing.convertHtml` used an unattached web view that hangs forever on
  /// newer Android.) A progress dialog shows while it works, the render is timed
  /// out, and the outcome always surfaces as a SnackBar. The real error is
  /// printed to the debug log only.
  Future<void> _exportPdf(
    BuildContext context,
    SongNote song,
    int semitones,
    LyricFont font,
  ) async {
    // Capture these before any await so we never touch a stale context.
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);

    var dialogOpen = true;
    void closeDialog() {
      if (dialogOpen) {
        dialogOpen = false;
        navigator.pop();
      }
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      const service = PdfExportService();
      final html = await service.buildHtml(
        song,
        semitones: semitones,
        font: font,
      );
      // The native web view shapes complex scripts (Malayalam chillu,
      // conjuncts, reordered vowel signs) and keeps the text selectable. The
      // native side has its own hard timeout; this outer timeout is a backstop
      // so a stuck render always fails loudly, never hangs silently.
      const converter = HtmlPdfService();
      final bytes = await converter
          .convert(html: html)
          .timeout(const Duration(seconds: 30));
      closeDialog();

      if (bytes.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Could not export the PDF (no pages).')),
        );
        return;
      }

      // Save through the system "Save" dialog (scoped storage, no permission).
      // This preserves a Unicode file name — the share sheet's content URI
      // percent-encodes non-ASCII names, so Malayalam titles came out garbled.
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export as PDF',
        fileName: '${safeFileName(song.title)}.pdf',
        bytes: bytes,
      );
      if (path != null) {
        messenger.showSnackBar(
          SnackBar(content: Text('Exported "${song.title}".')),
        );
      }
    } on TimeoutException {
      closeDialog();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('PDF export took too long and was stopped.'),
        ),
      );
    } catch (error, stack) {
      closeDialog();
      if (kDebugMode) {
        debugPrint('PDF export failed: $error\n$stack');
      }
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not export the PDF.')),
      );
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
        fileName: '${safeFileName(song.title)}.chordpro',
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

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
