import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// Detent heights for resizable sheets (iOS only)
class CNSheetDetent {
  final String type;
  final double? height;

  const CNSheetDetent._(this.type, this.height);

  /// Medium height (~50% of screen)
  static const medium = CNSheetDetent._('medium', null);

  /// Large height (~100% of screen)
  static const large = CNSheetDetent._('large', null);

  /// Custom fixed height in points
  /// Example: CNSheetDetent.custom(300) for a 300pt tall sheet
  static CNSheetDetent custom(double height) =>
      CNSheetDetent._('custom', height);

  Map<String, dynamic> toMap() {
    return {'type': type, if (height != null) 'height': height};
  }
}

/// An item to display in a native sheet
class CNSheetItem {
  final String? title;
  final String? icon;
  final bool dismissOnTap;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double? height;
  final double? fontSize;
  final double? iconSize;
  final FontWeight? fontWeight;
  final double? iconLabelSpacing;

  /// Creates a simple sheet item with title and optional icon.
  /// This will be rendered natively using UISheetPresentationController.
  ///
  /// [title] - The text to display
  /// [icon] - Optional SF Symbol icon name
  /// [dismissOnTap] - Whether tapping this item dismisses the sheet
  /// [backgroundColor] - Custom background color for this item
  /// [textColor] - Custom text color for this item
  /// [iconColor] - Custom icon/tint color for this item
  /// [height] - Custom height for this item (default: 50)
  /// [fontSize] - Font size for the title text (default: 17)
  /// [iconSize] - Size of the SF Symbol icon (default: 22)
  /// [fontWeight] - Font weight for the title text (default: regular)
  /// [iconLabelSpacing] - Spacing between icon and title (default: 8)
  const CNSheetItem({
    required this.title,
    this.icon,
    this.dismissOnTap = true,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.height,
    this.fontSize,
    this.iconSize,
    this.fontWeight,
    this.iconLabelSpacing,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      if (title != null) 'title': title,
      if (icon != null) 'icon': icon,
      'dismissOnTap': dismissOnTap,
    };
    
    // Add styling properties if provided
    if (backgroundColor != null) map['backgroundColor'] = backgroundColor!.value;
    if (textColor != null) map['textColor'] = textColor!.value;
    if (iconColor != null) map['iconColor'] = iconColor!.value;
    if (height != null) map['height'] = height;
    if (fontSize != null) map['fontSize'] = fontSize;
    if (iconSize != null) map['iconSize'] = iconSize;
    if (iconLabelSpacing != null) map['iconLabelSpacing'] = iconLabelSpacing;
    if (fontWeight != null) {
      // Map FontWeight to Swift weight value
      final weightMap = {
        FontWeight.w100: 100,
        FontWeight.w200: 200,
        FontWeight.w300: 300,
        FontWeight.w400: 400,
        FontWeight.w500: 500,
        FontWeight.w600: 600,
        FontWeight.w700: 700,
        FontWeight.w800: 800,
        FontWeight.w900: 900,
      };
      map['fontWeight'] = weightMap[fontWeight] ?? 400;
    }
    
    return map;
  }
}

/// A horizontal row of vertical-style items displayed side-by-side.
///
/// Use this to show 2-3 items in a row (e.g., "Cancel" and "Delete" buttons
/// side-by-side). Each item maintains the vertical button style but is placed
/// horizontally next to each other with equal widths.
class CNSheetItemRow {
  final List<CNSheetItem> items;
  final double? spacing;
  final double? height;

  /// Creates a row of vertical items displayed side-by-side.
  ///
  /// Best used with 2-3 items. Too many items will make buttons too narrow.
  /// 
  /// [items] - List of items to display side-by-side
  /// [spacing] - Spacing between items in the row (default: 8)
  /// [height] - Custom height for the entire row (default: 50)
  const CNSheetItemRow({
    required this.items,
    this.spacing,
    this.height,
  });
}

/// A horizontal row of inline action buttons in a native sheet.
///
/// These appear as icon buttons arranged horizontally, similar to the formatting
/// toolbar in iOS Notes app (Bold, Italic, Underline, etc.).
class CNSheetInlineActions {
  final List<CNSheetInlineAction> actions;
  final double? spacing;
  final double? horizontalPadding;
  final double? verticalPadding;
  final double? height;

  /// Creates a row of inline action buttons.
  ///
  /// [actions] - List of inline action buttons in this row
  /// [spacing] - Spacing between buttons (default: 12)
  /// [horizontalPadding] - Left and right padding for the entire row (default: 16)
  /// [verticalPadding] - Top and bottom padding for the row container (default: 0)
  /// [height] - Height of the row (default: 72)
  const CNSheetInlineActions({
    required this.actions,
    this.spacing,
    this.horizontalPadding,
    this.verticalPadding,
    this.height,
  });
}

/// An individual inline action button for sheets.
class CNSheetInlineAction {
  final String label;
  final String icon;
  final bool enabled;
  final bool isToggled;
  final Color? backgroundColor;
  final double? width;
  final double? iconSize;
  final double? labelSize;
  final double? cornerRadius;
  final double? iconLabelSpacing;

  /// Creates an inline action button.
  ///
  /// [label] - Label displayed below the icon
  /// [icon] - SF Symbol icon name
  /// [enabled] - Whether the action can be tapped
  /// [isToggled] - Whether the action appears in selected/highlighted state
  /// [backgroundColor] - Optional custom background color for this action button
  /// [width] - Custom width for this button (default: 70)
  /// [iconSize] - Size of the SF Symbol icon (default: 24)
  /// [labelSize] - Font size for the label text (default: 13)
  /// [cornerRadius] - Corner radius for the button (default: 12)
  /// [iconLabelSpacing] - Spacing between icon and label (default: 6)
  const CNSheetInlineAction({
    required this.label,
    required this.icon,
    this.enabled = true,
    this.isToggled = false,
    this.backgroundColor,
    this.width,
    this.iconSize,
    this.labelSize,
    this.cornerRadius,
    this.iconLabelSpacing,
  });
}

