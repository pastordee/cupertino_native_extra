import 'package:cupertino_ui/cupertino_ui.dart';

/// A bottom toolbar that transforms between search mode and tab bar mode.
///
/// **Unfocused state**: Shows icon + search field + trailing action
/// **Focused state**: Shows full tab bar + search button on trailing edge
///
/// This matches the Apple HIG pattern shown in iOS design guidelines.
///
/// **Best Practices (Apple HIG):**
/// - Use descriptive placeholder text (e.g., "Shows, Movies, and More" instead of just "Search")
/// - Search immediately as user types for responsive experience
/// - Show suggested search terms before or while typing
/// - Provide relevant results first, consider categorizing them
/// - Consider scope controls for filtering search categories
/// - Consider tokens for filtering by common terms
///
/// Example:
/// ```dart
/// CNTransformingToolbar(
///   leadingIcon: CupertinoIcons.square_grid_2x2,
///   searchPlaceholder: 'Shows, Movies, and More', // Descriptive!
///   trailingAction: Icon(CupertinoIcons.mic),
///   showSuggestions: true,
///   suggestions: ['Popular', 'New Releases', 'My List'],
///   scopeOptions: ['All', 'Movies', 'TV Shows'],
///   tabs: [
///     ToolbarTab(label: 'Tab 1', icon: CupertinoIcons.house_fill),
///     ToolbarTab(label: 'Tab 2', icon: CupertinoIcons.music_note),
///     ToolbarTab(label: 'Tab 3', icon: CupertinoIcons.folder),
///     ToolbarTab(label: 'Tab 4', icon: CupertinoIcons.settings),
///   ],
///   selectedIndex: 0,
///   onTabSelected: (index) => print('Tab $index'),
/// )
/// ```
class CNTransformingToolbar extends StatefulWidget {
  /// Creates a transforming toolbar that switches between search and tab bar modes.
  const CNTransformingToolbar({
    super.key,
    this.leadingIcon,
    this.searchPlaceholder = 'Search',
    this.trailingAction,
    this.tabs = const [],
    this.selectedIndex = 0,
    this.onTabSelected,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.showSuggestions = false,
    this.suggestions = const [],
    this.scopeOptions = const [],
    this.selectedScope = 0,
    this.onScopeChanged,
    this.searchImmediately = true,
    this.height = 50.0,
    this.backgroundColor,
  });

  /// Icon to display on leading edge when in search mode
  final IconData? leadingIcon;

  /// Placeholder text for search field - should describe what can be searched
  /// (e.g., "Shows, Movies, and More" instead of just "Search")
  final String searchPlaceholder;

  /// Widget to display on trailing edge in search mode (e.g., mic button)
  final Widget? trailingAction;

  /// List of tabs to display in tab bar mode
  final List<ToolbarTab> tabs;

  /// Currently selected tab index
  final int selectedIndex;

  /// Called when a tab is selected
  final ValueChanged<int>? onTabSelected;

  /// Called when search text changes (fires immediately as user types if searchImmediately is true)
  final ValueChanged<String>? onSearchChanged;

  /// Called when search is submitted
  final ValueChanged<String>? onSearchSubmitted;

  /// Whether to show search suggestions
  final bool showSuggestions;

  /// List of suggested search terms to display
  final List<String> suggestions;

  /// Scope control options for filtering search (e.g., ['All', 'Movies', 'TV Shows'])
  final List<String> scopeOptions;

  /// Currently selected scope index
  final int selectedScope;

  /// Called when scope selection changes
  final ValueChanged<int>? onScopeChanged;

  /// Whether to search immediately as user types (default: true per Apple HIG)
  final bool searchImmediately;

  /// Height of the toolbar
  final double height;

  /// Background color
  final Color? backgroundColor;

  @override
  State<CNTransformingToolbar> createState() => _CNTransformingToolbarState();
}

class _CNTransformingToolbarState extends State<CNTransformingToolbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showTabBar = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _showTabBar = !_showTabBar;
      if (_showTabBar) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor =
        widget.backgroundColor ?? CupertinoTheme.of(context).barBackgroundColor;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(
            color: CupertinoColors.separator.resolveFrom(context),
            width: 0.5,
          ),
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _showTabBar ? _buildTabBarMode() : _buildSearchMode(),
      ),
    );
  }

  Widget _buildSearchMode() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          // Leading icon
          if (widget.leadingIcon != null)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.leadingIcon,
                size: 20,
                color: CupertinoColors.label.resolveFrom(context),
              ),
            ),
          if (widget.leadingIcon != null) const SizedBox(width: 8),

          // Search field
          Expanded(
            child: GestureDetector(
              onTap: _toggleMode,
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: CupertinoColors.tertiarySystemFill.resolveFrom(
                    context,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.search,
                      size: 18,
                      color: CupertinoColors.secondaryLabel.resolveFrom(
                        context,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.searchPlaceholder,
                      style: TextStyle(
                        fontSize: 17,
                        color: CupertinoColors.secondaryLabel.resolveFrom(
                          context,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (widget.trailingAction != null) widget.trailingAction!,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarMode() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          // Tab bar
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  for (int i = 0; i < widget.tabs.length; i++) ...[
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          widget.onTabSelected?.call(i);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: i == widget.selectedIndex
                                ? CupertinoColors.systemBackground.resolveFrom(
                                    context,
                                  )
                                : const Color(0x00000000), // transparent
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: const EdgeInsets.all(2),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.tabs[i].icon,
                                size: 16,
                                color: i == widget.selectedIndex
                                    ? CupertinoColors.activeBlue
                                    : CupertinoColors.label.resolveFrom(
                                        context,
                                      ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.tabs[i].label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: i == widget.selectedIndex
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: i == widget.selectedIndex
                                      ? CupertinoColors.activeBlue
                                      : CupertinoColors.label.resolveFrom(
                                          context,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Search button (circular)
          GestureDetector(
            onTap: _toggleMode,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.search,
                size: 18,
                color: CupertinoColors.label.resolveFrom(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Represents a tab in the transforming toolbar
class ToolbarTab {
  /// Creates a toolbar tab with a label and icon
  const ToolbarTab({required this.label, required this.icon});

  /// The text label displayed below the icon
  final String label;

  /// The icon displayed for this tab
  final IconData icon;
}
