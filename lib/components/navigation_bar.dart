import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../channel/params.dart';
import '../style/sf_symbol.dart';
import 'icon.dart';
import 'popup_menu_button.dart';
import 'pull_down_button.dart';
import 'search_config.dart';
import 'search_bar.dart';
import 'segmented_control.dart';

/// Action item for navigation bar trailing/leading positions.
class CNNavigationBarAction { 
  /// Creates a navigation bar action item.
  const CNNavigationBarAction({
    this.icon,
    this.label,
    this.onPressed,
    this.padding,
    this.labelSize,
    this.iconSize,
    this.tint,
    this.badgeValue,
    this.badgeColor,
  })  : popupMenuItems = null,
        onPopupMenuSelected = null,
        segmentedControlLabels = null,
        segmentedControlSelectedIndex = null,
        onSegmentedControlValueChanged = null,
        segmentedControlHeight = null,
        segmentedControlWidth = null,
        _isFixedSpace = false,
        _isFlexibleSpace = false,
        _usePopupMenuButton = false,
        _usePullDownButton = false;

  /// Creates a navigation bar action with a popup menu.
  const CNNavigationBarAction.popupMenu({
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
  })  : onPressed = null,
        segmentedControlLabels = null,
        segmentedControlSelectedIndex = null,
        onSegmentedControlValueChanged = null,
        segmentedControlHeight = null,
        segmentedControlWidth = null,
        _isFixedSpace = false,
        _isFlexibleSpace = false,
        _usePopupMenuButton = false,
        _usePullDownButton = false;

  /// Creates a navigation bar action with a CNPopupMenuButton.
  /// This provides a more native-looking popup menu button with built-in styling.
  const CNNavigationBarAction.popupMenuButton({
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
  })  : onPressed = null,
        segmentedControlLabels = null,
        segmentedControlSelectedIndex = null,
        onSegmentedControlValueChanged = null,
        segmentedControlHeight = null,
        segmentedControlWidth = null,
        _isFixedSpace = false,
        _isFlexibleSpace = false,
        _usePopupMenuButton = true,
        _usePullDownButton = false;

  /// Creates a navigation bar action with a CNPullDownButton.
  /// This provides a native pull-down button that shows a menu below the button.
  const CNNavigationBarAction.pullDownButton({
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
  })  : onPressed = null,
        segmentedControlLabels = null,
        segmentedControlSelectedIndex = null,
        onSegmentedControlValueChanged = null,
        segmentedControlHeight = null,
        segmentedControlWidth = null,
        _isFixedSpace = false,
        _isFlexibleSpace = false,
        _usePopupMenuButton = false,
        _usePullDownButton = true;

  /// Creates a fixed space item with specific width.
  const CNNavigationBarAction.fixedSpace(double width)
      : icon = null,
        label = null,
        labelSize = null,
        iconSize = null,
        onPressed = null,
        popupMenuItems = null,
        onPopupMenuSelected = null,
        padding = width,
        tint = null,
        badgeValue = null,
        badgeColor = null,
        segmentedControlLabels = null,
        segmentedControlSelectedIndex = null,
        onSegmentedControlValueChanged = null,
        segmentedControlHeight = null,
        segmentedControlWidth = null,
        _isFixedSpace = true,
        _isFlexibleSpace = false,
        _usePopupMenuButton = false,
        _usePullDownButton = false;

  /// Creates a flexible space that expands to fill available space.
  const CNNavigationBarAction.flexibleSpace()
      : icon = null,
        label = null,
        labelSize = null,
        iconSize = null,
        onPressed = null,
        popupMenuItems = null,
        onPopupMenuSelected = null,
        padding = null,
        tint = null,
        badgeValue = null,
        badgeColor = null,
        segmentedControlLabels = null,
        segmentedControlSelectedIndex = null,
        onSegmentedControlValueChanged = null,
        segmentedControlHeight = null,
        segmentedControlWidth = null,
        _isFixedSpace = false,
        _isFlexibleSpace = true,
        _usePopupMenuButton = false,
        _usePullDownButton = false;

