import 'package:cupertino_native_extra/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

/// Demo page showing custom widget sheet examples
///
/// Demonstrates sheets with custom Flutter widgets:
/// - Flutter overlay rendering for rich custom UI
/// - Nonmodal sheets with custom widgets
/// - CNSheetItem.widget() for complex layouts
/// - Note: Custom widgets always use Flutter overlay (not native UIKit)
class CustomSheetDemoPage extends StatefulWidget {
  const CustomSheetDemoPage({super.key});

  @override
  State<CustomSheetDemoPage> createState() => _CustomSheetDemoPageState();
}

class _CustomSheetDemoPageState extends State<CustomSheetDemoPage> {
  String _lastAction = 'No action taken';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Custom Widget Sheets'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info section
            _buildInfoSection(),
            const SizedBox(height: 24),

            // ===== CUSTOM SHEETS SECTION =====
            _buildMainSectionHeader(
              'Custom Widget Examples',
              icon: CupertinoIcons.square_stack_3d_down_right,
            ),
            const SizedBox(height: 12),

            // Sheet Example 1: Nonmodal with Custom Widgets (Flutter Overlay)
            _buildSectionHeader('Custom Widget Nonmodal (Flutter Overlay)'),
            _buildExampleCard(
              title: 'Rich Format Panel',
              description:
                  'Flutter-rendered nonmodal sheet with custom widgets (segmented controls, toggles)',
              onTap: () => _showCustomNonmodalSheet(),
            ),
            const SizedBox(height: 16),

            // Sheet Example 2: Custom Widget Sheet with CNSheetItem.widget()
            _buildSectionHeader('Custom Widget Items (Modal)'),
            _buildExampleCard(
              title: 'Rich Custom UI',
              description:
                  'Custom Flutter widgets with rich styling (gradient backgrounds)',
              onTap: () => _showCustomWidgetSheet(),
            ),
            const SizedBox(height: 24),

