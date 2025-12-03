import 'package:flutter/cupertino.dart';
import 'package:cupertino_native_extra/cupertino_native.dart';

/// Demo page showcasing CNIcon - native iOS SF Symbol icons.
/// 
/// Features demonstrated:
/// - SF Symbols system icons from Apple's library
/// - Multiple rendering modes:
///   - Monochrome: Single color (traditional)
///   - Hierarchical: Layered with emphasis levels
///   - Multicolor: Full color palette
/// - Custom sizing from small (12pt) to large (40pt)
/// - Color customization per mode
/// - Size variations for different UI contexts
/// 
/// SF Symbols benefits:
/// - 4500+ professionally designed icons
/// - Consistent across Apple platforms
/// - Automatic baseline and sizing
/// - Built-in accessibility support
/// - Weight variations (light, regular, semibold, bold)
/// 
/// Best practices:
/// - Use standard symbol names from SF Symbols app
/// - Match icon size to context (toolbar: 18-20pt, nav: 24-28pt)
/// - Monochrome for traditional UI
/// - Hierarchical for depth
/// - Multicolor for decorative/branded icons
class IconDemoPage extends StatelessWidget {
  const IconDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Icon')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Basic'),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                CNIcon(symbol: CNSymbol('heart'), size: 24),
                CNIcon(symbol: CNSymbol('star'), size: 24),
                CNIcon(symbol: CNSymbol('bell'), size: 24),
                CNIcon(symbol: CNSymbol('figure.walk'), size: 24),
                CNIcon(symbol: CNSymbol('paperplane'), size: 24),
              ],
            ),

            const SizedBox(height: 24),

            const Text('Sizes'),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                CNIcon(symbol: CNSymbol('heart'), size: 12),
                CNIcon(symbol: CNSymbol('star'), size: 16),
                CNIcon(symbol: CNSymbol('bell'), size: 24),
                CNIcon(symbol: CNSymbol('figure.walk'), size: 32),
                CNIcon(symbol: CNSymbol('paperplane'), size: 40),
              ],
            ),

            const SizedBox(height: 24),

            const Text('Monochrome colors'),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                CNIcon(
                  symbol: CNSymbol('star.fill'),
                  color: CupertinoColors.systemPink,
                  mode: CNSymbolRenderingMode.monochrome,
                ),
                CNIcon(
                  symbol: CNSymbol('star.fill'),
                  color: CupertinoColors.systemBlue,
                  mode: CNSymbolRenderingMode.monochrome,
                ),
                CNIcon(
                  symbol: CNSymbol('star.fill'),
                  color: CupertinoColors.systemGreen,
                  mode: CNSymbolRenderingMode.monochrome,
                ),
                CNIcon(
                  symbol: CNSymbol('star.fill'),
                  color: CupertinoColors.systemOrange,
                  mode: CNSymbolRenderingMode.monochrome,
                ),
                CNIcon(
                  symbol: CNSymbol('star.fill'),
                  color: CupertinoColors.systemPurple,
                  mode: CNSymbolRenderingMode.monochrome,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Hierarchical'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                CNIcon(
                  symbol: CNSymbol('rectangle.and.pencil.and.ellipsis'),
                  size: 32,
                  color: CupertinoColors.systemBlue,
                  mode: CNSymbolRenderingMode.hierarchical,
                ),
                CNIcon(
                  symbol: CNSymbol('person.3.sequence'),
                  size: 32,
                  color: CupertinoColors.systemBlue,
                  mode: CNSymbolRenderingMode.hierarchical,
                ),
                CNIcon(
                  symbol: CNSymbol('speaker.wave.2.bubble'),
                  size: 32,
                  color: CupertinoColors.systemBlue,
                  mode: CNSymbolRenderingMode.hierarchical,
                ),
                CNIcon(
                  symbol: CNSymbol('ear.badge.waveform'),
                  size: 32,
                  color: CupertinoColors.systemBlue,
                  mode: CNSymbolRenderingMode.hierarchical,
                ),
                CNIcon(
                  symbol: CNSymbol('square.stack.3d.up'),
                  size: 32,
                  color: CupertinoColors.systemBlue,
                  mode: CNSymbolRenderingMode.hierarchical,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Multicolor'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                CNIcon(
                  symbol: CNSymbol('paintpalette.fill'),
                  size: 28,
                  mode: CNSymbolRenderingMode.multicolor,
                ),
                CNIcon(
                  symbol: CNSymbol('sun.rain.fill'),
                  size: 28,
                  mode: CNSymbolRenderingMode.multicolor,
                ),
                CNIcon(
                  symbol: CNSymbol('rainbow'),
                  size: 28,
                  mode: CNSymbolRenderingMode.multicolor,
                ),
                CNIcon(
                  symbol: CNSymbol('pc'),
                  size: 28,
                  mode: CNSymbolRenderingMode.multicolor,
                ),
                CNIcon(
                  symbol: CNSymbol('lightspectrum.horizontal'),
                  size: 28,
                  mode: CNSymbolRenderingMode.multicolor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