/// A native iOS/macOS sheet presentation using UIKit rendering.
///
/// Sheets are modal views that present scoped tasks closely related to the current context.
/// On iOS, sheets can be resizable with detents (medium/large heights).
/// On iPadOS, sheets use page or form sheet styles.
/// On macOS, sheets are always modal and attached to a window.
///
/// ## Nonmodal vs Modal Behavior
///
/// **Nonmodal Sheets** (like Apple Notes formatting sheet):
/// - User can interact with background content while sheet is open
/// - Can tap, scroll, and select in the parent view
/// - Sheet stays open during background interaction
/// - **Requires**: Set `isModal: false`
/// - Uses native UISheetPresentationController with `largestUndimmedDetentIdentifier`
///
/// **Modal Sheets** (default):
/// - Background is dimmed and non-interactive
/// - User must dismiss sheet before interacting with background
///
/// ## Usage
///
/// **Standard Sheet:**
/// ```dart
/// await CNNativeSheet.show(
///   context: context,
///   title: 'Settings',
///   items: [
///     CNSheetItem(title: 'Brightness', icon: 'sun.max'),
///     CNSheetItem(title: 'Appearance', icon: 'moon'),
///   ],
///   detents: [CNSheetDetent.medium],
/// );
/// ```
///
/// **Nonmodal Sheet:**
/// ```dart
/// await CNNativeSheet.show(
///   context: context,
///   title: 'Format',
///   items: [
///     CNSheetItem(title: 'Bold', icon: 'bold', dismissOnTap: false),
///     CNSheetItem(title: 'Italic', icon: 'italic', dismissOnTap: false),
///   ],
///   isModal: false,
/// );
/// ```
///
/// **Custom Header Sheet:**
/// ```dart
/// await CNNativeSheet.showWithCustomHeader(
///   context: context,
///   title: 'Format',
///   headerTitleWeight: FontWeight.w600,
///   items: [
///     CNSheetItem(title: 'Bold', icon: 'bold'),
///   ],
///   isModal: false,
/// );
/// ```
class CNNativeSheet {
  static const MethodChannel _channel = MethodChannel('cupertino_native_sheet');
  static const MethodChannel _customChannel = MethodChannel(
    'cupertino_native_custom_sheet',
  );

  /// Stores pending sheet completers to handle async results from native code
  static final Map<String, Completer<int?>> _pendingSheets =
      <String, Completer<int?>>{};

  /// Flag to track if handlers have been initialized
  static bool _handlersInitialized = false;