            // Status display
            _buildStatusSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.info_circle_fill,
                color: CupertinoColors.systemBlue.resolveFrom(context),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Custom Widget Sheet Info',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '• Custom widgets use Flutter overlay rendering\n'
            '• Use CNSheetItem.widget() for complex UI\n'
            '• Supports custom layouts and styling\n'
            '• Can be nonmodal for background interaction\n'
            '• Not rendered with native UIKit components',
            style: TextStyle(fontSize: 15, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.secondaryLabel.resolveFrom(context),
          letterSpacing: -0.08,
        ),
      ),
    );
  }

  Widget _buildExampleCard({
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CupertinoColors.separator.resolveFrom(context),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 15,
                      color: CupertinoColors.secondaryLabel.resolveFrom(
                        context,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              CupertinoIcons.chevron_forward,
              size: 20,
              color: CupertinoColors.systemGrey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Last Action',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _lastAction,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildMainSectionHeader(String title, {required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: CupertinoColors.activeBlue.resolveFrom(context),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ===== CUSTOM WIDGET SHEET METHODS =====

  /// Example 1: Custom widget nonmodal sheet with Flutter overlay
  /// This uses the Flutter overlay rendering for rich custom UI
  Future<void> _showCustomNonmodalSheet() async {
    final result = await CNCustomSheet.showWithCustomHeader(
      context: context,
      title: 'Format',
      message: 'Full custom UI with Flutter rendering',
      items: [
        CNCustomSheetItem.widget(
          widget: _NotesFormatPanel(
            onAction: (action) => setState(() => _lastAction = action),
          ),
          dismissOnTap: false,
        ),
      ],
      detents: [CNSheetDetent.custom(360)],
      prefersGrabberVisible: false,
      isModal: false,
      preferredCornerRadius: 36,
      headerHeight: 52,
      headerBackgroundColor: CupertinoColors.systemBackground
          .resolveFrom(context)
          .withOpacity(0.92),
      showHeaderDivider: false,
      headerTitleWeight: FontWeight.w600,
      closeButtonIcon: 'xmark',
      closeButtonColor: CupertinoColors.label.resolveFrom(context),
    );

    setState(
      () => _lastAction = result == null
          ? 'Custom format sheet closed'
          : 'Format action $result',
    );
  }

  /// Example 2: Custom widget sheet with CNCustomSheetItem.widget()
  ///
  /// IMPORTANT: Custom widgets use Flutter rendering which is always MODAL.
  /// For true nonmodal behavior with background interaction, use simple
  /// CNSheetItem(title:, icon:) in native sheets.
  Future<void> _showCustomWidgetSheet() async {
    final selectedIndex = await CNCustomSheet.show(
      context: context,
      title: 'Text Formatting',
      message: 'Tap an option to apply formatting',
      items: [
        // Custom widget items with rich UI
        CNCustomSheetItem.widget(
          widget: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  CupertinoColors.systemBlue,
                  CupertinoColors.systemIndigo,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  CupertinoIcons.bold,
                  color: CupertinoColors.white,
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bold',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.white,
                        ),
                      ),
                      Text(
                        'Make text bold',
                        style: TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        CNCustomSheetItem.widget(
          widget: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  CupertinoColors.systemPurple,
                  CupertinoColors.systemPink,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  CupertinoIcons.italic,
                  color: CupertinoColors.white,
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Italic',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.white,
                        ),
                      ),
                      Text(
                        'Make text italic',
                        style: TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Mix with simple items
        CNCustomSheetItem(title: 'Underline', icon: 'underline'),
        CNCustomSheetItem(title: 'Strikethrough', icon: 'strikethrough'),
      ],
      detents: [CNSheetDetent.medium],
      prefersGrabberVisible: true,
      isModal: true, // Custom widgets force modal behavior
    );

    if (selectedIndex != null) {
      final options = ['Bold', 'Italic', 'Underline', 'Strikethrough'];
      setState(() => _lastAction = '${options[selectedIndex]} applied');
    } else {
      setState(() => _lastAction = 'Custom widget sheet dismissed');
    }
  }
}

// ===== CUSTOM WIDGETS =====

class _NotesFormatPanel extends StatefulWidget {
  const _NotesFormatPanel({this.onAction});

  final ValueChanged<String>? onAction;

  @override
  State<_NotesFormatPanel> createState() => _NotesFormatPanelState();
}

class _NotesFormatPanelState extends State<_NotesFormatPanel> {
  String _heading = 'body';
  final Set<String> _activeStyles = {'bold'};
  String _alignment = 'left';
  String _listStyle = 'bullet';

  void _notify(String action) {
    widget.onAction?.call(action);
  }

  @override
  Widget build(BuildContext context) {
    final segmentedStyle = CupertinoTheme.of(
      context,
    ).textTheme.textStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w600);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CupertinoSlidingSegmentedControl<String>(
          groupValue: _heading,
          children: {
            'title': Text('Title', style: segmentedStyle),
            'heading': Text('Heading', style: segmentedStyle),
            'subheading': Text('Subheading', style: segmentedStyle),
            'body': Text('Body', style: segmentedStyle),
          },
          onValueChanged: (value) {
            if (value == null) return;
            setState(() => _heading = value);
            _notify('Heading: $value');
          },
        ),
        const SizedBox(height: 18),
        _FormatToggleRow(
          buttons: [
            _FormatToggleButtonConfig(
              label: 'B',
              tooltip: 'Bold',
              isActive: _activeStyles.contains('bold'),
              onPressed: () => _toggleStyle('bold'),
            ),
            _FormatToggleButtonConfig(
              label: 'I',
              tooltip: 'Italic',
              isActive: _activeStyles.contains('italic'),
              onPressed: () => _toggleStyle('italic'),
            ),
            _FormatToggleButtonConfig(
              label: 'U',
              tooltip: 'Underline',
              isActive: _activeStyles.contains('underline'),
              onPressed: () => _toggleStyle('underline'),
            ),
            _FormatToggleButtonConfig(
              label: 'S',
              tooltip: 'Strikethrough',
              isActive: _activeStyles.contains('strikethrough'),
              onPressed: () => _toggleStyle('strikethrough'),
            ),
            _FormatToggleButtonConfig.icon(
              icon: CupertinoIcons.pen,
              tooltip: 'Highlight',
              isActive: _activeStyles.contains('highlight'),
              onPressed: () => _toggleStyle('highlight'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _FormatToggleRow(
          buttons: [
            _FormatToggleButtonConfig.icon(
              icon: CupertinoIcons.text_alignleft,
              tooltip: 'Align Left',
              isActive: _alignment == 'left',
              onPressed: () => _setAlignment('left'),
            ),
            _FormatToggleButtonConfig.icon(
              icon: CupertinoIcons.text_aligncenter,
              tooltip: 'Align Center',
              isActive: _alignment == 'center',
              onPressed: () => _setAlignment('center'),
            ),
            _FormatToggleButtonConfig.icon(
              icon: CupertinoIcons.text_alignright,
              tooltip: 'Align Right',
              isActive: _alignment == 'right',
              onPressed: () => _setAlignment('right'),
            ),
            _FormatToggleButtonConfig.icon(
              icon: CupertinoIcons.list_bullet,
              tooltip: 'Bullet List',
              isActive: _listStyle == 'bullet',
              onPressed: () => _setListStyle('bullet'),
            ),
            _FormatToggleButtonConfig.icon(
              icon: CupertinoIcons.list_number,
              tooltip: 'Numbered List',
              isActive: _listStyle == 'number',
              onPressed: () => _setListStyle('number'),
            ),
          ],
        ),
      ],
    );
  }

  void _toggleStyle(String style) {
    setState(() {
      if (_activeStyles.contains(style)) {
        _activeStyles.remove(style);
      } else {
        _activeStyles.add(style);
      }
    });
    _notify(style);
  }

  void _setAlignment(String alignment) {
    setState(() => _alignment = alignment);
    _notify('Alignment: $alignment');
  }

  void _setListStyle(String style) {
    setState(() => _listStyle = style);
    _notify('List style: $style');
  }
}

class _FormatToggleRow extends StatelessWidget {
  const _FormatToggleRow({required this.buttons});

  final List<_FormatToggleButtonConfig> buttons;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < buttons.length; i++) ...[
          Expanded(child: _FormatToggleButton(config: buttons[i])),
          if (i != buttons.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _FormatToggleButtonConfig {
  const _FormatToggleButtonConfig({
    required this.label,
    required this.tooltip,
    required this.isActive,
    required this.onPressed,
  }) : icon = null;

  const _FormatToggleButtonConfig.icon({
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.onPressed,
  }) : label = null;

  final String? label;
  final IconData? icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onPressed;
}

class _FormatToggleButton extends StatelessWidget {
  const _FormatToggleButton({required this.config});

  final _FormatToggleButtonConfig config;

  @override
  Widget build(BuildContext context) {
    final activeBackground = CupertinoColors.activeBlue
        .resolveFrom(context)
        .withOpacity(0.15);
    final inactiveBackground = CupertinoColors.secondarySystemBackground
        .resolveFrom(context)
        .withOpacity(0.7);
    final activeColor = CupertinoColors.activeBlue.resolveFrom(context);
    final inactiveColor = CupertinoColors.label.resolveFrom(context);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: config.onPressed,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: config.isActive ? activeBackground : inactiveBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: config.isActive
                ? activeColor.withOpacity(0.4)
                : CupertinoColors.separator
                      .resolveFrom(context)
                      .withOpacity(0.2),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: config.label != null
            ? Text(
                config.label!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: config.isActive ? activeColor : inactiveColor,
                ),
              )
            : Icon(
                config.icon,
                size: 20,
                color: config.isActive ? activeColor : inactiveColor,
              ),
      ),
    );
  }
}