  /// Creates a navigation bar action with a segmented control.
  /// This embeds a native UISegmentedControl/NSSegmentedControl in the navigation bar.
  const CNNavigationBarAction.segmentedControl({
    required this.segmentedControlLabels,
    required this.segmentedControlSelectedIndex,
    required this.onSegmentedControlValueChanged,
    this.segmentedControlHeight,
    this.segmentedControlWidth,
    this.tint,
    this.padding,
  })  : icon = null,
        label = null,
        labelSize = null,
        iconSize = null,
        onPressed = null,
        popupMenuItems = null,
        onPopupMenuSelected = null,
        badgeValue = null,
        badgeColor = null,
        _isFixedSpace = false,
        _isFlexibleSpace = false,
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

  /// Tint color for this action's icon or label.
  /// If null, uses the navigation bar's global tint color.
  final Color? tint;

  /// Badge value to display on the action (e.g., notification count, status text).
  /// If null, no badge is shown.
  final String? badgeValue;

  /// Background color for the badge.
  /// If null, uses the platform default badge color (typically red).
  final Color? badgeColor;

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

  /// Segment labels for segmented control (only for segmentedControl constructor).
  final List<String>? segmentedControlLabels;

  /// Selected index for segmented control (only for segmentedControl constructor).
  final int? segmentedControlSelectedIndex;

  /// Called when a segment is selected in the segmented control.
  final ValueChanged<int>? onSegmentedControlValueChanged;

  /// Height of the segmented control in logical pixels.
  /// If null, uses platform default height (typically 28-32 points).
  final double? segmentedControlHeight;

  /// Width of the segmented control in logical pixels.
  /// If null, the control sizes itself based on content.
  final double? segmentedControlWidth;

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

  /// Returns true if this action is a segmented control.
  bool get isSegmentedControl => segmentedControlLabels != null && segmentedControlLabels!.isNotEmpty;
}

/// A Cupertino-native navigation bar with liquid glass translucent effect.
///
/// Uses native UINavigationBar on iOS and NSToolbar on macOS for authentic
/// translucent blur effects. The navigation bar automatically blurs content
/// behind it, creating the signature iOS/macOS "liquid glass" appearance.
class CNNavigationBar extends StatefulWidget {
  /// Creates a native translucent navigation bar.
  const CNNavigationBar({
    super.key,
    this.leading,
    this.title,
    this.titleSize,
    this.onTitlePressed,
    this.trailing,
    this.largeTitle = false,
    this.transparent = true,
    this.tint,
    this.height,
    this.segmentedControlLabels,
    this.segmentedControlSelectedIndex,
    this.onSegmentedControlValueChanged,
    this.segmentedControlHeight,
    this.segmentedControlTint,
  })  : searchConfig = null,
        scrollableContent = null,
        _isSearchEnabled = false,
        _isScrollable = false;

  /// Creates a navigation bar with integrated search functionality.
  ///
  /// When the search icon is tapped, the navigation bar transforms to show a search bar.
  /// Search button is automatically added to trailing actions.
  ///
  /// Example:
  /// ```dart
  /// CNNavigationBar.search(
  ///   title: 'Contacts',
  ///   leading: [CNNavigationBarAction(icon: CNSymbol('plus'), onPressed: () {})],
  ///   searchConfig: CNSearchConfig(
  ///     placeholder: 'Search contacts',
  ///     onSearchTextChanged: (text) => print(text),
  ///     resultsBuilder: (context, text) => ContactResults(text),
  ///   ),
  /// )
  /// ```
  const CNNavigationBar.search({
    super.key,
    this.leading,
    this.title,
    this.titleSize,
    this.onTitlePressed,
    this.trailing,
    required this.searchConfig,
    this.largeTitle = false,
    this.transparent = true,
    this.tint,
    this.height,
    this.segmentedControlLabels,
    this.segmentedControlSelectedIndex,
    this.onSegmentedControlValueChanged,
    this.segmentedControlHeight,
    this.segmentedControlTint,
  })  : scrollableContent = null,
        _isSearchEnabled = true,
        _isScrollable = false;

