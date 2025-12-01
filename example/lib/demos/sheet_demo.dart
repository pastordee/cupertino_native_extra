import 'package:cupertino_native_extra/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

/// Demo page showing native iOS Sheet examples
///
/// Demonstrates Apple HIG best practices for sheets:
/// - Sheets for scoped, contextual tasks
/// - Resizable with detents (medium/large/custom)
/// - Grabber for visual affordance
/// - Nonmodal sheets for Notes-style interaction
class SheetDemoPage extends StatefulWidget {
  const SheetDemoPage({super.key});

  @override
  State<SheetDemoPage> createState() => _SheetDemoPageState();
}

class _SheetDemoPageState extends State<SheetDemoPage> {
  String _lastAction = 'No action taken';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Native Sheets'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info section
            _buildInfoSection(),
            const SizedBox(height: 24),

            // ===== SHEETS SECTION =====
            _buildMainSectionHeader(
              'Sheet Examples',
              icon: CupertinoIcons.rectangle_on_rectangle,
            ),
            const SizedBox(height: 12),

            // Sheet Example 1: Settings Sheet (Medium Detent)
            _buildSectionHeader('Settings Sheet - Medium Detent'),
            _buildExampleCard(
              title: 'Display Settings',
              description: 'Sheet with medium detent (50% height)',
              onTap: () => _showSettingsSheet(),
            ),
            const SizedBox(height: 16),

            // Sheet Example 2: Photo Editor (Large Detent)
            _buildSectionHeader('Edit Sheet - Full Height'),
            _buildExampleCard(
              title: 'Edit Photo',
              description: 'Full height sheet for complex tasks',
              onTap: () => _showEditPhotoSheet(),
            ),
            const SizedBox(height: 16),

            // Sheet Example 3: Resizable with Grabber
            _buildSectionHeader('Resizable Sheet'),
            _buildExampleCard(
              title: 'Resizable Content',
              description: 'Sheet with both medium and large detents + grabber',
              onTap: () => _showResizableSheet(),
            ),
            const SizedBox(height: 16),

            // Sheet Example 4: Nonmodal Sheet (like Notes app)
            _buildSectionHeader('Nonmodal Sheet - Background Interaction'),
            _buildExampleCard(
              title: 'Text Formatter (Native)',
              description:
                  'True nonmodal - tap styles without closing! Background stays interactive.',
              onTap: () => _showNonmodalSheet(),
            ),
            const SizedBox(height: 16),

            // Sheet Example 5: Nonmodal with Custom Widgets (Flutter Overlay)
            _buildSectionHeader('Custom Widget Nonmodal (Flutter Overlay)'),
            _buildExampleCard(
              title: 'Rich Format Panel',
              description:
                  'Flutter-rendered nonmodal sheet with custom widgets (segmented controls, toggles)',
              onTap: () => _showCustomNonmodalSheet(),
            ),
            const SizedBox(height: 16),

