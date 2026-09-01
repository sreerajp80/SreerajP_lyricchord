import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:lyricchord/core/utils/safe_file_name.dart';
import 'package:lyricchord/core/utils/system_ui.dart';
import 'package:lyricchord/models/setlist.dart';
import 'package:lyricchord/models/lyric_font.dart';
import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/providers/auto_scroll_provider.dart';
import 'package:lyricchord/providers/lyric_font_provider.dart';
import 'package:lyricchord/providers/performance_provider.dart';
import 'package:lyricchord/providers/pitch_drone_provider.dart';
import 'package:lyricchord/providers/setlist_provider.dart';
import 'package:lyricchord/providers/song_list_provider.dart';
import 'package:lyricchord/providers/stage_mode_provider.dart';
import 'package:lyricchord/services/auto_scroll_calculator.dart';
import 'package:lyricchord/services/chord_pro_service.dart';
import 'package:lyricchord/services/chord_sheet_parser.dart';
import 'package:lyricchord/services/chord_transposer.dart';
import 'package:lyricchord/services/html_pdf_service.dart';
import 'package:lyricchord/services/pcm_synth_service.dart';
import 'package:lyricchord/services/pdf_export_service.dart';
import 'package:lyricchord/services/pitch_naming_service.dart';
import 'package:lyricchord/services/swara_notation_service.dart';
import 'package:lyricchord/widgets/chord_reference_dialog.dart';
import 'package:lyricchord/widgets/chord_sheet_view.dart';
import 'package:lyricchord/widgets/performance_controls.dart';
import 'package:lyricchord/widgets/stage_gesture_layer.dart';
import 'package:lyricchord/widgets/stage_help_overlay.dart';
import 'package:lyricchord/widgets/stage_hud.dart';
import 'package:lyricchord/widgets/transpose_sheet.dart';
import 'package:lyricchord/screens/air_qr_transmitter_screen.dart';

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

  /// Hides the Stage Mode control bar after a few idle seconds.
  Timer? _hudTimer;

  /// Kept from `initState` so [dispose] can flush a pending scroll-speed save
  /// without touching `ref`, which is no longer safe to use by then.
  late final AutoScrollNotifier _autoScroll;

  @override
  void initState() {
    super.initState();
    _currentId = widget.songId;
    _autoScroll = ref.read(autoScrollProvider.notifier);
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
      if (ref.read(stageModeProvider).enabled) SystemUi.enterImmersive();
    } else if (state == AppLifecycleState.paused) {
      // Never leave another app — or the launcher — with our hidden system
      // bars. They are put back on the way out and restored on resume.
      SystemUi.exitImmersive();
      // The app may not come back, so write a pending scroll speed now.
      ref.read(autoScrollProvider.notifier).flushSave();
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
    // Leaving the screen must not lose a speed still waiting on the debounce.
    _autoScroll.flushSave();
    WidgetsBinding.instance.removeObserver(this);
    // Give the screen back to the phone's normal timeout when leaving.
    WakelockPlus.disable();
    // Whatever route we left by, the system bars must come back.
    SystemUi.exitImmersive();
    _hudTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  /// Keeps the phone's chrome and the HUD timer in step with Stage Mode.
  ///
  /// Called from `build` through `ref.listen`, so every change goes through one
  /// place and the bars can never be left hidden.
  void _onStageModeChanged(StageModeState? before, StageModeState now) {
    if (before?.enabled != now.enabled) {
      if (now.enabled) {
        SystemUi.enterImmersive();
      } else {
        SystemUi.exitImmersive();
      }
    }

    _hudTimer?.cancel();
    if (now.enabled && now.hudVisible) {
      _hudTimer = Timer(StageModeState.hudTimeout, () {
        if (!mounted) return;
        ref.read(stageModeProvider.notifier).hideHud();
      });
    }
  }

  /// Back in Stage Mode leaves Stage Mode, not the song (or prompts auth unlock if locked).
  /// A second Back then goes to the songbook as usual.
  void _onBack(bool didPop, Object? result) {
    if (didPop) return;
    final stageState = ref.read(stageModeProvider);
    if (stageState.isLocked) {
      ref
          .read(stageModeProvider.notifier)
          .unlockStageWithAuth(
            reason: 'Authenticate to unlock Stage Mode and exit',
          );
      return;
    }
    ref.read(stageModeProvider.notifier).exit();
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
    ref.listen(stageModeProvider, _onStageModeChanged);
    final stage = ref.watch(stageModeProvider);

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
    final embedded = widget.embedded;
    final body = index < 0
        ? _SongPage(songId: id, active: true, embedded: embedded)
        : Listener(
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            onPointerUp: (_) => _onPointerEnded(),
            onPointerCancel: (_) => _onPointerEnded(),
            child: PageView.builder(
              // In Stage Mode a stray sideways swipe would throw the wrong song
              // on screen mid-performance, so song changing is off there — use
              // the HUD or leave Stage Mode.
              physics: (_allowPageSwipe && !stage.enabled)
                  ? const PageScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              controller: _controller,
              itemCount: ids.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, i) => _SongPage(
                songId: ids[i],
                active: ids[i] == _currentId,
                embedded: embedded,
              ),
            ),
          );

    return _shell(
      context,
      body: body,
      setlist: setlist,
      ids: ids,
      stageMode: stage.enabled,
    );
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

    // Save the speed of the song we are leaving before the new song loads its
    // own; after that the new page seeds the settings from its song row.
    ref.read(autoScrollProvider.notifier).flushSave();

    setState(() => _currentId = id);
    ref.read(performanceSettingsProvider.notifier).resetAll();
    ref.read(selectedSongIdProvider.notifier).select(id);
  }

  void _jumpToCurrent() {
    final index = _currentId == null ? -1 : _pagerIds.indexOf(_currentId!);
    final controller = _controller;
    if (index < 0 || controller == null || !controller.hasClients) return;
    ref.read(autoScrollProvider.notifier).flushSave();
    controller.jumpToPage(index);
    ref.read(performanceSettingsProvider.notifier).resetAll();
  }

  /// The screen frame: top bar plus [body].
  ///
  /// In Stage Mode there is no top bar at all — the lyrics get the whole
  /// window, and the way back out is the HUD's exit button or the Back gesture,
  /// which [PopScope] turns into "leave Stage Mode".
  Widget _shell(
    BuildContext context, {
    required Widget body,
    Setlist? setlist,
    List<int>? ids,
    bool stageMode = false,
  }) {
    if (stageMode) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: _onBack,
        child: Scaffold(body: body),
      );
    }

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
  const _SongPage({
    required this.songId,
    required this.active,
    this.embedded = false,
  });

  final int songId;

  /// True when this is the song on screen. Pre-built neighbours in the pager
  /// are inactive, so they never scroll or report their length.
  final bool active;

  /// True in the tablet's split view, where Stage Mode is not offered because
  /// it would only fill the pane, not the screen.
  final bool embedded;

  @override
  ConsumerState<_SongPage> createState() => _SongPageState();
}

