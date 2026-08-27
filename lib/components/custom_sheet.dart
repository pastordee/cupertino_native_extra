import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'native_sheet.dart'; // For CNSheetDetent

/// An item to display in a custom widget sheet
class CNCustomSheetItem {
  final String? title;
  final String? icon;
  final Widget? widget;
  final bool dismissOnTap;

  /// Creates a simple sheet item with title and optional icon.
  const CNCustomSheetItem({
    required this.title,
    this.icon,
    this.dismissOnTap = true,
  }) : widget = null;

  /// Creates a sheet item with a custom Flutter widget.
  /// Custom widgets use Flutter overlay rendering for rich custom UI.
  const CNCustomSheetItem.widget({
    required this.widget,
    this.dismissOnTap = true,
  }) : title = null,
       icon = null;

  bool get isCustomWidget => widget != null;
}

/// A custom widget sheet presentation using Flutter overlay rendering.
///
/// Use this for sheets with custom Flutter widgets and rich UI that isn't
/// possible with native UIKit rendering. Note that custom widget sheets
/// can be nonmodal but use Flutter overlay instead of native UISheetPresentationController.
///
/// ## When to Use
///
/// - Custom layouts with complex Flutter widgets
/// - Rich UI with segmented controls, toggles, custom components
/// - Full control over styling and animation
///
/// ## Limitations
///
/// - Uses Flutter overlay rendering (not native UIKit)
/// - Nonmodal behavior implemented via Flutter, not UISheetPresentationController
/// - May have slightly different performance characteristics than native sheets
///
/// ## Usage
///
/// **Modal Custom Widget Sheet:**
/// ```dart
/// await CNCustomSheet.show(
///   context: context,
///   title: 'Format',
///   items: [
///     CNCustomSheetItem.widget(
///       widget: MyCustomWidget(),
///       dismissOnTap: false,
///     ),
///   ],
///   isModal: true,
/// );
/// ```
///
/// **Nonmodal Custom Widget Sheet:**
/// ```dart
/// await CNCustomSheet.show(
///   context: context,
///   title: 'Format',
///   items: [
///     CNCustomSheetItem.widget(
///       widget: MyFormatPanel(),
///       dismissOnTap: false,
///     ),
///   ],
///   isModal: false, // Background remains interactive
/// );
/// ```
///
/// **With Custom Header:**
/// ```dart
/// await CNCustomSheet.showWithCustomHeader(
///   context: context,
///   title: 'Format',
///   headerTitleWeight: FontWeight.w600,
///   items: [
///     CNCustomSheetItem.widget(widget: MyWidget()),
///   ],
/// );
/// ```
class CNCustomSheet {
  /// Shows a custom widget sheet with Flutter rendering.
  ///
  /// [title] - Optional title for the sheet
  /// [message] - Optional message below the title
  /// [items] - List of items to display (can include custom widgets)
  /// [detents] - Heights at which the sheet can rest
  /// [prefersGrabberVisible] - Whether to show the grabber handle
  /// [isModal] - Whether the sheet is modal. Set to false for nonmodal behavior.
  /// [preferredCornerRadius] - Custom corner radius for the sheet
  /// [itemBackgroundColor] - Background color for sheet item buttons
  /// [itemTextColor] - Text color for sheet item buttons
  /// [itemTintColor] - Tint color for icons in sheet item buttons
  static Future<int?> show({
    required BuildContext context,
    String? title,
    String? message,
    List<CNCustomSheetItem> items = const [],
    List<CNSheetDetent> detents = const [CNSheetDetent.large],
    bool prefersGrabberVisible = true,
    bool isModal = true,
    double? preferredCornerRadius,
    Color? itemBackgroundColor,
    Color? itemTextColor,
    Color? itemTintColor,
  }) async {
    if (isModal) {
      return _showModalSheet(
        context: context,
        title: title,
        message: message,
        items: items,
        prefersGrabberVisible: prefersGrabberVisible,
        preferredCornerRadius: preferredCornerRadius,
        itemBackgroundColor: itemBackgroundColor,
        itemTextColor: itemTextColor,
        itemTintColor: itemTintColor,
      );
    } else {
      return _showNonmodalSheet(
        context: context,
        title: title,
        message: message,
        items: items,
        detents: detents,
        prefersGrabberVisible: prefersGrabberVisible,
        preferredCornerRadius: preferredCornerRadius,
        itemBackgroundColor: itemBackgroundColor,
        itemTextColor: itemTextColor,
        itemTintColor: itemTintColor,
      );
    }
  }

