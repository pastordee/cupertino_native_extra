import 'dart:async';
import 'dart:ui' as ui;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

import '../channel/params.dart';
import '../style/sf_symbol.dart';
import '../style/button_style.dart';

/// A Cupertino-native push button.
///
/// Embeds a native UIButton/NSButton for authentic visuals and behavior on
/// iOS and macOS. Falls back to [CupertinoButton] on other platforms.
class CNButton extends StatefulWidget {
  /// Creates a text button variant of [CNButton].
  const CNButton({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.tint,
    this.height = 32.0,
    this.shrinkWrap = false,
    this.style = CNButtonStyle.plain,
  }) : icon = null,
       image = null,
       imageSize = null,
       width = null,
       round = false;

  /// Creates a round, icon-only variant of [CNButton].
  const CNButton.icon({
    super.key,
    required this.icon,
    this.onPressed,
    this.enabled = true,
    this.tint,
    double size = 44.0,
    this.style = CNButtonStyle.glass,
  }) : label = null,
       image = null,
       imageSize = null,
       round = true,
       width = size,
       height = size,
       shrinkWrap = false,
       super();

  /// A round button showing a custom image rather than an SF Symbol — an app's
  /// own icon artwork on the same native glass.
  ///
  /// The image is drawn as a template: its shape is kept and its colour comes
  /// from the button, so [tint] and [style] colour it exactly as they would a
  /// symbol ([CNButtonStyle.prominentGlass] fills the glass with [tint] and
  /// draws the image in a readable colour on top).
  const CNButton.image({
    super.key,
    required ImageProvider this.image,
    this.imageSize = 22.0,
    this.onPressed,
    this.enabled = true,
    this.tint,
    double size = 44.0,
    this.style = CNButtonStyle.glass,
  }) : label = null,
       icon = null,
       round = true,
       width = size,
       height = size,
       shrinkWrap = false,
       super();

  /// Button text (null in icon mode).
  final String? label; // null in icon mode
  /// Button icon (non-null in icon mode).
  final CNSymbol? icon; // non-null in icon mode

  /// Custom image (non-null in image mode). See [CNButton.image].
  final ImageProvider? image;

  /// Point size the image is drawn at, in image mode.
  final double? imageSize;
  /// Callback when pressed.
  final VoidCallback? onPressed;

  /// Whether the control is interactive and tappable.
  final bool enabled;

  /// Accent/tint color.
  final Color? tint;

  /// Control height.
  final double height;

  /// Fixed width used in icon/round mode.
  final double? width; // fixed when round/icon mode
  /// If true, sizes the control to its intrinsic width.
  final bool shrinkWrap;

  /// Visual style to apply.
  final CNButtonStyle style;

  /// Whether the icon variant (round) is used.
  final bool round;

  /// Whether this instance is configured as the icon variant.
  bool get isIcon => icon != null || image != null;

  @override
  State<CNButton> createState() => _CNButtonState();
}

class _CNButtonState extends State<CNButton> {
  MethodChannel? _channel;
  bool? _lastIsDark;
  int? _lastTint;
  String? _lastTitle;
  String? _lastIconName;
  double? _lastIconSize;
  int? _lastIconColor;
  double? _intrinsicWidth;
  CNButtonStyle? _lastStyle;
  Offset? _downPosition;
  bool _pressed = false;

  /// The custom image's bytes once decoded, and what they were decoded from —
  /// so a rebuild with the same image sends nothing.
  Uint8List? _imageBytes;
  ImageProvider? _imageSource;
  double? _sentImageSize;
  Uint8List? _sentImageBytes;

  // brightnessOf resolves a null Cupertino brightness to the platform
  // brightness, so this tracks a live system light<->dark switch (and
  // registers the dependency that triggers didChangeDependencies).
  bool get _isDark => CupertinoTheme.brightnessOf(context) == Brightness.dark;

