import 'package:flutter/cupertino.dart';

/// Rendering modes for SF Symbols in native iOS widgets.
///
/// SF Symbols are Apple's library of 4500+ professionally designed icons
/// optimized for Apple platforms. Each rendering mode provides different
/// visual treatments suitable for different contexts.
///
/// ## Rendering Modes
///
/// ### [monochrome]
/// Single-color glyph. The icon uses the specified [CNSymbol.color].
/// Traditional, clean appearance. Use for:
/// - Navigation icons
/// - Toolbar buttons
/// - List item indicators
/// - Status icons
///
/// ### [hierarchical]
/// Layered rendering with color intensity hierarchy. Uses the primary color
/// at different opacity levels to create visual depth.
/// Use for:
/// - Complex multi-element icons
/// - System status indicators
/// - Elaborate toolbar buttons
/// - Icons needing visual emphasis on specific parts
///
/// ### [palette]
/// Uses up to 4 custom colors from [CNSymbol.paletteColors] list:
/// - colors[0]: Primary color (main elements)
/// - colors[1]: Secondary color (supporting elements)
/// - colors[2]: Tertiary color (accents)
/// - colors[3]: Quaternary color (fine details)
/// Use for:
/// - Branded icons
/// - Custom color schemes
/// - Category-specific icons with consistent colors
///
/// ### [multicolor]
/// Uses built-in multicolor assets from SF Symbols library.
/// Predefined color palette optimized by Apple.
/// Use for:
/// - Decorative icons
/// - Category badges
/// - Seasonal or themed icons
/// - Icons where color conveys meaning
///
/// ## Usage Examples
///
/// ```dart
/// // Monochrome toolbar icon
/// CNIcon(
///   symbol: CNSymbol('star.fill', size: 20),
///   color: CupertinoColors.systemBlue,
/// )
///
/// // Hierarchical system icon
/// CNIcon(
///   symbol: CNSymbol(
///     'square.stack.3d.up',
///     size: 28,
///     color: CupertinoColors.systemBlue,
///     mode: CNSymbolRenderingMode.hierarchical,
///   ),
/// )
///
/// // Palette with custom colors
/// CNIcon(
///   symbol: CNSymbol(
///     'paintpalette.fill',
///     size: 24,
///     paletteColors: [
///       CupertinoColors.systemRed,
///       CupertinoColors.systemOrange,
///     ],
///     mode: CNSymbolRenderingMode.palette,
///   ),
/// )
///
/// // Multicolor emoji-like icon
/// CNIcon(
///   symbol: CNSymbol(
///     'sun.rain.fill',
///     size: 28,
///     mode: CNSymbolRenderingMode.multicolor,
///   ),
/// )
/// ```
enum CNSymbolRenderingMode {
  /// Single-color glyph.
  monochrome,

  /// Hierarchical (shaded) rendering.
  hierarchical,

  /// Uses provided palette colors.
  palette,

  /// Uses built-in multicolor assets.
  multicolor,
}

/// Describes an SF Symbol to render natively.
///
/// SF Symbols are vector-based icons from Apple's comprehensive library.
/// This class encapsulates symbol configuration for native rendering
/// in iOS/macOS widgets.
///
/// The symbol rendering is performed natively using UIImage(systemName:)
/// for maximum compatibility and performance.
///
/// ## Properties
///
/// - [name]: The SF Symbol name (e.g., 'star.fill', 'chevron.down')
/// - [size]: Point size for display (default: 24.0)
/// - [color]: Icon color (used in monochrome/hierarchical modes)
/// - [paletteColors]: Custom colors for palette mode (up to 4 colors)
/// - [mode]: Rendering mode (monochrome, hierarchical, palette, multicolor)
/// - [gradient]: Whether to use built-in gradients when available
///
/// ## Finding Symbol Names
///
/// Use Apple's SF Symbols app (available on Mac App Store) to browse
/// all 4500+ available symbols. Symbols are named with dot notation
/// (e.g., 'heart.fill', 'square.and.arrow.up').
///
/// ## Performance Notes
///
/// - Symbol rendering is hardware-accelerated on native side
/// - Symbols are cached after first render
/// - Size changes are more efficient than rasterizing custom images
/// - Rendering is optimized for dark mode automatically
class CNSymbol {
  /// The SF Symbol name, e.g. `chevron.down`.
  ///
  /// Must be a valid SF Symbol name. Invalid names will fail at render time.
  final String name;

  /// Desired point size for the symbol.
  ///
  /// Common sizes:
  /// - 12-14: Small indicators
  /// - 16-18: Toolbar buttons
  /// - 20-24: Standard UI elements
  /// - 28-32: Large buttons
  /// - 40+: Decorative/hero icons
  final double size; // point size
  
  /// Preferred icon color (for monochrome/hierarchical modes).
  ///
  /// Ignored in multicolor mode. In hierarchical mode, this color
  /// is used as the base with varying opacity for layering.
  final Color? color; // preferred icon color (monochrome/hierarchical)
  
  /// Palette colors for multi-color/palette modes.
  ///
  /// Provide up to 4 colors in order:
  /// 1. Primary (main elements)
  /// 2. Secondary (supporting)
  /// 3. Tertiary (accents)
  /// 4. Quaternary (details)
  ///
  /// Unused in monochrome/hierarchical modes.
  final List<Color>? paletteColors; // multi-color palette
  
  /// Optional per-icon rendering mode.
  ///
  /// Defaults to monochrome if not specified.
  /// Can be overridden per-symbol for fine-grained control.
  final CNSymbolRenderingMode? mode; // per-icon rendering mode
  
  /// Whether to enable the built-in gradient when available.
  ///
  /// Some SF Symbols have built-in gradient variants.
  /// Set to true to use these gradients, false to disable.
  final bool? gradient; // prefer built-in gradient when available

  /// Creates a symbol description for native rendering.
  ///
  /// Example:
  /// ```dart
  /// CNSymbol(
  ///   'star.fill',
  ///   size: 24,
  ///   color: CupertinoColors.systemYellow,
  ///   mode: CNSymbolRenderingMode.monochrome,
  /// )
  /// ```
  const CNSymbol(
    this.name, {
    this.size = 24.0,
    this.color,
    this.paletteColors,
    this.mode,
    this.gradient,
  });
}