  /// Creates a navigation bar with native UINavigationController and scroll view.
  ///
  /// This enables proper iOS large title behavior where the title automatically
  /// collapses into the center when scrolling up. The navigation bar is embedded
  /// in a native UINavigationController with the provided content in a UIScrollView.
  ///
  /// **Note**: This is only available on iOS. On other platforms, it falls back
  /// to a standard navigation bar.
  ///
  /// Example:
  /// ```dart
  /// CNNavigationBar.scrollable(
  ///   title: 'Settings',
  ///   largeTitle: true,  // Will collapse on scroll
  ///   content: ListView(
  ///     children: [
  ///       // Your scrollable content
  ///     ],
  ///   ),
  ///   leading: [CNNavigationBarAction(icon: CNSymbol('chevron.left'), onPressed: () {})],
  /// )
  /// ```
  const CNNavigationBar.scrollable({
    super.key,
    this.leading,
    this.title,
    this.titleSize,
    this.onTitlePressed,
    this.trailing,
    required this.scrollableContent,
    this.largeTitle = true,
    this.transparent = false,
    this.tint,
    this.height,
    this.segmentedControlLabels,
    this.segmentedControlSelectedIndex,
    this.onSegmentedControlValueChanged,
    this.segmentedControlHeight,
    this.segmentedControlTint,
  })  : searchConfig = null,
        _isSearchEnabled = false,
        _isScrollable = true;

  /// Leading actions (typically back button, can include multiple items).
  final List<CNNavigationBarAction>? leading;

  /// Title text for the navigation bar.
  final String? title;

  /// Font size for the title text in points.
  /// If null, uses the platform default title size.
  final double? titleSize;

  /// Callback when the title is tapped.
  /// If null, the title is not clickable.
  final VoidCallback? onTitlePressed;

  /// Trailing actions (buttons/icons on the right).
  /// For search-enabled navigation bar, search button is added automatically.
  final List<CNNavigationBarAction>? trailing;

  /// Use large title style (iOS 11+ style).
  final bool largeTitle;

  /// Use completely transparent background (no blur).
  final bool transparent;

  /// Tint color for buttons and icons.
  final Color? tint;

  /// Fixed height (if null, uses intrinsic platform height).
  final double? height;

  /// Segment labels for the center segmented control.
  /// If provided, replaces the title with a segmented control.
  final List<String>? segmentedControlLabels;

  /// Selected index for the center segmented control.
  final int? segmentedControlSelectedIndex;

  /// Called when a segment is selected in the center segmented control.
  final ValueChanged<int>? onSegmentedControlValueChanged;

  /// Height of the center segmented control in logical pixels.
  /// If null, uses platform default height (typically 28 points).
  final double? segmentedControlHeight;

  /// Tint color for the selected segment background in the segmented control.
  /// This is the background color of the selected segment.
  /// If null, uses the navigation bar's tint color or system default.
  final Color? segmentedControlTint;

  /// Search configuration (only for search-enabled navigation bar).
  final CNSearchConfig? searchConfig;

  /// Scrollable content widget (only for scrollable navigation bar with UINavigationController).
  /// This should be your page content that will be placed in a native scroll view.
  final Widget? scrollableContent;

  /// Internal flag to indicate search functionality is enabled.
  final bool _isSearchEnabled;

  /// Internal flag to indicate scrollable UINavigationController mode is enabled.
  final bool _isScrollable;

  @override
  State<CNNavigationBar> createState() {
    if (_isScrollable) {
      return _CNNavigationBarScrollableState();
    }
    if (_isSearchEnabled) {
      return _CNNavigationBarSearchState();
    }
    return _CNNavigationBarState();
  }
}

