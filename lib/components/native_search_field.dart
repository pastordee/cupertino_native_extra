// Created: 2026-09-26
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';

/// Drives a [CNNativeSearchField] from Dart after it is built.
class CNNativeSearchFieldController {
  MethodChannel? _channel;

  /// Raises the keyboard in the field.
  Future<void> focus() async => _channel?.invokeMethod<void>('focus');

  /// Dismisses the keyboard.
  Future<void> unfocus() async => _channel?.invokeMethod<void>('unfocus');

  /// Replaces the field's text (e.g. a recent search was tapped). Does not
  /// report back through `onChanged`.
  Future<void> setText(String text) async =>
      _channel?.invokeMethod<void>('setText', <String, Object?>{'text': text});
}

/// The search field iOS 26 shows while searching (Mail, Photos, Music): a
/// native `UISearchTextField` in a glass capsule, with a round glass × beside
/// it (hidden with [showsClose] false).
///
/// Only the field is native. `UISearchController` draws its results in a
/// native view controller, where a Flutter app can't draw, so the page around
/// this — recents, suggestions, results — is Flutter. base_plus's
/// `BaseSearch` puts the two together.
///
/// iOS only; give it a height (50 matches the system field).
class CNNativeSearchField extends StatefulWidget {
  /// Creates the field.
  const CNNativeSearchField({
    super.key,
    this.controller,
    this.placeholder = 'Search',
    this.initialText = '',
    this.autofocus = false,
    this.showsClose = true,
    this.tint,
    this.onChanged,
    this.onSubmitted,
    this.onClose,
    this.onFocusChanged,
  });

  /// Lets the page focus the field or set its text.
  final CNNativeSearchFieldController? controller;

  /// Grey text shown while the field is empty.
  final String placeholder;

  /// Text the field starts with.
  final String initialText;

  /// Raise the keyboard as soon as the field appears.
  final bool autofocus;

  /// Show the round × that ends the search.
  final bool showsClose;

  /// Cursor colour.
  final Color? tint;

  /// Every edit, including the in-field clear button.
  final ValueChanged<String>? onChanged;

  /// The keyboard's Search key.
  final ValueChanged<String>? onSubmitted;

  /// The × was tapped.
  final VoidCallback? onClose;

  /// The keyboard came up (true) or went away (false).
  final ValueChanged<bool>? onFocusChanged;

  @override
  State<CNNativeSearchField> createState() => _CNNativeSearchFieldState();
}

class _CNNativeSearchFieldState extends State<CNNativeSearchField> {
  MethodChannel? _channel;

  bool get _isDark =>
      CupertinoTheme.maybeBrightnessOf(context) == Brightness.dark;

  @override
  void didUpdateWidget(covariant CNNativeSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._channel = null;
      widget.controller?._channel = _channel;
    }
    if (oldWidget.placeholder != widget.placeholder ||
        oldWidget.showsClose != widget.showsClose ||
        oldWidget.tint != widget.tint) {
      _sendStyle();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sendStyle();
  }

  @override
  void dispose() {
    widget.controller?._channel = null;
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  void _sendStyle() {
    _channel?.invokeMethod<void>('update', <String, Object?>{
      'placeholder': widget.placeholder,
      'showsClose': widget.showsClose,
      'isDark': _isDark,
      if (widget.tint != null) 'tint': widget.tint!.toARGB32(),
    });
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    final Map<Object?, Object?> args =
        (call.arguments as Map<Object?, Object?>?) ?? const {};
    switch (call.method) {
      case 'onChanged':
        widget.onChanged?.call(args['text'] as String? ?? '');
      case 'onSubmitted':
        widget.onSubmitted?.call(args['text'] as String? ?? '');
      case 'onClose':
        widget.onClose?.call();
      case 'onFocusChanged':
        widget.onFocusChanged?.call(args['focused'] as bool? ?? false);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return UiKitView(
      viewType: 'CupertinoNativeSearchField',
      creationParams: <String, Object?>{
        'placeholder': widget.placeholder,
        'text': widget.initialText,
        'autofocus': widget.autofocus,
        'showsClose': widget.showsClose,
        'isDark': _isDark,
        if (widget.tint != null) 'tint': widget.tint!.toARGB32(),
      },
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: (int id) {
        _channel = MethodChannel('cupertino_native_search_field_$id')
          ..setMethodCallHandler(_onMethodCall);
        widget.controller?._channel = _channel;
      },
    );
  }
}