            // Sheet Example 6: Custom Widget Sheet with CNSheetItem.widget()
            _buildSectionHeader('Custom Widget Items (Modal Only)'),
            _buildExampleCard(
              title: 'Rich Custom UI',
              description:
                  'Custom Flutter widgets with rich styling (note: always modal)',
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
                'Native Sheet Best Practices',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '• Use sheets for scoped, contextual tasks\n'
            '• Medium detent (~50%) for quick selections\n'
            '• Large detent (full height) for complex tasks\n'
            '• Grabber provides visual affordance\n'
            '• Nonmodal sheets allow background interaction',
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

  // ===== SHEET METHODS =====

  /// Example 1: Settings sheet with medium detent
  Future<void> _showSettingsSheet() async {
    await CNSheet.show(
      context: context,
      title: 'Display Settings',
      message: 'Sheet with medium detent (50% height)',
      items: [
        CNSheetItem(title: 'Brightness', icon: 'sun.max'),
        CNSheetItem(title: 'Text Size', icon: 'textformat.size'),
        CNSheetItem(title: 'Appearance', icon: 'moon'),
        CNSheetItem(title: 'Display Zoom', icon: 'magnifyingglass'),
      ],
      detents: [CNSheetDetent.medium],
      prefersGrabberVisible: true,
    );
    setState(() => _lastAction = 'Settings sheet dismissed');
  }

  /// Example 2: Full height edit photo sheet
  Future<void> _showEditPhotoSheet() async {
    await CNSheet.show(
      context: context,
      title: 'Edit Photo',
      message: 'Full height sheet for complex editing tasks',
      items: [
        CNSheetItem(title: 'Crop', icon: 'crop'),
        CNSheetItem(title: 'Adjust', icon: 'slider.horizontal.3'),
        CNSheetItem(title: 'Filters', icon: 'camera.filters'),
        CNSheetItem(title: 'Enhance', icon: 'wand.and.stars'),
        CNSheetItem(title: 'Markup', icon: 'pencil.tip.crop.circle'),
        CNSheetItem(title: 'Retouch', icon: 'bandage'),
      ],
      detents: [CNSheetDetent.large],
      prefersGrabberVisible: true,
    );
    setState(() => _lastAction = 'Photo editing dismissed');
  }

  /// Example 3: Resizable sheet with both detents
  Future<void> _showResizableSheet() async {
    await CNSheet.show(
      context: context,
      title: 'Resizable Content',
      message: 'Drag the grabber or scroll to resize',
      items: List.generate(
        10,
        (index) => CNSheetItem(title: 'Item ${index + 1}', icon: 'square.fill'),
      ),
      detents: [CNSheetDetent.medium, CNSheetDetent.large],
      prefersGrabberVisible: true,
    );
    setState(() => _lastAction = 'Resizable sheet dismissed');
  }

  /// Example 4: Nonmodal sheet - allows background interaction like Notes app
  /// Uses NATIVE rendering with simple items for true nonmodal behavior
  Future<void> _showNonmodalSheet() async {
    final result = await CNSheet.showWithCustomHeader(
      context: context,
      title: 'Format',
      message:
          'Tap styles to apply formatting. Background remains interactive!',
      items: [
        CNSheetItem(title: 'Bold', icon: 'bold', dismissOnTap: false),
        CNSheetItem(title: 'Italic', icon: 'italic', dismissOnTap: false),
        CNSheetItem(title: 'Underline', icon: 'underline', dismissOnTap: false),
        CNSheetItem(
          title: 'Strikethrough',
          icon: 'strikethrough',
          dismissOnTap: false,
        ),
        CNSheetItem(
          title: 'Highlight',
          icon: 'paintbrush',
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
      itemBackgroundColor: CupertinoColors.secondarySystemBackground
          .resolveFrom(context),
      itemTextColor: CupertinoColors.label.resolveFrom(context),
      itemTintColor: CupertinoColors.activeBlue.resolveFrom(context),
    );

    if (result != null) {
      final actions = [
        'Bold',
        'Italic',
        'Underline',
        'Strikethrough',
        'Highlight',
      ];
      setState(() => _lastAction = '${actions[result]} applied');
    } else {
      setState(() => _lastAction = 'Format sheet closed');
    }
  }

  /// Example 5: Custom widget nonmodal sheet with Flutter overlay
  /// This uses the Flutter overlay rendering for rich custom UI
  Future<void> _showCustomNonmodalSheet() async {
    final result = await CNSheet.showWithCustomHeader(
      context: context,
      title: 'Format',
      message: 'Full custom UI with Flutter rendering',
      items: [
        CNSheetItem.widget(
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

  /// Example 6: Custom widget sheet with CNSheetItem.widget()
  ///
  /// IMPORTANT: Custom widgets use Flutter rendering which is always MODAL.
  /// For true nonmodal behavior with background interaction, use simple
  /// CNSheetItem(title:, icon:) like in _showNonmodalSheet().
  Future<void> _showCustomWidgetSheet() async {
    final selectedIndex = await CNSheet.show(
      context: context,
      title: 'Text Formatting',
      message: 'Tap an option to apply formatting',
      items: [
        // Custom widget items with rich UI
        CNSheetItem.widget(
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
        CNSheetItem.widget(
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
        CNSheetItem(title: 'Underline', icon: 'underline'),
        CNSheetItem(title: 'Strikethrough', icon: 'strikethrough'),
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
