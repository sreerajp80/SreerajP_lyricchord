import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyricchord/l10n/app_localizations.dart';

import 'package:lyricchord/providers/auto_scroll_provider.dart';
import 'package:lyricchord/providers/stage_mode_provider.dart';
import 'package:lyricchord/widgets/auto_scroll_controls.dart';
import 'package:lyricchord/widgets/stage_feedback.dart';

/// The scroll gesture layer: the taps that control the sheet with no buttons on
/// screen, plus the big flash that says what just changed.
///
/// | Gesture | Does |
/// |---|---|
/// | Single tap | Show / hide the control bar (Stage Mode only) |
/// | Double-tap, upper half | Faster (Manual) / more bars (Tempo) |
/// | Double-tap, lower half | Slower (Manual) / fewer bars (Tempo) |
/// | Two-finger tap | Play / pause |
///
/// It sits over the sheet in both views. Stage Mode has a HUD for a single tap
/// to show and hide; the normal song view has none, so it passes
/// [singleTapTogglesHud] as `false` and a lone tap there does nothing.
///
/// Up for more and down for less is the same direction as volume and
/// brightness, so it needs no teaching.
///
/// **Why the taps are worked out by hand.** This uses a passive [Listener]
/// rather than a [GestureDetector]. The sheet underneath already has a drag
/// (scrolling) and a scale (pinch to zoom the font) fighting for the same
/// fingers; adding tap recognisers to that contest makes both flaky. A
/// [Listener] never claims a gesture, so scrolling and pinching keep working
/// exactly as before and the taps are simply read off the pointer stream.
class ScrollGestureLayer extends ConsumerStatefulWidget {
  const ScrollGestureLayer({
    super.key,
    required this.child,
    this.singleTapTogglesHud = true,
  });

  /// The lyrics sheet this layer sits over.
  final Widget child;

  /// Whether one tap shows and hides the Stage Mode control bar.
  ///
  /// `false` in the normal song view, which has no such bar — a lone tap there
  /// is left alone so it cannot disturb the sheet. Double-taps and the
  /// two-finger tap work the same either way.
  final bool singleTapTogglesHud;

  @override
  ConsumerState<ScrollGestureLayer> createState() => _ScrollGestureLayerState();
}

class _ScrollGestureLayerState extends ConsumerState<ScrollGestureLayer> {
  /// Longest a one-finger touch can last and still count as a tap. Kept short
  /// because the double-tap window hangs off it.
  static const Duration _tapTimeout = Duration(milliseconds: 300);

  /// The same for two or more fingers. People are much slower putting two
  /// fingers down and lifting them again — 400 to 600 ms is normal, and more
  /// with an instrument in the way — and nothing else is racing this gesture.
  static const Duration _multiTapTimeout = Duration(milliseconds: 600);

  /// How long after a first tap a second one still counts as a double-tap.
  static const Duration _doubleTapWindow = Duration(milliseconds: 300);

  /// How far a finger may travel and still count as a tap, in logical pixels.
  /// Two fingers landing together roll and settle more than one does.
  static const double _tapSlop = 24;

  /// How long the value flash stays on screen.
  static const Duration _flashDuration = Duration(milliseconds: 900);

  /// Fingers currently touching.
  int _pointersDown = 0;

  /// Most fingers seen at once during the touch being measured.
  int _maxPointers = 0;

  /// When the first finger of the current touch went down.
  ///
  /// This is the pointer event's own timestamp, not `DateTime.now()`. The event
  /// clock is the one the framework — and the test binding — controls, so the
  /// timeout behaves the same in a test as it does on a phone.
  Duration? _touchStart;

  /// Where each finger went down, by pointer id.
  ///
  /// One shared origin is not enough: two fingers sit 100–200 px apart, so
  /// measuring the second finger against the first finger's starting point
  /// makes every two-finger touch look like a long drag. Each finger is judged
  /// against its own starting point.
  final Map<int, Offset> _origins = {};

  /// The furthest any one finger has strayed from where it went down.
  double _maxTravel = 0;

  /// Set while we are waiting to see whether a single tap becomes a double-tap.
  Timer? _singleTapTimer;
  Offset? _pendingTapPosition;

  /// The text of the big flash, or `null` when nothing is showing.
  String? _flashText;
  Timer? _flashTimer;

  @override
  void dispose() {
    _singleTapTimer?.cancel();
    _flashTimer?.cancel();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointersDown++;
    if (_pointersDown == 1) {
      _touchStart = event.timeStamp;
      _origins.clear();
      _maxTravel = 0;
      _maxPointers = 1;
    } else if (_pointersDown > _maxPointers) {
      _maxPointers = _pointersDown;
    }
    _origins[event.pointer] = event.localPosition;
  }

  void _onPointerMove(PointerMoveEvent event) {
    final origin = _origins[event.pointer];
    if (origin == null) return;
    final travel = (event.localPosition - origin).distance;
    if (travel > _maxTravel) _maxTravel = travel;
  }

