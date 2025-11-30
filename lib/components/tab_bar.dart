import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'; 
import 'package:flutter/services.dart';

import '../channel/params.dart';
import '../style/sf_symbol.dart';
import 'search_config.dart';
import 'search_bar.dart';
import 'toolbar.dart';

/// Immutable data describing a single tab bar item.
class CNTabBarItem {
  /// Creates a tab bar item description.
  const CNTabBarItem({
    this.label,
    this.icon,
    this.image,
    this.imageSize,
    this.badgeValue,
    this.badgeColor,
    this.labelSize,
    this.iconSize,
  }) : assert(
         icon == null || image == null,
         'Cannot provide both icon and image',
       );

  /// Optional tab item label.
  final String? label;

  /// Font size for the label text in points.
  /// If null, uses the platform default size.
  final double? labelSize;

  /// Optional SF Symbol for the item.
  final CNSymbol? icon;

  /// Size for the icon in points.
  /// If null, uses the icon's intrinsic size or platform default.
  /// This overrides the size specified in the CNSymbol.
  final double? iconSize;

  /// Optional custom image provider for the item.
  /// Cannot be used together with [icon].
  final ImageProvider? image;

  /// Size for the custom image in points. Only applies when [image] is used.
  /// If not specified, the image will use its intrinsic size or be scaled to fit.
  final double? imageSize;

  /// Badge value to display on the tab.
  ///
  /// Supports automatic formatting:
  /// - Numbers are formatted (e.g., 150 becomes "99+" if over 99)
  /// - Use "!" for critical alerts
  /// - Use empty string or null to hide the badge
  ///
  /// Pass either a String or an int:
  /// ```dart
  /// badgeValue: '5'      // Shows "5"
  /// badgeValue: 150      // Shows "99+"
  /// badgeValue: '!'      // Shows "!" for alerts
  /// ```
  final dynamic badgeValue;

  /// Optional custom badge background color.
  /// If null, uses the system default red color for badges.
  ///
  /// Examples:
  /// ```dart
  /// badgeColor: CupertinoColors.systemRed      // Default critical (red)
  /// badgeColor: CupertinoColors.systemBlue     // Informational (blue)
  /// badgeColor: CupertinoColors.systemGreen    // Success (green)
  /// badgeColor: CupertinoColors.systemOrange   // Warning (orange)
  /// ```
  final Color? badgeColor;

  /// Formats a badge value for display.
  /// Numbers over 99 are shown as "99+".
  /// Strings are returned as-is.
  String? get formattedBadgeValue {
    if (badgeValue == null) return null;
    if (badgeValue is int) {
      final count = badgeValue as int;
      if (count <= 0) return null;
      if (count > 99) return '99+';
      return count.toString();
    }
    final str = badgeValue.toString();
    return str.isEmpty ? null : str;
  }
}