  /// Shows a custom widget sheet with custom header (title + close button).
  ///
  /// [title] - Title displayed in the header
  /// [message] - Optional message below the header
  /// [items] - List of items to display
  /// [detents] - Heights at which the sheet can rest
  /// [prefersGrabberVisible] - Whether to show the grabber handle
  /// [isModal] - Whether the sheet blocks background interaction
  ///
  /// **Header Styling Options:**
  /// [headerTitleSize] - Font size for the title
  /// [headerTitleWeight] - Font weight for the title
  /// [headerTitleColor] - Color for the title
  /// [headerHeight] - Height of the header bar
  /// [headerBackgroundColor] - Background color of the header
  /// [showHeaderDivider] - Whether to show divider below header
  /// [headerDividerColor] - Color of the header divider
  /// [closeButtonPosition] - Position of close button: 'leading' or 'trailing'
  /// [closeButtonIcon] - SF Symbol name for close button
  /// [closeButtonSize] - Size of the close button icon
  /// [closeButtonColor] - Color of the close button
  /// [itemBackgroundColor] - Background color for sheet item buttons
  /// [itemTextColor] - Text color for sheet item buttons
  /// [itemTintColor] - Tint color for icons in sheet item buttons
  static Future<int?> showWithCustomHeader({
    required BuildContext context,
    required String title,
    String? message,
    List<CNCustomSheetItem> items = const [],
    List<CNSheetDetent> detents = const [CNSheetDetent.large],
    bool prefersGrabberVisible = true,
    bool isModal = true,
    double? preferredCornerRadius,
    // Header styling
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
    // Item styling
    Color? itemBackgroundColor,
    Color? itemTextColor,
    Color? itemTintColor,
  }) async {
    if (isModal) {
      return _showModalSheet(
        context: context,
        title: title,
        message: message,
        items: items,
        prefersGrabberVisible: prefersGrabberVisible,
        preferredCornerRadius: preferredCornerRadius,
        useCustomHeader: true,
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
        itemBackgroundColor: itemBackgroundColor,
        itemTextColor: itemTextColor,
        itemTintColor: itemTintColor,
      );
    } else {
      return _showNonmodalSheet(
        context: context,
        title: title,
        message: message,
        items: items,
        detents: detents,
        prefersGrabberVisible: prefersGrabberVisible,
        preferredCornerRadius: preferredCornerRadius,
        useCustomHeader: true,
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
        itemBackgroundColor: itemBackgroundColor,
        itemTextColor: itemTextColor,
        itemTintColor: itemTintColor,
      );
    }
  }

