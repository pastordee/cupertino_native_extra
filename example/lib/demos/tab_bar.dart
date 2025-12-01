import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show TabController, TabBarView;
import 'package:cupertino_native_extra/cupertino_native.dart';

/// Demonstrates CNTabBar with search integration.
///
/// IMPORTANT: When using CNToolbar with a SINGLE item, use `trailing` instead of `leading`.
/// This is iOS native behavior - single items in rightBarButtonItems position and respond
/// better than leftBarButtonItems. See TOOLBAR_SINGLE_ITEM_BEHAVIOR.md for details.
class TabBarDemoPage extends StatefulWidget {
  const TabBarDemoPage({super.key});

  @override
  State<TabBarDemoPage> createState() => _TabBarDemoPageState();
}

class _TabBarDemoPageState extends State<TabBarDemoPage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;
  int _index = 0;
  bool _isSearchExpanded = false;
  String _searchText = '';
  int _lastTabIndex = 0; // Remember the last tab before search

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 4, vsync: this);
    _controller.addListener(() {
      final i = _controller.index;
      if (i != _index) setState(() => _index = i);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Native Tab Bar'),
      ),
      child: Stack(
        children: [
          // Content below
          Positioned.fill(
            child: TabBarView(
              controller: _controller,
              children: const [
                _ImageTabPage(asset: 'assets/home.jpg', label: 'Home'),
                _ImageTabPage(asset: 'assets/profile.jpg', label: 'Radio'),
                _ImageTabPage(asset: 'assets/settings.jpg', label: 'Library'),
                _ImageTabPage(asset: 'assets/search.jpg', label: 'Search'),
              ],
            ),
          ),
          // Native tab bar overlay
          Align(
            alignment: Alignment.bottomCenter,
            child: _isSearchExpanded ? _buildExpandedSearch() : _buildTabBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return CNTabBar(
      // Using split mode to create visual separation for search tab
      // This matches the iOS pattern where search is on the trailing edge
      items: const [
        CNTabBarItem(
          label: 'Home', 
          icon: CNSymbol('house.fill'),
          labelSize: 10,
          iconSize: 20,
        ),
        CNTabBarItem(
          label: 'Radio',
          icon: CNSymbol('dot.radiowaves.left.and.right'),
          labelSize: 12,
          iconSize: 24,
        ),
        CNTabBarItem(
          label: 'Library',
          icon: CNSymbol('music.note.list'),
          badgeValue: 99, // Shows as "99+"
          badgeColor: CupertinoColors.systemRed,
          labelSize: 14,
          iconSize: 28,
        ),
        CNTabBarItem(
          label: 'Search',
          icon: CNSymbol('magnifyingglass'),
          badgeValue: 3,
          badgeColor: CupertinoColors.systemBlue,
          labelSize: 16,
          iconSize: 32,
        ),
      ],
      currentIndex: _index,
      split: true, // Creates visual separation between main tabs and search
      rightCount: 1, // Search tab on trailing side
      shrinkCentered: true,
      onTap: (i) {
        if (i == 3) {
          // Search tab tapped - remember current tab and expand search
          print('🔍 Search tapped! Current tab before search: $_index');
          setState(() {
            _lastTabIndex = _index;
            _isSearchExpanded = true;
          });
          print('🔍 _lastTabIndex set to: $_lastTabIndex');
        } else {
          setState(() => _index = i);
          _controller.animateTo(i);
        }
      },
    );
  }

  // Method 2: Using CupertinoButton with Flutter Icon (works but different look)
  Widget _buildLastTabIconWithButton() {
    return SizedBox(
      width: 44,
      height: 44,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          print('✅ CupertinoButton pressed! Last tab index: $_lastTabIndex');
          // Tapping the icon returns to that tab and collapses search
          setState(() {
            _isSearchExpanded = false;
            _index = _lastTabIndex;
            _searchText = '';
          });
          _controller.animateTo(_lastTabIndex);
        },
        child: Icon(
          _getLastTabIconData(),
          size: 24,
          color: CupertinoColors.systemBlue,
        ),
      ),
    );
  }

  // Get the IconData for the last selected tab (for CupertinoButton approach)
  IconData _getLastTabIconData() {
    switch (_lastTabIndex) {
      case 0:
        return CupertinoIcons.house_fill;
      case 1:
        return CupertinoIcons.dot_radiowaves_left_right;
      case 2:
        return CupertinoIcons.music_note_list;
      default:
        return CupertinoIcons.house_fill;
    }
  }

  // Get the CNSymbol for the last selected tab
  CNSymbol _getLastTabIconSymbol() {
    CNSymbol symbol;
    switch (_lastTabIndex) {
      case 0:
        symbol = const CNSymbol('house.fill', size: 64);
        break;
      case 1:
        symbol = const CNSymbol('dot.radiowaves.left.and.right', size: 64);
        break;
      case 2:
        symbol = const CNSymbol('music.note.list', size: 64);
        break;
      default:
        symbol = const CNSymbol('house.fill', size: 64);
    }
    print('📍 Getting symbol for tab $_lastTabIndex: ${symbol.name}');
    return symbol;
  }

  // Method 1: Using CNToolbar with native SF Symbols (native look with blur)
  // NOTE: When CNToolbar has only one item, use 'trailing' to position it on the left side
  // This is iOS native behavior - 'trailing' in a single-item toolbar positions it naturally
  Widget _buildLastTabIconWithToolbar() {
    final symbol = _getLastTabIconSymbol();
    print(
      '🎨 Building toolbar with symbol: ${symbol.name} for tab $_lastTabIndex',
    );

    return SizedBox(
      width: 80, // Wider for better touch target
      child: CNToolbar(
        trailing: [
          // Use 'trailing' for single items to position on left
          CNToolbarAction(
            icon: symbol,
            onPressed: () {
              print(
                '� Toolbar button pressed! Returning to tab $_lastTabIndex',
              );
              setState(() {
                _isSearchExpanded = false;
                _index = _lastTabIndex;
                _searchText = '';
              });
              _controller.animateTo(_lastTabIndex);
            },
          ),
        ],
        height: 44,
        transparent: true,
      ),
    );
  }

  Widget _buildExpandedSearch() {
    return SafeArea(
      top: false,
      child: Container(
        // color: CupertinoColors.systemBackground.resolveFrom(context).withOpacity(0.95),
        padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
        child: Row(
          children: [
            // METHOD 1: CNToolbar with native SF Symbols (unified native look with blur)
            _buildLastTabIconWithToolbar(),

            const SizedBox(width: 1),
            // Expanded search bar
            Expanded(
              child: CNSearchBar(
                placeholder: 'Shows, Movies, and More',
                showsCancelButton: true,
                onTextChanged: (text) {
                  setState(() => _searchText = text);
                  print('Searching: $text');
                },
                onSearchButtonClicked: (text) {
                  print('Search submitted: $text');
                },
                onCancelButtonClicked: () {
                  setState(() {
                    _isSearchExpanded = false;
                    _searchText = '';
                  });
                },
                height: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageTabPage extends StatelessWidget {
  const _ImageTabPage({required this.asset, required this.label});
  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(asset, fit: BoxFit.cover),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(top: 12),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