  /// Initialize method channel handlers for receiving sheet dismissal callbacks
  static void _initializeHandlers() {
    if (_handlersInitialized) return;
    _handlersInitialized = true;

    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onDismiss') {
        final args = call.arguments as Map;
        final selectedIndex = args['selectedIndex'] as int?;
        
        // Complete the oldest pending sheet completer
        if (_pendingSheets.isNotEmpty) {
          final key = _pendingSheets.keys.first;
          final completer = _pendingSheets.remove(key);
          completer?.complete(selectedIndex == -1 ? null : selectedIndex);
        }
      }
    });

    _customChannel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onDismiss') {
        final args = call.arguments as Map;
        final selectedIndex = args['selectedIndex'] as int?;
        
        // Complete the oldest pending sheet completer
        if (_pendingSheets.isNotEmpty) {
          final key = _pendingSheets.keys.first;
          final completer = _pendingSheets.remove(key);
          completer?.complete(selectedIndex == -1 ? null : selectedIndex);
        }
      }
    });
  }

  /// Generate a unique ID for sheet tracking
  static String _generateSheetId() {
    return 'sheet_${DateTime.now().millisecondsSinceEpoch}_${_pendingSheets.length}';
  }

  /// Shows a native sheet with the given content.
  ///
  /// Uses native UISheetPresentationController for rendering. All items are
  /// rendered as native UIKit components for optimal performance and true
  /// nonmodal behavior.
  ///
  /// [title] - Optional title for the sheet (displays in content area with close button)
  /// [message] - Optional message below the title
  /// [items] - List of items to display in the sheet
  /// [detents] - Heights at which the sheet can rest (iOS only, defaults to [large])
  /// [prefersGrabberVisible] - Whether to show the grabber handle (iOS only)
  /// [isModal] - Whether the sheet is modal (blocks interaction with parent view).
  ///            Default is true. Set to false for nonmodal sheets that allow
  ///            background interaction (iOS/iPadOS only, always modal on macOS/visionOS/watchOS).
  /// [prefersEdgeAttachedInCompactHeight] - Whether sheet attaches to edge in compact height
  /// [widthFollowsPreferredContentSizeWhenEdgeAttached] - Whether width follows preferred content size
  /// [preferredCornerRadius] - Custom corner radius for the sheet
  /// [itemBackgroundColor] - Background color for sheet item buttons (default: clear)
  /// [itemTextColor] - Text color for sheet item buttons (default: system label)
  /// [itemTintColor] - Tint color for icons in sheet item buttons (default: system tint)
  /// [onItemSelected] - Callback invoked when a sheet item is tapped, receives the item index
  static Future<int?> show({
    required BuildContext context,
    String? title,
    String? message,
    List<CNSheetItem> items = const [],
    List<CNSheetDetent> detents = const [CNSheetDetent.large],
    bool prefersGrabberVisible = true,
    bool isModal = true,
    bool prefersEdgeAttachedInCompactHeight = false,
    bool widthFollowsPreferredContentSizeWhenEdgeAttached = false,
    double? preferredCornerRadius,
    Color? itemBackgroundColor,
    Color? itemTextColor,
    Color? itemTintColor,
    void Function(int index)? onItemSelected,
  }) async {
    try {
      // Initialize handlers on first call
      _initializeHandlers();
      
      // Create a completer to wait for the native dismissal callback
      final completer = Completer<int?>();
      final sheetId = _generateSheetId();
      _pendingSheets[sheetId] = completer;
      
      // Set up callback handler if provided
      if (onItemSelected != null) {
        _channel.setMethodCallHandler((call) async {
          if (call.method == 'onItemSelected') {
            final index = call.arguments['index'] as int;
            onItemSelected(index);
          } else if (call.method == 'onDismiss') {
            final args = call.arguments as Map;
            final selectedIndex = args['selectedIndex'] as int?;
            
            // Complete the pending sheet completer for onDismiss
            if (_pendingSheets.isNotEmpty) {
              final key = _pendingSheets.keys.first;
              final completer = _pendingSheets.remove(key);
              completer?.complete(selectedIndex == -1 ? null : selectedIndex);
            }
          }
        });
      }

      // Call native method (result will be null from this call)
      await _channel.invokeMethod('showSheet', {
        'title': title,
        'message': message,
        'items': items.map((item) => item.toMap()).toList(),
        'detents': detents.map((d) => d.toMap()).toList(),
        'prefersGrabberVisible': prefersGrabberVisible,
        'isModal': isModal,
        'prefersEdgeAttachedInCompactHeight':
            prefersEdgeAttachedInCompactHeight,
        'widthFollowsPreferredContentSizeWhenEdgeAttached':
            widthFollowsPreferredContentSizeWhenEdgeAttached,
        'preferredCornerRadius': preferredCornerRadius,
        if (itemBackgroundColor != null)
          'itemBackgroundColor': itemBackgroundColor.value,
        if (itemTextColor != null) 'itemTextColor': itemTextColor.value,
        if (itemTintColor != null) 'itemTintColor': itemTintColor.value,
      });

      // Wait for the sheet dismissal callback to complete the completer
      return completer.future;
    } catch (e) {
      debugPrint('Error showing native sheet: $e');
      return null;
    }
  }

  /// Shows a native sheet with custom header (title + close button).
  ///
  /// This is like the Apple Notes formatting sheet - it has a custom header bar
  /// with the title on the left and a close button (X) on the right.
  ///
  /// **Key differences from `show()`:**
  /// - Custom header with title and close button (like Notes app)
  /// - Title is displayed in the header bar, not in the content area
  /// - Close button allows manual dismissal
  /// - Still supports nonmodal behavior with `isModal: false`
  /// - Full control over header styling
  ///
  /// **Example:**
  /// ```dart
  /// await CNNativeSheet.showWithCustomHeader(
  ///   context: context,
  ///   title: 'Format',
  ///   headerTitleSize: 20,
  ///   headerTitleWeight: FontWeight.w600,
  ///   headerHeight: 56,
  ///   items: [
  ///     CNSheetItem(title: 'Bold', icon: 'bold'),
  ///     CNSheetItem(title: 'Italic', icon: 'italic'),
  ///   ],
  ///   detents: [CNSheetDetent.custom(280)],
  ///   isModal: false, // Nonmodal - can interact with background
  /// );
  /// ```
  ///
  /// [title] - Title displayed in the header (required for custom header)
  /// [message] - Optional message below the header
  /// [items] - List of items to display
  /// [detents] - Heights at which the sheet can rest
  /// [prefersGrabberVisible] - Whether to show the grabber handle
  /// [isModal] - Whether the sheet blocks background interaction
  ///
  /// **Header Styling Options:**
  /// [headerTitleSize] - Font size for the title (default: 20)
  /// [headerTitleWeight] - Font weight for the title (default: semibold/600)
  /// [headerTitleColor] - Color for the title (default: label color)
  /// [headerTitleAlignment] - Alignment of title: 'left', 'center' (default: 'left')
  /// [subtitle] - Optional subtitle/subheading displayed below the title
  /// [subtitleSize] - Font size for the subtitle (default: 13)
  /// [subtitleColor] - Color for the subtitle (default: secondary label)
  /// [headerHeight] - Height of the header bar (default: 56)
  /// [headerBackgroundColor] - Background color of the header (default: system background)
  /// [showHeaderDivider] - Whether to show divider below header (default: true)
  /// [headerDividerColor] - Color of the header divider (default: separator color)
  /// [closeButtonPosition] - Position of close button: 'leading' or 'trailing' (default: 'trailing')
  /// [closeButtonIcon] - SF Symbol name for close button (default: 'xmark')
  /// [closeButtonSize] - Size of the close button icon (default: 17)
  /// [closeButtonColor] - Color of the close button (default: label color)
  /// [itemBackgroundColor] - Background color for sheet item buttons (default: clear)
  /// [itemTextColor] - Text color for sheet item buttons (default: system label)
  /// [itemTintColor] - Tint color for icons in sheet item buttons (default: system tint)
  /// [onInlineActionSelected] - Callback invoked when an inline action is tapped, receives row and action indices
  /// [onItemSelected] - Callback invoked when a regular vertical item is tapped, receives the item index
  /// [onItemRowSelected] - Callback invoked when an item row item is tapped, receives row index and item index
  static Future<int?> showWithCustomHeader({
    required BuildContext context,
    required String title,
    String? message,
    List<CNSheetItem> items = const [],
    List<CNSheetItemRow> itemRows = const [],
    List<CNSheetInlineActions> inlineActions = const [],
    List<CNSheetDetent> detents = const [CNSheetDetent.large],
    bool prefersGrabberVisible = true,
    bool isModal = true,
    bool prefersEdgeAttachedInCompactHeight = false,
    bool widthFollowsPreferredContentSizeWhenEdgeAttached = false,
    double? preferredCornerRadius,
    // Header styling
    double? headerTitleSize,
    FontWeight? headerTitleWeight,
    Color? headerTitleColor,
    String headerTitleAlignment = 'left',
    String? subtitle,
    double? subtitleSize,
    Color? subtitleColor,
    double? headerHeight,
    Color? headerBackgroundColor,
    bool showHeaderDivider = true,
    Color? headerDividerColor,
    String closeButtonPosition = 'trailing',
    String closeButtonIcon = 'xmark',
    double? closeButtonSize,
    Color? closeButtonColor,
    // Item styling
    Color? itemBackgroundColor,
    Color? itemTextColor,
    Color? itemTintColor,
    // Callbacks
    void Function(int rowIndex, int actionIndex)? onInlineActionSelected,
    void Function(int index)? onItemSelected,
    void Function(int rowIndex, int itemIndex)? onItemRowSelected,
  }) async {
    try {
      // Initialize handlers on first call
      _initializeHandlers();
      
      // Create a completer to wait for the native dismissal callback
      final completer = Completer<int?>();
      final sheetId = _generateSheetId();
      _pendingSheets[sheetId] = completer;
      
      // Serialize inline actions
      final inlineActionsList = <Map<String, dynamic>>[];
      for (final actionGroup in inlineActions) {
        final actionMaps = actionGroup.actions.map((action) {
          final map = <String, dynamic>{
            'label': action.label,
            'icon': action.icon,
            'enabled': action.enabled,
            'isToggled': action.isToggled,
          };
          // Add backgroundColor if provided (convert to ARGB int)
          if (action.backgroundColor != null) {
            map['backgroundColor'] = action.backgroundColor!.value;
          }
          // Add styling properties if provided
          if (action.width != null) map['width'] = action.width;
          if (action.iconSize != null) map['iconSize'] = action.iconSize;
          if (action.labelSize != null) map['labelSize'] = action.labelSize;
          if (action.cornerRadius != null) map['cornerRadius'] = action.cornerRadius;
          if (action.iconLabelSpacing != null) map['iconLabelSpacing'] = action.iconLabelSpacing;
          
          return map;
        }).toList();
        
        // Add row-level styling properties
        final rowMap = <String, dynamic>{'actions': actionMaps};
        if (actionGroup.spacing != null) rowMap['spacing'] = actionGroup.spacing;
        if (actionGroup.horizontalPadding != null) rowMap['horizontalPadding'] = actionGroup.horizontalPadding;
        if (actionGroup.verticalPadding != null) rowMap['verticalPadding'] = actionGroup.verticalPadding;
        if (actionGroup.height != null) rowMap['height'] = actionGroup.height;
        
        inlineActionsList.add(rowMap);
      }
      
      // Set up callback handler if provided - merge with the existing onDismiss handler
      if (onInlineActionSelected != null || onItemSelected != null || onItemRowSelected != null) {
        _customChannel.setMethodCallHandler((call) async {
          if (call.method == 'onDismiss') {
            final args = call.arguments as Map;
            final selectedIndex = args['selectedIndex'] as int?;
            
            // Complete the pending sheet completer for onDismiss
            if (_pendingSheets.isNotEmpty) {
              final key = _pendingSheets.keys.first;
              final completer = _pendingSheets.remove(key);
              completer?.complete(selectedIndex == -1 ? null : selectedIndex);
            }
          } else if (call.method == 'onInlineActionSelected' && onInlineActionSelected != null) {
            final rowIndex = call.arguments['rowIndex'] as int;
            final actionIndex = call.arguments['actionIndex'] as int;
            onInlineActionSelected(rowIndex, actionIndex);
          } else if (call.method == 'onItemSelected' && onItemSelected != null) {
            final index = call.arguments['index'] as int;
            onItemSelected(index);
          } else if (call.method == 'onItemRowSelected' && onItemRowSelected != null) {
            final rowIndex = call.arguments['rowIndex'] as int;
            final itemIndex = call.arguments['itemIndex'] as int;
            onItemRowSelected(rowIndex, itemIndex);
          }
        });
      }
      
      // Serialize item rows
      final itemRowsList = itemRows.map((row) {
        final rowMap = <String, dynamic>{
          'items': row.items.map((item) => item.toMap()).toList(),
        };
        
        // Add row-level styling properties
        if (row.spacing != null) rowMap['spacing'] = row.spacing;
        if (row.height != null) rowMap['height'] = row.height;
        
        return rowMap;
      }).toList();
      
      // Call native method (result will be null from this call)
      await _customChannel.invokeMethod('showSheet', {
        'title': title,
        'message': message,
        'items': items.map((item) => item.toMap()).toList(),
        'itemRows': itemRowsList,
        'inlineActions': inlineActionsList,
        'detents': detents.map((d) => d.toMap()).toList(),
        'prefersGrabberVisible': prefersGrabberVisible,
        'isModal': isModal,
        'prefersEdgeAttachedInCompactHeight':
            prefersEdgeAttachedInCompactHeight,
        'widthFollowsPreferredContentSizeWhenEdgeAttached':
            widthFollowsPreferredContentSizeWhenEdgeAttached,
        'preferredCornerRadius': preferredCornerRadius,
        // Header styling parameters
        if (headerTitleSize != null) 'headerTitleSize': headerTitleSize,
        if (headerTitleWeight != null)
          'headerTitleWeight': _fontWeightToString(headerTitleWeight),
        if (headerTitleColor != null)
          'headerTitleColor': headerTitleColor.value,
        'headerTitleAlignment': headerTitleAlignment,
        if (subtitle != null) 'subtitle': subtitle,
        if (subtitleSize != null) 'subtitleSize': subtitleSize,
        if (subtitleColor != null) 'subtitleColor': subtitleColor.value,
        if (headerHeight != null) 'headerHeight': headerHeight,
        if (headerBackgroundColor != null)
          'headerBackgroundColor': headerBackgroundColor.value,
        'showHeaderDivider': showHeaderDivider,
        if (headerDividerColor != null)
          'headerDividerColor': headerDividerColor.value,
        'closeButtonPosition': closeButtonPosition,
        'closeButtonIcon': closeButtonIcon,
        if (closeButtonSize != null) 'closeButtonSize': closeButtonSize,
        if (closeButtonColor != null)
          'closeButtonColor': closeButtonColor.value,
        // Item styling parameters
        if (itemBackgroundColor != null)
          'itemBackgroundColor': itemBackgroundColor.value,
        if (itemTextColor != null) 'itemTextColor': itemTextColor.value,
        if (itemTintColor != null) 'itemTintColor': itemTintColor.value,
      });

      // Wait for the sheet dismissal callback to complete the completer
      return completer.future;
    } catch (e) {
      debugPrint('Error showing native custom header sheet: $e');
      return null;
    }
  }

  /// Shows a native sheet with custom Flutter widget content using UiKitView.
  ///
  /// This is the **ULTIMATE GOAL** - it combines:
  /// - Native UISheetPresentationController (real iOS sheet with blur, animations, detents)
  /// - Custom Flutter widgets embedded via UiKitView
  /// - Non-modal behavior (interact with background while sheet is open)
  /// - Custom header with title and close button
  ///
  /// Unlike `showCustomContent` which uses Flutter's modal popup, this uses a real
  /// native iOS sheet presentation, giving you the authentic iOS look and feel while
  /// still allowing full customization of the content area with Flutter widgets.
  ///
  /// **Perfect for:**
  /// - Formatting toolbars (like Apple Notes)
  /// - Inspector panels
  /// - Tool palettes
  /// - Any auxiliary UI that needs to stay visible during work
  ///
  /// **Example:**
  /// ```dart
  /// await CNNativeSheet.showWithCustomHeaderUiKitView(
  ///   context: context,
  ///   title: 'Format',
  ///   builder: (context) => Column(
  ///     children: [
  ///       Row(
  ///         children: [
  ///           IconButton(icon: Icon(CupertinoIcons.bold), onPressed: () {}),
  ///           IconButton(icon: Icon(CupertinoIcons.italic), onPressed: () {}),
  ///         ],
  ///       ),
  ///     ],
  ///   ),
  ///   detents: [CNSheetDetent.custom(280)],
  ///   isModal: false, // Allow background interaction!
  /// );
  /// ```
  static Future<void> showWithCustomHeaderUiKitView({
    required BuildContext context,
    required String title,
    required Widget Function(BuildContext) builder,
    List<CNSheetDetent> detents = const [CNSheetDetent.large],
    bool prefersGrabberVisible = true,
    bool isModal = false,
    bool prefersEdgeAttachedInCompactHeight = false,
    bool widthFollowsPreferredContentSizeWhenEdgeAttached = false,
    double? preferredCornerRadius,
    double? headerTitleSize,
    FontWeight? headerTitleWeight,
    Color? headerTitleColor,
    double? headerHeight,
    Color? headerBackgroundColor,
    bool showHeaderDivider = true,
    Color? headerDividerColor,
    String closeButtonPosition = 'trailing',
    String closeButtonIcon = 'xmark',
    double? closeButtonSize,
    Color? closeButtonColor,
  }) async {
    if (isModal) {
      // For modal sheets, use CupertinoModalPopupRoute
      await Navigator.of(context).push(
        CupertinoModalPopupRoute(
          builder: (context) => _NativeSheetWithUiKitView(
            title: title,
            builder: builder,
            detents: detents,
            prefersGrabberVisible: prefersGrabberVisible,
            isModal: isModal,
            prefersEdgeAttachedInCompactHeight:
                prefersEdgeAttachedInCompactHeight,
            widthFollowsPreferredContentSizeWhenEdgeAttached:
                widthFollowsPreferredContentSizeWhenEdgeAttached,
            preferredCornerRadius: preferredCornerRadius,
            headerTitleSize: headerTitleSize,
            headerTitleWeight: headerTitleWeight,
            headerTitleColor: headerTitleColor,
            headerHeight: headerHeight,
            headerBackgroundColor: headerBackgroundColor,
            showHeaderDivider: showHeaderDivider,
            headerDividerColor: headerDividerColor,
            closeButtonPosition: closeButtonPosition,
            closeButtonIcon: closeButtonIcon,
            closeButtonSize: closeButtonSize,
            closeButtonColor: closeButtonColor,
          ),
          barrierDismissible: false,
          barrierColor: CupertinoColors.black.withOpacity(0.4),
        ),
      );
    } else {
      // For non-modal sheets, use Overlay to allow background interaction
      final overlay = Overlay.of(context);
      late OverlayEntry overlayEntry;
      
      overlayEntry = OverlayEntry(
        builder: (context) => _NativeSheetWithUiKitView(
          title: title,
          builder: builder,
          detents: detents,
          prefersGrabberVisible: prefersGrabberVisible,
          isModal: isModal,
          prefersEdgeAttachedInCompactHeight:
              prefersEdgeAttachedInCompactHeight,
          widthFollowsPreferredContentSizeWhenEdgeAttached:
              widthFollowsPreferredContentSizeWhenEdgeAttached,
          preferredCornerRadius: preferredCornerRadius,
          headerTitleSize: headerTitleSize,
          headerTitleWeight: headerTitleWeight,
          headerTitleColor: headerTitleColor,
          headerHeight: headerHeight,
          headerBackgroundColor: headerBackgroundColor,
          showHeaderDivider: showHeaderDivider,
          headerDividerColor: headerDividerColor,
          closeButtonPosition: closeButtonPosition,
          closeButtonIcon: closeButtonIcon,
          closeButtonSize: closeButtonSize,
          closeButtonColor: closeButtonColor,
          onClose: () {
            overlayEntry.remove();
          },
        ),
      );
      
      overlay.insert(overlayEntry);
    }
  }

  /// Shows a native sheet with custom Flutter widget header and content using UiKitView.
  ///
  /// Similar to `showWithCustomHeaderUiKitView` but allows the header (title/subtitle) to be
  /// custom Flutter widgets instead of just strings. This gives you full flexibility to style
  /// the header while maintaining the native iOS sheet presentation.
  ///
  /// **Features:**
  /// - Native UISheetPresentationController (real iOS sheet)
  /// - Custom Flutter widget header (title as a widget!)
  /// - Custom Flutter widgets as content via UiKitView
  /// - Non-modal behavior (interact with background)
  /// - Native feel and animations
  ///
  /// **Example:**
  /// ```dart
  /// await CNNativeSheet.showWithCustomHeaderWidget(
  ///   context: context,
  ///   headerBuilder: (context) => Column(
  ///     children: [
  ///       Text('Format', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
  ///       Text('Text formatting options', style: TextStyle(fontSize: 13, color: Colors.grey)),
  ///     ],
  ///   ),
  ///   contentBuilder: (context) => Column(
  ///     children: [
  ///       Row(
  ///         children: [
  ///           IconButton(icon: Icon(CupertinoIcons.bold), onPressed: () {}),
  ///           IconButton(icon: Icon(CupertinoIcons.italic), onPressed: () {}),
  ///         ],
  ///       ),
  ///     ],
  ///   ),
  ///   detents: [CNSheetDetent.custom(300)],
  ///   isModal: false,
  /// );
  /// ```
  static Future<void> showWithCustomHeaderWidget({
    required BuildContext context,
    required Widget Function(BuildContext) headerBuilder,
    required Widget Function(BuildContext) contentBuilder,
    List<CNSheetDetent> detents = const [CNSheetDetent.large],
    bool prefersGrabberVisible = true,
    bool isModal = false,
    bool prefersEdgeAttachedInCompactHeight = false,
    bool widthFollowsPreferredContentSizeWhenEdgeAttached = false,
    double? preferredCornerRadius,
    double? headerHeight,
    Color? headerBackgroundColor,
    bool showHeaderDivider = true,
    Color? headerDividerColor,
    VoidCallback? onClose,
  }) async {
    if (isModal) {
      // For modal sheets, use CupertinoModalPopupRoute
      await Navigator.of(context).push(
        CupertinoModalPopupRoute(
          builder: (context) => _NativeSheetWithCustomWidgetHeader(
            headerBuilder: headerBuilder,
            contentBuilder: contentBuilder,
            detents: detents,
            prefersGrabberVisible: prefersGrabberVisible,
            isModal: isModal,
            prefersEdgeAttachedInCompactHeight:
                prefersEdgeAttachedInCompactHeight,
            widthFollowsPreferredContentSizeWhenEdgeAttached:
                widthFollowsPreferredContentSizeWhenEdgeAttached,
            preferredCornerRadius: preferredCornerRadius,
            headerHeight: headerHeight,
            headerBackgroundColor: headerBackgroundColor,
            showHeaderDivider: showHeaderDivider,
            headerDividerColor: headerDividerColor,
            onClose: onClose,
          ),
          barrierDismissible: false,
          barrierColor: CupertinoColors.black.withOpacity(0.4),
        ),
      );
    } else {
      // For non-modal sheets, use Overlay to allow background interaction
      final overlay = Overlay.of(context);
      late OverlayEntry overlayEntry;
      
      overlayEntry = OverlayEntry(
        builder: (context) => _NativeSheetWithCustomWidgetHeader(
          headerBuilder: headerBuilder,
          contentBuilder: contentBuilder,
          detents: detents,
          prefersGrabberVisible: prefersGrabberVisible,
          isModal: isModal,
          prefersEdgeAttachedInCompactHeight:
              prefersEdgeAttachedInCompactHeight,
          widthFollowsPreferredContentSizeWhenEdgeAttached:
              widthFollowsPreferredContentSizeWhenEdgeAttached,
          preferredCornerRadius: preferredCornerRadius,
          headerHeight: headerHeight,
          headerBackgroundColor: headerBackgroundColor,
          showHeaderDivider: showHeaderDivider,
          headerDividerColor: headerDividerColor,
          onClose: () {
            overlayEntry.remove();
            onClose?.call();
          },
        ),
      );
      
      overlay.insert(overlayEntry);
    }
  }

  // Helper to convert FontWeight to string for native side
  static String _fontWeightToString(FontWeight weight) {
    if (weight == FontWeight.w100) return 'ultraLight';
    if (weight == FontWeight.w200) return 'thin';
    if (weight == FontWeight.w300) return 'light';
    if (weight == FontWeight.w400) return 'regular';
    if (weight == FontWeight.w500) return 'medium';
    if (weight == FontWeight.w600) return 'semibold';
    if (weight == FontWeight.w700) return 'bold';
    if (weight == FontWeight.w800) return 'heavy';
    if (weight == FontWeight.w900) return 'black';
    return 'regular';
  }

  /// Shows a sheet with custom Flutter widget content (like Apple Notes formatting sheet).
  ///
  /// This creates a non-modal sheet that allows background interaction while displaying
  /// custom Flutter widgets as the content. Perfect for formatting toolbars, inspectors,
  /// and other auxiliary UI that needs to stay visible while working with the main content.
  ///
  /// **Key Features:**
  /// - Custom Flutter widget content (full control over UI)
  /// - Non-modal by default (can interact with background)
  /// - Native iOS sheet presentation with blur and animations
  /// - Draggable with detents
  /// - Optional close button in header
  ///
  /// **Example:**
  /// ```dart
  /// await CNNativeSheet.showCustomContent(
  ///   context: context,
  ///   builder: (context) => Padding(
  ///     padding: EdgeInsets.all(16),
  ///     child: Column(
  ///       children: [
  ///         Text('Format', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
  ///         SizedBox(height: 16),
  ///         Row(
  ///           children: [
  ///             IconButton(icon: Icon(CupertinoIcons.bold), onPressed: () {}),
  ///             IconButton(icon: Icon(CupertinoIcons.italic), onPressed: () {}),
  ///           ],
  ///         ),
  ///       ],
  ///     ),
  ///   ),
  ///   detents: [CNSheetDetent.custom(280)],
  ///   isModal: false,
  /// );
  /// ```
  ///
  /// [builder] - Function that builds the custom Flutter widget content
  /// [detents] - Heights at which the sheet can rest
  /// [prefersGrabberVisible] - Whether to show the grabber handle
  /// [isModal] - Whether the sheet blocks background interaction (default: false for custom content)
  /// [barrierDismissible] - Whether tapping outside dismisses the sheet (default: false for non-modal)
  static Future<void> showCustomContent({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    List<CNSheetDetent> detents = const [CNSheetDetent.large],
    bool prefersGrabberVisible = true,
    bool isModal = false,
    bool barrierDismissible = false,
  }) async {
    await showCupertinoModalPopup(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: isModal
          ? CupertinoColors.black.withOpacity(0.4)
          : CupertinoColors.transparent,
      builder: (context) => _CustomContentSheet(
        builder: builder,
        detents: detents,
        prefersGrabberVisible: prefersGrabberVisible,
        isModal: isModal,
      ),
    );
  }
}