  void _onPointerUp(PointerUpEvent event) =>
      _endPointer(event.localPosition, event.timeStamp);

  void _onPointerCancel(PointerCancelEvent event) {
    // A cancel means the OS took the gesture (an edge swipe, a system sheet).
    // Drop the whole touch rather than guess at it.
    if (_pointersDown > 0) _pointersDown--;
    if (_pointersDown == 0) _resetTouch();
  }

  void _endPointer(Offset position, Duration timeStamp) {
    if (_pointersDown > 0) _pointersDown--;
    if (_pointersDown > 0) return;

    final start = _touchStart;
    final fingers = _maxPointers;
    final travel = _maxTravel;
    _resetTouch();

    if (start == null) return;
    final limit = fingers >= 2 ? _multiTapTimeout : _tapTimeout;
    final wasTap = (timeStamp - start) <= limit && travel <= _tapSlop;
    if (!wasTap) return;

    if (fingers >= 2) {
      _onTwoFingerTap();
    } else {
      _onSingleFingerTap(position);
    }
  }

  void _resetTouch() {
    _touchStart = null;
    _origins.clear();
    _maxTravel = 0;
    _maxPointers = 0;
  }

  /// Two fingers, tapped and lifted without moving — play or pause. A pinch
  /// always moves, so it can never land here.
  void _onTwoFingerTap() {
    // A pending single tap is cancelled: the user clearly meant this instead.
    _singleTapTimer?.cancel();
    _singleTapTimer = null;

    final controls = ref.read(autoScrollProvider.notifier);
    controls.togglePlay();
    final l10n = AppLocalizations.of(context);
    _flash(
      ref.read(autoScrollProvider).isPlaying
          ? l10n.labelStagePlaying
          : l10n.labelStagePaused,
    );
  }

  /// One finger. Either the second half of a double-tap, or a single tap once
  /// the double-tap window has passed with nothing following it.
  void _onSingleFingerTap(Offset position) {
    final pending = _pendingTapPosition;
    if (pending != null && (position - pending).distance <= _tapSlop * 3) {
      _singleTapTimer?.cancel();
      _singleTapTimer = null;
      _pendingTapPosition = null;
      _onDoubleTap(position);
      return;
    }

    _pendingTapPosition = position;
    _singleTapTimer?.cancel();
    _singleTapTimer = Timer(_doubleTapWindow, () {
      _singleTapTimer = null;
      _pendingTapPosition = null;
      if (!mounted) return;
      if (!widget.singleTapTogglesHud) return;
      ref.read(stageModeProvider.notifier).toggleHud();
    });
  }

  /// Upper half is faster, lower half is slower — in Tempo mode that means more
  /// or fewer bars, because bars are what set the speed there.
  void _onDoubleTap(Offset position) {
    final box = context.findRenderObject() as RenderBox?;
    final height = box?.size.height ?? 0;
    if (height <= 0) return;
    final isUpperHalf = position.dy < height / 2;

    final controls = ref.read(autoScrollProvider.notifier);
    final isTempo = ref.read(autoScrollProvider).mode == AutoScrollMode.tempo;

    if (isTempo) {
      isUpperHalf ? controls.increaseMeasures() : controls.decreaseMeasures();
      _flash(
        AppLocalizations.of(
          context,
        ).labelInfoBars(ref.read(autoScrollProvider).measures),
      );
    } else {
      isUpperHalf ? controls.increaseSpeed() : controls.decreaseSpeed();
      _flash(
        formatSpeedLabel(
          ref.read(autoScrollProvider).speed,
          AppLocalizations.of(context).localeName,
        ),
      );
    }
  }

  /// Shows [text] big in the middle of the screen for a moment, so the change
  /// is readable from a metre away with the phone on a stand.
  void _flash(String text) {
    _flashTimer?.cancel();
    setState(() => _flashText = text);
    _flashTimer = Timer(_flashDuration, () {
      if (!mounted) return;
      setState(() => _flashText = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final stageState = ref.watch(stageModeProvider);
    final isLocked = stageState.isLocked;

    return Listener(
      onPointerDown: isLocked ? null : _onPointerDown,
      onPointerMove: isLocked ? null : _onPointerMove,
      onPointerUp: isLocked ? null : _onPointerUp,
      onPointerCancel: isLocked ? null : _onPointerCancel,
      child: Stack(
        children: [
          Positioned.fill(child: widget.child),
          if (_flashText != null && !isLocked)
            Positioned.fill(
              child: IgnorePointer(child: _ValueFlash(text: _flashText!)),
            ),
          if (isLocked)
            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: Material(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(20),
                  elevation: 4,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => unlockStageWithFeedback(context, ref),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context).labelStageLocked,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The large, short-lived read-out of whatever a gesture just changed.
class _ValueFlash extends StatelessWidget {
  const _ValueFlash({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.bold,
            color: scheme.primary,
          ),
        ),
      ),
    );
  }
}
