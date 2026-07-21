import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../channel/params.dart';
import '../style/sf_symbol.dart';
import 'popup_menu_button.dart';
import 'pull_down_button.dart';
import 'search_config.dart';
import 'search_bar.dart';

/// Alignment options for middle toolbar actions.
enum CNToolbarMiddleAlignment {
  /// Position middle close to leading (left side).
  leading,

  /// Position middle in the center.
  center,

  /// Position middle close to trailing (right side).
  trailing,
}

/// Action item for toolbar trailing/leading positions.
class CNToolbarAction {
  /// Creates a toolbar action item.
  const CNToolbarAction({
    this.icon, 
    this.label, 
    this.onPressed, 
    this.padding,
    this.labelSize,
    this.iconSize,
    this.tint,
    this.badgeValue,
    this.badgeColor,
  }) : popupMenuItems = null,
       onPopupMenuSelected = null,
       _isFixedSpace = false,
       _isFlexibleSpace = false,
       _usePopupMenuButton = false,
       _usePullDownButton = false;

  /// Creates a toolbar action with a popup menu.
  const CNToolbarAction.popupMenu({
    this.icon,
    this.label,
    required this.popupMenuItems,
    required this.onPopupMenuSelected,
    this.padding,
    this.labelSize,
    this.iconSize,
    this.tint,
    this.badgeValue,
    this.badgeColor,
  }) : onPressed = null,
       _isFixedSpace = false,
       _isFlexibleSpace = false,
       _usePopupMenuButton = false,
       _usePullDownButton = false;

  /// Creates a toolbar action with a CNPopupMenuButton.
  /// This provides a more native-looking popup menu button with built-in styling.
  const CNToolbarAction.popupMenuButton({
    this.icon,
    this.label,
    required this.popupMenuItems,
    required this.onPopupMenuSelected,
    this.padding,
    this.labelSize,
    this.iconSize,
    this.tint,
    this.badgeValue,
    this.badgeColor,
  }) : onPressed = null,
       _isFixedSpace = false,
       _isFlexibleSpace = false,
       _usePopupMenuButton = true,
       _usePullDownButton = false;

  /// Creates a toolbar action with a CNPullDownButton.
  /// This provides Apple Design Guidelines compliant pull-down menus that appear below the button.
  const CNToolbarAction.pullDownButton({
    this.icon,
    this.label,
    required this.popupMenuItems,
    required this.onPopupMenuSelected,
    this.padding,
    this.labelSize,
    this.iconSize,
    this.tint,
    this.badgeValue,
    this.badgeColor,
  }) : onPressed = null,
       _isFixedSpace = false,
       _isFlexibleSpace = false,
       _usePopupMenuButton = false,
       _usePullDownButton = true;

  /// Creates a fixed space item with specific width.
  const CNToolbarAction.fixedSpace(double width)
    : icon = null,
      label = null,
      onPressed = null,
      popupMenuItems = null,
      onPopupMenuSelected = null,
      padding = width,
      labelSize = null,
      iconSize = null,
      tint = null,
      badgeValue = null,
      badgeColor = null,
      _isFixedSpace = true,
      _isFlexibleSpace = false,
      _usePopupMenuButton = false,
      _usePullDownButton = false;

  /// Creates a flexible space that expands to fill available space.
  const CNToolbarAction.flexibleSpace()
    : icon = null,
      label = null,
      onPressed = null,
      popupMenuItems = null,
      onPopupMenuSelected = null,
      padding = null,
      labelSize = null,
      iconSize = null,
      tint = null,
      badgeValue = null,
      badgeColor = null,
      _isFixedSpace = false,
      _isFlexibleSpace = true,
      _usePopupMenuButton = false,
      _usePullDownButton = false;

  /// SF Symbol icon for the action.
  final CNSymbol? icon;

  /// Text label for the action (used if icon is null).
  final String? label;

  /// Font size for the label text in points.
  /// If null, uses the platform default size.
  final double? labelSize;

