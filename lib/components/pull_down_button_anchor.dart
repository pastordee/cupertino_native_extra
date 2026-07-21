import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

import '../channel/params.dart';
import '../style/sf_symbol.dart';
import '../style/button_style.dart';
import 'pull_down_button.dart'; // Import menu entry classes

/// A Cupertino-native pull-down button with automatic menu anchoring.
///
/// This creates a popup menu that appears anchored to the button, similar to 
/// UIMenu with automatic presentation. The menu appears near the button with
/// an arrow pointing to it.
///
/// On iOS/macOS this uses native UIButton with UIMenu for authentic behavior.
/// The menu presentation style is set to automatic, allowing the system to
/// choose the best presentation (typically a popover-style menu).
class CNPullDownButtonAnchor extends StatefulWidget {
  /// Creates a text-labeled pull-down button with automatic anchoring.
  const CNPullDownButtonAnchor({
    super.key,
    required this.buttonLabel,
    required this.items,
    required this.onSelected,
    this.tint,
    this.height = 44.0,
    this.width,
    this.buttonStyle = CNButtonStyle.plain,
    this.menuTitle,
    this.alignment = Alignment.center,
  }) : buttonIcon = null,
       round = false;

  /// Creates a round, icon-only pull-down button with automatic anchoring.
  const CNPullDownButtonAnchor.icon({
    super.key,
    required this.buttonIcon,
    required this.items,
    required this.onSelected,
    this.tint,
    double size = 44.0,
    this.buttonStyle = CNButtonStyle.glass,
    this.menuTitle,
    this.alignment = Alignment.center,
  }) : buttonLabel = null,
       round = true,
       width = size,
       height = size;

  /// Text for the button (null when using [buttonIcon]).
  final String? buttonLabel;

  /// Icon for the button (non-null in icon mode).
  final CNSymbol? buttonIcon;

  /// Fixed width; if null, uses intrinsic width.
  final double? width;

  /// Whether this is the round icon variant.
  final bool round;

  /// Control height; icon mode uses diameter semantics.
  final double height;

  /// Entries that populate the pull-down menu.
  final List<CNPullDownMenuEntry> items;

  /// Called with the selected index when the user makes a selection.
  final ValueChanged<int> onSelected;

  /// Tint color for the control.
  final Color? tint;

  /// Visual style to apply to the button.
  final CNButtonStyle buttonStyle;

  /// Optional title for the menu.
  final String? menuTitle;

  /// Alignment of the button content.
  final Alignment alignment;

  /// Whether this instance is configured as an icon button variant.
  bool get isIconButton => buttonIcon != null;

  @override
  State<CNPullDownButtonAnchor> createState() => _CNPullDownButtonAnchorState();
}

class _CNPullDownButtonAnchorState extends State<CNPullDownButtonAnchor> {
  MethodChannel? _channel;
  bool? _lastIsDark;
  int? _lastTint;
  double? _intrinsicWidth;
  CNButtonStyle? _lastStyle;
  Offset? _downPosition;
  bool _pressed = false;

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;
  Color? get _effectiveTint =>
      widget.tint ?? CupertinoTheme.of(context).primaryColor;

  @override
  void didUpdateWidget(covariant CNPullDownButtonAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBrightnessIfNeeded();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!(defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS)) {
      // Fallback Flutter implementation
      return SizedBox(
        height: widget.height,
        width: widget.isIconButton && widget.round
            ? (widget.width ?? widget.height)
            : widget.width,
        child: CupertinoButton(
          padding: widget.isIconButton
              ? const EdgeInsets.all(4)
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          onPressed: () => _showPullDownMenu(),
          child: widget.isIconButton
              ? Icon(
                  CupertinoIcons.ellipsis_circle,
                  size: widget.buttonIcon?.size ?? 22,
                )
              : Text(widget.buttonLabel ?? ''),
        ),
      );
    }

    const viewType = 'CupertinoNativePullDownButtonAnchor';

    // Flatten entries into parallel arrays for the platform view.
    final labels = <String>[];
    final symbols = <String>[];
    final isDivider = <bool>[];
    final enabled = <bool>[];
    final isDestructive = <bool>[];
    final sizes = <double?>[];
    final colors = <int?>[];
    final modes = <String?>[];
    final palettes = <List<int?>?>[];
    final gradients = <bool?>[];

    for (final e in widget.items) {
      if (e is CNPullDownMenuDivider) {
        labels.add('');
        symbols.add('');
        isDivider.add(true);
        enabled.add(false);
        isDestructive.add(false);
        sizes.add(null);
        colors.add(null);
        modes.add(null);
        palettes.add(null);
        gradients.add(null);
      } else if (e is CNPullDownMenuItem) {
        labels.add(e.label);
        symbols.add(e.icon?.name ?? '');
        isDivider.add(false);
        enabled.add(e.enabled);
        isDestructive.add(e.isDestructive);
        sizes.add(e.icon?.size);
        colors.add(resolveColorToArgb(e.icon?.color, context));
        modes.add(e.icon?.mode?.name);
        palettes.add(
          e.icon?.paletteColors
              ?.map((c) => resolveColorToArgb(c, context))
              .toList(),
        );
        gradients.add(e.icon?.gradient);
      }
    }

