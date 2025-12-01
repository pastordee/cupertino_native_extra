import 'package:cupertino_native_extra/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

/// Demo page showing native iOS Sheet examples
///
/// Demonstrates Apple HIG best practices for native sheets:
/// - Sheets for scoped, contextual tasks
/// - Resizable with detents (medium/large/custom)
/// - Grabber for visual affordance
/// - Nonmodal sheets for Notes-style interaction
/// - Uses native UIKit rendering
class NativeSheetDemoPage extends StatefulWidget {
  const NativeSheetDemoPage({super.key});

  @override
  State<NativeSheetDemoPage> createState() => _NativeSheetDemoPageState();
}

class _NativeSheetDemoPageState extends State<NativeSheetDemoPage> {
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

            // ===== NATIVE SHEETS SECTION =====
            _buildMainSectionHeader(
              'Native Sheet Examples',
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

            // Sheet Example 5: Custom Flutter Widget Sheet
            _buildSectionHeader('Custom Flutter Widget Sheet'),
            _buildExampleCard(
              title: 'Widget Content',
              description:
                  'Native header with custom Flutter widgets as content',
              onTap: () => _showCustomWidgetSheet(),
            ),
            const SizedBox(height: 16),

            // Sheet Example 6: Custom Widget Header Sheet
            _buildSectionHeader('Custom Widget Header Sheet'),
            _buildExampleCard(
              title: 'Widget Header + Content',
              description:
                  'Both header AND content as custom Flutter widgets',
              onTap: () => _showCustomHeaderWidgetSheet(),
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
            '• Nonmodal sheets allow background interaction\n'
            '• Native rendering uses UISheetPresentationController',
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

  // ===== NATIVE SHEET METHODS =====

  /// Example 1: Settings sheet with medium detent
  Future<void> _showSettingsSheet() async {
    final result = await CNSheet.show(
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
    
    if (result != null) {
      final settings = ['Brightness', 'Text Size', 'Appearance', 'Display Zoom'];
      setState(() => _lastAction = '${settings[result]} selected');
    } else {
      setState(() => _lastAction = 'Settings sheet dismissed without selection');
    }
  }

  /// Example 2: Full height edit photo sheet
  Future<void> _showEditPhotoSheet() async {
    await CNSheet.show(
      context: context,
      title: 'Edit Photo',
      message: 'Full height sheet for complex editing tasks',
      items: [
        CNSheetItem(title: 'Crop', icon: 'crop', iconLabelSpacing: 12),
        CNSheetItem(title: 'Adjust', icon: 'slider.horizontal.3', iconLabelSpacing: 12),
        CNSheetItem(title: 'Filters', icon: 'camera.filters', iconLabelSpacing: 12),
        CNSheetItem(title: 'Enhance', icon: 'wand.and.stars', iconLabelSpacing: 12),
        CNSheetItem(title: 'Markup', icon: 'pencil.tip.crop.circle', iconLabelSpacing: 12),
        CNSheetItem(title: 'Retouch', icon: 'bandage', iconLabelSpacing: 12),
      ],
      detents: [CNSheetDetent.large],
      prefersGrabberVisible: true,
      onItemSelected: (index) {
        final edits = ['Crop', 'Adjust', 'Filters', 'Enhance', 'Markup', 'Retouch'];
        setState(() => _lastAction = '${edits[index]} selected for photo');
        print('${edits[index]} selected for photo');
      },
    );
  }

  /// Example 3: Resizable sheet with both detents
  Future<void> _showResizableSheet() async {
    final result = await CNSheet.show(
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
    
    if (result != null) {
      setState(() => _lastAction = 'Item ${result + 1} selected from resizable sheet');
    } else {
      setState(() => _lastAction = 'Resizable sheet dismissed without selection');
    }
  }

  /// Example 4: Nonmodal sheet - allows background interaction like Notes app
  /// Uses NATIVE rendering with simple items for true nonmodal behavior
  /// Uses onItemSelected callback to capture formatting actions without dismissing
  Future<void> _showNonmodalSheet() async {
    final result = await CNSheet.showWithCustomHeader(
      context: context,
      title: 'Format',
      subtitle: 'Background remains interactive',
      headerTitleAlignment: 'center',
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
      inlineActions: [
        CNSheetInlineActions(
          actions: [
            CNSheetInlineAction(
              label: 'B',
              icon: 'bold',
            ),
            CNSheetInlineAction(
              label: 'I',
              icon: 'italic',
              dismissOnTap: false
            ),
            CNSheetInlineAction(
              label: 'U',
              icon: 'underline',
            ),
            CNSheetInlineAction(
              label: 'S',
              icon: 'strikethrough',
            ),
          ],
        ),
      ],
      itemRows: const [
        CNSheetItemRow(
          items: [
            CNSheetItem(
              title: 'Reset All',
              icon: 'arrow.counterclockwise',
            ),
            CNSheetItem(
              title: 'Copy Format',
              icon: 'doc.on.clipboard',
            ),
          ],
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
      // Callback to capture item selections without dismissing the sheet
      onItemSelected: (index) {
        final actions = ['Bold', 'Italic', 'Underline', 'Strikethrough', 'Highlight'];
        setState(() => _lastAction = '${actions[index]} applied (sheet stays open)');
        print('${actions[index]} applied');
      },
      onItemRowSelected: (rowIndex, itemIndex) {
        final itemNames = ['Reset All', 'Copy Format'];
        setState(() => _lastAction = '${itemNames[itemIndex]} tapped in row $rowIndex');
        print('${itemNames[itemIndex]} tapped');
      },
      onInlineActionSelected: (rowIndex, inlineActionIndex) {
        setState(() {
          final inlineActions = ['B', 'I', 'U', 'S'];
          _lastAction = 'Inline action ${inlineActions[inlineActionIndex]} tapped (sheet stays open)';
          print('${inlineActions[inlineActionIndex]} applied');
        });
      },
    );

    // Result is null because all items have dismissOnTap: false
    // Use the onItemSelected callback above to capture individual actions
    if (result == null) {
      setState(() => _lastAction = 'Format sheet closed');
    }
  }

  /// Example 5: Custom Flutter Widget Sheet
  /// Uses native header with UiKitView to render Flutter widgets as content
  Future<void> _showCustomWidgetSheet() async {
    await CNSheet.showWithCustomHeaderUiKitView(
      context: context,
      title: 'Custom Content',
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This is Flutter Widget Content',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6.resolveFrom(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'You can put any Flutter widgets here!\n\n'
                  '• Custom layouts\n'
                  '• Complex widgets\n'
                  '• Interactive elements\n'
                  '• Images and animations',
                  style: TextStyle(fontSize: 15, height: 1.6),
                ),
              ),
              const SizedBox(height: 16),
              // Example of interactive content
              Center(
                child: CupertinoButton(
                  color: CupertinoColors.activeBlue.resolveFrom(context),
                  onPressed: () {
                    setState(() => _lastAction = 'Button tapped in custom widget sheet');
                  },
                  child: const Text('Tap Me!'),
                ),
              ),
              const SizedBox(height: 16),
              // Custom grid example
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: List.generate(
                  9,
                  (index) => Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.activeBlue.resolveFrom(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      detents: [CNSheetDetent.custom(500)],
      prefersGrabberVisible: true,
      isModal: false,
      headerHeight: 56,
      headerTitleWeight: FontWeight.w600,
      closeButtonIcon: 'xmark',
      closeButtonColor: CupertinoColors.label.resolveFrom(context),
    );
    setState(() => _lastAction = 'Custom widget sheet closed');
  }

  /// Example 6: Custom Widget Header Sheet
  /// Uses custom Flutter widgets for BOTH header and content
  Future<void> _showCustomHeaderWidgetSheet() async {
    await CNSheet.showWithCustomHeaderWidget(
      context: context,
      headerBuilder: (context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Advanced Options',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Customize your experience',
            style: TextStyle(
              fontSize: 13,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
        ],
      ),
      contentBuilder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Settings group
            Text(
              'APPEARANCE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                letterSpacing: -0.08,
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingItem(
              context,
              icon: CupertinoIcons.sun_max,
              title: 'Theme',
              subtitle: 'Light & Dark',
            ),
            _buildSettingItem(
              context,
              icon: CupertinoIcons.textformat,
              title: 'Text Size',
              subtitle: 'Adjust for readability',
            ),
            const SizedBox(height: 24),
            
            // Preferences group
            Text(
              'PREFERENCES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                letterSpacing: -0.08,
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingItem(
              context,
              icon: CupertinoIcons.bell,
              title: 'Notifications',
              subtitle: 'Enable alerts',
              trailing: CupertinoSwitch(
                value: true,
                onChanged: (value) {},
              ),
            ),
            _buildSettingItem(
              context,
              icon: CupertinoIcons.lock,
              title: 'Privacy',
              subtitle: 'Control data sharing',
            ),
          ],
        ),
      ),
      detents: [CNSheetDetent.custom(450)],
      prefersGrabberVisible: true,
      isModal: false,
      headerHeight: 80,
      headerBackgroundColor: CupertinoColors.systemBackground
          .resolveFrom(context)
          .withOpacity(0.95),
      showHeaderDivider: true,
    );
    setState(() => _lastAction = 'Custom header widget sheet closed');
  }

  /// Helper widget for settings items
  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: CupertinoColors.activeBlue.resolveFrom(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