class _CNNavigationBarState extends State<CNNavigationBar> {
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
  void didUpdateWidget(covariant CNNavigationBar oldWidget) {
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
    // Check if segmented control is provided as a center view
    final hasSegmentedControl = widget.segmentedControlLabels != null && 
                                widget.segmentedControlLabels!.isNotEmpty;

    if (!(defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS)) {
      // Fallback for non-Apple platforms
      Widget? middle;
      if (hasSegmentedControl) {
        middle = CNSegmentedControl(
          labels: widget.segmentedControlLabels!,
          selectedIndex: widget.segmentedControlSelectedIndex ?? 0,
          onValueChanged: widget.onSegmentedControlValueChanged!,
          height: widget.segmentedControlHeight ?? 28.0,
          color: widget.tint,
          shrinkWrap: false,
        );
      } else if (widget.title != null) {
        middle = Text(widget.title!);
      }
      
      return CupertinoNavigationBar(
        leading: widget.leading != null && widget.leading!.isNotEmpty
            ? _buildActionWidget(widget.leading!.first)
            : null,
        middle: middle,
        trailing: widget.trailing != null && widget.trailing!.isNotEmpty
            ? _buildActionWidget(widget.trailing!.first)
            : null,
        backgroundColor: widget.transparent ? CupertinoColors.transparent : null,
      );
    }

    // No need to filter actions anymore - segmented control is separate
    final leadingIcons =
        widget.leading?.map((e) => e.isSpacer ? '' : (e.icon?.name ?? '')).toList() ?? [];
    final leadingLabels =
        widget.leading?.map((e) => e.isSpacer ? '' : (e.label ?? '')).toList() ?? [];
    final leadingPaddings =
        widget.leading?.map((e) => e.padding ?? 0.0).toList() ?? [];
    final leadingLabelSizes =
        widget.leading?.map((e) => e.labelSize ?? 0.0).toList() ?? [];
    final leadingIconSizes =
        widget.leading?.map((e) => e.iconSize ?? e.icon?.size ?? 0.0).toList() ?? [];
    final leadingSpacers =
        widget.leading?.map((e) => e.isFlexibleSpace ? 'flexible' : (e.isFixedSpace ? 'fixed' : '')).toList() ?? [];
    final leadingTints =
        widget.leading?.map((e) => resolveColorToArgb(e.tint, context) ?? 0).toList() ?? [];
    final leadingBadgeValues =
        widget.leading?.map((e) => e.badgeValue ?? '').toList() ?? [];
    final leadingBadgeColors =
        widget.leading?.map((e) => resolveColorToArgb(e.badgeColor, context) ?? 0).toList() ?? [];
    final trailingIcons =
        widget.trailing?.map((e) => e.isSpacer ? '' : (e.icon?.name ?? '')).toList() ?? [];
    final trailingLabels =
        widget.trailing?.map((e) => e.isSpacer ? '' : (e.label ?? '')).toList() ?? [];
    final trailingPaddings =
        widget.trailing?.map((e) => e.padding ?? 0.0).toList() ?? [];
    final trailingLabelSizes =
        widget.trailing?.map((e) => e.labelSize ?? 0.0).toList() ?? [];
    final trailingIconSizes =
        widget.trailing?.map((e) => e.iconSize ?? e.icon?.size ?? 0.0).toList() ?? [];
    final trailingSpacers =
        widget.trailing?.map((e) => e.isFlexibleSpace ? 'flexible' : (e.isFixedSpace ? 'fixed' : '')).toList() ?? [];
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

    // Use title only if no segmented control is present
    final effectiveTitle = hasSegmentedControl ? '' : (widget.title ?? '');

    final creationParams = <String, dynamic>{
      'title': effectiveTitle,
      'titleSize': widget.titleSize ?? 0.0,
      'titleClickable': widget.onTitlePressed != null && !hasSegmentedControl,
      'leadingIcons': leadingIcons,
      'leadingLabels': leadingLabels,
      'leadingPaddings': leadingPaddings,
      'leadingLabelSizes': leadingLabelSizes,
      'leadingIconSizes': leadingIconSizes,
      'leadingSpacers': leadingSpacers,
      'leadingTints': leadingTints,
      'leadingBadgeValues': leadingBadgeValues,
      'leadingBadgeColors': leadingBadgeColors,
      'leadingPopupMenus': leadingPopupMenus,
      'trailingIcons': trailingIcons,
      'trailingLabels': trailingLabels,
      'trailingPaddings': trailingPaddings,
      'trailingLabelSizes': trailingLabelSizes,
      'trailingIconSizes': trailingIconSizes,
      'trailingSpacers': trailingSpacers,
      'trailingTints': trailingTints,
      'trailingBadgeValues': trailingBadgeValues,
      'trailingBadgeColors': trailingBadgeColors,
      'trailingPopupMenus': trailingPopupMenus,
      'largeTitle': widget.largeTitle,
      'transparent': widget.transparent,
      'isDark': _isDark,
      'style': encodeStyle(context, tint: _effectiveTint),
      // Segmented control parameters for native rendering in title view
      'hasSegmentedControl': hasSegmentedControl,
      'segmentedControlLabels': widget.segmentedControlLabels ?? [],
      'segmentedControlSelectedIndex': widget.segmentedControlSelectedIndex ?? 0,
      'segmentedControlHeight': widget.segmentedControlHeight ?? 28.0,
      'segmentedControlTint': resolveColorToArgb(widget.segmentedControlTint ?? _effectiveTint, context),
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
    
    // Native platform view handles segmented control rendering in title view
    return SizedBox(height: h, child: platformView);
  }

  void _onCreated(int id) {
    final ch = MethodChannel('CupertinoNativeNavigationBar_$id');
    _channel = ch;
    ch.setMethodCallHandler(_onMethodCall);
    _lastTitle = widget.title;
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
      } else if (location == 'trailing' &&
          actionIndex >= 0 &&
          widget.trailing != null &&
          actionIndex < widget.trailing!.length) {
        final action = widget.trailing![actionIndex];
        action.onPopupMenuSelected?.call(menuIndex);
      }
    } else if (call.method == 'titleTapped') {
      widget.onTitlePressed?.call();
    } else if (call.method == 'segmentedControlChanged') {
      final args = call.arguments as Map?;
      final selectedIndex = (args?['selectedIndex'] as num?)?.toInt() ?? 0;
      widget.onSegmentedControlValueChanged?.call(selectedIndex);
    }
    return null;
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;