/// A Cupertino-native tab bar. Uses native UITabBar/NSTabView style visuals.
class CNTabBar extends StatefulWidget {
  /// Creates a Cupertino-native tab bar.
  const CNTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.tint,
    this.backgroundColor,
    this.iconSize,
    this.height,
    this.split = false,
    this.rightCount = 1,
    this.shrinkCentered = true,
    this.splitSpacing = 8.0,
    this.leadingAccessory,
    this.trailingAccessory,
    this.showSearchField = false,
    this.searchPlaceholder,
    this.onSearchChanged,
    this.onSearchSubmitted,
  }) : searchConfig = null,
       searchIndex = null,
       _isSearchEnabled = false;

  /// Creates a tab bar with integrated search functionality.
  ///
  /// When the search tab is tapped, it expands to show a search bar with
  /// the previously active tab icon for context. Search tab is automatically
  /// added to the items list.
  ///
  /// Example:
  /// ```dart
  /// CNTabBar.search(
  ///   items: [
  ///     CNTabBarItem(label: 'Home', icon: CNSymbol('house.fill')),
  ///     CNTabBarItem(label: 'Library', icon: CNSymbol('music.note.list')),
  ///   ],
  ///   currentIndex: _currentIndex,
  ///   onTap: (index) => setState(() => _currentIndex = index),
  ///   searchConfig: CNSearchConfig(
  ///     placeholder: 'Search',
  ///     onSearchTextChanged: (text) => print(text),
  ///     resultsBuilder: (context, text) => SearchResults(text),
  ///   ),
  ///   split: true,
  ///   rightCount: 1, // Search will be on the right
  /// )
  /// ```
  const CNTabBar.search({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.searchConfig,
    this.searchIndex,
    this.tint,
    this.backgroundColor,
    this.iconSize,
    this.height,
    this.split = false,
    this.rightCount = 0,
    this.shrinkCentered = false,
    this.splitSpacing = 8.0,
  }) : leadingAccessory = null,
       trailingAccessory = null,
       showSearchField = false,
       searchPlaceholder = null,
       onSearchChanged = null,
       onSearchSubmitted = null,
       _isSearchEnabled = true;

  /// Items to display in the tab bar.
  /// For search-enabled tab bar, search tab is added automatically.
  final List<CNTabBarItem> items;

  /// The index of the currently selected item.
  final int currentIndex;

  /// Called when the user selects a new item.
  final ValueChanged<int> onTap;

  /// Accent/tint color.
  final Color? tint;

  /// Background color for the bar.
  final Color? backgroundColor;

  /// Default icon size when item icon does not specify one.
  final double? iconSize;

  /// Fixed height; if null uses intrinsic height reported by native view.
  final double? height;

  /// When true, splits items between left and right sections.
  final bool split;

  /// How many trailing items to pin right when [split] is true.
  final int rightCount; // how many trailing items to pin right when split

  /// When true, centers the split groups more tightly.
  final bool shrinkCentered;

  /// Gap between left/right halves when split.
  final double splitSpacing; // gap between left/right halves when split

  /// Optional leading accessory (button or control) to display before tabs.
  /// Typically used for menu buttons, filters, or navigation controls.
  ///
  /// Example:
  /// ```dart
  /// leadingAccessory: CNButton(
  ///   icon: CNSymbol('line.3.horizontal'),
  ///   style: CNButtonStyle.borderless,
  ///   onTap: () => showMenu(),
  /// )
  /// ```
  final Widget? leadingAccessory;

  /// Optional trailing accessory (button or control) to display after tabs.
  /// Typically used for compose, add, or action buttons.
  ///
  /// Example:
  /// ```dart
  /// trailingAccessory: CNButton(
  ///   icon: CNSymbol('square.and.pencil'),
  ///   style: CNButtonStyle.borderless,
  ///   onTap: () => compose(),
  /// )
  /// ```
  final Widget? trailingAccessory;

  /// When true, displays a search field in the tab bar.
  /// The search field can be positioned inline with tabs or as a separate row.
  final bool showSearchField;

  /// Placeholder text for the search field.
  /// Defaults to "Search" if not specified.
  final String? searchPlaceholder;

  /// Called when the search text changes.
  final ValueChanged<String>? onSearchChanged;

  /// Called when the user submits the search (e.g., taps return key).
  final ValueChanged<String>? onSearchSubmitted;

  /// Search configuration (only for search-enabled tab bar).
  final CNSearchConfig? searchConfig;

  /// Index where search tab should be placed. If null, adds to the end.
  final int? searchIndex;

  /// Internal flag to indicate search functionality is enabled.
  final bool _isSearchEnabled;

  @override
  State<CNTabBar> createState() {
    if (_isSearchEnabled) {
      return _CNTabBarSearchState();
    }
    return _CNTabBarState();
  }
}

class _CNTabBarState extends State<CNTabBar> {
  MethodChannel? _channel;
  int? _lastIndex;
  int? _lastTint;
  int? _lastBg;
  bool? _lastIsDark;
  double? _intrinsicHeight;
  double? _intrinsicWidth;
  List<String>? _lastLabels;
  List<double>? _lastLabelSizes;
  List<String>? _lastSymbols;
  List<String>? _lastImageKeys;
  List<String>? _lastBadges;
  bool? _lastSplit;
  int? _lastRightCount;
  double? _lastSplitSpacing;

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;
  Color? get _effectiveTint =>
      widget.tint ?? CupertinoTheme.of(context).primaryColor;

