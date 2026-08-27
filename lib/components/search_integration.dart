import 'package:cupertino_ui/cupertino_ui.dart';
import 'search_bar.dart';
import 'toolbar.dart';
import 'navigation_bar.dart';
import 'tab_bar.dart';
import '../style/sf_symbol.dart';

/// Callback for search text changes with search results.
typedef SearchResultsBuilder =
    Widget Function(BuildContext context, String searchText);

/// Configuration for search integration.
class CNSearchConfig {
  const CNSearchConfig({
    this.placeholder = 'Search',
    this.searchIcon = const CNSymbol('magnifyingglass'),
    this.showsCancelButton = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.searchBarHeight = 50.0,
    this.onSearchTextChanged,
    this.onSearchSubmitted,
    this.onSearchCancelled,
    this.resultsBuilder,
    this.showResultsOverlay = true,
  });

  /// Placeholder text for the search bar.
  final String placeholder;

  /// Icon to display for the search button/tab.
  final CNSymbol searchIcon;

  /// Whether to show the cancel button in the search bar.
  final bool showsCancelButton;

  /// Duration of expand/collapse animation.
  final Duration animationDuration;

  /// Height of the search bar when expanded.
  final double searchBarHeight;

  /// Called when search text changes.
  final ValueChanged<String>? onSearchTextChanged;

  /// Called when search is submitted (return key pressed).
  final ValueChanged<String>? onSearchSubmitted;

  /// Called when search is cancelled.
  final VoidCallback? onSearchCancelled;

  /// Builder for search results overlay.
  final SearchResultsBuilder? resultsBuilder;

  /// Whether to show results overlay as user types.
  final bool showResultsOverlay;
}

/// A toolbar with integrated search functionality.
///
/// When the search action is tapped, the toolbar animates to show a search bar
/// with optional context indicator (showing the previous state).
class CNToolbarSearch extends StatefulWidget {
  /// Creates a search-enabled toolbar.
  const CNToolbarSearch({
    super.key,
    required this.leading,
    this.middle,
    this.trailing,
    required this.searchConfig,
    this.contextIcon,
    this.middleAlignment = CNToolbarMiddleAlignment.center,
    this.transparent = false,
    this.tint,
    this.height,
    this.pillHeight,
  });

  /// Leading actions (before search is activated).
  final List<CNToolbarAction>? leading;

  /// Middle actions (before search is activated).
  final List<CNToolbarAction>? middle;

  /// Trailing actions (before search is activated). Search button will be added here.
  final List<CNToolbarAction>? trailing;

  /// Search configuration.
  final CNSearchConfig searchConfig;

  /// Optional icon to show when search is active (represents previous context).
  final CNSymbol? contextIcon;

  /// Alignment of middle actions.
  final CNToolbarMiddleAlignment middleAlignment;

  /// Use completely transparent background.
  final bool transparent;

  /// Tint color for buttons and icons.
  final Color? tint;

  /// Fixed height.
  final double? height;

  /// Height of button group pills.
  final double? pillHeight;

  @override
  State<CNToolbarSearch> createState() => _CNToolbarSearchState();
}

