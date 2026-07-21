import 'package:flutter/cupertino.dart';

/// Converts a [Color] to ARGB int (0xAARRGGBB) format for native communication.
///
/// This helper converts Flutter colors to the native ARGB format required
/// for iOS/macOS UIKit components. The format is:
/// - Bits 24-31: Alpha channel (0-255)
/// - Bits 16-23: Red channel (0-255)
/// - Bits 8-15: Green channel (0-255)
/// - Bits 0-7: Blue channel (0-255)
///
/// Private helper for internal use.
int? _argbFromColor(Color? color) {
  if (color == null) return null;
  // Use component accessors recommended by lints (.a/.r/.g/.b as doubles 0..1)
  final a = (color.a * 255.0).round() & 0xff;
  final r = (color.r * 255.0).round() & 0xff;
  final g = (color.g * 255.0).round() & 0xff;
  final b = (color.b * 255.0).round() & 0xff;
  return (a << 24) | (r << 16) | (g << 8) | b;
}

/// Resolves a possibly dynamic Cupertino color to a concrete ARGB int
/// for the current [BuildContext]. Falls back to the raw color if not dynamic.
///
/// ## Purpose
///
/// This function handles Flutter's dynamic colors (colors that change based on
/// brightness, contrast, or accessibility settings) by resolving them in the
/// current context before converting to native format.
///
/// ## Parameters
///
/// - [color]: The color to resolve (nullable)
/// - [context]: The build context for resolving dynamic colors
///
/// ## Returns
///
/// An ARGB integer suitable for passing to native iOS/macOS code, or null
/// if the input color is null.
///
/// ## Example
///
/// ```dart
/// final tintInt = resolveColorToArgb(
///   CupertinoColors.systemBlue,
///   context,
/// ); // Returns: 0xFF007AFF (iOS system blue)
/// ```
int? resolveColorToArgb(Color? color, BuildContext context) {
  if (color == null) return null;
  if (color is CupertinoDynamicColor) {
    final resolved = color.resolveFrom(context);
    return _argbFromColor(resolved);
  }
  return _argbFromColor(color);
}

/// Creates a unified style map for platform views.
///
/// This function encodes color styling information into a single map
/// that can be passed to native iOS/macOS code via method channels.
/// All colors are resolved and converted to ARGB format for compatibility.
///
/// ## Parameters
///
/// - [context]: Build context for resolving dynamic colors
/// - [tint]: General accent/tint color (primary color)
/// - [thumbTint]: Slider thumb or switch knob color
/// - [trackTint]: Active track color (slider/switch)
/// - [trackBackgroundTint]: Inactive track background color
///
/// ## Returns
///
/// A map with string keys and ARGB integer values. Only non-null colors
/// are included in the map. Keys:
/// - 'tint': General accent color
/// - 'thumbTint': Slider/switch thumb color
/// - 'trackTint': Active track color
/// - 'trackBackgroundTint': Inactive track color
///
/// ## Example
///
/// ```dart
/// final style = encodeStyle(
///   context,
///   tint: CupertinoColors.systemBlue,
///   thumbTint: CupertinoColors.systemPink,
///   trackTint: CupertinoColors.systemGreen,
/// );
/// // Returns: {
/// //   'tint': 0xFF007AFF,
/// //   'thumbTint': 0xFFFF2D55,
/// //   'trackTint': 0xFF34C759,
/// // }
/// ```
Map<String, dynamic> encodeStyle(
  BuildContext context, {
  Color? tint,
  Color? thumbTint,
  Color? trackTint,
  Color? trackBackgroundTint,
}) {
  final style = <String, dynamic>{};
  final tintInt = resolveColorToArgb(tint, context);
  final thumbInt = resolveColorToArgb(thumbTint, context);
  final trackInt = resolveColorToArgb(trackTint, context);
  final trackBgInt = resolveColorToArgb(trackBackgroundTint, context);
  if (tintInt != null) style['tint'] = tintInt;
  if (thumbInt != null) style['thumbTint'] = thumbInt;
  if (trackInt != null) style['trackTint'] = trackInt;
  if (trackBgInt != null) style['trackBackgroundTint'] = trackBgInt;
  return style;
}