class _SongPageState extends ConsumerState<_SongPage>
    with SingleTickerProviderStateMixin {
  static const ChordSheetParser _parser = ChordSheetParser();
  static const ChordTransposer _transposer = ChordTransposer();
  static const AutoScrollCalculator _calc = AutoScrollCalculator();
  static const SwaraNotation _swara = SwaraNotation();

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
    final duration = _calc.tempoDuration(
      _bpm,
      settings.measures,
      beatsPerMeasure: settings.beatsPerMeasure,
    );
    return _calc.tempoPixelsPerSecond(maxExtent, duration);
  }

  /// One finger lifted or was cancelled — never let the count go negative.
  void _releasePointer() {
    setState(() {
      if (_pointersDown > 0) _pointersDown--;
    });
  }

  /// Gives the auto-scroll notifier this song's saved speed and measures.
  ///
  /// Done after the frame because a provider must not be changed while widgets
  /// are building. Only the song on screen does this — pre-built neighbours in
  /// the pager must not take over the live settings.
  void _loadScrollSettingsAfterFrame(SongNote song, ParsedSheet sheet) {
    if (!widget.active) return;

    // An Indian song's cycle is its tala, not 4/4 — Adi is 8 beats. An unknown
    // or missing tala falls back to common time.
    //
    // The stored column wins; the `{tala: …}` header is only read for a song
    // that predates the column.
    final tala = song.tala.trim().isNotEmpty ? song.tala : sheet.tala;
    final beats = tala == null
        ? AutoScrollSettings.defaultBeatsPerMeasure
        : _swara.talaBeats(tala) ?? AutoScrollSettings.defaultBeatsPerMeasure;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.active) return;
      ref
          .read(autoScrollProvider.notifier)
          .loadForSong(
            song.id,
            speed: song.scrollSpeed,
            measures: song.scrollMeasures,
            beatsPerMeasure: beats,
          );
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
          isIndian: song.isIndian,
        );
        final sheet = _parser.parseSheet(lyrics);
        final lines = sheet.lines;
        // The stored columns win; the header lines are the fallback for a song
        // written before those columns existed.
        final raga = song.raga.trim().isNotEmpty ? song.raga : sheet.raga;
        final tala = song.tala.trim().isNotEmpty ? song.tala : sheet.tala;
        // After parsing, so the song's tala can set the Tempo-Auto beat count.
        _loadScrollSettingsAfterFrame(song, sheet);
        final currentKey = _transposer.transposeKey(
          song.key,
          settings.semitones,
        );

        _reportExtentAfterFrame();

        // Melody playback needs a real pitch for Sa and a real tempo. Either
        // missing simply leaves the beat grid readable but silent.
        final tonicHz = _melodyTonicHz(song, sheet, settings.semitones);
        final tempoBpm = song.bpm > 0 ? song.bpm.toDouble() : null;

        final stage = ref.watch(stageModeProvider);
        if (stage.enabled) {
          return _stageBody(
            context,
            sheet: _sheet(
              settings,
              lines,
              stageMode: true,
              tonicHz: tonicHz,
              tempoBpm: tempoBpm,
            ),
            title: song.title,
            currentKey: currentKey,
            bpm: song.bpm,
            raga: raga,
            tala: tala,
            hudVisible: stage.hudVisible,
          );
        }

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
              showFullScreenButton: !widget.embedded,
              raga: raga,
              tala: tala,
            ),
            Expanded(
              child: _sheet(
                settings,
                lines,
                tonicHz: tonicHz,
                tempoBpm: tempoBpm,
              ),
            ),
          ],
        );
      },
    );
  }

  /// The scrolling chord sheet, with pinch-to-zoom.
  ///
  /// One finger scrolls as normal; as soon as a second finger touches,
  /// scrolling is paused ([NeverScrollableScrollPhysics]) so the scale gesture
  /// owns the pointers. Any pinch direction works — the scale gesture only
  /// measures the distance between the fingers, wherever they are.
  /// The frequency of this song's Sa, for humming a `{melody}` line.
  ///
  /// The song's own `{tonic: ...}` line wins. An Indian song without one falls
  /// back to its key, which is its Sa. A Western song has no Sa at all, so it
  /// gets nothing and its melody lines stay unplayable rather than humming a
  /// guessed pitch.
  ///
  /// [semitones] is the active transpose. Sa moves with it, or the tune would
  /// be hummed in the old key while the chords showed the new one.
  ///
  /// A `{sruti: madhyama}` song is notated from the shuddha madhyamam rather
  /// than the adhara shadja, so its written Sa sounds five semitones higher.
  double? _melodyTonicHz(SongNote song, ParsedSheet sheet, int semitones) {
    const naming = PitchNamingService();

    final written = sheet.directives['tonic']?.trim() ?? '';
    final fallback = song.isIndian ? song.key.trim() : '';
    final source = written.isNotEmpty ? written : fallback;
    if (source.isEmpty) return null;

    final note = naming.noteForTonic(source);
    if (note == null) return null;

    // Shuddha madhyamam sits five semitones above Sa.
    final shift = semitones + (sheet.isMadhyamaSruti ? 5 : 0);

    return PcmSynthService.getFrequency(_transposer.transposeKey(note, shift));
  }

  Widget _sheet(
    PerformanceSettings settings,
    List<ChordLine> lines, {
    bool stageMode = false,
    double? tonicHz,
    double? tempoBpm,
  }) {
    return Listener(
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
          // In Stage Mode there is no app bar above and the HUD floats over the
          // bottom, so the sheet keeps clear of both.
          padding: stageMode
              ? const EdgeInsets.fromLTRB(16, 32, 16, StageHud.height + 24)
              : const EdgeInsets.fromLTRB(16, 8, 16, 48),
          child: ChordSheetView(
            lines: lines,
            fontSize:
                settings.fontSize *
                ref.watch(pitchDroneProvider.select((s) => s.fontScaleFactor)),
            showChords: settings.showChords,
            lyricFontFamily: ref.watch(lyricFontProvider).family,
            melodyTonicHz: tonicHz,
            melodyTempoBpm: tempoBpm,
          ),
        ),
      ),
    );
  }

  /// Stage Mode: lyrics edge to edge, the gesture layer over them, the HUD
  /// floating at the bottom, and the one-time gesture guide on first use.
  Widget _stageBody(
    BuildContext context, {
    required Widget sheet,
    required String title,
    required String currentKey,
    required int bpm,
    required String? raga,
    required String? tala,
    required bool hudVisible,
  }) {
    final helpSeen = ref.watch(stageHelpSeenProvider);

    return Stack(
      children: [
        Positioned.fill(child: StageGestureLayer(child: sheet)),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: StageHud(
            visible: hudVisible,
            title: title,
            currentKey: currentKey,
            bpm: bpm,
            raga: raga,
            tala: tala,
          ),
        ),
        if (!helpSeen)
          Positioned.fill(
            child: StageHelpOverlay(
              onDismiss: () =>
                  ref.read(stageHelpSeenProvider.notifier).markSeen(),
            ),
          ),
      ],
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
    final settings = ref.watch(performanceSettingsProvider);
    final semitones = settings.semitones;

    return PopupMenuButton<VoidCallback>(
      tooltip: 'More options',
      onSelected: (action) => action(),
      itemBuilder: (menuContext) => [
        PopupMenuItem<VoidCallback>(
          enabled: song != null,
          value: song == null
              ? null
              : () => showTransposeSheet(
                  context,
                  writtenKey: song.key,
                  // A swara sheet has nothing to transpose.
                  showTranspose: !song.isIndian,
                ),
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
              : () => _showExportDialog(
                  context,
                  song,
                  semitones,
                  ref.read(lyricFontProvider),
                ),
          child: const ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.output_rounded),
            title: Text('Export'),
          ),
        ),
        PopupMenuItem<VoidCallback>(
          enabled: song != null,
          value: song == null
              ? null
              : () => _showShareDialog(
                  context,
                  song,
                  semitones,
                  ref.read(lyricFontProvider),
                ),
          child: const ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.share_outlined),
            title: Text('Share'),
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
  ///
  /// A song written in swaras gets the **Swara Reference** instead: the same
  /// item, but it opens keyboards showing where each swara sits, not chord
  /// shapes. Before this, it drew a C major chord for `Sa` and a G major for
  /// `Ga` — confident and wrong.
  PopupMenuItem<VoidCallback> _chordReferenceItem(
    BuildContext context,
    WidgetRef ref,
  ) {
    final id = songId;
    final song = id == null ? null : ref.watch(songByIdProvider(id)).value;
    final settings = ref.watch(performanceSettingsProvider);
    final indian = song != null && song.isIndian;

    final markers = song == null
        ? const <String>[]
        : _transposer.chordsUsed(
            song.lyrics,
            settings.semitones,
            song.key,
            isIndian: indian,
          );
    // A reference reads best as a scale, so swaras are ordered low to high
    // rather than in order of appearance.
    final chords = indian ? _sortedByPitch(markers) : markers;

    return PopupMenuItem<VoidCallback>(
      enabled: chords.isNotEmpty,
      value: () =>
          showChordReferenceDialog(context, chords: chords, swaraMode: indian),
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.piano_outlined),
        title: Text(indian ? 'Swara Reference' : 'Chord Reference Guide'),
      ),
    );
  }

  /// [swaras] ordered by how far above Sa they sit. Anything unplaceable keeps
  /// its position at the end rather than being dropped.
  List<String> _sortedByPitch(List<String> swaras) {
    const notation = SwaraNotation();
    final sorted = [...swaras];
    sorted.sort((a, b) {
      final left = notation.swaraPosition(a) ?? 99;
      final right = notation.swaraPosition(b) ?? 99;
      return left.compareTo(right);
    });
    return sorted;
  }

  Future<void> _showExportDialog(
    BuildContext context,
    SongNote song,
    int semitones,
    LyricFont font,
  ) async {
    String chosenFormat = 'chordpro';

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Export song'),
              content: RadioGroup<String>(
                groupValue: chosenFormat,
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => chosenFormat = val);
                  }
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      title: Text('ChordPro (.chordpro)'),
                      value: 'chordpro',
                    ),
                    RadioListTile<String>(
                      title: Text('PDF (.pdf)'),
                      value: 'pdf',
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.of(dialogContext).pop(chosenFormat),
                  child: const Text('Export'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null || !context.mounted) return;

    if (result == 'chordpro') {
      await _exportChordPro(context, song, semitones);
    } else if (result == 'pdf') {
      await _exportPdf(context, song, semitones, font);
    }
  }

  Future<void> _showShareDialog(
    BuildContext context,
    SongNote song,
    int semitones,
    LyricFont font,
  ) async {
    String chosenFormat = 'chordpro';

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Share song'),
              content: RadioGroup<String>(
                groupValue: chosenFormat,
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => chosenFormat = val);
                  }
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      title: Text('AirQR Stream (Animated QR)'),
                      value: 'airqr',
                    ),
                    RadioListTile<String>(
                      title: Text('ChordPro (.chordpro)'),
                      value: 'chordpro',
                    ),
                    RadioListTile<String>(
                      title: Text('PDF (.pdf)'),
                      value: 'pdf',
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.of(dialogContext).pop(chosenFormat),
                  child: const Text('Share'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null || !context.mounted) return;

    if (result == 'airqr') {
      const service = ChordProService();
      final text = service.format(song, semitones: semitones);
      context.push(
        '/air-qr-transmit',
        extra: AirQrTransmitterArgs(title: song.title, chordProPayload: text),
      );
    } else if (result == 'chordpro') {
      await _shareChordPro(context, song, semitones);
    } else if (result == 'pdf') {
      await _sharePdf(context, song, semitones, font);
    }
  }

  Future<void> _shareChordPro(
    BuildContext context,
    SongNote song,
    int semitones,
  ) async {
    try {
      const service = ChordProService();
      final text = service.format(song, semitones: semitones);
      final fileName = '${safeFileName(song.title)}.chordpro';
      final bytes = Uint8List.fromList(utf8.encode(text));
      await Printing.sharePdf(bytes: bytes, filename: fileName);
    } catch (_) {
      if (context.mounted) {
        _showSnack(context, 'Could not share the ChordPro file.');
      }
    }
  }

  Future<void> _sharePdf(
    BuildContext context,
    SongNote song,
    int semitones,
    LyricFont font,
  ) async {
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

      final fileName = '${safeFileName(song.title)}.pdf';
      await Printing.sharePdf(bytes: bytes, filename: fileName);
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
        debugPrint('PDF share failed: $error\n$stack');
      }
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not share the PDF.')),
      );
    }
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
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
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
        type: FileType.custom,
        allowedExtensions: const ['chordpro'],
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