class _CNToolbarSearchState extends State<CNToolbarSearch>
    with SingleTickerProviderStateMixin {
  bool _isSearchExpanded = false;
  String _searchText = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.searchConfig.animationDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _expandSearch() {
    setState(() => _isSearchExpanded = true);
    _animationController.forward();
  }

  void _collapseSearch() {
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isSearchExpanded = false;
          _searchText = '';
        });
      }
    });
    widget.searchConfig.onSearchCancelled?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_isSearchExpanded) {
      return _buildSearchView();
    } else {
      return _buildNormalView();
    }
  }

  Widget _buildNormalView() {
    // Add search button to trailing actions
    final searchAction = CNToolbarAction(
      icon: widget.searchConfig.searchIcon,
      onPressed: _expandSearch,
    );

    final trailingWithSearch = [...?widget.trailing, searchAction];

    return CNToolbar(
      leading: widget.leading,
      middle: widget.middle,
      trailing: trailingWithSearch,
      middleAlignment: widget.middleAlignment,
      transparent: widget.transparent,
      tint: widget.tint,
      height: widget.height,
      pillHeight: widget.pillHeight,
    );
  }

  Widget _buildSearchView() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          // Search results overlay
          if (widget.searchConfig.showResultsOverlay &&
              widget.searchConfig.resultsBuilder != null &&
              _searchText.isNotEmpty)
            Positioned.fill(
              child: widget.searchConfig.resultsBuilder!(context, _searchText),
            ),
          // Search bar with context icon
          SafeArea(
            top: false,
            child: Container(
              height: widget.searchConfig.searchBarHeight,
              padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
              child: Row(
                children: [
                  // Context icon (if provided)
                  if (widget.contextIcon != null)
                    SizedBox(
                      width: 80,
                      child: CNToolbar(
                        trailing: [
                          CNToolbarAction(
                            icon: widget.contextIcon,
                            onPressed: _collapseSearch,
                          ),
                        ],
                        height: 44,
                        transparent: true,
                      ),
                    ),
                  const SizedBox(width: 1),
                  // Search bar
                  Expanded(
                    child: CNSearchBar(
                      placeholder: widget.searchConfig.placeholder,
                      showsCancelButton: widget.searchConfig.showsCancelButton,
                      onTextChanged: (text) {
                        setState(() => _searchText = text);
                        widget.searchConfig.onSearchTextChanged?.call(text);
                      },
                      onSearchButtonClicked: (text) {
                        widget.searchConfig.onSearchSubmitted?.call(text);
                      },
                      onCancelButtonClicked: _collapseSearch,
                      height: widget.searchConfig.searchBarHeight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A navigation bar with integrated search functionality.
///
/// When the search action is tapped, the navigation bar transforms to show a search bar.
class CNNavigationBarSearch extends StatefulWidget {
  /// Creates a search-enabled navigation bar.
  const CNNavigationBarSearch({
    super.key,
    this.leading,
    this.title,
    this.trailing,
    required this.searchConfig,
    this.largeTitle = false,
    this.transparent = true,
    this.tint,
    this.height,
  });

  /// Leading actions (before search is activated).
  final List<CNNavigationBarAction>? leading;

  /// Title text (before search is activated).
  final String? title;

  /// Trailing actions (before search is activated). Search button will be added here.
  final List<CNNavigationBarAction>? trailing;

  /// Search configuration.
  final CNSearchConfig searchConfig;

  /// Use large title style.
  final bool largeTitle;

  /// Use completely transparent background.
  final bool transparent;

  /// Tint color for buttons and icons.
  final Color? tint;

  /// Fixed height.
  final double? height;

  @override
  State<CNNavigationBarSearch> createState() => _CNNavigationBarSearchState();
}

class _CNNavigationBarSearchState extends State<CNNavigationBarSearch>
    with SingleTickerProviderStateMixin {
  bool _isSearchExpanded = false;
  String _searchText = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.searchConfig.animationDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _expandSearch() {
    setState(() => _isSearchExpanded = true);
    _animationController.forward();
  }

  void _collapseSearch() {
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isSearchExpanded = false;
          _searchText = '';
        });
      }
    });
    widget.searchConfig.onSearchCancelled?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_isSearchExpanded) {
      return _buildSearchView();
    } else {
      return _buildNormalView();
    }
  }

  Widget _buildNormalView() {
    // Add search button to trailing actions
    final searchAction = CNNavigationBarAction(
      icon: widget.searchConfig.searchIcon,
      onPressed: _expandSearch,
    );

    final trailingWithSearch = [...?widget.trailing, searchAction];

    return CNNavigationBar(
      leading: widget.leading,
      title: widget.title,
      trailing: trailingWithSearch,
      largeTitle: widget.largeTitle,
      transparent: widget.transparent,
      tint: widget.tint,
      height: widget.height,
    );
  }

  Widget _buildSearchView() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          // Search results overlay
          if (widget.searchConfig.showResultsOverlay &&
              widget.searchConfig.resultsBuilder != null &&
              _searchText.isNotEmpty)
            Positioned.fill(
              child: widget.searchConfig.resultsBuilder!(context, _searchText),
            ),
          // Search bar
          SafeArea(
            top: false,
            child: CNSearchBar(
              placeholder: widget.searchConfig.placeholder,
              showsCancelButton: widget.searchConfig.showsCancelButton,
              onTextChanged: (text) {
                setState(() => _searchText = text);
                widget.searchConfig.onSearchTextChanged?.call(text);
              },
              onSearchButtonClicked: (text) {
                widget.searchConfig.onSearchSubmitted?.call(text);
              },
              onCancelButtonClicked: _collapseSearch,
              height: widget.searchConfig.searchBarHeight,
            ),
          ),
        ],
      ),
    );
  }
}

/// A tab bar with integrated search functionality.
///
/// The search tab can be positioned anywhere in the tab bar. When tapped,
/// it expands to show a search bar with optional context indicator showing
/// the previously active tab icon.
class CNTabBarSearch extends StatefulWidget {
  /// Creates a search-enabled tab bar.
  const CNTabBarSearch({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.searchConfig,
    this.searchIndex,
    this.split = false,
    this.rightCount = 0,
    this.shrinkCentered = false,
    this.backgroundColor,
    this.height,
  });