  @override
  void didUpdateWidget(covariant CNTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!(defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS)) {
      // Simple Flutter fallback using CupertinoTabBar for non-Apple platforms.
      return SizedBox(
        height: widget.height,
        child: CupertinoTabBar(
          items: [
            for (final item in widget.items)
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.circle),
                label: item.label,
              ),
          ],
          currentIndex: widget.currentIndex,
          onTap: widget.onTap,
          backgroundColor: widget.backgroundColor,
          inactiveColor: CupertinoColors.inactiveGray,
          activeColor: widget.tint ?? CupertinoTheme.of(context).primaryColor,
        ),
      );
    }

    final labels = widget.items.map((e) => e.label ?? '').toList();
    final labelSizes = widget.items.map((e) => e.labelSize ?? 0.0).toList();
    final symbols = widget.items.map((e) => e.icon?.name ?? '').toList();
    final sizes = widget.items
        .map((e) => (e.iconSize ?? widget.iconSize ?? e.icon?.size))
        .toList();
    final colors = widget.items
        .map((e) => resolveColorToArgb(e.icon?.color, context))
        .toList();
    final badges = widget.items
        .map((e) => e.formattedBadgeValue ?? '')
        .toList();
    final badgeColors = widget.items
        .map((e) => resolveColorToArgb(e.badgeColor, context))
        .toList();

    // Build image keys and sizes for items with custom images
    final imageKeys = widget.items.map((e) {
      if (e.image != null) {
        // Generate a unique key for the image
        return e.image.hashCode.toString();
      }
      return '';
    }).toList();

    final imageSizes = widget.items.map((e) => e.imageSize).toList();

    final creationParams = <String, dynamic>{
      'labels': labels,
      'labelSizes': labelSizes,
      'sfSymbols': symbols,
      'sfSymbolSizes': sizes,
      'sfSymbolColors': colors,
      'badges': badges,
      'badgeColors': badgeColors,
      'imageKeys': imageKeys,
      'imageSizes': imageSizes,
      'selectedIndex': widget.currentIndex,
      'isDark': _isDark,
      'split': widget.split,
      'rightCount': widget.rightCount,
      'splitSpacing': widget.splitSpacing,
      'style': encodeStyle(context, tint: _effectiveTint)
        ..addAll({
          if (widget.backgroundColor != null)
            'backgroundColor': resolveColorToArgb(
              widget.backgroundColor,
              context,
            ),
        }),
    };

    final viewType = 'CupertinoNativeTabBar';
    final platformView = defaultTargetPlatform == TargetPlatform.iOS
        ? UiKitView(
            viewType: viewType,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onCreated,
          )
        : AppKitView(
            viewType: viewType,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onCreated,
          );

    final h = widget.height ?? _intrinsicHeight ?? 50.0;

    Widget tabBarWidget;
    if (!widget.split && widget.shrinkCentered) {
      final w = _intrinsicWidth;
      tabBarWidget = SizedBox(height: h, width: w, child: platformView);
    } else {
      tabBarWidget = SizedBox(height: h, child: platformView);
    }

    // Wrap with accessories and/or search field if needed
    final hasLeadingAccessory = widget.leadingAccessory != null;
    final hasTrailingAccessory = widget.trailingAccessory != null;
    final hasSearchField = widget.showSearchField;

    if (!hasLeadingAccessory && !hasTrailingAccessory && !hasSearchField) {
      return tabBarWidget;
    }

    // Build the complete tab bar with accessories and/or search
    return _buildTabBarWithAccessories(tabBarWidget, h);
  }

  Widget _buildTabBarWithAccessories(Widget tabBar, double height) {
    final children = <Widget>[];

    // Add search field row if enabled
    if (widget.showSearchField) {
      children.add(_buildSearchRow(height));
    }

    // Build main tab bar row with accessories
    final tabBarRow = <Widget>[];

    if (widget.leadingAccessory != null) {
      tabBarRow.add(
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 4),
          child: SizedBox(
            height: height,
            child: Center(child: widget.leadingAccessory!),
          ),
        ),
      );
    }

    tabBarRow.add(Expanded(child: tabBar));

    if (widget.trailingAccessory != null) {
      tabBarRow.add(
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 8),
          child: SizedBox(
            height: height,
            child: Center(child: widget.trailingAccessory!),
          ),
        ),
      );
    }

    children.add(
      SizedBox(
        height: height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: tabBarRow,
        ),
      ),
    );

    return Column(mainAxisSize: MainAxisSize.min, children: children);
  }

  Widget _buildSearchRow(double tabBarHeight) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color:
            widget.backgroundColor ??
            CupertinoColors.systemBackground.resolveFrom(context),
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.separator.resolveFrom(context),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          if (widget.leadingAccessory != null) ...[
            SizedBox(height: 40, child: widget.leadingAccessory!),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: CupertinoSearchTextField(
              placeholder: widget.searchPlaceholder ?? 'Search',
              onChanged: widget.onSearchChanged,
              onSubmitted: widget.onSearchSubmitted,
              backgroundColor: CupertinoColors.tertiarySystemFill.resolveFrom(
                context,
              ),
            ),
          ),
          if (widget.trailingAccessory != null) ...[
            const SizedBox(width: 8),
            SizedBox(height: 40, child: widget.trailingAccessory!),
          ],
        ],
      ),
    );
  }

  void _onCreated(int id) {
    final ch = MethodChannel('CupertinoNativeTabBar_$id');
    _channel = ch;
    ch.setMethodCallHandler(_onMethodCall);
    _lastIndex = widget.currentIndex;
    _lastTint = resolveColorToArgb(_effectiveTint, context);
    _lastBg = resolveColorToArgb(widget.backgroundColor, context);
    _lastIsDark = _isDark;
    _requestIntrinsicSize();
    _cacheItems();
    _lastSplit = widget.split;
    _lastRightCount = widget.rightCount;
    _lastSplitSpacing = widget.splitSpacing;
    _loadAndSendImages();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'valueChanged') {
      final args = call.arguments as Map?;
      final idx = (args?['index'] as num?)?.toInt();
      if (idx != null) {
        // Always call onTap, even if the index hasn't changed
        // This allows users to respond to taps on the currently selected tab
        widget.onTap(idx);
        _lastIndex = idx;
      }
    }
    return null;
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;
    // Capture theme-dependent values before awaiting
    final idx = widget.currentIndex;
    final tint = resolveColorToArgb(_effectiveTint, context);
    final bg = resolveColorToArgb(widget.backgroundColor, context);
    if (_lastIndex != idx) {
      await ch.invokeMethod('setSelectedIndex', {'index': idx});
      _lastIndex = idx;
    }

    final style = <String, dynamic>{};
    if (_lastTint != tint && tint != null) {
      style['tint'] = tint;
      _lastTint = tint;
    }
    if (_lastBg != bg && bg != null) {
      style['backgroundColor'] = bg;
      _lastBg = bg;
    }
    if (style.isNotEmpty) {
      await ch.invokeMethod('setStyle', style);
    }

    // Items update (for hot reload or dynamic changes)
    final labels = widget.items.map((e) => e.label ?? '').toList();
    final labelSizes = widget.items.map((e) => e.labelSize ?? 0.0).toList();
    final symbols = widget.items.map((e) => e.icon?.name ?? '').toList();
    final imageKeys = widget.items
        .map((e) => e.image?.hashCode.toString() ?? '')
        .toList();
    final badges = widget.items
        .map((e) => e.formattedBadgeValue ?? '')
        .toList();
    final badgeColors = widget.items
        .map((e) => resolveColorToArgb(e.badgeColor, context))
        .toList();
    if (_lastLabels?.join('|') != labels.join('|') ||
        _lastLabelSizes?.join('|') != labelSizes.join('|') ||
        _lastSymbols?.join('|') != symbols.join('|') ||
        _lastImageKeys?.join('|') != imageKeys.join('|') ||
        _lastBadges?.join('|') != badges.join('|')) {
      await ch.invokeMethod('setItems', {
        'labels': labels,
        'labelSizes': labelSizes,
        'sfSymbols': symbols,
        'imageKeys': imageKeys,
        'badges': badges,
        'badgeColors': badgeColors,
        'selectedIndex': widget.currentIndex,
      });
      _lastLabels = labels;
      _lastLabelSizes = labelSizes;
      _lastSymbols = symbols;
      _lastImageKeys = imageKeys;
      _lastBadges = badges;
      // Reload images if they changed
      _loadAndSendImages();
      // Re-measure width in case content changed
      _requestIntrinsicSize();
    }

    // Layout updates (split / insets)
    if (_lastSplit != widget.split ||
        _lastRightCount != widget.rightCount ||
        _lastSplitSpacing != widget.splitSpacing) {
      await ch.invokeMethod('setLayout', {
        'split': widget.split,
        'rightCount': widget.rightCount,
        'splitSpacing': widget.splitSpacing,
        'selectedIndex': widget.currentIndex,
      });
      _lastSplit = widget.split;
      _lastRightCount = widget.rightCount;
      _lastSplitSpacing = widget.splitSpacing;
      _requestIntrinsicSize();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBrightnessIfNeeded();
    _syncPropsToNativeIfNeeded();
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;
    final isDark = _isDark;
    if (_lastIsDark != isDark) {
      await ch.invokeMethod('setBrightness', {'isDark': isDark});
      _lastIsDark = isDark;
    }
  }

  void _cacheItems() {
    _lastLabels = widget.items.map((e) => e.label ?? '').toList();
    _lastLabelSizes = widget.items.map((e) => e.labelSize ?? 0.0).toList();
    _lastSymbols = widget.items.map((e) => e.icon?.name ?? '').toList();
    _lastImageKeys = widget.items
        .map((e) => e.image?.hashCode.toString() ?? '')
        .toList();
    _lastBadges = widget.items.map((e) => e.formattedBadgeValue ?? '').toList();
  }

  Future<void> _loadAndSendImages() async {
    final ch = _channel;
    if (ch == null) return;

    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      if (item.image != null) {
        try {
          final imageData = await _loadImageAsBytes(item.image!);
          if (imageData != null && mounted) {
            await ch.invokeMethod('setCustomImage', {
              'index': i,
              'imageData': imageData,
              if (item.imageSize != null) 'imageSize': item.imageSize,
            });
          }
        } catch (e) {
          // Silently fail if image loading fails
        }
      }
    }
  }

  Future<Uint8List?> _loadImageAsBytes(ImageProvider imageProvider) async {
    final imageStream = imageProvider.resolve(const ImageConfiguration());
    final completer = Completer<Uint8List?>();

    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool _) async {
        try {
          final byteData = await info.image.toByteData(
            format: ui.ImageByteFormat.png,
          );
          if (byteData != null) {
            completer.complete(byteData.buffer.asUint8List());
          } else {
            completer.complete(null);
          }
        } catch (e) {
          completer.complete(null);
        } finally {
          imageStream.removeListener(listener);
        }
      },
      onError: (dynamic exception, StackTrace? stackTrace) {
        completer.complete(null);
        imageStream.removeListener(listener);
      },
    );

    imageStream.addListener(listener);
    return completer.future;
  }

  Future<void> _requestIntrinsicSize() async {
    if (widget.height != null) return;
    final ch = _channel;
    if (ch == null) return;
    try {
      final size = await ch.invokeMethod<Map>('getIntrinsicSize');
      final h = (size?['height'] as num?)?.toDouble();
      final w = (size?['width'] as num?)?.toDouble();
      if (!mounted) return;
      setState(() {
        if (h != null && h > 0) _intrinsicHeight = h;
        if (w != null && w > 0) _intrinsicWidth = w;
      });
    } catch (_) {}
  }
}

