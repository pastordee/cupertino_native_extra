import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';

/// Demo page for iOS 26+ Native Search Tab Bar (Option B)
///
/// This demo showcases the native UITabBarController implementation that provides
/// true iOS 26+ tab bar behavior with native search tab transformation.
///
/// **Important**: This completely replaces the Flutter navigation structure with
/// native UIKit components. Use only for experimentation and prototyping.
class IOS26SearchTabBarDemoPage extends StatefulWidget {
  const IOS26SearchTabBarDemoPage({super.key});

  @override
  State<IOS26SearchTabBarDemoPage> createState() =>
      _IOS26SearchTabBarDemoPageState();
}

class _IOS26SearchTabBarDemoPageState extends State<IOS26SearchTabBarDemoPage> {
  int _currentTab = 0;
  String _searchQuery = '';
  bool _isNativeEnabled = true;  // Start enabled to show at bottom
  String _debugLog = '';

  @override
  void initState() {
    super.initState();
    // Enable native tab bar on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enableNativeTabBar();
    });
  }

  @override
  void dispose() {
    // Disable native tab bar when leaving the page
    if (_isNativeEnabled) {
      _disableNativeTabBar();
    }
    super.dispose();
  }

  @override§
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('iOS 26+ Native Tab Bar'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(CupertinoIcons.back),
        ),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildWarningCard(context),
        const SizedBox(height: 24),
        _buildControlsCard(context),
        const SizedBox(height: 24),
        _buildStatusCard(context),
        const SizedBox(height: 24),
        _buildDescriptionCard(context),
        const SizedBox(height: 24),
        _buildDebugLogCard(context),
      ],
    );
  }

  Widget _buildWarningCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemYellow.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.systemYellow.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                CupertinoIcons.exclamationmark_triangle_fill,
                color: CupertinoColors.systemYellow,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'EXPERIMENTAL FEATURE',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'This is Option B: A completely native iOS 26+ tab bar controller that replaces Flutter\'s root view controller.\n\n'
            'Features:\n'
            '• Native UITabBarController at the root\n'
            '• True iOS search tab transformation\n'
            '• iOS 26+ Liquid Glass effects\n'
            '• Native animation performance\n\n'
            'Status: Tap the button below to enable/disable.',
            style: TextStyle(
              fontSize: 15,
              color: CupertinoColors.label.withOpacity(0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Native Tab Bar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.checkmark_circle_fill,
                        color: CupertinoColors.systemGreen,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Enabled at Bottom',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.systemGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Tap the search icon (magnifying glass) to search. Tap Home, Explore, or Profile to return to this page.',
            style: TextStyle(
              fontSize: 13,
              color: CupertinoColors.label.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatusRow('Native Tab Bar', _isNativeEnabled ? '✅ Active' : '⏳ Disabled'),
          if (_isNativeEnabled)
            _buildStatusRow('Current Tab', 'Tab $_currentTab'),
          if (_searchQuery.isNotEmpty)
            _buildStatusRow('Search Query', _searchQuery),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: CupertinoColors.label.withOpacity(0.6),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How It Works',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Option B replaces your Flutter app\'s root view controller with a native iOS UITabBarController. '
            'This approach provides:\n\n'
            '1. True native tab bar behavior\n'
            '2. Native search tab transformation\n'
            '3. Direct access to iOS 26+ features\n'
            '4. Full native animation support\n\n'
            'However, this breaks some Flutter assumptions about the view hierarchy and may cause issues with:\n'
            '• Navigator.pop()\n'
            '• Hot reload\n'
            '• State management\n'
            '• Platform channels\n\n'
            'This implementation is more experimental than Option A.',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.label.withOpacity(0.7),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugLogCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Debug Log',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _debugLog.isEmpty
                  ? '> Waiting for events...\n> Tab bar will be enabled automatically'
                  : _debugLog,
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGreen,
                fontFamily: 'Menlo',
              ),
              maxLines: 10,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enableNativeTabBar() async {
    try {
      _addDebugLog('Enabling native tab bar...');

      await IOS26NativeSearchTabBar.enable(
        tabs: [
          const NativeTabConfig(title: 'Home', sfSymbol: 'house.fill'),
          const NativeTabConfig(title: 'Explore', sfSymbol: 'safari'),
          const NativeTabConfig(
            title: 'Search',
            sfSymbol: 'magnifyingglass',
            isSearchTab: true,
          ),
          const NativeTabConfig(title: 'Profile', sfSymbol: 'person.fill'),
        ],
        selectedIndex: 0,
        onTabSelected: (index) {
          _addDebugLog('Tab selected: $index');
          if (mounted) {
            setState(() {
              _currentTab = index;
            });
            // If search tab (index 2) is selected, show search
            if (index == 2) {
              _addDebugLog('Search tab selected - showing search');
              IOS26NativeSearchTabBar.showSearch();
            } else {
              // For Home (0), Explore (1), or Profile (3) - navigate back
              _addDebugLog('Non-search tab selected - navigating back');
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  Navigator.of(context).pop();
                }
              });
            }
          }
        },
        onSearchQueryChanged: (query) {
          _addDebugLog('Search query: $query');
          if (mounted) {
            setState(() {
              _searchQuery = query;
            });
          }
        },
        onSearchSubmitted: (query) {
          _addDebugLog('Search submitted: $query');
        },
        onSearchCancelled: () {
          _addDebugLog('Search cancelled');
          if (mounted) {
            setState(() {
              _searchQuery = '';
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isNativeEnabled = true;
        });
        _addDebugLog('✅ Native tab bar enabled');
      }
    } catch (e) {
      _addDebugLog('❌ Error: $e');
      print('Error enabling native tab bar: $e');
    }
  }

  Future<void> _disableNativeTabBar() async {
    try {
      _addDebugLog('Disabling native tab bar...');
      await IOS26NativeSearchTabBar.disable();
      if (mounted) {
        setState(() {
          _isNativeEnabled = false;
        });
      }
      _addDebugLog('✅ Native tab bar disabled');
    } catch (e) {
      _addDebugLog('❌ Error disabling: $e');
      print('Error disabling native tab bar: $e');
    }
  }

  void _addDebugLog(String message) {
    final timestamp = DateTime.now().toString().split('.')[0];
    if (mounted) {
      setState(() {
        _debugLog = '> [$timestamp] $message\n$_debugLog';
        // Keep only last 20 lines
        final lines = _debugLog.split('\n');
        if (lines.length > 20) {
          _debugLog = lines.take(20).join('\n');
        }
      });
    }
  }
}