  /// Size for the icon in points.
  /// If null, uses the icon's intrinsic size or platform default.
  /// This overrides the size specified in the CNSymbol.
  final double? iconSize;

  /// Callback when the action is tapped.
  final VoidCallback? onPressed;

  /// Popup menu items to display when the action is pressed.
  /// If provided, this action will show a popup menu instead of calling onPressed.
  final List<CNPopupMenuEntry>? popupMenuItems;

  /// Called when a popup menu item is selected.
  /// The index corresponds to the position in the popupMenuItems list.
  final ValueChanged<int>? onPopupMenuSelected;

  /// Custom padding for this action. If null, uses default platform padding.
  /// Specified in logical pixels. For fixed space, this is the width of the space.
  final double? padding;

  /// Tint color for this action's icon or label.
  /// If null, uses the toolbar's global tint color.
  final Color? tint;

  /// Badge value to display on the action (e.g., notification count, status text).
  /// If null, no badge is shown.
  final String? badgeValue;

  /// Background color for the badge.
  /// If null, uses the platform default badge color (typically red).
  final Color? badgeColor;

  /// Internal flag to indicate this is a fixed space item.
  final bool _isFixedSpace;

  /// Internal flag to indicate this is a flexible space item.
  final bool _isFlexibleSpace;

  /// Internal flag to indicate this uses CNPopupMenuButton.
  final bool _usePopupMenuButton;

  /// Internal flag to indicate this uses CNPullDownButton.
  final bool _usePullDownButton;

  /// Returns true if this is a spacer (fixed or flexible).
  bool get isSpacer => _isFixedSpace || _isFlexibleSpace;

  /// Returns true if this is a fixed space item.
  bool get isFixedSpace => _isFixedSpace;

  /// Returns true if this is a flexible space item.
  bool get isFlexibleSpace => _isFlexibleSpace;

  /// Returns true if this action has a popup menu.
  bool get hasPopupMenu => popupMenuItems != null && popupMenuItems!.isNotEmpty;

  /// Returns true if this action uses CNPopupMenuButton.
  bool get usePopupMenuButton => _usePopupMenuButton;

  /// Returns true if this action uses CNPullDownButton.
  bool get usePullDownButton => _usePullDownButton;
}

/// A Cupertino-native toolbar with liquid glass translucent effect.
///
/// Uses native UINavigationBar on iOS and NSToolbar on macOS for authentic
/// translucent blur effects. The toolbar automatically blurs content
/// behind it, creating the signature iOS/macOS "liquid glass" appearance.
class CNToolbar extends StatefulWidget {
  /// Creates a native translucent toolbar.
  const CNToolbar({
    super.key,
    this.leading,
    this.middle,
    this.trailing,
    this.middleAlignment = CNToolbarMiddleAlignment.center,
    this.transparent = false,
    this.tint,
    this.height,
    this.pillHeight,
  }) : searchConfig = null,
       contextIcon = null,
       _isSearchEnabled = false;

  /// Creates a toolbar with integrated search functionality.
  ///
  /// When the search icon is tapped, the toolbar animates to show a search bar
  /// with optional context indicator. Search button is automatically added to trailing actions.
  ///
  /// Example:
  /// ```dart
  /// CNToolbar.search(
  ///   leading: [CNToolbarAction(icon: CNSymbol('star.fill'), onPressed: () {})],
  ///   searchConfig: CNSearchConfig(
  ///     placeholder: 'Search',
  ///     onSearchTextChanged: (text) => print(text),
  ///     resultsBuilder: (context, text) => SearchResults(text),
  ///   ),
  ///   contextIcon: CNSymbol('apps.iphone'),
  /// )
  /// ```
  const CNToolbar.search({
    super.key,
    this.leading,
    this.middle,
    this.trailing,
    required this.searchConfig,
    this.contextIcon,
    this.middleAlignment = CNToolbarMiddleAlignment.center,
    this.transparent = false,
    this.tint,
    this.height,
    this.pillHeight,
  }) : _isSearchEnabled = true;

