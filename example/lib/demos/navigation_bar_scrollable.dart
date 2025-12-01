import 'package:flutter/cupertino.dart';
import 'package:cupertino_native_extra/cupertino_native.dart';

/// Demo page showing CNNavigationBar.scrollable() with native large title collapse.
///
/// This demonstrates the proper iOS large title behavior where the title
/// starts large below the navigation bar and smoothly collapses into the
/// navigation bar as you scroll up. Set largeTitle: true to enable this behavior,
/// or largeTitle: false for a standard small navigation bar title.
class NavigationBarScrollableDemoPage extends StatefulWidget {
  const NavigationBarScrollableDemoPage({super.key});

  @override
  State<NavigationBarScrollableDemoPage> createState() =>
      _NavigationBarScrollableDemoPageState();
}

class _NavigationBarScrollableDemoPageState
    extends State<NavigationBarScrollableDemoPage> {
  int _currentIndex = 0;
  final _searchController = CNNativeSearchController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CNNavigationBar.scrollable(
          title: 'Large Title',
          leading: [
            CNNavigationBarAction(
              icon: CNSymbol('chevron.left'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          trailing: [
            CNNavigationBarAction(
              icon: CNSymbol('ellipsis.circle'),
              onPressed: () {
                print('More options tapped');
              },
            ),
            // CNNavigationBarAction.flexibleSpace(),
            CNNavigationBarAction(
              icon: CNSymbol('ellipsis.circle'),
              onPressed: () {
                print('More options tapped');
              },
            ),
          ],
          largeTitle: true, // Set to false for standard small title
          transparent: true,
          scrollableContent: _buildContent(context),
        ),
        // Tab bar at the bottom
        Align(
          alignment: Alignment.bottomCenter,
          child: CNTabBar.search(
            currentIndex: _currentIndex,
            onTap: (index) {
              print('Tab tapped: index = $index');
              
              // For non-search tabs, update the current index
              setState(() {
                _currentIndex = index;
              });
              print('Tab $index tapped');
            },
            items: [
              CNTabBarItem(icon: CNSymbol('house.fill'), label: 'Home'),
              CNTabBarItem(icon: CNSymbol('bell.fill'), label: 'Notifications'),
              CNTabBarItem(icon: CNSymbol('person.fill'), label: 'Profile'),
            ],
            searchConfig: CNSearchConfig(
              placeholder: 'Search music...',
              onSearchActivated: () {
                print('Search bar activated - opening native search controller');
                // Open native search controller when search bar is activated
                _searchController.show(
                  placeholder: 'Search music...',
                  onTextChanged: (query) {
                    print('Native search text: $query');
                  },
                  onSubmitted: (query) {
                    print('Native search submitted: $query');
                  },
                  onCancelled: () {
                    print('Native search cancelled');
                  },
                );
              },
              onSearchTextChanged: (text) {
                print('Search text changed: $text');
              },
            ),
            split: true,
            rightCount: 1, // Search on the right
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [CupertinoColors.systemBlue, CupertinoColors.systemPurple],
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Info card
          _buildCard(
            context,
            title: 'iOS Large Title Behavior',
            description:
                'This demo uses CNNavigationBar.scrollable() which uses '
                'CupertinoSliverNavigationBar for authentic iOS large title behavior:\n\n'
                '• Set largeTitle: true for collapsing large title\n'
                '• Set largeTitle: false for standard small title\n'
                '• Title smoothly collapses into the bar as you scroll up\n'
                '• Automatically tracks scroll position\n'
                '• Provides the native iOS navigation experience',
          ),

          const SizedBox(height: 20),

          _buildCard(
            context,
            title: 'Try It Out',
            description:
                'Scroll up and down to see the large title animate smoothly '
                'as it collapses into the navigation bar. The title starts '
                'large below the nav bar and transitions to small as you scroll.',
          ),

          const SizedBox(height: 20),

          // Sample list items
          ...List.generate(30, (index) => _buildListItem(context, index)),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground
            .resolveFrom(context)
            .withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 15,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground
            .resolveFrom(context)
            .withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.systemBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'List Item ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Scroll to see the large title collapse',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            CupertinoIcons.chevron_right,
            size: 16,
            color: CupertinoColors.systemGrey,
          ),
        ],
      ),
    );
  }
}
