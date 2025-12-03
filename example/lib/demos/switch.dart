import 'package:flutter/cupertino.dart';
import 'package:cupertino_native_extra/cupertino_native.dart';

/// Demo page showcasing CNSwitch - a native iOS toggle switch.
/// 
/// Features demonstrated:
/// - On/off toggle with native UISwitch rendering
/// - Custom tint colors for visual variety
/// - Disabled state for non-interactive UI
/// - Real-time state feedback
/// 
/// Best practices:
/// - Use for binary choices (on/off, enabled/disabled)
/// - Ideal for settings and feature toggles
/// - Provides immediate visual feedback
/// - No confirmation needed unlike buttons
class SwitchDemoPage extends StatefulWidget {
  const SwitchDemoPage({super.key});
/// Demo page showcasing CNSwitch - a native iOS toggle switch control.
/// 
/// Features demonstrated:
/// - Basic on/off toggle functionality
/// - Custom tint colors (e.g., systemPink for theme customization)
/// - Disabled state for non-interactive UI
/// - Native iOS UISwitch rendering with hardware acceleration
/// 
/// Switches are ideal for binary choices (on/off, enabled/disabled).
/// Use for settings, permissions, and feature toggles that require
/// immediate feedback without confirmation.

  @override
  State<SwitchDemoPage> createState() => _SwitchDemoPageState();
}

class _SwitchDemoPageState extends State<SwitchDemoPage> {
  bool _basicSwitchValue = true;
  bool _coloredSwitchValue = true;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Switch')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Row(
              children: [
                Text('Basic ${_basicSwitchValue ? 'ON' : 'OFF'}'),
                Spacer(),
                CNSwitch(
                  value: _basicSwitchValue,
                  onChanged: (v) => setState(() => _basicSwitchValue = v),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Row(
              children: [
                Text('Colored ${_coloredSwitchValue ? 'ON' : 'OFF'}'),
                Spacer(),
                CNSwitch(
                  value: _coloredSwitchValue,
                  color: CupertinoColors.systemPink,
                  onChanged: (v) => setState(() => _coloredSwitchValue = v),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Row(
              children: [
                Text('Disabled'),
                Spacer(),
                CNSwitch(value: false, enabled: false, onChanged: (_) {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
