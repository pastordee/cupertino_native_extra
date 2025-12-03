import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

import '../channel/params.dart';
import '../style/sf_symbol.dart';
import '../style/button_style.dart';

/// Base type for entries in a [CNPullDownButton] menu.
abstract class CNPullDownMenuEntry {
  /// Const constructor for subclasses.
  const CNPullDownMenuEntry();
}

/// A selectable item in a pull-down menu.
class CNPullDownMenuItem extends CNPullDownMenuEntry {
  /// Creates a selectable pull-down menu item.
  const CNPullDownMenuItem({
    required this.label, 
    this.icon, 
    this.enabled = true,
    this.isDestructive = false,
    this.subtitle,
    this.hasNavigation = false,
  });

  /// Display label for the item.
  final String label;

  /// Optional SF Symbol shown before the label.
  final CNSymbol? icon;

  /// Whether the item can be selected.
  final bool enabled;

  /// Whether this is a destructive action (shown in red).
  final bool isDestructive;
  
  /// Optional subtitle text shown below the label in gray.
  final String? subtitle;
  
  /// Whether to show a trailing chevron (navigation indicator).
  final bool hasNavigation;
}

/// A visual divider between pull-down menu items.
class CNPullDownMenuDivider extends CNPullDownMenuEntry {
  /// Creates a visual divider between items.
  const CNPullDownMenuDivider();
}

/// A submenu in a pull-down menu.
class CNPullDownMenuSubmenu extends CNPullDownMenuEntry {
  /// Creates a submenu with its own items.
  const CNPullDownMenuSubmenu({
    required this.title,
    required this.items,
    this.icon,
    this.subtitle,
  });

  /// Title of the submenu.
  final String title;

  /// Items in the submenu.
  final List<CNPullDownMenuEntry> items;

  /// Optional SF Symbol shown before the title.
  final CNSymbol? icon;
  
  /// Optional subtitle text shown below the title in gray.
  final String? subtitle;
}

/// A horizontal row of inline action buttons in a pull-down menu.
///
/// These appear as icon buttons across the top of the menu, similar to iOS Notes app.
/// On iOS 15+, this creates a displayInline menu section with prominent buttons.
class CNPullDownMenuInlineActions extends CNPullDownMenuEntry {
  /// Creates a row of inline action buttons.
  const CNPullDownMenuInlineActions({
    required this.actions,
  });

  /// The inline actions to display horizontally.
  final List<CNPullDownInlineAction> actions;
}

/// An individual inline action button.
class CNPullDownInlineAction {
  /// Creates an inline action button.
  const CNPullDownInlineAction({
    required this.label,
    required this.icon,
    this.enabled = true,
  });

  /// Label displayed below the icon.
  final String label;

  /// SF Symbol icon to display.
  final CNSymbol icon;

  /// Whether the action can be tapped.
  final bool enabled;
}

/// A Cupertino-native pull-down button.
///
/// Pull-down buttons display a menu of items or actions that directly relate 
/// to the button's purpose. The menu appears below the button when tapped.
/// 
/// On iOS/macOS this uses native UIButton with UIMenu for authentic behavior.
class CNPullDownButton extends StatefulWidget {
  /// Creates a text-labeled pull-down button.
  const CNPullDownButton({
    super.key,
    required this.buttonLabel,
    required this.items,
    required this.onSelected,
    this.onInlineActionSelected,
    this.tint,
    this.height = 32.0,
    this.shrinkWrap = false,
    this.buttonStyle = CNButtonStyle.plain,
    this.menuTitle,
  }) : buttonIcon = null,
       width = null,
       round = false;

  /// Creates a round, icon-only pull-down button.
  const CNPullDownButton.icon({
    super.key,
    required this.buttonIcon,
    required this.items,
    required this.onSelected,
    this.onInlineActionSelected,
    this.tint,
    double size = 44.0, // button diameter (width = height)
    this.buttonStyle = CNButtonStyle.glass,
    this.menuTitle,
  }) : buttonLabel = null,
       round = true,
       width = size,
       height = size,
       shrinkWrap = false,
       super();

  /// Text for the button (null when using [buttonIcon]).
  final String? buttonLabel;
  
  /// Icon for the button (non-null in icon mode).
  final CNSymbol? buttonIcon;
  
  /// Fixed width in icon mode; otherwise computed/intrinsic.
  final double? width;

  /// Whether this is the round icon variant.
  final bool round;
  
  /// Entries that populate the pull-down menu.
  final List<CNPullDownMenuEntry> items;

  /// Called with the selected index when the user makes a selection.
  final ValueChanged<int> onSelected;

  /// Called with the selected index when an inline action is tapped.
  final ValueChanged<int>? onInlineActionSelected;

