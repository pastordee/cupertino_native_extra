// Backward compatibility wrapper for sheet components
// This file provides a CNSheet class that delegates to the appropriate implementation.
//
// For new code, prefer using:
// - CNNativeSheet for native UIKit rendering
// - CNCustomSheet for custom Flutter widget rendering

import 'package:flutter/widgets.dart';
import 'native_sheet.dart';

// Re-export everything from both modules
export 'native_sheet.dart';
export 'custom_sheet.dart';

/// Backward compatibility class for CNSheet
///
/// Delegates to CNNativeSheet for native rendering.
/// This maintains API compatibility with existing code.
class CNSheet {
  /// Shows a native sheet (delegates to CNNativeSheet)
  static Future<int?> show({
    required context,
    String? title,
    String? message,
    List<CNSheetItem> items = const [],
    List<CNSheetDetent> detents = const [CNSheetDetent.large],
    bool prefersGrabberVisible = true,
    bool isModal = true,
    bool prefersEdgeAttachedInCompactHeight = false,
    bool widthFollowsPreferredContentSizeWhenEdgeAttached = false,
    double? preferredCornerRadius,
    itemBackgroundColor,
    itemTextColor,
    itemTintColor,
    void Function(int index)? onItemSelected,
  }) {
    return CNNativeSheet.show(
      context: context,
      title: title,
      message: message,
      items: items,
      detents: detents,
      prefersGrabberVisible: prefersGrabberVisible,
      isModal: isModal,
      prefersEdgeAttachedInCompactHeight: prefersEdgeAttachedInCompactHeight,
      widthFollowsPreferredContentSizeWhenEdgeAttached:
          widthFollowsPreferredContentSizeWhenEdgeAttached,
      preferredCornerRadius: preferredCornerRadius,
      itemBackgroundColor: itemBackgroundColor,
      itemTextColor: itemTextColor,
      itemTintColor: itemTintColor,
      onItemSelected: onItemSelected,
    );
  }

  /// Shows a sheet with custom header (delegates to CNNativeSheet)
  static Future<int?> showWithCustomHeader({
    required context,
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
    double? headerTitleSize,
    headerTitleWeight,
    headerTitleColor,
    String headerTitleAlignment = 'left',
    String? subtitle,
    double? subtitleSize,
    subtitleColor,
    double? headerHeight,
    headerBackgroundColor,
    bool showHeaderDivider = true,
    headerDividerColor,
    String closeButtonPosition = 'trailing',
    String closeButtonIcon = 'xmark',
    double? closeButtonSize,
    closeButtonColor,
    itemBackgroundColor,
    itemTextColor,
    itemTintColor,
    void Function(int rowIndex, int actionIndex)? onInlineActionSelected,
    void Function(int index)? onItemSelected,
    void Function(int rowIndex, int itemIndex)? onItemRowSelected,
  }) {
    return CNNativeSheet.showWithCustomHeader(
      context: context,
      title: title,
      message: message,
      items: items,
      itemRows: itemRows,
      inlineActions: inlineActions,
      detents: detents,
      prefersGrabberVisible: prefersGrabberVisible,
      isModal: isModal,
      prefersEdgeAttachedInCompactHeight: prefersEdgeAttachedInCompactHeight,
      widthFollowsPreferredContentSizeWhenEdgeAttached:
          widthFollowsPreferredContentSizeWhenEdgeAttached,
      preferredCornerRadius: preferredCornerRadius,
      headerTitleSize: headerTitleSize,
      headerTitleWeight: headerTitleWeight,
      headerTitleColor: headerTitleColor,
      headerTitleAlignment: headerTitleAlignment,
      subtitle: subtitle,
      subtitleSize: subtitleSize,
      subtitleColor: subtitleColor,
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
      onInlineActionSelected: onInlineActionSelected,
      onItemSelected: onItemSelected,
      onItemRowSelected: onItemRowSelected,
    );
  }

  /// Shows a native sheet with custom Flutter widget content using UiKitView (delegates to CNNativeSheet)
  ///
  /// This is the ULTIMATE solution combining:
  /// - Native UISheetPresentationController (real iOS sheet)
  /// - Custom Flutter widgets via UiKitView
  /// - Non-modal behavior (interact with background)
  static Future<void> showWithCustomHeaderUiKitView({
    required context,
    required String title,
    required Widget Function(BuildContext) builder,
    List<CNSheetDetent> detents = const [CNSheetDetent.large],
    bool prefersGrabberVisible = true,
    bool isModal = false,
    bool prefersEdgeAttachedInCompactHeight = false,
    bool widthFollowsPreferredContentSizeWhenEdgeAttached = false,
    double? preferredCornerRadius,
    double? headerTitleSize,
    headerTitleWeight,
    headerTitleColor,
    double? headerHeight,
    headerBackgroundColor,
    bool showHeaderDivider = true,
    headerDividerColor,
    String closeButtonPosition = 'trailing',
    String closeButtonIcon = 'xmark',
    double? closeButtonSize,
    closeButtonColor,
  }) {
    return CNNativeSheet.showWithCustomHeaderUiKitView(
      context: context,
      title: title,
      builder: builder,
      detents: detents,
      prefersGrabberVisible: prefersGrabberVisible,
      isModal: isModal,
      prefersEdgeAttachedInCompactHeight: prefersEdgeAttachedInCompactHeight,
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
    );
  }

  /// Shows a native sheet with custom Flutter widget header and content (delegates to CNNativeSheet)
  static Future<void> showWithCustomHeaderWidget({
    required context,
    required Widget Function(BuildContext) headerBuilder,
    required Widget Function(BuildContext) contentBuilder,
    List<CNSheetDetent> detents = const [CNSheetDetent.large],
    bool prefersGrabberVisible = true,
    bool isModal = false,
    bool prefersEdgeAttachedInCompactHeight = false,
    bool widthFollowsPreferredContentSizeWhenEdgeAttached = false,
    double? preferredCornerRadius,
    double? headerHeight,
    headerBackgroundColor,
    bool showHeaderDivider = true,
    headerDividerColor,
    VoidCallback? onClose,
  }) {
    return CNNativeSheet.showWithCustomHeaderWidget(
      context: context,
      headerBuilder: headerBuilder,
      contentBuilder: contentBuilder,
      detents: detents,
      prefersGrabberVisible: prefersGrabberVisible,
      isModal: isModal,
      prefersEdgeAttachedInCompactHeight: prefersEdgeAttachedInCompactHeight,
      widthFollowsPreferredContentSizeWhenEdgeAttached:
          widthFollowsPreferredContentSizeWhenEdgeAttached,
      preferredCornerRadius: preferredCornerRadius,
      headerHeight: headerHeight,
      headerBackgroundColor: headerBackgroundColor,
      showHeaderDivider: showHeaderDivider,
      headerDividerColor: headerDividerColor,
      onClose: onClose,
    );
  }
}
