import 'package:cupertino_native_extra/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

/// Demo page showcasing CNButton - native iOS buttons with 8 styles.
/// 
/// Features demonstrated:
/// - 8 button styles following Apple iOS HIG:
///   1. Plain: Minimal emphasis for secondary actions
///   2. Gray: Subtle background, tertiary actions
///   3. Tinted: Moderate emphasis using accent color
///   4. Bordered: Clear container for important actions
///   5. BorderedProminent: High emphasis bordered style
///   6. Filled: Primary action with solid color
///   7. Glass: Modern frosted glass effect
///   8. ProminentGlass: High emphasis glass style
/// - Text and icon button variants
/// - Shrink wrap for compact layouts
/// - Disabled state support
/// - Custom callbacks for interactions
/// 
/// Design guidance:
/// - Use prominent styles (filled, borderedProminent) for primary CTAs
/// - Use plain or gray for secondary/tertiary options
/// - Use glass styles for modern, premium feel
/// - Always disable instead of hiding unavailable buttons
/// - Label buttons with clear action verbs (Save, Delete, etc.)
/// 
/// Apple HIG recommendations:
/// - One primary button per screen
/// - Consistent sizing in groups
/// - Adequate touch targets (44pt minimum)
/// - Clear hierarchy with visual weight
class ButtonDemoPage extends StatefulWidget {
  const ButtonDemoPage({super.key});

  @override
  State<ButtonDemoPage> createState() => _ButtonDemoPageState();
}

class _ButtonDemoPageState extends State<ButtonDemoPage> {
  String _last = 'None';

  void _set(String what) => setState(() => _last = what);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Button')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Text buttons'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                CNButton(
                  label: 'Plain',
                  style: CNButtonStyle.plain,
                  onPressed: () => _set('Plain'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Gray',
                  style: CNButtonStyle.gray,
                  onPressed: () => _set('Gray'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Tinted',
                  style: CNButtonStyle.tinted,
                  onPressed: () => _set('Tinted'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Bordered',
                  style: CNButtonStyle.bordered,
                  onPressed: () => _set('Bordered'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'BorderedProminent',
                  style: CNButtonStyle.borderedProminent,
                  onPressed: () => _set('BorderedProminent'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Filled',
                  style: CNButtonStyle.filled,
                  onPressed: () => _set('Filled'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Glass',
                  style: CNButtonStyle.glass,
                  onPressed: () => _set('Glass'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'ProminentGlass',
                  style: CNButtonStyle.prominentGlass,
                  onPressed: () => _set('ProminentGlass'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Disabled',
                  style: CNButtonStyle.bordered,
                  onPressed: null,
                  shrinkWrap: true,
                ),
              ],
            ),
            const SizedBox(height: 48),
            const Text('Icon buttons'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  style: CNButtonStyle.plain,
                  onPressed: () => _set('Icon Plain'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  style: CNButtonStyle.gray,
                  onPressed: () => _set('Icon Gray'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  style: CNButtonStyle.tinted,
                  onPressed: () => _set('Icon Tinted'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  style: CNButtonStyle.bordered,
                  onPressed: () => _set('Icon Bordered'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  style: CNButtonStyle.borderedProminent,
                  onPressed: () => _set('Icon BorderedProminent'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  style: CNButtonStyle.filled,
                  onPressed: () => _set('Icon Filled'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  style: CNButtonStyle.glass,
                  onPressed: () => _set('Icon Glass'),
                ),
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  style: CNButtonStyle.prominentGlass,
                  onPressed: () => _set('Icon ProminentGlass'),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Center(child: Text('Last pressed: $_last')),
          ],
        ),
      ),
    );
  }
}
