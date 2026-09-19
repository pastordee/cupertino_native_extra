// Created: 2026-09-19
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Which edge iOS puts tab bars and toolbars on, from iOS 27.1's
/// `UITraitCollection.verticalBarEdge` — the trailing edge on iPhone Duo's
/// outer display, and on its inner one in landscape; none everywhere else.
///
/// Leading and trailing are logical: in a right-to-left language the system
/// keeps the bars aligned with the hardware, so resolve against the layout
/// direction if a physical side is needed.
enum CNVerticalBarEdge { none, leading, trailing }

/// Asks the system which edge its vertical bars are on.
///
/// Changes when the device folds, unfolds or rotates; ask again on a metrics
/// change (`WidgetsBindingObserver.didChangeMetrics`). Anywhere but iOS, and on
/// iOS before 27.1, the answer is [CNVerticalBarEdge.none].
Future<CNVerticalBarEdge> cnVerticalBarEdge() async {
  if (defaultTargetPlatform != TargetPlatform.iOS) {
    return CNVerticalBarEdge.none;
  }
  try {
    final String? raw = await const MethodChannel(
      'cupertino_native',
    ).invokeMethod<String>('getVerticalBarEdge');
    return switch (raw) {
      'leading' => CNVerticalBarEdge.leading,
      'trailing' => CNVerticalBarEdge.trailing,
      _ => CNVerticalBarEdge.none,
    };
  } catch (_) {
    return CNVerticalBarEdge.none;
  }
}

/// One entry in a native menu opened from a [CNVerticalBarItem].
class CNVerticalBarMenuItem {
  const CNVerticalBarMenuItem({
    required this.title,
    this.symbol,
    this.destructive = false,
  }) : divider = false;

  const CNVerticalBarMenuItem.divider()
      : title = '',
        symbol = null,
        destructive = false,
        divider = true;

  final String title;

  /// SF Symbol name.
  final String? symbol;
  final bool destructive;
  final bool divider;

  Map<String, Object?> _encode() => {
        'title': title,
        'symbol': symbol,
        'destructive': destructive,
        'divider': divider,
      };
}

/// One button in a [CNVerticalBar]: an SF Symbol or an image, never text —
/// Apple keeps labelled controls horizontal, and [label] is what VoiceOver and
/// menus read.
class CNVerticalBarItem {
  const CNVerticalBarItem({
    this.symbol,
    this.image,
    this.imageSize = 22,
    required this.label,
    this.badge,
    this.onPressed,
    this.menu,
    this.onMenuSelected,
  }) : assert(symbol != null || image != null, 'A symbol or an image');

  /// SF Symbol name.
  final String? symbol;

  /// An app's own artwork, drawn as a template so the bar colours it.
  final ImageProvider? image;
  final double imageSize;
  final String label;

  /// A count, or a blank string for a plain dot.
  final String? badge;
  final VoidCallback? onPressed;

  /// When set, the button opens this native menu instead of calling
  /// [onPressed].
  final List<CNVerticalBarMenuItem>? menu;
  final ValueChanged<int>? onMenuSelected;
}

/// Items that share one capsule of glass — related actions, as Mail keeps
/// reply, forward and trash together.
class CNVerticalBarGroup {
  const CNVerticalBarGroup(this.items, {this.prominent = false});

  final List<CNVerticalBarItem> items;

  /// Filled with the tint: the screen's primary action (Compose, Done).
  final bool prominent;
}

/// A tab bar or toolbar laid out down the side of the screen, in native
/// Liquid Glass — what iOS 27.1 does with its own bars on iPhone Duo.
///
/// UIKit only makes the bars it manages vertical; a bar inside a Flutter view
/// isn't one of those, so this builds the same thing natively: each
/// [CNVerticalBarGroup] a glass capsule, all in one glass container so nearby
/// capsules merge, each item a system button (presses, menus and the glass's
/// reaction to a finger are UIKit's own).
///
/// Set [selectedIndex] for tab mode: the selected item (counted across all
/// groups) sits on the system tab bar's lozenge with its symbol tinted. Leave
/// it null for a toolbar.
///
/// Sizes itself: [itemSize] per item, [groupSpacing] between groups.
/// Elsewhere than iOS it draws a Flutter equivalent.
class CNVerticalBar extends StatefulWidget {
  const CNVerticalBar({
    super.key,
    required this.groups,
    this.selectedIndex,
    this.tint,
    this.itemSize = 46,
    this.groupSpacing = 10,
    this.inset = 4,
  });

  final List<CNVerticalBarGroup> groups;
  final int? selectedIndex;
  final Color? tint;
  final double itemSize;
  final double groupSpacing;
  final double inset;

  /// The height the bar will take for [groups].
  double get height {
    if (groups.isEmpty) return 0;
    double h = 0;
    for (final g in groups) {
      h += itemSize * g.items.length + inset * 2;
    }
    return h + groupSpacing * (groups.length - 1);
  }

  double get width => itemSize + inset * 2;

  @override
  State<CNVerticalBar> createState() => _CNVerticalBarState();
}

class _CNVerticalBarState extends State<CNVerticalBar> {
  MethodChannel? _channel;
  final Map<ImageProvider, Uint8List> _images = <ImageProvider, Uint8List>{};
  Map<String, Object?>? _lastSent;