  /// Leading actions (buttons/icons on the left).
  final List<CNToolbarAction>? leading;

  /// Middle actions (buttons/icons in the center).
  final List<CNToolbarAction>? middle;

  /// Trailing actions (buttons/icons on the right).
  /// For search-enabled toolbar, search button is added automatically.
  final List<CNToolbarAction>? trailing;

  /// Alignment of middle actions.
  /// - [CNToolbarMiddleAlignment.leading]: Position close to leading
  /// - [CNToolbarMiddleAlignment.center]: Position in center (default)
  /// - [CNToolbarMiddleAlignment.trailing]: Position close to trailing
  final CNToolbarMiddleAlignment middleAlignment;

  /// Use completely transparent background (no blur).
  final bool transparent;

  /// Tint color for buttons and icons.
  final Color? tint;

  /// Fixed height (if null, uses intrinsic platform height).
  final double? height;

  /// Height of button group pills. If null, uses default platform height.
  /// Controls the vertical size of the pill-shaped button groups.
  final double? pillHeight;

  /// Search configuration (only for search-enabled toolbar).
  final CNSearchConfig? searchConfig;

  /// Optional icon to show when search is active (represents previous context).
  final CNSymbol? contextIcon;

  /// Internal flag to indicate search functionality is enabled.
  final bool _isSearchEnabled;

  @override
  State<CNToolbar> createState() {
    if (_isSearchEnabled) {
      return _CNToolbarSearchState();
    }
    return _CNToolbarState();
  }
}

class _CNToolbarState extends State<CNToolbar> {
  MethodChannel? _channel;
  double? _intrinsicHeight;
  bool? _lastIsDark;
  String? _lastTitle;
  int? _lastTint;
  bool? _lastTransparent;

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;
  Color? get _effectiveTint =>
      widget.tint ?? CupertinoTheme.of(context).primaryColor;