  static Future<int?> _showModalSheet({
    required BuildContext context,
    String? title,
    String? message,
    required List<CNCustomSheetItem> items,
    bool prefersGrabberVisible = true,
    double? preferredCornerRadius,
    bool useCustomHeader = false,
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
    Color? itemBackgroundColor,
    Color? itemTextColor,
    Color? itemTintColor,
  }) {
    return showCupertinoModalPopup<int>(
      context: context,
      builder: (BuildContext context) => Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(preferredCornerRadius ?? 10),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (prefersGrabberVisible)
                Container(
                  margin: const EdgeInsets.only(top: 6, bottom: 0),
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey3.resolveFrom(context),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              if (useCustomHeader)
                _CustomHeader(
                  title: title ?? '',
                  height: headerHeight,
                  titleSize: headerTitleSize,
                  titleWeight: headerTitleWeight,
                  titleColor: headerTitleColor,
                  backgroundColor: headerBackgroundColor,
                  showDivider: showHeaderDivider,
                  dividerColor: headerDividerColor,
                  closeButtonPosition: closeButtonPosition,
                  closeButtonIcon: closeButtonIcon,
                  closeButtonSize: closeButtonSize,
                  closeButtonColor: closeButtonColor,
                  onClose: () => Navigator.of(context).pop(),
                )
              else if (title != null)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: [
                    if (message != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          message,
                          style: const TextStyle(
                            fontSize: 15,
                            color: CupertinoColors.secondaryLabel,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ...items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;

                      if (item.widget != null) {
                        if (item.dismissOnTap) {
                          return GestureDetector(
                            onTap: () => Navigator.of(context).pop(index),
                            child: item.widget!,
                          );
                        }
                        return item.widget!;
                      } else if (item.title != null) {
                        return CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.of(context).pop(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color:
                                  itemBackgroundColor ??
                                  CupertinoColors.secondarySystemBackground
                                      .resolveFrom(context),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                if (item.icon != null) ...[
                                  Icon(
                                    _parseIconName(item.icon!),
                                    size: 20,
                                    color: itemTintColor,
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Expanded(
                                  child: Text(
                                    item.title!,
                                    style: TextStyle(
                                      fontSize: 17,
                                      color:
                                          itemTextColor ??
                                          CupertinoColors.label,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static double _resolveDetentHeight(
    BuildContext context,
    List<CNSheetDetent> detents,
  ) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final safeBottom = mediaQuery.padding.bottom;
    double resolvedHeight = screenHeight * 0.5;

    for (final detent in detents) {
      switch (detent.type) {
        case 'custom':
          if (detent.height != null) {
            resolvedHeight = detent.height!;
          }
          break;
        case 'large':
          resolvedHeight = math.max(resolvedHeight, screenHeight * 0.9);
          break;
        case 'medium':
          resolvedHeight = math.max(resolvedHeight, screenHeight * 0.5);
          break;
        default:
          break;
      }
    }

    final maxHeight = screenHeight - safeBottom - 24.0;
    resolvedHeight = resolvedHeight.clamp(220.0, maxHeight);
    return resolvedHeight;
  }

  static Future<int?> _showNonmodalSheet({
    required BuildContext context,
    required List<CNCustomSheetItem> items,
    required List<CNSheetDetent> detents,
    String? title,
    String? message,
    bool prefersGrabberVisible = true,
    double? preferredCornerRadius,
    bool useCustomHeader = false,
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
    Color? itemBackgroundColor,
    Color? itemTextColor,
    Color? itemTintColor,
  }) async {
    final overlayState = Overlay.of(context);

    final sheetHeight = _resolveDetentHeight(context, detents);
    final completer = Completer<int?>();

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (overlayContext) => _NonmodalSheetOverlay(
        items: items,
        sheetHeight: sheetHeight,
        prefersGrabberVisible: prefersGrabberVisible,
        cornerRadius: preferredCornerRadius,
        title: title,
        message: message,
        useCustomHeader: useCustomHeader,
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
        itemBackgroundColor: itemBackgroundColor,
        itemTextColor: itemTextColor,
        itemTintColor: itemTintColor,
        onClosed: (value) {
          if (!completer.isCompleted) {
            completer.complete(value);
          }
          entry.remove();
        },
      ),
    );

    overlayState.insert(entry);
    return completer.future;
  }

  // Helper to parse icon names (basic implementation)
  static IconData _parseIconName(String iconName) {
    // Map common SF Symbol names to CupertinoIcons
    switch (iconName) {
      case 'bold':
        return CupertinoIcons.bold;
      case 'italic':
        return CupertinoIcons.italic;
      case 'underline':
        return CupertinoIcons.underline;
      case 'strikethrough':
        return CupertinoIcons.strikethrough;
      case 'paintbrush':
        return CupertinoIcons.paintbrush;
      case 'highlighter':
        return CupertinoIcons.color_filter;
      case 'xmark':
      case 'close':
      case 'dismiss':
        return CupertinoIcons.xmark;
      case 'chevron.down':
        return CupertinoIcons.chevron_down;
      case 'chevron.up':
        return CupertinoIcons.chevron_up;
      default:
        return CupertinoIcons.circle;
    }
  }
}

Color? _resolveDynamicColor(BuildContext context, Color? color) {
  if (color == null) {
    return null;
  }
  if (color is CupertinoDynamicColor) {
    return color.resolveFrom(context);
  }
  return color;
}

class _NonmodalSheetOverlay extends StatefulWidget {
  const _NonmodalSheetOverlay({
    required this.items,
    required this.sheetHeight,
    required this.prefersGrabberVisible,
    this.cornerRadius,
    this.title,
    this.message,
    required this.useCustomHeader,
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
    this.itemBackgroundColor,
    this.itemTextColor,
    this.itemTintColor,
    required this.onClosed,
  });

  final List<CNCustomSheetItem> items;
  final double sheetHeight;
  final bool prefersGrabberVisible;
  final double? cornerRadius;
  final String? title;
  final String? message;
  final bool useCustomHeader;
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
  final Color? itemBackgroundColor;
  final Color? itemTextColor;
  final Color? itemTintColor;
  final ValueChanged<int?> onClosed;

  @override
  State<_NonmodalSheetOverlay> createState() => _NonmodalSheetOverlayState();
}

class _NonmodalSheetOverlayState extends State<_NonmodalSheetOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  Future<void> _close([int? result]) async {
    if (_isClosing) return;
    _isClosing = true;
    await _controller.reverse();
    widget.onClosed(result);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return IgnorePointer(
      ignoring: false,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Container(color: CupertinoColors.transparent),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final dy = (1 - _animation.value) * (widget.sheetHeight + 80);
                return Transform.translate(offset: Offset(0, dy), child: child);
              },
              child: Padding(
                padding: EdgeInsets.only(
                  left: 12,
                  right: 12,
                  bottom: bottomPadding > 0 ? bottomPadding : 12,
                ),
                child: _buildSheet(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheet(BuildContext context) {
    final themeBackground =
        _resolveDynamicColor(context, widget.headerBackgroundColor) ??
        CupertinoColors.systemBackground.resolveFrom(context).withOpacity(0.92);

    final cornerRadius = widget.cornerRadius ?? 32.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(cornerRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: themeBackground,
            border: Border.all(
              color: CupertinoColors.separator
                  .resolveFrom(context)
                  .withOpacity(0.4),
              width: 0.6,
            ),
          ),
          child: SizedBox(
            height: widget.sheetHeight,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.prefersGrabberVisible)
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 4),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey2.resolveFrom(
                            context,
                          ),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                  ),
                if (widget.useCustomHeader)
                  _CustomHeader(
                    title: widget.title ?? '',
                    height: widget.headerHeight,
                    titleSize: widget.headerTitleSize,
                    titleWeight: widget.headerTitleWeight,
                    titleColor: widget.headerTitleColor,
                    backgroundColor: widget.headerBackgroundColor,
                    showDivider: widget.showHeaderDivider,
                    dividerColor: widget.headerDividerColor,
                    closeButtonPosition: widget.closeButtonPosition,
                    closeButtonIcon: widget.closeButtonIcon,
                    closeButtonSize: widget.closeButtonSize,
                    closeButtonColor: widget.closeButtonColor,
                    onClose: () => _close(null),
                  )
                else if (widget.title != null || widget.message != null)
                  _StandardHeader(
                    title: widget.title,
                    message: widget.message,
                    closeButtonIcon: widget.closeButtonIcon,
                    closeButtonSize: widget.closeButtonSize,
                    closeButtonColor: widget.closeButtonColor,
                    onClose: () => _close(null),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _buildContent(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent(BuildContext context) {
    final resolvedItemBackground =
        _resolveDynamicColor(context, widget.itemBackgroundColor) ??
        CupertinoColors.secondarySystemBackground
            .resolveFrom(context)
            .withOpacity(0.8);
    final resolvedItemText =
        _resolveDynamicColor(context, widget.itemTextColor) ??
        CupertinoColors.label.resolveFrom(context);
    final resolvedItemTint =
        _resolveDynamicColor(context, widget.itemTintColor) ??
        CupertinoColors.activeBlue.resolveFrom(context);

    final content = <Widget>[];

    if (widget.useCustomHeader && widget.message != null) {
      content
        ..add(
          Text(
            widget.message!,
            style: TextStyle(
              fontSize: 15,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
            textAlign: TextAlign.center,
          ),
        )
        ..add(const SizedBox(height: 12));
    }

    final entries = widget.items.asMap().entries.toList();
    for (final entry in entries) {
      final index = entry.key;
      final item = entry.value;
      Widget? child;

      if (item.widget != null) {
        child = item.widget!;
        if (item.dismissOnTap) {
          child = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _close(index),
            child: child,
          );
        }
      } else if (item.title != null) {
        child = CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _close(index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: resolvedItemBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (item.icon != null) ...[
                  Icon(
                    CNCustomSheet._parseIconName(item.icon!),
                    size: 20,
                    color: resolvedItemTint,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    item.title!,
                    style: TextStyle(fontSize: 17, color: resolvedItemText),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (child != null) {
        content.add(child);
        if (index != entries.length - 1) {
          content.add(const SizedBox(height: 12));
        }
      }
    }

    return content;
  }
}

class _CustomHeader extends StatelessWidget {
  const _CustomHeader({
    required this.title,
    this.height,
    this.titleSize,
    this.titleWeight,
    this.titleColor,
    this.backgroundColor,
    required this.showDivider,
    this.dividerColor,
    required this.closeButtonPosition,
    required this.closeButtonIcon,
    this.closeButtonSize,
    this.closeButtonColor,
    required this.onClose,
  });

  final String title;
  final double? height;
  final double? titleSize;
  final FontWeight? titleWeight;
  final Color? titleColor;
  final Color? backgroundColor;
  final bool showDivider;
  final Color? dividerColor;
  final String closeButtonPosition;
  final String closeButtonIcon;
  final double? closeButtonSize;
  final Color? closeButtonColor;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final resolvedBackground =
        _resolveDynamicColor(context, backgroundColor) ??
        CupertinoColors.systemBackground.resolveFrom(context).withOpacity(0.92);
    final resolvedDivider =
        _resolveDynamicColor(context, dividerColor) ??
        CupertinoColors.separator.resolveFrom(context).withOpacity(0.6);
    final resolvedTitleColor =
        _resolveDynamicColor(context, titleColor) ??
        CupertinoColors.label.resolveFrom(context);
    final resolvedCloseColor =
        _resolveDynamicColor(context, closeButtonColor) ??
        CupertinoColors.label.resolveFrom(context);

    final closeButton = CupertinoButton(
      padding: const EdgeInsets.all(8),
      onPressed: onClose,
      child: Icon(
        CNCustomSheet._parseIconName(closeButtonIcon),
        size: closeButtonSize ?? 20,
        color: resolvedCloseColor,
      ),
    );

    final titleWidget = Text(
      title,
      style: TextStyle(
        fontSize: titleSize ?? 20,
        fontWeight: titleWeight ?? FontWeight.w600,
        color: resolvedTitleColor,
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: resolvedBackground,
          height: height ?? 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              if (closeButtonPosition == 'leading') closeButton,
              Expanded(child: titleWidget),
              if (closeButtonPosition != 'leading') closeButton,
            ],
          ),
        ),
        if (showDivider) Container(height: 0.6, color: resolvedDivider),
      ],
    );
  }
}

class _StandardHeader extends StatelessWidget {
  const _StandardHeader({
    this.title,
    this.message,
    required this.closeButtonIcon,
    this.closeButtonSize,
    this.closeButtonColor,
    required this.onClose,
  });

  final String? title;
  final String? message;
  final String closeButtonIcon;
  final double? closeButtonSize;
  final Color? closeButtonColor;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final titleColor = CupertinoColors.label.resolveFrom(context);
    final subtitleColor = CupertinoColors.secondaryLabel.resolveFrom(context);
    final closeColor =
        _resolveDynamicColor(context, closeButtonColor) ??
        CupertinoColors.label.resolveFrom(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (message != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    message!,
                    style: TextStyle(fontSize: 15, color: subtitleColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.all(6),
            onPressed: onClose,
            child: Icon(
              CNCustomSheet._parseIconName(closeButtonIcon),
              size: closeButtonSize ?? 20,
              color: closeColor,
            ),
          ),
        ],
      ),
    );
  }
}
