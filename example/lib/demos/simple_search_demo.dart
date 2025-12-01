import 'package:flutter/cupertino.dart';
import 'package:cupertino_native_extra/cupertino_native.dart';

/// Simple demo showing search-enabled components with named constructors:
/// - CNToolbar.search()
/// - CNNavigationBar.search()
/// - CNTabBar.search()
class SimpleSearchDemoPage extends StatelessWidget {
  const SimpleSearchDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Search Demo')),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Examples of CNToolbar.search(), CNNavigationBar.search(), and CNTabBar.search()',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildTabBarExample(),
              const SizedBox(height: 32),
              _buildNavBarExample(),
              const SizedBox(height: 32),
              _buildToolbarExample(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CNToolbar.search()',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Toolbar with integrated search. Tap the search icon to expand.',
          style: TextStyle(color: CupertinoColors.systemGrey),
        ),
        const SizedBox(height: 16),
        _ToolbarSearchExample(),
      ],
    );
  }

  Widget _buildNavBarExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CNNavigationBar.search()',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Navigation bar with integrated search. Tap the search icon to transform.',
          style: TextStyle(color: CupertinoColors.systemGrey),
        ),
        const SizedBox(height: 16),
        _NavBarSearchExample(),
      ],
    );
  }

  Widget _buildTabBarExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CNTabBar.search()',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tab bar with integrated search tab. Tap search to expand.',
          style: TextStyle(color: CupertinoColors.systemGrey),
        ),
        const SizedBox(height: 16),
        _TabBarSearchExample(),
      ],
    );
  }
}

class _TabBarSearchExample extends StatefulWidget {
  @override
  State<_TabBarSearchExample> createState() => _TabBarSearchExampleState();
}

class _TabBarSearchExampleState extends State<_TabBarSearchExample> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          border: Border.all(color: CupertinoColors.systemGrey4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // Tab content
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  _buildTabContent('Home', CupertinoIcons.house_fill),
                  _buildTabContent(
                    'Radio',
                    CupertinoIcons.dot_radiowaves_left_right,
                  ),
                  _buildTabContent('Library', CupertinoIcons.music_note_list),
                ],
              ),
            ),
            // Tab bar at bottom - wrapped in Container to ensure proper sizing
            Container(
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
                  print('item $index tapped');
                  setState(() => _currentIndex = index);
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
      ),
    );
  }

  Widget _buildTabContent(String label, IconData icon) {
    return Container(
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: CupertinoColors.systemGrey),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarSearchExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.systemGrey4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Mock content
          Center(
            child: Text(
              'Content Area',
              style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 18),
            ),
          ),
          // Toolbar with search
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CNToolbar.search(
              leading: [
                CNToolbarAction(
                  icon: const CNSymbol('star.fill'),
                  onPressed: () {
                    print('Favorites tapped');
                  },
                ),
              ],
              trailing: [
                CNToolbarAction(
                  icon: const CNSymbol('ellipsis.circle'),
                  onPressed: () {
                    print('More tapped');
                  },
                ),
              ],
              searchConfig: CNSearchConfig(
                placeholder: 'Search...',
                onSearchTextChanged: (text) {
                  print('Searching: $text');
                },
              ),
              contextIcon: const CNSymbol('house.fill'),
              transparent: false,
              height: 50,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBarSearchExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.systemGrey4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Mock content
          Center(
            child: Text(
              'Content Area',
              style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 18),
            ),
          ),
          // Navigation bar with search
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CNNavigationBar.search(
              title: 'Items',
              leading: [
                CNNavigationBarAction(
                  icon: const CNSymbol('plus'),
                  onPressed: () {
                    print('Add tapped');
                  },
                ),
              ],
              searchConfig: CNSearchConfig(
                placeholder: 'Search items...',
                onSearchTextChanged: (text) {
                  print('Searching: $text');
                },
              ),
              transparent: false,
            ),
          ),
        ],
      ),
    );
  }
}