  @override
  void didUpdateWidget(covariant CNToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBrightnessIfNeeded();
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
      // Fallback for non-Apple platforms
      return CupertinoNavigationBar(
        leading: widget.leading != null && widget.leading!.isNotEmpty
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: widget.leading!.first.onPressed,
                child: Icon(CupertinoIcons.back),
              )
            : null,
        trailing: widget.trailing != null && widget.trailing!.isNotEmpty
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: widget.trailing!.first.onPressed,
                child: Icon(CupertinoIcons.ellipsis_circle),
              )
            : null,
        backgroundColor: widget.transparent
            ? CupertinoColors.transparent
            : null,
      );
    }

    final leadingIcons =
        widget.leading
            ?.map((e) => e.isSpacer ? '' : (e.icon?.name ?? ''))
            .toList() ??
        [];
    final leadingLabels =
        widget.leading
            ?.map((e) => e.isSpacer ? '' : (e.label ?? ''))
            .toList() ??
        [];
    final leadingPaddings =
        widget.leading?.map((e) => e.padding ?? 0.0).toList() ?? [];
    final leadingLabelSizes =
        widget.leading?.map((e) => e.labelSize ?? 0.0).toList() ?? [];
    final leadingIconSizes =
        widget.leading?.map((e) => e.iconSize ?? e.icon?.size ?? 0.0).toList() ?? [];
    final leadingSpacers =
        widget.leading
            ?.map(
              (e) => e.isFlexibleSpace
                  ? 'flexible'
                  : (e.isFixedSpace ? 'fixed' : ''),
            )
            .toList() ??
        [];
    final leadingTints =
        widget.leading?.map((e) => resolveColorToArgb(e.tint, context) ?? 0).toList() ?? [];
    final leadingBadgeValues =
        widget.leading?.map((e) => e.badgeValue ?? '').toList() ?? [];
    final leadingBadgeColors =
        widget.leading?.map((e) => resolveColorToArgb(e.badgeColor, context) ?? 0).toList() ?? [];

    final middleIcons =
        widget.middle
            ?.map((e) => e.isSpacer ? '' : (e.icon?.name ?? ''))
            .toList() ??
        [];
    final middleLabels =
        widget.middle?.map((e) => e.isSpacer ? '' : (e.label ?? '')).toList() ??
        [];
    final middlePaddings =
        widget.middle?.map((e) => e.padding ?? 0.0).toList() ?? [];
    final middleLabelSizes =
        widget.middle?.map((e) => e.labelSize ?? 0.0).toList() ?? [];
    final middleIconSizes =
        widget.middle?.map((e) => e.iconSize ?? e.icon?.size ?? 0.0).toList() ?? [];
    final middleSpacers =
        widget.middle
            ?.map(
              (e) => e.isFlexibleSpace
                  ? 'flexible'
                  : (e.isFixedSpace ? 'fixed' : ''),
            )
            .toList() ??
        [];
    final middleTints =
        widget.middle?.map((e) => resolveColorToArgb(e.tint, context) ?? 0).toList() ?? [];
    final middleBadgeValues =
        widget.middle?.map((e) => e.badgeValue ?? '').toList() ?? [];
    final middleBadgeColors =
        widget.middle?.map((e) => resolveColorToArgb(e.badgeColor, context) ?? 0).toList() ?? [];

    final trailingIcons =
        widget.trailing
            ?.map((e) => e.isSpacer ? '' : (e.icon?.name ?? ''))
            .toList() ??
        [];
    final trailingLabels =
        widget.trailing
            ?.map((e) => e.isSpacer ? '' : (e.label ?? ''))
            .toList() ??
        [];
    final trailingPaddings =
        widget.trailing?.map((e) => e.padding ?? 0.0).toList() ?? [];
    final trailingLabelSizes =
        widget.trailing?.map((e) => e.labelSize ?? 0.0).toList() ?? [];
    final trailingIconSizes =
        widget.trailing?.map((e) => e.iconSize ?? e.icon?.size ?? 0.0).toList() ?? [];
    final trailingSpacers =
        widget.trailing
            ?.map(
              (e) => e.isFlexibleSpace
                  ? 'flexible'
                  : (e.isFixedSpace ? 'fixed' : ''),
            )
            .toList() ??
        [];
    final trailingTints =
        widget.trailing?.map((e) => resolveColorToArgb(e.tint, context) ?? 0).toList() ?? [];
    final trailingBadgeValues =
        widget.trailing?.map((e) => e.badgeValue ?? '').toList() ?? [];
    final trailingBadgeColors =
        widget.trailing?.map((e) => resolveColorToArgb(e.badgeColor, context) ?? 0).toList() ?? [];

    // Collect popup menu data for native implementation  
    final leadingPopupMenus = widget.leading?.map((action) {
      if (action.hasPopupMenu) {
        return action.popupMenuItems!.map((item) {
          if (item is CNPopupMenuItem) {
            return {
              'type': 'item',
              'label': item.label,
              'icon': item.icon?.name ?? '',
              'enabled': item.enabled,
            };
          } else if (item is CNPopupMenuDivider) {
            return {
              'type': 'divider',
            };
          }
          return null;
        }).where((item) => item != null).toList();
      }
      return null;
    }).toList() ?? [];

    final middlePopupMenus = widget.middle?.map((action) {
      if (action.hasPopupMenu) {
        return action.popupMenuItems!.map((item) {
          if (item is CNPopupMenuItem) {
            return {
              'type': 'item',
              'label': item.label,
              'icon': item.icon?.name ?? '',
              'enabled': item.enabled,
            };
          } else if (item is CNPopupMenuDivider) {
            return {
              'type': 'divider',
            };
          }
          return null;
        }).where((item) => item != null).toList();
      }
      return null;
    }).toList() ?? [];

    final trailingPopupMenus = widget.trailing?.map((action) {
      if (action.hasPopupMenu) {
        return action.popupMenuItems!.map((item) {
          if (item is CNPopupMenuItem) {
            return {
              'type': 'item',
              'label': item.label,
              'icon': item.icon?.name ?? '',
              'enabled': item.enabled,
            };
          } else if (item is CNPopupMenuDivider) {
            return {
              'type': 'divider',
            };
          }
          return null;
        }).where((item) => item != null).toList();
      }
      return null;
    }).toList() ?? [];

    // Collect popup menu type flags
    final leadingPopupMenuTypes = widget.leading?.map((action) => 
      action.usePopupMenuButton ? 'popupMenuButton' : 
      (action.usePullDownButton ? 'pullDownButton' : 'traditional')).toList() ?? [];
    final middlePopupMenuTypes = widget.middle?.map((action) => 
      action.usePopupMenuButton ? 'popupMenuButton' : 
      (action.usePullDownButton ? 'pullDownButton' : 'traditional')).toList() ?? [];
    final trailingPopupMenuTypes = widget.trailing?.map((action) => 
      action.usePopupMenuButton ? 'popupMenuButton' : 
      (action.usePullDownButton ? 'pullDownButton' : 'traditional')).toList() ?? [];

    final creationParams = <String, dynamic>{
      'title': '',
      'leadingIcons': leadingIcons,
      'leadingLabels': leadingLabels,
      'leadingPaddings': leadingPaddings,
      'leadingLabelSizes': leadingLabelSizes,
      'leadingIconSizes': leadingIconSizes,
      'leadingSpacers': leadingSpacers,
      'leadingTints': leadingTints,
      'leadingBadgeValues': leadingBadgeValues,
      'leadingBadgeColors': leadingBadgeColors,
      'middleIcons': middleIcons,
      'middleLabels': middleLabels,
      'middlePaddings': middlePaddings,
      'middleLabelSizes': middleLabelSizes,
      'middleIconSizes': middleIconSizes,
      'middleSpacers': middleSpacers,
      'middleTints': middleTints,
      'middleBadgeValues': middleBadgeValues,
      'middleBadgeColors': middleBadgeColors,
      'middleAlignment': widget.middleAlignment.name,
      'trailingIcons': trailingIcons,
      'trailingLabels': trailingLabels,
      'trailingPaddings': trailingPaddings,
      'trailingLabelSizes': trailingLabelSizes,
      'trailingIconSizes': trailingIconSizes,
      'trailingSpacers': trailingSpacers,
      'trailingTints': trailingTints,
      'trailingBadgeValues': trailingBadgeValues,
      'trailingBadgeColors': trailingBadgeColors,
      'leadingPopupMenus': leadingPopupMenus,
      'middlePopupMenus': middlePopupMenus, 
      'trailingPopupMenus': trailingPopupMenus,
      'leadingPopupMenuTypes': leadingPopupMenuTypes,
      'middlePopupMenuTypes': middlePopupMenuTypes,
      'trailingPopupMenuTypes': trailingPopupMenuTypes,
      'transparent': widget.transparent,
      'isDark': _isDark,
      'style': encodeStyle(context, tint: _effectiveTint),
      'pillHeight': widget.pillHeight,
    };

    final viewType = 'CupertinoNativeNavigationBar';
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

    final h = widget.height ?? _intrinsicHeight ?? 44.0;
    return SizedBox(height: h, child: platformView);
  }

  void _onCreated(int id) {
    final ch = MethodChannel('CupertinoNativeNavigationBar_$id');
    _channel = ch;
    ch.setMethodCallHandler(_onMethodCall);
    _lastTitle = '';
    _lastTint = resolveColorToArgb(_effectiveTint, context);
    _lastIsDark = _isDark;
    _lastTransparent = widget.transparent;
    _requestIntrinsicSize();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'leadingTapped') {
      final args = call.arguments as Map?;
      final index = (args?['index'] as num?)?.toInt() ?? 0;
      if (index >= 0 &&
          widget.leading != null &&
          index < widget.leading!.length) {
        final action = widget.leading![index];
        // For actions without popup menus, call onPressed directly
        // Actions with popup menus are handled natively
        if (!action.hasPopupMenu) {
          action.onPressed?.call();
        }
      }
    } else if (call.method == 'middleTapped') {
      final args = call.arguments as Map?;
      final index = (args?['index'] as num?)?.toInt() ?? 0;
      if (index >= 0 &&
          widget.middle != null &&
          index < widget.middle!.length) {
        final action = widget.middle![index];
        // For actions without popup menus, call onPressed directly
        // Actions with popup menus are handled natively
        if (!action.hasPopupMenu) {
          action.onPressed?.call();
        }
      }
    } else if (call.method == 'trailingTapped') {
      final args = call.arguments as Map?;
      final index = (args?['index'] as num?)?.toInt() ?? 0;
      if (index >= 0 &&
          widget.trailing != null &&
          index < widget.trailing!.length) {
        final action = widget.trailing![index];
        // For actions without popup menus, call onPressed directly
        // Actions with popup menus are handled natively
        if (!action.hasPopupMenu) {
          action.onPressed?.call();
        }
      }
    } else if (call.method == 'popupMenuSelected') {
      final args = call.arguments as Map?;
      final location = args?['location'] as String?;
      final actionIndex = (args?['actionIndex'] as num?)?.toInt() ?? 0;
      final menuIndex = (args?['menuIndex'] as num?)?.toInt() ?? 0;
      
      if (location == 'leading' &&
          actionIndex >= 0 &&
          widget.leading != null &&
          actionIndex < widget.leading!.length) {
        final action = widget.leading![actionIndex];
        action.onPopupMenuSelected?.call(menuIndex);
      } else if (location == 'middle' &&
          actionIndex >= 0 &&
          widget.middle != null &&
          actionIndex < widget.middle!.length) {
        final action = widget.middle![actionIndex];
        action.onPopupMenuSelected?.call(menuIndex);
      } else if (location == 'trailing' &&
          actionIndex >= 0 &&
          widget.trailing != null &&
          actionIndex < widget.trailing!.length) {
        final action = widget.trailing![actionIndex];
        action.onPopupMenuSelected?.call(menuIndex);
      }
    }
    return null;
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;

    final title = '';
    final tint = resolveColorToArgb(_effectiveTint, context);
    final transparent = widget.transparent;

    if (_lastTitle != title) {
      await ch.invokeMethod('setTitle', {'title': title});
      _lastTitle = title;
    }

    final style = <String, dynamic>{};
    if (_lastTint != tint && tint != null) {
      style['tint'] = tint;
      _lastTint = tint;
    }
    if (_lastTransparent != transparent) {
      style['transparent'] = transparent;
      _lastTransparent = transparent;
    }
    if (style.isNotEmpty) {
      await ch.invokeMethod('setStyle', style);
    }
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

  Future<void> _requestIntrinsicSize() async {
    if (widget.height != null) return;
    final ch = _channel;
    if (ch == null) return;
    try {
      final size = await ch.invokeMethod<Map>('getIntrinsicSize');
      final h = (size?['height'] as num?)?.toDouble();
      if (!mounted) return;
      setState(() {
        if (h != null && h > 0) _intrinsicHeight = h;
      });
    } catch (_) {}
  }
}

/// State class for search-enabled toolbar.
class _CNToolbarSearchState extends State<CNToolbar>
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
      duration: widget.searchConfig!.animationDuration,
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
    // Add search button to trailing actions
    final searchAction = CNToolbarAction(
      icon: widget.searchConfig!.searchIcon,
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
    final config = widget.searchConfig!;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          // Search results overlay
          if (config.showResultsOverlay &&
              config.resultsBuilder != null &&
              _searchText.isNotEmpty)
            Positioned.fill(
              child: config.resultsBuilder!(context, _searchText),
            ),
          // Search bar with context icon
          SafeArea(
            top: false,
            child: Container(
              height: config.searchBarHeight,
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
        ],
      ),
    );
  }
}