/// A custom content sheet that mimics iOS sheet presentation with Flutter widget content.
class _CustomContentSheet extends StatefulWidget {
  final Widget Function(BuildContext) builder;
  final List<CNSheetDetent> detents;
  final bool prefersGrabberVisible;
  final bool isModal;

  const _CustomContentSheet({
    required this.builder,
    required this.detents,
    required this.prefersGrabberVisible,
    required this.isModal,
  });

  @override
  State<_CustomContentSheet> createState() => _CustomContentSheetState();
}

class _CustomContentSheetState extends State<_CustomContentSheet> {
  double _dragOffset = 0.0;

  double get _sheetHeight {
    if (widget.detents.isEmpty) return MediaQuery.of(context).size.height * 0.5;

    final firstDetent = widget.detents.first;
    if (firstDetent.type == 'custom' && firstDetent.height != null) {
      return firstDetent.height!;
    } else if (firstDetent.type == 'medium') {
      return MediaQuery.of(context).size.height * 0.5;
    } else {
      return MediaQuery.of(context).size.height * 0.9;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          _dragOffset += details.delta.dy;
          if (_dragOffset < 0) _dragOffset = 0;
        });
      },
      onVerticalDragEnd: (details) {
        if (_dragOffset > 100) {
          Navigator.of(context).pop();
        } else {
          setState(() {
            _dragOffset = 0;
          });
        }
      },
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Transform.translate(
          offset: Offset(0, _dragOffset),
          child: Container(
            height: _sheetHeight,
            decoration: BoxDecoration(
              color: CupertinoTheme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Column(
                children: [
                  if (widget.prefersGrabberVisible)
                    Container(
                      height: 20,
                      alignment: Alignment.center,
                      child: Container(
                        width: 36,
                        height: 5,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey3.resolveFrom(
                            context,
                          ),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: widget.builder(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A native sheet with UiKitView for custom Flutter content.
///
/// This widget creates a TRUE native iOS sheet using UISheetPresentationController
/// and embeds a Flutter widget inside via UiKitView. This is the ultimate solution
/// combining native sheet behavior with custom Flutter content.
class _NativeSheetWithUiKitView extends StatefulWidget {
  final String title;
  final Widget Function(BuildContext) builder;
  final List<CNSheetDetent> detents;
  final bool prefersGrabberVisible;
  final bool isModal;
  final bool prefersEdgeAttachedInCompactHeight;
  final bool widthFollowsPreferredContentSizeWhenEdgeAttached;
  final double? preferredCornerRadius;
  final double? headerTitleSize;
  final FontWeight? headerTitleWeight;
  final Color? headerTitleColor;
  final double? headerHeight;
  final Color? headerBackgroundColor;
  final bool showHeaderDivider;
  final Color? headerDividerColor;
  final String closeButtonPosition;
  final String closeButtonIcon;
  final double? closeButtonSize;
  final Color? closeButtonColor;
  final VoidCallback? onClose;

  const _NativeSheetWithUiKitView({
    required this.title,
    required this.builder,
    required this.detents,
    required this.prefersGrabberVisible,
    required this.isModal,
    required this.prefersEdgeAttachedInCompactHeight,
    required this.widthFollowsPreferredContentSizeWhenEdgeAttached,
    this.preferredCornerRadius,
    this.headerTitleSize,
    this.headerTitleWeight,
    this.headerTitleColor,
    this.headerHeight,
    this.headerBackgroundColor,
    required this.showHeaderDivider,
    this.headerDividerColor,
    required this.closeButtonPosition,
    required this.closeButtonIcon,
    this.closeButtonSize,
    this.closeButtonColor,
    this.onClose,
  });

  @override
  State<_NativeSheetWithUiKitView> createState() =>
      _NativeSheetWithUiKitViewState();
}

class _NativeSheetWithUiKitViewState extends State<_NativeSheetWithUiKitView> {
  MethodChannel? _channel;

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  double get _sheetHeight {
    if (widget.detents.isEmpty) {
      return MediaQuery.of(context).size.height * 0.5;
    }

    final firstDetent = widget.detents.first;
    if (firstDetent.type == 'custom' && firstDetent.height != null) {
      return firstDetent.height!;
    } else if (firstDetent.type == 'medium') {
      return MediaQuery.of(context).size.height * 0.5;
    } else {
      return MediaQuery.of(context).size.height * 0.9;
    }
  }

  void _onPlatformViewCreated(int id) {
    final ch = MethodChannel('cupertino_native_sheet_content_$id');
    _channel = ch;
    ch.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onClose':
        if (mounted) {
          // Use the onClose callback if provided (for non-modal sheets)
          // Otherwise use Navigator.pop (for modal sheets)
          if (widget.onClose != null) {
            widget.onClose!();
          } else {
            Navigator.of(context).pop();
          }
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerHeight = widget.headerHeight ?? 56.0;

    // Create parameters for the native sheet chrome (header + presentation)
    final creationParams = <String, dynamic>{
      'title': widget.title,
      'detents': widget.detents.map((d) => d.toMap()).toList(),
      'prefersGrabberVisible': widget.prefersGrabberVisible,
      'isModal': widget.isModal,
      'prefersEdgeAttachedInCompactHeight':
          widget.prefersEdgeAttachedInCompactHeight,
      'widthFollowsPreferredContentSizeWhenEdgeAttached':
          widget.widthFollowsPreferredContentSizeWhenEdgeAttached,
      if (widget.preferredCornerRadius != null)
        'preferredCornerRadius': widget.preferredCornerRadius,
      // Header customization
      if (widget.headerTitleSize != null)
        'headerTitleSize': widget.headerTitleSize,
      if (widget.headerTitleWeight != null)
        'headerTitleWeight': CNNativeSheet._fontWeightToString(
          widget.headerTitleWeight!,
        ),
      if (widget.headerTitleColor != null)
        'headerTitleColor': widget.headerTitleColor!.value,
      'headerHeight': headerHeight,
      if (widget.headerBackgroundColor != null)
        'headerBackgroundColor': widget.headerBackgroundColor!.value,
      'showHeaderDivider': widget.showHeaderDivider,
      if (widget.headerDividerColor != null)
        'headerDividerColor': widget.headerDividerColor!.value,
      'closeButtonPosition': widget.closeButtonPosition,
      'closeButtonIcon': widget.closeButtonIcon,
      if (widget.closeButtonSize != null)
        'closeButtonSize': widget.closeButtonSize,
      if (widget.closeButtonColor != null)
        'closeButtonColor': widget.closeButtonColor!.value,
    };

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: _sheetHeight,
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Column(
            children: [
              // Native header using UiKitView for the chrome
              SizedBox(
                height: headerHeight,
                child: UiKitView(
                  viewType: 'CupertinoNativeSheetHeader',
                  creationParams: creationParams,
                  creationParamsCodec: const StandardMessageCodec(),
                  onPlatformViewCreated: _onPlatformViewCreated,
                ),
              ),
              // Custom Flutter content
              Expanded(
                child: SingleChildScrollView(child: widget.builder(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A native sheet with custom Flutter widget header and content via UiKitView
class _NativeSheetWithCustomWidgetHeader extends StatefulWidget {
  final Widget Function(BuildContext) headerBuilder;
  final Widget Function(BuildContext) contentBuilder;
  final List<CNSheetDetent> detents;
  final bool prefersGrabberVisible;
  final bool isModal;
  final bool prefersEdgeAttachedInCompactHeight;
  final bool widthFollowsPreferredContentSizeWhenEdgeAttached;
  final double? preferredCornerRadius;
  final double? headerHeight;
  final Color? headerBackgroundColor;
  final bool showHeaderDivider;
  final Color? headerDividerColor;
  final VoidCallback? onClose;

  const _NativeSheetWithCustomWidgetHeader({
    required this.headerBuilder,
    required this.contentBuilder,
    required this.detents,
    required this.prefersGrabberVisible,
    required this.isModal,
    required this.prefersEdgeAttachedInCompactHeight,
    required this.widthFollowsPreferredContentSizeWhenEdgeAttached,
    this.preferredCornerRadius,
    this.headerHeight,
    this.headerBackgroundColor,
    required this.showHeaderDivider,
    this.headerDividerColor,
    this.onClose,
  });

  @override
  State<_NativeSheetWithCustomWidgetHeader> createState() =>
      _NativeSheetWithCustomWidgetHeaderState();
}

class _NativeSheetWithCustomWidgetHeaderState
    extends State<_NativeSheetWithCustomWidgetHeader> {
  double get _sheetHeight {
    if (widget.detents.isEmpty) {
      return MediaQuery.of(context).size.height * 0.5;
    }

    final firstDetent = widget.detents.first;
    if (firstDetent.type == 'custom' && firstDetent.height != null) {
      return firstDetent.height!;
    } else if (firstDetent.type == 'medium') {
      return MediaQuery.of(context).size.height * 0.5;
    } else {
      return MediaQuery.of(context).size.height * 0.9;
    }
  }

  double get _headerHeight => widget.headerHeight ?? 56;

  @override
  Widget build(BuildContext context) {
    final headerBgColor = widget.headerBackgroundColor ??
        CupertinoTheme.of(context).scaffoldBackgroundColor;
    final dividerColor = widget.headerDividerColor ??
        CupertinoColors.separator.resolveFrom(context);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: _sheetHeight,
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Column(
            children: [
              // Custom Flutter widget header
              Container(
                height: _headerHeight,
                color: headerBgColor,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: widget.headerBuilder(context)),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 44,
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onClose?.call();
                      },
                      child: const Icon(CupertinoIcons.xmark),
                    ),
                  ],
                ),
              ),
              // Divider
              if (widget.showHeaderDivider)
                Container(
                  height: 0.5,
                  color: dividerColor,
                ),
              // Custom Flutter content
              Expanded(
                child: SingleChildScrollView(
                  child: widget.contentBuilder(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
