import 'dart:math' as math;

import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/core/constants/app_constants.dart';
import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/providers/split_view_provider.dart';

/// The tablet two-pane layout: [list] on the left, [detail] on the right, and
/// a divider handle between them.
///
/// Drag the handle to resize the list (kept between
/// [AppConstants.splitMinListWidth] and [AppConstants.splitMaxListFraction] of
/// the width). Dragging it narrower than [AppConstants.splitCollapseWidth]
/// hides the list; double-tap or the chevron button hides or shows it. The
/// layout is kept in [splitViewProvider], so it survives a restart.
class ResizableSplitView extends ConsumerStatefulWidget {
  const ResizableSplitView({
    super.key,
    required this.list,
    required this.detail,
  });

  final Widget list;
  final Widget detail;

  /// Total width of the divider handle (its touch area).
  static const double handleWidth = 24;

  @override
  ConsumerState<ResizableSplitView> createState() => _ResizableSplitViewState();
}

class _ResizableSplitViewState extends ConsumerState<ResizableSplitView> {
  /// The list width while a drag is under way; null when not dragging.
  double? _dragWidth;

  void _toggleCollapsed(bool collapsed) {
    ref.read(splitViewProvider.notifier).setListCollapsed(!collapsed);
  }

  @override
  Widget build(BuildContext context) {
    final layout = ref.watch(splitViewProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final total = constraints.maxWidth;
        final maxList = math.max(
          0.0,
          math.min(
            total * AppConstants.splitMaxListFraction,
            total - ResizableSplitView.handleWidth,
          ),
        );
        final minList = math.min(AppConstants.splitMinListWidth, maxList);
        final openWidth = (layout.listFraction * total).clamp(minList, maxList);
        final listWidth =
            _dragWidth ?? (layout.listCollapsed ? 0.0 : openWidth);
        final hidden = _dragWidth == null && layout.listCollapsed;

        return Row(
          // Full height, so the handle's line and drag area run top to bottom.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedContainer(
              duration: _dragWidth == null
                  ? const Duration(milliseconds: 200)
                  : Duration.zero,
              curve: Curves.easeOut,
              width: listWidth,
              child: ClipRect(
                // The list never lays out narrower than its minimum: while it
                // closes it slides out of view instead of squashing, and it
                // stays in the tree so its scroll and search survive.
                child: OverflowBox(
                  alignment: AlignmentDirectional.centerEnd,
                  minWidth: math.max(listWidth, minList),
                  maxWidth: math.max(listWidth, minList),
                  child: ExcludeFocus(
                    excluding: hidden,
                    child: ExcludeSemantics(
                      excluding: hidden,
                      child: widget.list,
                    ),
                  ),
                ),
              ),
            ),
            _Handle(
              collapsed: layout.listCollapsed,
              onToggle: () => _toggleCollapsed(layout.listCollapsed),
              onDragStart: () => setState(() => _dragWidth = listWidth),
              onDragUpdate: (dx) => setState(() {
                _dragWidth = ((_dragWidth ?? listWidth) + dx).clamp(
                  0.0,
                  maxList,
                );
              }),
              onDragEnd: () {
                final width = _dragWidth ?? listWidth;
                setState(() => _dragWidth = null);
                final notifier = ref.read(splitViewProvider.notifier);
                if (width < AppConstants.splitCollapseWidth || total <= 0) {
                  notifier.setListCollapsed(true);
                } else {
                  notifier.setListFraction(
                    width.clamp(minList, maxList) / total,
                  );
                }
              },
            ),
            Expanded(child: widget.detail),
          ],
        );
      },
    );
  }
}

/// The divider between the panes: a thin line with a grip, a drag area, and
/// a chevron button that hides or shows the list.
class _Handle extends StatelessWidget {
  const _Handle({
    required this.collapsed,
    required this.onToggle,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final bool collapsed;
  final VoidCallback onToggle;
  final VoidCallback onDragStart;
  final ValueChanged<double> onDragUpdate;
  final VoidCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: ResizableSplitView.handleWidth,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Semantics(
              label: l10n.descResizeListHandle,
              onTap: onToggle,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: GestureDetector(
                  key: const ValueKey('splitViewHandle'),
                  behavior: HitTestBehavior.opaque,
                  // Count the drag from touch-down, so the divider stays
                  // under the finger instead of lagging by the touch slop.
                  dragStartBehavior: DragStartBehavior.down,
                  onDoubleTap: onToggle,
                  onHorizontalDragStart: (_) => onDragStart(),
                  onHorizontalDragUpdate: (details) =>
                      onDragUpdate(details.delta.dx),
                  onHorizontalDragEnd: (_) => onDragEnd(),
                  onHorizontalDragCancel: onDragEnd,
                  child: Center(
                    child: Container(width: 1, color: colors.outlineVariant),
                  ),
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IgnorePointer(
                child: Container(
                  width: 4,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              IconButton(
                tooltip: collapsed
                    ? l10n.tooltipShowList
                    : l10n.tooltipHideList,
                onPressed: onToggle,
                padding: EdgeInsets.zero,
                iconSize: 20,
                constraints: const BoxConstraints.tightFor(
                  width: ResizableSplitView.handleWidth,
                  height: 48,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: colors.surfaceContainerHighest,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: Icon(
                  collapsed ? Icons.chevron_right : Icons.chevron_left,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
