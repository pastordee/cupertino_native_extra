// Created: 2026-10-19
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

import '../channel/params.dart';

/// The system AirPlay button (`AVRoutePickerView`).
///
/// Tapping it opens the system's own route picker, listing the Apple TVs,
/// AirPlay speakers and other outputs nearby. Playback from an `AVPlayer` in
/// the app follows whichever route is picked, so there is nothing to wire up
/// on the Dart side: put the button next to the video and the system does the
/// rest. The icon fills in with [activeTint] while a route other than the
/// device itself is in use.
///
/// Sized like a bar icon, [size] square (28 by default).
///
/// iOS and macOS 10.15+ only. On every other platform it builds
/// `SizedBox.shrink()`, so a caller can drop it into a shared row unguarded.
///
/// ```dart
/// CNAirPlayButton(tint: CupertinoColors.white)
/// ```
class CNAirPlayButton extends StatefulWidget {
  /// Creates an AirPlay route picker button.
  const CNAirPlayButton({
    super.key,
    this.tint,
    this.activeTint,
    this.size = 28,
    this.prioritizesVideoDevices = true,
  });

  /// The icon's colour while playing on this device. Null leaves the system
  /// tint.
  final Color? tint;

  /// The icon's colour while playing on another device. Null leaves the system
  /// colour.
  final Color? activeTint;

  /// Width and height of the button.
  final double size;

  /// List video-capable outputs (Apple TV, AirPlay TVs) first in the picker.
  /// iOS only; macOS always lists outputs in its own order.
  final bool prioritizesVideoDevices;

  @override
  State<CNAirPlayButton> createState() => _CNAirPlayButtonState();
}

class _CNAirPlayButtonState extends State<CNAirPlayButton> {
  MethodChannel? _channel;
  int? _lastTint;
  int? _lastActiveTint;
  bool? _lastPrioritizesVideo;

  @override
  void didUpdateWidget(covariant CNAirPlayButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A dynamic colour resolves differently after a light<->dark switch.
    _syncPropsToNativeIfNeeded();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  bool get _isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  @override
  Widget build(BuildContext context) {
    if (!_isSupported) return const SizedBox.shrink();

    const viewType = 'CupertinoNativeAirPlayButton';

    final tint = resolveColorToArgb(widget.tint, context);
    final activeTint = resolveColorToArgb(widget.activeTint, context);
    final creationParams = <String, dynamic>{
      'prioritizesVideoDevices': widget.prioritizesVideoDevices,
      if (tint != null) 'tint': tint,
      if (activeTint != null) 'activeTint': activeTint,
    };

    // Forward taps to native; let Flutter keep drags for scrolling.
    final gestureRecognizers = <Factory<OneSequenceGestureRecognizer>>{
      Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
    };

    final platformView = defaultTargetPlatform == TargetPlatform.iOS
        ? UiKitView(
            viewType: viewType,
            creationParamsCodec: const StandardMessageCodec(),
            creationParams: creationParams,
            onPlatformViewCreated: _onPlatformViewCreated,
            gestureRecognizers: gestureRecognizers,
          )
        : AppKitView(
            viewType: viewType,
            creationParamsCodec: const StandardMessageCodec(),
            creationParams: creationParams,
            onPlatformViewCreated: _onPlatformViewCreated,
            gestureRecognizers: gestureRecognizers,
          );

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: platformView,
    );
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('CupertinoNativeAirPlayButton_$id');
    _lastTint = resolveColorToArgb(widget.tint, context);
    _lastActiveTint = resolveColorToArgb(widget.activeTint, context);
    _lastPrioritizesVideo = widget.prioritizesVideoDevices;
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null || !mounted) return;

    // Resolve before any awaits
    final tint = resolveColorToArgb(widget.tint, context);
    final activeTint = resolveColorToArgb(widget.activeTint, context);
    final prioritizesVideo = widget.prioritizesVideoDevices;

    final style = <String, dynamic>{};
    if (_lastTint != tint) {
      // Null clears back to the system tint.
      style['tint'] = tint;
      _lastTint = tint;
    }
    if (_lastActiveTint != activeTint) {
      style['activeTint'] = activeTint;
      _lastActiveTint = activeTint;
    }
    if (_lastPrioritizesVideo != prioritizesVideo) {
      style['prioritizesVideoDevices'] = prioritizesVideo;
      _lastPrioritizesVideo = prioritizesVideo;
    }
    if (style.isNotEmpty) {
      await channel.invokeMethod('setStyle', style);
    }
  }
}
