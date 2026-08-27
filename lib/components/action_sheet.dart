import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';

/// Button style for action sheet actions
enum CNActionSheetButtonStyle {
  /// Default style
  defaultStyle,

  /// Cancel style (bold text, typically at bottom)
  cancel,

  /// Destructive style (red text, typically at top)
  destructive,
}

/// Represents a single action in an action sheet
class CNActionSheetAction {
  /// The title of the action
  final String title;

  /// The style of the action
  final CNActionSheetButtonStyle style;

  /// Callback when the action is tapped
  final VoidCallback? onPressed;

  const CNActionSheetAction({
    required this.title,
    this.style = CNActionSheetButtonStyle.defaultStyle,
    this.onPressed,
  });
}

/// Native iOS Action Sheet
///
/// An action sheet is a modal view that presents choices related to an action
/// people initiate.
///
/// Best practices from Apple HIG:
/// - Use action sheets to offer choices related to an intentional action
/// - Keep titles short (single line when possible)
/// - Provide a message only if necessary
/// - Make destructive choices visually prominent (place at top)
/// - Always provide a Cancel button that lets people reject destructive actions
/// - Place Cancel button at the bottom
/// - Avoid letting action sheets scroll (too many buttons)
///
/// Example:
/// ```dart
/// CNActionSheet.show(
///   context: context,
///   title: 'Delete Draft?',
///   message: 'This action cannot be undone.',
///   actions: [
///     CNActionSheetAction(
///       title: 'Delete Draft',
///       style: CNActionSheetButtonStyle.destructive,
///       onPressed: () => deleteDraft(),
///     ),
///     CNActionSheetAction(
///       title: 'Save Draft',
///       onPressed: () => saveDraft(),
///     ),
///   ],
///   cancelAction: CNActionSheetAction(
///     title: 'Cancel',
///     style: CNActionSheetButtonStyle.cancel,
///   ),
/// );
/// ```
class CNActionSheet {
  static const MethodChannel _channel = MethodChannel(
    'cupertino_native_action_sheet',
  );

  /// Shows a native iOS action sheet
  ///
  /// [context] - Build context for showing the sheet
  /// [title] - Title text (keep short, ideally single line)
  /// [message] - Optional message for additional context
  /// [actions] - List of actions to display (destructive actions should be first)
  /// [cancelAction] - Optional cancel action (recommended, especially for destructive actions)
  ///
  /// Returns the index of the action that was tapped, or null if cancelled
  static Future<int?> show({
    required BuildContext context,
    String? title,
    String? message,
    required List<CNActionSheetAction> actions,
    CNActionSheetAction? cancelAction,
  }) async {
    if (actions.isEmpty) {
      throw ArgumentError('Actions list cannot be empty');
    }

    // Build the action list for native side
    final List<Map<String, dynamic>> actionMaps = actions.map((action) {
      return {'title': action.title, 'style': action.style.index};
    }).toList();

    // Add cancel action if provided
    Map<String, dynamic>? cancelMap;
    if (cancelAction != null) {
      cancelMap = {
        'title': cancelAction.title,
        'style': CNActionSheetButtonStyle.cancel.index,
      };
    }

    try {
      final result = await _channel.invokeMethod('showActionSheet', {
        'title': title,
        'message': message,
        'actions': actionMaps,
        'cancelAction': cancelMap,
      });

      // Handle the result
      if (result == null) {
        // User cancelled
        return null;
      }

      final int index = result as int;

      // If cancel button was tapped, call its callback
      if (index == -1) {
        cancelAction?.onPressed?.call();
        return null;
      }

      // Call the appropriate action callback
      if (index >= 0 && index < actions.length) {
        actions[index].onPressed?.call();
        return index;
      }

      return null;
    } on PlatformException catch (e) {
      debugPrint('Error showing action sheet: ${e.message}');
      return null;
    }
  }

  /// Shows a simple confirmation action sheet with delete/cancel options
  ///
  /// Common pattern for destructive actions like deleting drafts, removing items, etc.
  ///
  /// Example:
  /// ```dart
  /// final confirmed = await CNActionSheet.showConfirmation(
  ///   context: context,
  ///   title: 'Delete Message?',
  ///   message: 'This action cannot be undone.',
  ///   confirmTitle: 'Delete',
  ///   onConfirm: () => deleteMessage(),
  /// );
  /// ```
  static Future<bool> showConfirmation({
    required BuildContext context,
    String? title,
    String? message,
    String confirmTitle = 'Delete',
    String cancelTitle = 'Cancel',
    VoidCallback? onConfirm,
  }) async {
    final result = await show(
      context: context,
      title: title,
      message: message,
      actions: [
        CNActionSheetAction(
          title: confirmTitle,
          style: CNActionSheetButtonStyle.destructive,
          onPressed: onConfirm,
        ),
      ],
      cancelAction: CNActionSheetAction(
        title: cancelTitle,
        style: CNActionSheetButtonStyle.cancel,
      ),
    );

    return result != null && result == 0;
  }
}
