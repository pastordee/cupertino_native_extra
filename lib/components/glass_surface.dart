// Created: 2026-09-09
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../channel/params.dart';

/// One glass shape on a [CNGlassSurface].
///
/// Positions are in logical pixels, relative to the surface's own top-left.
class CNGlassElement {
  /// Creates a shape at [rect], optionally rounded by [cornerRadius].
  const CNGlassElement({
    required this.rect,
    this.cornerRadius = 0,
  });

  /// Where the shape sits within the surface.
  final Rect rect;

  /// Corner radius, drawn with iOS's continuous curve. For a capsule, pass
  /// half the height.
  final double cornerRadius;

  Map<String, dynamic> _encode() => {
    'x': rect.left,
    'y': rect.top,
    'width': rect.width,
    'height': rect.height,
    'cornerRadius': cornerRadius,
  };

  @override
  bool operator ==(Object other) =>
      other is CNGlassElement &&
      other.rect == rect &&
      other.cornerRadius == cornerRadius;

  @override
  int get hashCode => Object.hash(rect, cornerRadius);
}

/// How thick the glass reads.
enum CNGlassStyle {
  /// The standard material — frosted, and it carries a tint.
  regular,

  /// Thinner and closer to clear, for glass over busy content.
  clear,
}

/// A backdrop of Liquid Glass shapes that **flow together as they approach**.
///
/// This is the one thing a `BackdropFilter` cannot do, and the reason this
/// widget exists. Two shapes drawn close together stay two shapes, however
/// carefully their materials are matched. UIKit's `UIGlassContainerEffect`
/// instead merges glass elements once they come within [spacing] of each
/// other, and pulls them apart again as they separate — which is how a tab bar
/// can vanish into the sheet it is sitting on and re-form when the sheet
/// opens.
///
/// Merging only happens between elements described to the *same* surface.
/// Shapes on two different [CNGlassSurface]s will never merge, no matter how
/// close they are drawn, so anything that has to flow together belongs in one
/// [elements] list.
///
/// The surface draws no content and takes no touches. It is a backdrop: give
/// it the size of the area the shapes live in, put it at the bottom of a
/// [Stack], and lay Flutter widgets over the top as normal.
///
/// ```dart
/// Stack(
///   children: [
///     Positioned.fill(
///       child: CNGlassSurface(
///         spacing: 12,
///         elements: [
///           CNGlassElement(rect: trayRect, cornerRadius: 50),
///           CNGlassElement(rect: barRect, cornerRadius: barRect.height / 2),
///         ],
///       ),
///     ),
///     ...content,
///   ],
/// )
/// ```
///
/// Requires iOS 26 for the glass and for any merging at all. Below that each
/// element falls back to a plain blur and the shapes stay separate; on every
/// other platform the widget builds nothing, so a caller needs its own
/// backdrop there.
class CNGlassSurface extends StatefulWidget {
  /// Creates a glass backdrop drawing [elements].
  const CNGlassSurface({
    super.key,
    required this.elements,
    this.spacing = 0,
    this.style = CNGlassStyle.regular,
    this.tint,
  });

  /// The shapes to draw, in paint order.
  final List<CNGlassElement> elements;

  /// How close two elements get before they begin to merge, in logical pixels.
  ///
  /// Zero means they merge only once they actually touch. Raising it makes
  /// them reach for each other sooner, so a bar can start dissolving into a
  /// tray before the two are flush.
  final double spacing;

  /// How thick the material reads.
  final CNGlassStyle style;

  /// An optional colour mixed into the glass. Null leaves the system tint.
  final Color? tint;

  @override
  State<CNGlassSurface> createState() => _CNGlassSurfaceState();
}

class _CNGlassSurfaceState extends State<CNGlassSurface> {
  MethodChannel? _channel;
  List<CNGlassElement>? _lastSent;
  double? _lastSpacing;
  bool? _lastDark;

  bool get _isDark =>
      MediaQuery.maybeOf(context)?.platformBrightness == Brightness.dark ||
      Theme.of(context).brightness == Brightness.dark;

  void _onCreated(int id) {
    _channel = MethodChannel('cupertino_native_glass_surface_$id');
    _lastSent = widget.elements;
    _lastSpacing = widget.spacing;
    _lastDark = _isDark;
  }

  @override
  void didUpdateWidget(covariant CNGlassSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.style != widget.style || oldWidget.tint != widget.tint) {
      _pushStyle();
    }
    _pushElementsIfChanged();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_lastDark != null && _lastDark != _isDark) _pushStyle();
  }

  void _pushStyle() {
    final ch = _channel;
    if (ch == null) return;
    _lastDark = _isDark;
    ch.invokeMethod('setStyle', {
      'style': widget.style.name,
      'isDark': _isDark,
      if (widget.tint != null) 'tint': resolveColorToArgb(widget.tint, context),
    });
  }

  void _pushElementsIfChanged() {
    final ch = _channel;
    if (ch == null) return;
    // Frames arrive for every step of an animation. Sending an unchanged list
    // would cross the channel sixty times a second to move nothing.
    if (_lastSpacing == widget.spacing &&
        _lastSent != null &&
        listEquals(_lastSent, widget.elements)) {
      return;
    }
    _lastSent = widget.elements;
    _lastSpacing = widget.spacing;
    ch.invokeMethod('setElements', {
      'spacing': widget.spacing,
      'elements': widget.elements.map((e) => e._encode()).toList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return const SizedBox.shrink();
    }
    return IgnorePointer(
      child: UiKitView(
        viewType: 'CupertinoNativeGlassSurface',
        creationParams: {
          'spacing': widget.spacing,
          'style': widget.style.name,
          'isDark': _isDark,
          if (widget.tint != null)
            'tint': resolveColorToArgb(widget.tint, context),
          'elements': widget.elements.map((e) => e._encode()).toList(),
        },
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onCreated,
      ),
    );
  }
}