/// State class for search-enabled tab bar.
class _CNTabBarSearchState extends State<CNTabBar>
    with SingleTickerProviderStateMixin {
  bool _isSearchExpanded = false;
  String _searchText = '';
  int _lastTabIndex = 0;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _lastTabIndex = widget.currentIndex;
    _animationController = AnimationController(
      vsync: this,
      duration: widget.searchConfig!.animationDuration,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CNTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Track the last non-search tab
    if (widget.currentIndex != _getSearchTabIndex() && !_isSearchExpanded) {
      setState(() {
        _lastTabIndex = widget.currentIndex;
      });
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
    // Call onSearchActivated callback
    widget.searchConfig!.onSearchActivated?.call();
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
    widget.searchConfig!.onSearchCancelled?.call();
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
      icon: widget.searchConfig!.searchIcon,
    );

    final searchTabIndex = _getSearchTabIndex();
    final itemsWithSearch = <CNTabBarItem>[
      ...widget.items.take(searchTabIndex),
      searchTab,
      ...widget.items.skip(searchTabIndex),
    ];

    // Adjust currentIndex to account for the inserted search tab
    final adjustedCurrentIndex = widget.currentIndex >= searchTabIndex
        ? widget.currentIndex + 1
        : widget.currentIndex;

    return CNTabBar(
      items: itemsWithSearch,
      currentIndex: adjustedCurrentIndex,
      split: widget.split,
      rightCount: widget.rightCount,
      shrinkCentered: widget.shrinkCentered,
      backgroundColor: widget.backgroundColor,
      height: widget.height,
      tint: widget.tint,
      iconSize: widget.iconSize,
      splitSpacing: widget.splitSpacing,
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
    final config = widget.searchConfig!;

    return SlideTransition(
      position: _slideAnimation,
      child: Stack(
        children: [
          // Search results overlay
          if (config.showResultsOverlay &&
              config.resultsBuilder != null &&
              _searchText.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: config.searchBarHeight,
              top: 0,
              child: config.resultsBuilder!(context, _searchText),
            ),
          // Search bar with context icon
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Container(
                height: config.searchBarHeight,
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
                        placeholder: config.placeholder,
                        showsCancelButton: config.showsCancelButton,
                        onTextChanged: (text) {
                          setState(() => _searchText = text);
                          config.onSearchTextChanged?.call(text);
                        },
                        onSearchButtonClicked: (text) {
                          config.onSearchSubmitted?.call(text);
                        },
                        onCancelButtonClicked: _collapseSearch,
                        height: config.searchBarHeight,
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