  List<CNVerticalBarItem> get _flat =>
      [for (final g in widget.groups) ...g.items];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  @override
  void didUpdateWidget(CNVerticalBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadImages();
    _send();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _send();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  Future<void> _loadImages() async {
    bool added = false;
    for (final item in _flat) {
      final p = item.image;
      if (p == null || _images.containsKey(p)) continue;
      final bytes = await _bytes(p);
      if (bytes != null && mounted) {
        _images[p] = bytes;
        added = true;
      }
    }
    if (added) _send();
  }

  Future<Uint8List?> _bytes(ImageProvider provider) {
    final completer = Completer<Uint8List?>();
    final stream = provider.resolve(const ImageConfiguration());
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) async {
        stream.removeListener(listener);
        final data = await info.image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        completer.complete(data?.buffer.asUint8List());
      },
      onError: (_, _) {
        stream.removeListener(listener);
        if (!completer.isCompleted) completer.complete(null);
      },
    );
    stream.addListener(listener);
    return completer.future;
  }

  Map<String, Object?> _params() {
    final Color tint = widget.tint ?? Theme.of(context).colorScheme.primary;
    return {
      'itemSize': widget.itemSize,
      'gap': widget.groupSpacing,
      'inset': widget.inset,
      'tint': tint.toARGB32(),
      'selected': widget.selectedIndex ?? -1,
      'tabMode': widget.selectedIndex != null,
      'isDark': Theme.of(context).brightness == Brightness.dark,
      'groups': [
        for (final g in widget.groups)
          {
            'prominent': g.prominent,
            'items': [
              for (final i in g.items)
                {
                  'symbol': i.symbol,
                  'label': i.label,
                  'badge': i.badge,
                  'imageSize': i.imageSize,
                  if (i.image != null && _images[i.image] != null)
                    'imageData': _images[i.image],
                  if (i.menu != null)
                    'menu': [for (final m in i.menu!) m._encode()],
                },
            ],
          },
      ],
    };
  }

  void _send() {
    final ch = _channel;
    if (ch == null) return;
    final params = _params();
    if (mapEquals(_lastSent, params)) return;
    _lastSent = params;
    ch.invokeMethod('update', params);
  }

  Future<dynamic> _onCall(MethodCall call) async {
    final args = (call.arguments as Map?) ?? const {};
    final int index = (args['index'] as int?) ?? -1;
    final items = _flat;
    if (index < 0 || index >= items.length) return null;
    if (call.method == 'pressed') {
      items[index].onPressed?.call();
    } else if (call.method == 'menuSelected') {
      items[index].onMenuSelected?.call((args['item'] as int?) ?? 0);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = Size(widget.width, widget.height);
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return SizedBox.fromSize(size: size, child: _fallback(context));
    }
    final params = _params();
    return SizedBox.fromSize(
      size: size,
      child: UiKitView(
        viewType: 'CupertinoNativeVerticalBar',
        creationParams: params,
        creationParamsCodec: const StandardMessageCodec(),
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
          Factory<LongPressGestureRecognizer>(
            () => LongPressGestureRecognizer(),
          ),
          // The drag across tabs belongs to the native bar.
          Factory<VerticalDragGestureRecognizer>(
            () => VerticalDragGestureRecognizer(),
          ),
        },
        onPlatformViewCreated: (id) {
          final ch = MethodChannel('CupertinoNativeVerticalBar_$id');
          ch.setMethodCallHandler(_onCall);
          _channel = ch;
          _lastSent = params;
          _loadImages();
        },
      ),
    );
  }

  /// A plain Flutter drawing of the same bar, for other platforms.
  Widget _fallback(BuildContext context) {
    final theme = Theme.of(context);
    final Color tint = widget.tint ?? theme.colorScheme.primary;
    int flat = 0;
    final children = <Widget>[];
    for (int g = 0; g < widget.groups.length; g++) {
      final group = widget.groups[g];
      if (g > 0) children.add(SizedBox(height: widget.groupSpacing));
      final items = <Widget>[];
      for (final item in group.items) {
        final int index = flat++;
        final bool on = widget.selectedIndex == index;
        final Color fg = group.prominent
            ? Colors.white
            : (widget.selectedIndex != null
                ? (on ? tint : theme.colorScheme.onSurface)
                : tint);
        items.add(
          Semantics(
            button: true,
            selected: on,
            label: item.label,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: item.onPressed,
              child: Container(
                width: widget.itemSize,
                height: widget.itemSize,
                decoration: on
                    ? BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.1,
                        ),
                        shape: BoxShape.circle,
                      )
                    : null,
                alignment: Alignment.center,
                child: item.image != null
                    ? Image(
                        image: item.image!,
                        width: item.imageSize,
                        height: item.imageSize,
                        color: fg,
                      )
                    : Icon(Icons.circle_outlined, color: fg, size: 18),
              ),
            ),
          ),
        );
      }
      children.add(
        Container(
          padding: EdgeInsets.all(widget.inset),
          decoration: BoxDecoration(
            color: group.prominent
                ? tint
                : theme.colorScheme.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(widget.width / 2),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: items),
        ),
      );
    }
    return Column(mainAxisSize: MainAxisSize.min, children: children);
  }
}
