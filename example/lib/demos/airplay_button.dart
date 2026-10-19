// Created: 2026-10-19
import 'package:flutter/cupertino.dart';
import 'package:cupertino_native_extra/cupertino_native.dart';

class AirPlayButtonDemoPage extends StatelessWidget {
  const AirPlayButtonDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('AirPlay Button')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Default'),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CNAirPlayButton(),
                CNAirPlayButton(size: 22),
                CNAirPlayButton(size: 36),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Over video'),
            const SizedBox(height: 12),
            Container(
              height: 120,
              color: CupertinoColors.black,
              alignment: Alignment.topRight,
              padding: const EdgeInsets.all(8),
              child: const CNAirPlayButton(
                tint: CupertinoColors.white,
                activeTint: CupertinoColors.activeBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
