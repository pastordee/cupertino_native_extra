import 'package:flutter/cupertino.dart';
import 'package:cupertino_native_extra/cupertino_native.dart';

/// Demo page showcasing CNSlider - a native iOS slider control.
/// 
/// Features demonstrated:
/// - Basic value selection (0-100)
/// - Step intervals for discrete value selection
/// - Custom tint colors
/// - Disabled state
/// - Real-time value feedback
/// 
/// The CNSlider provides a native iOS UISlider experience with full support
/// for iOS design patterns and accessibility features.
class SliderDemoPage extends StatefulWidget {
  const SliderDemoPage({super.key});

  @override
  State<SliderDemoPage> createState() => _SliderDemoPageState();
}

class _SliderDemoPageState extends State<SliderDemoPage> {
  double _defaultSliderValue = 50;
  double _stepSliderValue = 50;
  double _coloredSliderValue = 50;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Slider')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Row(
              children: [
                const Text('Default'),
                Spacer(),
                Text('Value: ${_defaultSliderValue.toStringAsFixed(1)}'),
              ],
            ),
            CNSlider(
              value: _defaultSliderValue,
              min: 0,
              max: 100,
              enabled: true,
              onChanged: (v) => setState(() => _defaultSliderValue = v),
            ),
            const SizedBox(height: 48),
            Row(
              children: [
                const Text('Shared value'),
                Spacer(),
                Text('Value: ${_defaultSliderValue.toStringAsFixed(1)}'),
              ],
            ),
            CNSlider(
              value: _defaultSliderValue,
              min: 0,
              max: 100,
              enabled: true,
              onChanged: (v) => setState(() => _defaultSliderValue = v),
            ),
            const SizedBox(height: 48),
            Row(
              children: [
                const Text('With color'),
                Spacer(),
                Text('Value: ${_coloredSliderValue.toStringAsFixed(1)}'),
              ],
            ),
            CNSlider(
              value: _coloredSliderValue,
              min: 0,
              max: 100,
              enabled: true,
              color: CupertinoColors.systemPink,
              onChanged: (v) => setState(() => _coloredSliderValue = v),
            ),
            const SizedBox(height: 48),

            Row(
              children: [
                const Text('Step slider'),
                Spacer(),
                Text('Value: ${_stepSliderValue.toStringAsFixed(0)}'),
              ],
            ),
            CNSlider(
              value: _stepSliderValue,
              min: 0,
              max: 100,
              enabled: true,
              step: 10,
              onChanged: (v) => setState(() => _stepSliderValue = v),
            ),

            const SizedBox(height: 48),

            const Text('Disabled'),
            CNSlider(
              value: 50,
              min: 0,
              max: 100,
              enabled: false,
              onChanged: (_) {},
            ),
          ],
        ),
      ),
    );
  }
}