    final creationParams = <String, dynamic>{
      if (widget.buttonLabel != null) 'buttonTitle': widget.buttonLabel,
      if (widget.buttonIcon != null) 'buttonIconName': widget.buttonIcon!.name,
      if (widget.buttonIcon?.size != null)
        'buttonIconSize': widget.buttonIcon!.size,
      if (widget.buttonIcon?.color != null)
        'buttonIconColor': resolveColorToArgb(
          widget.buttonIcon!.color,
          context,
        ),
      if (widget.isIconButton) 'round': true,
      'buttonStyle': widget.buttonStyle.name,
      'labels': labels,
      'sfSymbols': symbols,
      'isDivider': isDivider,
      'enabled': enabled,
      'isDestructive': isDestructive,
      'sfSymbolSizes': sizes,
      'sfSymbolColors': colors,
      'sfSymbolRenderingModes': modes,
      'sfSymbolPaletteColors': palettes,
      'sfSymbolGradientEnabled': gradients,
      'isDark': _isDark,
      'style': encodeStyle(context, tint: _effectiveTint),
      if (widget.menuTitle != null) 'menuTitle': widget.menuTitle,
      if (widget.buttonIcon?.mode != null)
        'buttonIconRenderingMode': widget.buttonIcon!.mode!.name,
      if (widget.buttonIcon?.paletteColors != null)
        'buttonIconPaletteColors': widget.buttonIcon!.paletteColors!
            .map((c) => resolveColorToArgb(c, context))
            .toList(),
      if (widget.buttonIcon?.gradient != null)
        'buttonIconGradientEnabled': widget.buttonIcon!.gradient,
      'anchoredMenu': true, // Key parameter for automatic presentation
    };

    final platformView = defaultTargetPlatform == TargetPlatform.iOS
        ? UiKitView(
            viewType: viewType,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onCreated,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
            },
          )
        : AppKitView(
            viewType: viewType,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onCreated,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
            },
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        double? width = widget.width;
        if (widget.isIconButton && width == null) {
          width = widget.height;
        } else if (!widget.isIconButton && width == null) {
          width = _intrinsicWidth ?? 120.0;
        }

        return Listener(
          onPointerDown: (e) {
            _downPosition = e.position;
            _setPressed(true);
          },
          onPointerMove: (e) {
            final start = _downPosition;
            if (start != null && _pressed) {
              final moved = (e.position - start).distance;
              if (moved > kTouchSlop) {
                _setPressed(false);
              }
            }
          },
          onPointerUp: (_) {
            _setPressed(false);
            _downPosition = null;
          },
          onPointerCancel: (_) {
            _setPressed(false);
            _downPosition = null;
          },
          child: SizedBox(
            height: widget.height,
            width: width,
            child: platformView,
          ),
        );
      },
    );
  }

  void _onCreated(int id) {
    final ch = MethodChannel('CupertinoNativePullDownButtonAnchor_$id');
    _channel = ch;
    ch.setMethodCallHandler(_onMethodCall);
    _lastTint = resolveColorToArgb(_effectiveTint, context);
    _lastIsDark = _isDark;
    _lastStyle = widget.buttonStyle;
    if (!widget.isIconButton) {
      _requestIntrinsicSize();
    }
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'itemSelected') {
      final args = call.arguments as Map?;
      final idx = (args?['index'] as num?)?.toInt();
      if (idx != null) widget.onSelected(idx);
    }
    return null;
  }

  Future<void> _requestIntrinsicSize() async {
    final ch = _channel;
    if (ch == null) return;
    try {
      final size = await ch.invokeMethod<Map>('getIntrinsicSize');
      final w = (size?['width'] as num?)?.toDouble();
      if (w != null && mounted) {
        setState(() => _intrinsicWidth = w);
      }
    } catch (_) {}
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;

    final tint = resolveColorToArgb(_effectiveTint, context);

    if (_lastTint != tint && tint != null) {
      await ch.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }

    if (_lastStyle != widget.buttonStyle) {
      await ch.invokeMethod('setStyle', {
        'buttonStyle': widget.buttonStyle.name,
      });
      _lastStyle = widget.buttonStyle;
    }
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;
    final isDark = _isDark;
    final tint = resolveColorToArgb(_effectiveTint, context);
    if (_lastIsDark != isDark) {
      await ch.invokeMethod('setBrightness', {'isDark': isDark});
      _lastIsDark = isDark;
    }
    if (_lastTint != tint && tint != null) {
      await ch.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }
  }

  Future<void> _setPressed(bool pressed) async {
    final ch = _channel;
    if (ch == null) return;
    if (_pressed == pressed) return;
    _pressed = pressed;
    try {
      await ch.invokeMethod('setPressed', {'pressed': pressed});
    } catch (_) {}
  }

  Future<void> _showPullDownMenu() async {
    // Fallback implementation using CupertinoModalPopup
    final selected = await showCupertinoModalPopup<int>(
      context: context,
      builder: (ctx) {
        return CupertinoActionSheet(
          title: widget.menuTitle != null ? Text(widget.menuTitle!) : null,
          actions: [
            for (var i = 0; i < widget.items.length; i++)
              if (widget.items[i] is CNPullDownMenuItem) ...[
                () {
                  final item = widget.items[i] as CNPullDownMenuItem;
                  return CupertinoActionSheetAction(
                    onPressed: () => Navigator.of(ctx).pop(i),
                    isDestructiveAction: item.isDestructive,
                    child: Text(item.label),
                  );
                }(),
              ] else if (widget.items[i] is CNPullDownMenuDivider)
                const SizedBox(height: 8),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(ctx).pop(),
            isDefaultAction: true,
            child: const Text('Cancel'),
          ),
        );
      },
    );
    if (selected != null) widget.onSelected(selected);
  }
}