  /// Tab bar items. Search tab will be added automatically if searchIndex is null.
  final List<CNTabBarItem> items;

  /// Currently selected tab index.
  final int currentIndex;

  /// Called when a tab is tapped (excluding search tab).
  final ValueChanged<int> onTap;

  /// Search configuration.
  final CNSearchConfig searchConfig;

  /// Index where search tab should be placed. If null, adds to the end.
  final int? searchIndex;

  /// Use split mode (visual separation).
  final bool split;

  /// Number of tabs on the right side (when split is true).
  final int rightCount;

  /// Shrink centered tabs.
  final bool shrinkCentered;

  /// Background color.
  final Color? backgroundColor;

  /// Fixed height.
  final double? height;

  @override
  State<CNTabBarSearch> createState() => _CNTabBarSearchState();
}

class _CNTabBarSearchState extends State<CNTabBarSearch>
    with SingleTickerProviderStateMixin {
  bool _isSearchExpanded = false;
  String _searchText = '';
  int _lastTabIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _lastTabIndex = widget.currentIndex;
    _animationController = AnimationController(
      vsync: this,
      duration: widget.searchConfig.animationDuration,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CNTabBarSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Track the last non-search tab
    if (widget.currentIndex != _getSearchTabIndex() && !_isSearchExpanded) {
      _lastTabIndex = widget.currentIndex;
    }
  }

  int _getSearchTabIndex() {
    return widget.searchIndex ?? widget.items.length;
  }

  CNSymbol _getLastTabIcon() {
    if (_lastTabIndex >= 0 && _lastTabIndex < widget.items.length) {
      return widget.items[_lastTabIndex].icon ?? const CNSymbol('house.fill');
    }
    return widget.items[0].icon ?? const CNSymbol('house.fill');
  }

  void _expandSearch() {
    setState(() {
      _lastTabIndex = widget.currentIndex;
      _isSearchExpanded = true;
    });
    _animationController.forward();
  }

  void _collapseSearch() {
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isSearchExpanded = false;
          _searchText = '';
        });
      }
    });
    widget.onTap(_lastTabIndex);
    widget.searchConfig.onSearchCancelled?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_isSearchExpanded) {
      return _buildSearchView();
    } else {
      return _buildNormalView();
    }
  }

  Widget _buildNormalView() {
    // Add search tab to items
    final searchTab = CNTabBarItem(
      label: 'Search',
      icon: widget.searchConfig.searchIcon,
    );

    final searchTabIndex = _getSearchTabIndex();
    final itemsWithSearch = <CNTabBarItem>[
      ...widget.items.take(searchTabIndex),
      searchTab,
      ...widget.items.skip(searchTabIndex),
    ];

    return CNTabBar(
      items: itemsWithSearch,
      currentIndex: widget.currentIndex,
      split: widget.split,
      rightCount: widget.rightCount,
      shrinkCentered: widget.shrinkCentered,
      backgroundColor: widget.backgroundColor,
      height: widget.height,
      onTap: (index) {
        if (index == searchTabIndex) {
          _expandSearch();
        } else {
          // Adjust index if after search tab
          final adjustedIndex = index > searchTabIndex ? index - 1 : index;
          widget.onTap(adjustedIndex);
        }
      },
    );
  }

  Widget _buildSearchView() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: Stack(
        children: [
          // Search results overlay
          if (widget.searchConfig.showResultsOverlay &&
              widget.searchConfig.resultsBuilder != null &&
              _searchText.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: widget.searchConfig.searchBarHeight,
              top: 0,
              child: widget.searchConfig.resultsBuilder!(context, _searchText),
            ),
          // Search bar with context icon
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Container(
                height: widget.searchConfig.searchBarHeight,
                padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                child: Row(
                  children: [
                    // Last tab icon
                    SizedBox(
                      width: 80,
                      child: CNToolbar(
                        trailing: [
                          CNToolbarAction(
                            icon: _getLastTabIcon(),
                            onPressed: _collapseSearch,
                          ),
                        ],
                        height: 44,
                        transparent: true,
                      ),
                    ),
                    const SizedBox(width: 1),
                    // Search bar
                    Expanded(
                      child: CNSearchBar(
                        placeholder: widget.searchConfig.placeholder,
                        showsCancelButton:
                            widget.searchConfig.showsCancelButton,
                        onTextChanged: (text) {
                          setState(() => _searchText = text);
                          widget.searchConfig.onSearchTextChanged?.call(text);
                        },
                        onSearchButtonClicked: (text) {
                          widget.searchConfig.onSearchSubmitted?.call(text);
                        },
                        onCancelButtonClicked: _collapseSearch,
                        height: widget.searchConfig.searchBarHeight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
