import 'package:flutter/cupertino.dart';
import 'package:cupertino_native_extra/cupertino_native.dart';

/// Standalone demo page with ONLY CNTabBar.search() to isolate issues
class TabBarOnlyDemoPage extends StatefulWidget {
  const TabBarOnlyDemoPage({super.key});

  @override
  State<TabBarOnlyDemoPage> createState() => _TabBarOnlyDemoPageState();
}

class _TabBarOnlyDemoPageState extends State<TabBarOnlyDemoPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    print('BUILD: TabBarOnlyDemoPage with _currentIndex=$_currentIndex');

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Tab Bar Only Demo'),
      ),
      child: Stack(
        children: [
          // Tab content - full screen
          IndexedStack(
            index: _currentIndex,
            children: [
              _buildTabContent(
                'Home',
                CupertinoIcons.house_fill,
                CupertinoColors.systemRed,
              ),
              _buildTabContent(
                'Radio',
                CupertinoIcons.dot_radiowaves_left_right,
                CupertinoColors.systemBlue,
              ),
              _buildTabContent(
                'Library',
                CupertinoIcons.music_note_list,
                CupertinoColors.systemGreen,
              ),
            ],
          ),
          // Tab bar at bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: CNTabBar.search(
              items: const [
                CNTabBarItem(label: 'Home', icon: CNSymbol('house.fill')),
                CNTabBarItem(
                  label: 'Radio',
                  icon: CNSymbol('dot.radiowaves.left.and.right'),
                ),
                CNTabBarItem(
                  label: 'Library',
                  icon: CNSymbol('music.note.list'),
                  badgeValue: 5,
                ),
              ],
              currentIndex: _currentIndex,
              onTap: (index) {
                print(
                  '====> DEMO: Tab $index tapped! Current was $_currentIndex',
                );
                setState(() {
                  _currentIndex = index;
                });
                print(
                  '====> DEMO: setState called, _currentIndex now = $_currentIndex',
                );
              },
              searchConfig: CNSearchConfig(
                placeholder: 'Search music...',
                onSearchTextChanged: (text) {
                  print('Searching: $text');
                },
              ),
              split: true,
              rightCount: 1, // Search on the right
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(String label, IconData icon, Color color) {
    return Container(
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 100, color: color),
            const SizedBox(height: 24),
            Text(
              label,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Current Index: $_currentIndex',
              style: const TextStyle(
                fontSize: 18,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