    final title = widget.title ?? '';
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

  /// Builds a widget for the given navigation bar action.
  Widget _buildActionWidget(CNNavigationBarAction action) {
    if (action.hasPopupMenu && action.usePopupMenuButton) {
      // Use CNPopupMenuButton for native-style popup menu
      if (action.icon != null) {
        return CNPopupMenuButton.icon(
          buttonIcon: action.icon!,
          items: action.popupMenuItems!,
          onSelected: action.onPopupMenuSelected!,
          size: action.iconSize ?? 44.0,
        );
      } else {
        return CNPopupMenuButton(
          buttonLabel: action.label ?? '',
          items: action.popupMenuItems!,
          onSelected: action.onPopupMenuSelected!,
          height: 32.0,
        );
      }
    } else if (action.hasPopupMenu && action.usePullDownButton) {
      // Use CNPullDownButton for native pull-down menu
      final pullDownItems = action.popupMenuItems!.map((item) {
        if (item is CNPopupMenuItem) {
          return CNPullDownMenuItem(
            label: item.label,
            icon: item.icon,
            enabled: item.enabled,
          );
        } else if (item is CNPopupMenuDivider) {
          return CNPullDownMenuDivider();
        }
        return CNPullDownMenuItem(label: '');
      }).toList();

      if (action.icon != null) {
        return CNPullDownButton.icon(
          buttonIcon: action.icon!,
          items: pullDownItems,
          onSelected: action.onPopupMenuSelected!,
          size: action.iconSize ?? 44.0,
        );
      } else {
        return CNPullDownButton(
          buttonLabel: action.label ?? '',
          items: pullDownItems,
          onSelected: action.onPopupMenuSelected!,
          height: 32.0,
        );
      }
    } else if (action.hasPopupMenu) {
      // Use traditional popup menu fallback
      final child = action.icon != null 
          ? CNIcon(symbol: action.icon!, size: action.iconSize, color: action.tint)
          : Text(action.label ?? '', style: action.tint != null ? TextStyle(color: action.tint) : null);
      
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () async {
          final selected = await showCupertinoModalPopup<int>(
            context: context,
            builder: (ctx) {
              return CupertinoActionSheet(
                actions: [
                  for (var i = 0; i < action.popupMenuItems!.length; i++)
                    if (action.popupMenuItems![i] is CNPopupMenuItem)
                      CupertinoActionSheetAction(
                        onPressed: () => Navigator.of(ctx).pop(i),
                        child: Text(
                          (action.popupMenuItems![i] as CNPopupMenuItem).label,
                        ),
                      )
                    else
                      const SizedBox(height: 8),
                ],
                cancelButton: CupertinoActionSheetAction(
                  onPressed: () => Navigator.of(ctx).pop(),
                  isDefaultAction: true,
                  child: const Text('Cancel'),
                ),
              );
            },
          );
          if (selected != null) action.onPopupMenuSelected?.call(selected);
        },
        child: child,
      );
    } else if (action.isSegmentedControl) {
      // Segmented control action
      return SizedBox(
        width: action.segmentedControlWidth,
        child: CNSegmentedControl(
          labels: action.segmentedControlLabels!,
          selectedIndex: action.segmentedControlSelectedIndex ?? 0,
          onValueChanged: action.onSegmentedControlValueChanged!,
          height: action.segmentedControlHeight ?? 28.0,
          color: action.tint,
          shrinkWrap: action.segmentedControlWidth == null,
        ),
      );
    } else {
      // Regular action button
      final child = action.icon != null 
          ? CNIcon(symbol: action.icon!, size: action.iconSize, color: action.tint)
          : Text(action.label ?? '', style: action.tint != null ? TextStyle(color: action.tint) : null);
      
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: action.onPressed,
        child: child,
      );
    }
  }
}

