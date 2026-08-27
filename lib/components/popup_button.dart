import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

import '../style/sf_symbol.dart';
import '../style/button_style.dart';

/// A Cupertino-native popup button that displays a menu of mutually exclusive options.
///
/// After selecting an item, the button updates its label to show the current selection,
/// and the menu displays a checkmark next to the selected item.
///
/// This differs from [CNPullDownButton] which shows a menu of actions and doesn't
/// maintain selection state.
///
/// Example:
/// ```dart
/// CNPopupButton(
///   options: ['Never', 'Every Day', 'Every Week', 'Every Month'],
///   selectedIndex: 1,
///   onSelected: (index) {
///     print('Selected: ${options[index]}');
///   },
/// )
/// ```
class CNPopupButton extends StatefulWidget {
  /// Creates a popup button with text label.
  const CNPopupButton({
    super.key,
    required this.options,
    this.selectedIndex = 0,
    required this.onSelected,
    this.tint,
    this.height = 32.0,
    this.width,
    this.buttonStyle = CNButtonStyle.plain,
    this.prefix,
    this.dividerIndices = const [],
  }) : buttonIcon = null,
       round = false;

  /// Creates a round, icon-only popup button.
  const CNPopupButton.icon({
    super.key,
    required this.buttonIcon,
    required this.options,
    this.selectedIndex = 0,
    required this.onSelected,
    this.tint,
    double size = 44.0,
    this.buttonStyle = CNButtonStyle.gray,
    this.prefix,
    this.dividerIndices = const [],
  }) : round = true,
       width = size,
       height = size;

  /// List of option labels to display in the menu.
  final List<String> options;

  /// Index of the currently selected option (0-based).
  final int selectedIndex;

  /// Called when an option is selected, with the index of the selected option.
  final ValueChanged<int> onSelected;

  /// Optional icon for icon-only button variant.
  final CNSymbol? buttonIcon;

  /// Optional prefix text to show before the selected option (e.g., "Repeat: ").
  final String? prefix;
  
  /// Indices of options that should have a divider before them.
  /// For example, [5] will add a divider before the 6th option.
  final List<int> dividerIndices;

  /// Whether this is a round icon button.
  final bool round;

  /// Tint color for the control.
  final Color? tint;

  /// Control height; icon mode uses diameter semantics.
  final double height;

  /// Fixed width; if null, sizes to content.
  final double? width;

  /// Visual style to apply to the button.
  final CNButtonStyle buttonStyle;

  @override
  State<CNPopupButton> createState() => _CNPopupButtonState();
}

class _CNPopupButtonState extends State<CNPopupButton> {
  late int _selectedIndex;
  final String _viewType = 'CupertinoNativePopupButton';
  MethodChannel? _channel;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(CNPopupButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _selectedIndex = widget.selectedIndex;
      _updateSelection();
    }
    if (widget.tint != oldWidget.tint || widget.buttonStyle != oldWidget.buttonStyle) {
      _updateStyle();
    }
  }

  void _updateSelection() {
    _channel?.invokeMethod('setSelection', {
      'selectedIndex': _selectedIndex,
    });
  }

  void _updateStyle() {
    _channel?.invokeMethod('setStyle', {
      'tint': widget.tint?.toARGB32(),
      'buttonStyle': widget.buttonStyle.name,
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;

    // Build button label from selected option and optional prefix
    String buttonLabel;
    if (widget.round || widget.buttonIcon != null) {
      buttonLabel = ''; // Icon buttons don't show text
    } else {
      final selectedOption = _selectedIndex < widget.options.length
          ? widget.options[_selectedIndex]
          : widget.options.first;
      buttonLabel = widget.prefix != null
          ? '${widget.prefix}$selectedOption'
          : selectedOption;
    }

    final creationParams = <String, dynamic>{
      'buttonTitle': buttonLabel,
      'buttonIconName': widget.buttonIcon?.name ?? '',
      'buttonIconSize': widget.buttonIcon?.size ?? 22,
      'round': widget.round,
      'labels': widget.options,
      'selectedIndex': _selectedIndex,
      'prefix': widget.prefix ?? '',
      'dividerIndices': widget.dividerIndices,
      'style': {
        if (widget.tint != null) 'tint': widget.tint!.toARGB32(),
      },
      'buttonStyle': widget.buttonStyle.name,
      'isDark': isDark,
    };

    // Wrap in intrinsic width if no explicit width is provided
    final platformView = _buildPlatformView(creationParams);
    
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: widget.width == null 
          ? IntrinsicWidth(child: platformView)
          : platformView,
    );
  }

  Widget _buildPlatformView(Map<String, dynamic> creationParams) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: _viewType,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: {
          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          ),
        },
      );
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      return AppKitView(
        viewType: _viewType,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: {
          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          ),
        },
      );
    }
    return const SizedBox.shrink();
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('${_viewType}_$id');
    _channel!.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'optionSelected':
        final args = call.arguments as Map;
        final index = args['index'] as int;
        if (index >= 0 && index < widget.options.length) {
          setState(() {
            _selectedIndex = index;
          });
          widget.onSelected(index);
        }
        break;
    }
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }
}