  Color? get _effectiveTint =>
      widget.tint ?? CupertinoTheme.of(context).primaryColor;

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadImageIfNeeded();
  }

  @override
  void didUpdateWidget(covariant CNButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadImageIfNeeded();
    _syncPropsToNativeIfNeeded();
  }

  /// Decodes [CNButton.image] to PNG bytes for the native side, which cannot
  /// read a Flutter asset itself.
  Future<void> _loadImageIfNeeded() async {
    final source = widget.image;
    if (source == null || source == _imageSource) return;
    _imageSource = source;
    final bytes = await _loadImageAsBytes(source);
    if (!mounted || source != _imageSource || bytes == null) return;
    setState(() => _imageBytes = bytes);
    _sendImageIfNeeded();
  }

  Future<void> _sendImageIfNeeded() async {
    final ch = _channel;
    final bytes = _imageBytes;
    if (ch == null || bytes == null) return;
    final size = widget.imageSize ?? 22.0;
    if (identical(bytes, _sentImageBytes) && size == _sentImageSize) return;
    _sentImageBytes = bytes;
    _sentImageSize = size;
    try {
      await ch.invokeMethod('setButtonImage', {
        'imageData': bytes,
        'imageSize': size,
      });
    } catch (_) {}
  }

  Future<Uint8List?> _loadImageAsBytes(ImageProvider provider) {
    final completer = Completer<Uint8List?>();
    final stream = provider.resolve(const ImageConfiguration());
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) async {
        stream.removeListener(listener);
        try {
          final data = await info.image.toByteData(
            format: ui.ImageByteFormat.png,
          );
          completer.complete(data?.buffer.asUint8List());
        } catch (_) {
          completer.complete(null);
        }
      },
      onError: (_, _) {
        stream.removeListener(listener);
        if (!completer.isCompleted) completer.complete(null);
      },
    );
    stream.addListener(listener);
    return completer.future;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBrightnessIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    if (!(defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS)) {
      // Fallback Flutter implementation
      return SizedBox(
        height: widget.height,
        width: widget.isIcon && widget.round
            ? (widget.width ?? widget.height)
            : null,
        child: CupertinoButton(
          padding: widget.isIcon
              ? const EdgeInsets.all(4)
              : const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          onPressed: (widget.enabled && widget.onPressed != null)
              ? widget.onPressed
              : null,
          child: widget.image != null
              ? Image(
                  image: widget.image!,
                  width: widget.imageSize,
                  height: widget.imageSize,
                  color: _effectiveTint,
                )
              : widget.isIcon
              ? Icon(CupertinoIcons.ellipsis, size: widget.icon?.size)
              : Text(widget.label ?? ''),
        ),
      );
    }

    const viewType = 'CupertinoNativeButton';

    final creationParams = <String, dynamic>{
      if (widget.label != null) 'buttonTitle': widget.label,
      if (widget.icon != null) 'buttonIconName': widget.icon!.name,
      if (widget.icon?.size != null) 'buttonIconSize': widget.icon!.size,
      if (widget.icon?.color != null)
        'buttonIconColor': resolveColorToArgb(widget.icon!.color, context),
      if (widget.icon?.mode != null)
        'buttonIconRenderingMode': widget.icon!.mode!.name,
      if (widget.icon?.paletteColors != null)
        'buttonIconPaletteColors': widget.icon!.paletteColors!
            .map((c) => resolveColorToArgb(c, context))
            .toList(),
      if (widget.icon?.gradient != null)
        'buttonIconGradientEnabled': widget.icon!.gradient,
      if (widget.isIcon) 'round': true,
      'buttonStyle': widget.style.name,
      'enabled': (widget.enabled && widget.onPressed != null),
      'isDark': _isDark,
      'style': encodeStyle(context, tint: _effectiveTint),
    };

    final platformView = defaultTargetPlatform == TargetPlatform.iOS
        ? UiKitView(
            viewType: viewType,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onCreated,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              // Forward taps to native; let Flutter keep drags for scrolling.
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
        final hasBoundedWidth = constraints.hasBoundedWidth;
        final preferIntrinsic = widget.shrinkWrap || !hasBoundedWidth;
        double? width;
        if (widget.isIcon) {
          width = widget.width ?? widget.height;
        } else if (preferIntrinsic) {
          width = _intrinsicWidth ?? 80.0;
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
    final ch = MethodChannel('CupertinoNativeButton_$id');
    _channel = ch;
    ch.setMethodCallHandler(_onMethodCall);
    _lastTint = resolveColorToArgb(_effectiveTint, context);
    _lastIsDark = _isDark;
    _lastTitle = widget.label;
    _lastIconName = widget.icon?.name;
    _lastIconSize = widget.icon?.size;
    _lastIconColor = resolveColorToArgb(widget.icon?.color, context);
    _lastStyle = widget.style;
    if (!widget.isIcon) {
      _requestIntrinsicSize();
    }
    _sentImageBytes = null;
    _sendImageIfNeeded();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'pressed':
        if (widget.enabled && widget.onPressed != null) {
          widget.onPressed!();
        }
        break;
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
    final preIconName = widget.icon?.name;
    final preIconSize = widget.icon?.size;
    final preIconColor = resolveColorToArgb(widget.icon?.color, context);

    if (_lastTint != tint && tint != null) {
      await ch.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }
    if (_lastStyle != widget.style) {
      await ch.invokeMethod('setStyle', {'buttonStyle': widget.style.name});
      _lastStyle = widget.style;
    }
    // Enabled state
    await ch.invokeMethod('setEnabled', {
      'enabled': (widget.enabled && widget.onPressed != null),
    });
    if (_lastTitle != widget.label && widget.label != null) {
      await ch.invokeMethod('setButtonTitle', {'title': widget.label});
      _lastTitle = widget.label;
      _requestIntrinsicSize();
    }

    if (widget.image != null) {
      _sendImageIfNeeded();
    } else if (widget.isIcon) {
      final iconName = preIconName;
      final iconSize = preIconSize;
      final iconColor = preIconColor;
      final updates = <String, dynamic>{};
      if (_lastIconName != iconName && iconName != null) {
        updates['buttonIconName'] = iconName;
        _lastIconName = iconName;
      }
      if (_lastIconSize != iconSize && iconSize != null) {
        updates['buttonIconSize'] = iconSize;
        _lastIconSize = iconSize;
      }
      if (_lastIconColor != iconColor && iconColor != null) {
        updates['buttonIconColor'] = iconColor;
        _lastIconColor = iconColor;
      }
      if (widget.icon?.mode != null) {
        updates['buttonIconRenderingMode'] = widget.icon!.mode!.name;
      }
      if (widget.icon?.paletteColors != null) {
        updates['buttonIconPaletteColors'] = widget.icon!.paletteColors!
            .map((c) => resolveColorToArgb(c, context))
            .toList();
      }
      if (widget.icon?.gradient != null) {
        updates['buttonIconGradientEnabled'] = widget.icon!.gradient;
      }
      if (updates.isNotEmpty) {
        // The native side rebuilds the image from whatever it is sent, so a
        // colour-only update without the name drew no icon at all.
        if (iconName != null) updates['buttonIconName'] = iconName;
        if (iconSize != null) updates['buttonIconSize'] = iconSize;
        if (iconColor != null) updates['buttonIconColor'] = iconColor;
        await ch.invokeMethod('setButtonIcon', updates);
      }
    }
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;
    // Capture context-derived values before any awaits
    final isDark = _isDark;
    final tint = resolveColorToArgb(_effectiveTint, context);
    if (_lastIsDark != isDark) {
      await ch.invokeMethod('setBrightness', {'isDark': isDark});
      _lastIsDark = isDark;
    }
    // Also propagate theme-driven tint changes (e.g., accent color changes)
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
}