/// State class for search-enabled navigation bar.
class _CNNavigationBarSearchState extends State<CNNavigationBar>
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
    final searchAction = CNNavigationBarAction(
      icon: widget.searchConfig!.searchIcon,
      onPressed: _expandSearch,
    );

    final trailingWithSearch = [
      ...?widget.trailing,
      searchAction,
    ];

    return CNNavigationBar(
      leading: widget.leading,
      title: widget.title,
      onTitlePressed: widget.onTitlePressed,
      trailing: trailingWithSearch,
      largeTitle: widget.largeTitle,
      transparent: widget.transparent,
      tint: widget.tint,
      height: widget.height,
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
          // Search bar
          SafeArea(
            top: false,
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
    );
  }
}

/// State class for scrollable navigation bar with UINavigationController.
/// 
/// This creates a native UINavigationController with the navigation bar
/// and content in a UIScrollView, enabling proper large title collapse behavior.
class _CNNavigationBarScrollableState extends State<CNNavigationBar> {
  MethodChannel? _channel;
  
  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // For scrollable mode on iOS, use CustomScrollView with CupertinoSliverNavigationBar
    // This provides authentic iOS large title behavior with automatic collapse on scroll
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // Build leading widget if actions exist
      Widget? leadingWidget;
      if (widget.leading != null && widget.leading!.isNotEmpty) {
        final firstAction = widget.leading!.first;
        leadingWidget = CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: firstAction.onPressed,
          child: firstAction.icon != null
              ? CNIcon(symbol: firstAction.icon!)
              : Text(firstAction.label ?? ''),
        );
      }

      // Build trailing widget if actions exist
      Widget? trailingWidget;
      if (widget.trailing != null && widget.trailing!.isNotEmpty) {
        if (widget.trailing!.length == 1) {
          final action = widget.trailing!.first;
          trailingWidget = CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: action.onPressed,
            child: action.icon != null
                ? CNIcon(symbol: action.icon!)
                : Text(action.label ?? ''),
          );
        } else {
          // Multiple trailing actions
          trailingWidget = Row(
            mainAxisSize: MainAxisSize.min,
            children: widget.trailing!.map((action) {
              return CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: action.onPressed,
                child: action.icon != null
                    ? CNIcon(symbol: action.icon!)
                    : Text(action.label ?? ''),
              );
            }).toList(),
          );
        }
      }

      return CupertinoPageScaffold(
        child: CustomScrollView(
          slivers: [
            if (widget.largeTitle)
              // Use CupertinoSliverNavigationBar for large title with collapse behavior
              CupertinoSliverNavigationBar(
                largeTitle: widget.title != null ? Text(widget.title!) : const Text(''),
                leading: leadingWidget,
                trailing: trailingWidget,
                backgroundColor: widget.transparent
                    ? CupertinoColors.transparent
                    : null,
                border: widget.transparent
                    ? null
                    : const Border(
                        bottom: BorderSide(
                          color: CupertinoColors.separator,
                          width: 0.0,
                        ),
                      ),
              )
            else
              // Use SliverPersistentHeader for small title only
              SliverPersistentHeader(
                pinned: true,
                delegate: _SmallNavigationBarDelegate(
                  title: widget.title,
                  leading: leadingWidget,
                  trailing: trailingWidget,
                  transparent: widget.transparent,
                  context: context,
                ),
              ),
            SliverToBoxAdapter(
              child: widget.scrollableContent ?? const SizedBox.shrink(),
            ),
          ],
        ),
      );
    }

    // On non-iOS platforms, fall back to regular navigation bar + content
    return Column(
      children: [
        CNNavigationBar(
          leading: widget.leading,
          title: widget.title,
          onTitlePressed: widget.onTitlePressed,
          trailing: widget.trailing,
          largeTitle: widget.largeTitle,
          transparent: widget.transparent,
          tint: widget.tint,
          height: widget.height,
        ),
        Expanded(
          child: widget.scrollableContent ?? const SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// Delegate for creating a small navigation bar in a sliver.
class _SmallNavigationBarDelegate extends SliverPersistentHeaderDelegate {
  final String? title;
  final Widget? leading;
  final Widget? trailing;
  final bool transparent;
  final BuildContext context;

  _SmallNavigationBarDelegate({
    this.title,
    this.leading,
    this.trailing,
    required this.transparent,
    required this.context,
  });

  @override
  double get minExtent => 44.0 + MediaQuery.of(context).padding.top;

  @override
  double get maxExtent => 44.0 + MediaQuery.of(context).padding.top;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final backgroundColor = transparent
        ? CupertinoColors.transparent
        : CupertinoTheme.of(context).barBackgroundColor;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: transparent
            ? null
            : const Border(
                bottom: BorderSide(
                  color: CupertinoColors.separator,
                  width: 0.0,
                ),
              ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: SizedBox(
          height: 44,
          child: Stack(
            children: [
              // Title in center
              if (title != null)
                Center(
                  child: Text(
                    title!,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              // Leading on left
              if (leading != null)
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: leading!,
                  ),
                ),
              // Trailing on right
              if (trailing != null)
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: trailing!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SmallNavigationBarDelegate oldDelegate) {
    return title != oldDelegate.title ||
        leading != oldDelegate.leading ||
        trailing != oldDelegate.trailing ||
        transparent != oldDelegate.transparent;
  }
}