  /// Tint color for the control.
  final Color? tint;

  /// Control height; icon mode uses diameter semantics.
  final double height;

  /// If true, sizes the control to its intrinsic width.
  final bool shrinkWrap;

  /// Visual style to apply to the button.
  final CNButtonStyle buttonStyle;

  /// Optional title for the menu.
  final String? menuTitle;

  /// Whether this instance is configured as an icon button variant.
  bool get isIconButton => buttonIcon != null;

  @override
  State<CNPullDownButton> createState() => _CNPullDownButtonState();
}

class _CNPullDownButtonState extends State<CNPullDownButton> {
  MethodChannel? _channel;
  bool? _lastIsDark;
  int? _lastTint;
  int? _lastIconColor;
  double? _intrinsicWidth;
  CNButtonStyle? _lastStyle;
  Offset? _downPosition;
  bool _pressed = false;

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;
  Color? get _effectiveTint =>
      widget.tint ?? CupertinoTheme.of(context).primaryColor;

  @override
  void didUpdateWidget(covariant CNPullDownButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBrightnessIfNeeded();
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
      // Fallback Flutter implementation
      return SizedBox(
        height: widget.height,
        width: widget.isIconButton && widget.round
            ? (widget.width ?? widget.height)
            : null,
        child: CupertinoButton(
          padding: widget.isIconButton
              ? const EdgeInsets.all(4)
              : const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          onPressed: () => _showPullDownMenu(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isIconButton)
                Icon(
                  widget.buttonIcon?.name.isNotEmpty == true 
                    ? IconData(
                        widget.buttonIcon!.name.codeUnitAt(0),
                        fontFamily: 'SF Pro Icons',
                      )
                    : CupertinoIcons.ellipsis_circle, 
                  size: widget.buttonIcon?.size,
                )
              else
                Text(widget.buttonLabel ?? ''),
              if (!widget.isIconButton) ...[
                const SizedBox(width: 4),
                const Icon(
                  CupertinoIcons.chevron_down,
                  size: 12,
                ),
              ],
            ],
          ),
        ),
      );
    }

    const viewType = 'CupertinoNativePullDownButton';

    // Flatten entries into parallel arrays for the platform view.
    final labels = <String>[];
    final symbols = <String>[];
    final isDivider = <bool>[];
    final enabled = <bool>[];
    final isDestructive = <bool>[];
    final sizes = <double?>[];
    final colors = <int?>[];
    final modes = <String?>[];
    final palettes = <List<int?>?>[];
    final gradients = <bool?>[];
    final isInlineAction = <bool>[];
    final subtitles = <String?>[];
    final hasNavigation = <bool>[];
    final submenuItemCounts = <int>[]; // Number of items in each submenu (0 for non-submenus)
    
    // Track inline actions separately for grouping
    final inlineActionLabels = <String>[];
    final inlineActionSymbols = <String>[];
    final inlineActionEnabled = <bool>[];
    final inlineActionSizes = <double?>[];
    final inlineActionColors = <int?>[];
    final inlineActionModes = <String?>[];
    final inlineActionPalettes = <List<int?>?>[];
    final inlineActionGradients = <bool?>[];
    
    for (final e in widget.items) {
      if (e is CNPullDownMenuDivider) {
        labels.add('');
        symbols.add('');
        isDivider.add(true);
        enabled.add(false);
        isDestructive.add(false);
        sizes.add(null);
        colors.add(null);
        modes.add(null);
        palettes.add(null);
        gradients.add(null);
        isInlineAction.add(false);
        subtitles.add(null);
        hasNavigation.add(false);
        submenuItemCounts.add(0);
      } else if (e is CNPullDownMenuItem) {
        labels.add(e.label);
        symbols.add(e.icon?.name ?? '');
        isDivider.add(false);
        enabled.add(e.enabled);
        isDestructive.add(e.isDestructive);
        sizes.add(e.icon?.size);
        colors.add(resolveColorToArgb(e.icon?.color, context));
        modes.add(e.icon?.mode?.name);
        palettes.add(
          e.icon?.paletteColors
              ?.map((c) => resolveColorToArgb(c, context))
              .toList(),
        );
        gradients.add(e.icon?.gradient);
        isInlineAction.add(false);
        subtitles.add(e.subtitle);
        hasNavigation.add(false); // Regular items don't have navigation
        submenuItemCounts.add(0);
      } else if (e is CNPullDownMenuSubmenu) {
        // Add submenu parent
        labels.add(e.title);
        symbols.add(e.icon?.name ?? '');
        isDivider.add(false);
        enabled.add(true);
        isDestructive.add(false);
        sizes.add(e.icon?.size);
        colors.add(resolveColorToArgb(e.icon?.color, context));
        modes.add(e.icon?.mode?.name);
        palettes.add(
          e.icon?.paletteColors
              ?.map((c) => resolveColorToArgb(c, context))
              .toList(),
        );
        gradients.add(e.icon?.gradient);
        isInlineAction.add(false);
        subtitles.add(e.subtitle);
        hasNavigation.add(true); // Submenus show navigation chevron
        submenuItemCounts.add(e.items.length);
        
        // Add submenu child items
        for (final child in e.items) {
          if (child is CNPullDownMenuItem) {
            labels.add(child.label);
            symbols.add(child.icon?.name ?? '');
            isDivider.add(false);
            enabled.add(child.enabled);
            isDestructive.add(child.isDestructive);
            sizes.add(child.icon?.size);
            colors.add(resolveColorToArgb(child.icon?.color, context));
            modes.add(child.icon?.mode?.name);
            palettes.add(
              child.icon?.paletteColors
                  ?.map((c) => resolveColorToArgb(c, context))
                  .toList(),
            );
            gradients.add(child.icon?.gradient);
            isInlineAction.add(false);
            subtitles.add(child.subtitle);
            hasNavigation.add(false);
            submenuItemCounts.add(0);
          } else if (child is CNPullDownMenuDivider) {
            labels.add('');
            symbols.add('');
            isDivider.add(true);
            enabled.add(false);
            isDestructive.add(false);
            sizes.add(null);
            colors.add(null);
            modes.add(null);
            palettes.add(null);
            gradients.add(null);
            isInlineAction.add(false);
            subtitles.add(null);
            hasNavigation.add(false);
            submenuItemCounts.add(0);
          }
        }
      } else if (e is CNPullDownMenuInlineActions) {
        // Add inline actions
        for (final action in e.actions) {
          inlineActionLabels.add(action.label);
          inlineActionSymbols.add(action.icon.name);
          inlineActionEnabled.add(action.enabled);
          inlineActionSizes.add(action.icon.size);
          inlineActionColors.add(resolveColorToArgb(action.icon.color, context));
          inlineActionModes.add(action.icon.mode?.name);
          inlineActionPalettes.add(
            action.icon.paletteColors
                ?.map((c) => resolveColorToArgb(c, context))
                .toList(),
          );
          inlineActionGradients.add(action.icon.gradient);
        }
      }
    }

    final creationParams = <String, dynamic>{
      if (widget.buttonLabel != null) 'buttonTitle': widget.buttonLabel,
      if (widget.buttonIcon != null) 'buttonIconName': widget.buttonIcon!.name,
      if (widget.buttonIcon?.size != null)
        'buttonIconSize': widget.buttonIcon!.size,
      if (widget.buttonIcon?.color != null)
        'buttonIconColor': resolveColorToArgb(
          widget.buttonIcon!.color,
          context,
        ),
      if (widget.isIconButton) 'round': true,
      'buttonStyle': widget.buttonStyle.name,
      'labels': labels,
      'sfSymbols': symbols,
      'isDivider': isDivider,
      'enabled': enabled,
      'isDestructive': isDestructive,
      'sfSymbolSizes': sizes,
      'sfSymbolColors': colors,
      'sfSymbolRenderingModes': modes,
      'sfSymbolPaletteColors': palettes,
      'sfSymbolGradientEnabled': gradients,
      'isDark': _isDark,
      'style': encodeStyle(context, tint: _effectiveTint),
      if (widget.menuTitle != null) 'menuTitle': widget.menuTitle,
      if (widget.buttonIcon?.mode != null)
        'buttonIconRenderingMode': widget.buttonIcon!.mode!.name,
      if (widget.buttonIcon?.paletteColors != null)
        'buttonIconPaletteColors': widget.buttonIcon!.paletteColors!
            .map((c) => resolveColorToArgb(c, context))
            .toList(),
      if (widget.buttonIcon?.gradient != null)
        'buttonIconGradientEnabled': widget.buttonIcon!.gradient,
      'subtitles': subtitles,
      'hasNavigation': hasNavigation,
      'submenuItemCounts': submenuItemCounts,
      // Inline actions
      if (inlineActionLabels.isNotEmpty) ...{
        'inlineActionLabels': inlineActionLabels,
        'inlineActionSymbols': inlineActionSymbols,
        'inlineActionEnabled': inlineActionEnabled,
        'inlineActionSizes': inlineActionSizes,
        'inlineActionColors': inlineActionColors,
        'inlineActionModes': inlineActionModes,
        'inlineActionPaletteColors': inlineActionPalettes,
        'inlineActionGradientEnabled': inlineActionGradients,
      },
    };

    final platformView = defaultTargetPlatform == TargetPlatform.iOS
        ? UiKitView(
            viewType: viewType,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onCreated,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
            },
          )
        : AppKitView(
            viewType: viewType,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onCreated,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
            },
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedWidth = constraints.hasBoundedWidth;
        final preferIntrinsic = widget.shrinkWrap || !hasBoundedWidth;
        double? width;
        if (widget.isIconButton) {
          width = widget.width ?? widget.height;
        } else if (preferIntrinsic) {
          width = _intrinsicWidth ?? 80.0;
        }
        return Listener(
          onPointerDown: (e) {
            _downPosition = e.position;
            _setPressed(true);
          },
          onPointerMove: (e) {
            final start = _downPosition;
            if (start != null && _pressed) {
              final moved = (e.position - start).distance;
              if (moved > kTouchSlop) {
                _setPressed(false);
              }
            }
          },
          onPointerUp: (_) {
            _setPressed(false);
            _downPosition = null;
          },
          onPointerCancel: (_) {
            _setPressed(false);
            _downPosition = null;
          },
          child: SizedBox(
            height: widget.height,
            width: width,
            child: platformView,
          ),
        );
      },
    );
  }

  void _onCreated(int id) {
    final ch = MethodChannel('CupertinoNativePullDownButton_$id');
    _channel = ch;
    ch.setMethodCallHandler(_onMethodCall);
    _lastTint = resolveColorToArgb(_effectiveTint, context);
    _lastIsDark = _isDark;
    _lastIconColor = resolveColorToArgb(widget.buttonIcon?.color, context);
    _lastStyle = widget.buttonStyle;
    if (!widget.isIconButton) {
      _requestIntrinsicSize();
    }
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'itemSelected') {
      final args = call.arguments as Map?;
      final idx = (args?['index'] as num?)?.toInt();
      if (idx != null) widget.onSelected(idx);
    } else if (call.method == 'onInlineActionSelected') {
      final idx = (call.arguments as num?)?.toInt();
      if (idx != null) widget.onInlineActionSelected?.call(idx);
    }
    return null;
  }

  Future<void> _requestIntrinsicSize() async {
    final ch = _channel;
    if (ch == null) return;
    try {
      final size = await ch.invokeMethod<Map>('getIntrinsicSize');
      final w = (size?['width'] as num?)?.toDouble();
      if (w != null && mounted) {
        setState(() => _intrinsicWidth = w);
      }
    } catch (_) {}
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;
    
    // Similar to popup menu button but for pull-down specific properties
    final tint = resolveColorToArgb(_effectiveTint, context);
    final preIconName = widget.buttonIcon?.name;
    final preIconSize = widget.buttonIcon?.size;
    final preIconColor = resolveColorToArgb(widget.buttonIcon?.color, context);
    
    if (_lastTint != tint && tint != null) {
      await ch.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }
    
    if (_lastStyle != widget.buttonStyle) {
      await ch.invokeMethod('setStyle', {
        'buttonStyle': widget.buttonStyle.name,
      });
      _lastStyle = widget.buttonStyle;
    }
    
    // Update other properties as needed...
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;
    final isDark = _isDark;
    final tint = resolveColorToArgb(_effectiveTint, context);
    if (_lastIsDark != isDark) {
      await ch.invokeMethod('setBrightness', {'isDark': isDark});
      _lastIsDark = isDark;
    }
    if (_lastTint != tint && tint != null) {
      await ch.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }
  }

  Future<void> _setPressed(bool pressed) async {
    final ch = _channel;
    if (ch == null) return;
    if (_pressed == pressed) return;
    _pressed = pressed;
    try {
      await ch.invokeMethod('setPressed', {'pressed': pressed});
    } catch (_) {}
  }

  Future<void> _showPullDownMenu() async {
    // Fallback implementation using CupertinoModalPopup
    final selected = await showCupertinoModalPopup<int>(
      context: context,
      builder: (ctx) {
        return CupertinoActionSheet(
          title: widget.menuTitle != null ? Text(widget.menuTitle!) : null,
          actions: [
            for (var i = 0; i < widget.items.length; i++)
              if (widget.items[i] is CNPullDownMenuItem) ...[
                () {
                  final item = widget.items[i] as CNPullDownMenuItem;
                  return CupertinoActionSheetAction(
                    onPressed: () => Navigator.of(ctx).pop(i),
                    isDestructiveAction: item.isDestructive,
                    child: Text(item.label),
                  );
                }(),
              ] else if (widget.items[i] is CNPullDownMenuDivider)
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
    if (selected != null) widget.onSelected(selected);
  }
}