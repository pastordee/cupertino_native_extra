import 'package:flutter/cupertino.dart';
import 'package:cupertino_native_extra/cupertino_native.dart';

/// Demo page showing a native sheet with UiKitView embedded content.
///
/// This is the **ULTIMATE GOAL** - using a real native UISheetPresentationController
/// with custom Flutter widgets inside via UiKitView. You get:
/// - Native iOS sheet chrome (blur, detents, presentation)
/// - Custom Flutter widgets for content
/// - Non-modal behavior (interact with background)
class SheetUiKitViewDemoPage extends StatefulWidget {
  const SheetUiKitViewDemoPage({super.key});

  @override
  State<SheetUiKitViewDemoPage> createState() => _SheetUiKitViewDemoPageState();
}

class _SheetUiKitViewDemoPageState extends State<SheetUiKitViewDemoPage> {
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderlined = false;
  String _textContent =
      'This demo uses a REAL native iOS sheet with UiKitView! The sheet chrome is completely native while the content is custom Flutter widgets. Try scrolling the background while the sheet is open!';

  void _showNativeFormattingSheet() {
    CNNativeSheet.showWithCustomHeaderUiKitView(
      context: context,
      title: 'Format',
      builder: (context) => _buildFormattingToolbar(),
      detents: [CNSheetDetent.custom(280), CNSheetDetent.large],
      prefersGrabberVisible: true,
      isModal: false,
      headerTitleWeight: FontWeight.w600,
      closeButtonPosition: 'trailing',
    );
  }

  Widget _buildFormattingToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Text Style',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildFormatButton(
                icon: CupertinoIcons.bold,
                label: 'Bold',
                isActive: _isBold,
                onTap: () => setState(() => _isBold = !_isBold),
              ),
              const SizedBox(width: 12),
              _buildFormatButton(
                icon: CupertinoIcons.italic,
                label: 'Italic',
                isActive: _isItalic,
                onTap: () => setState(() => _isItalic = !_isItalic),
              ),
              const SizedBox(width: 12),
              _buildFormatButton(
                icon: CupertinoIcons.underline,
                label: 'Underline',
                isActive: _isUnderlined,
                onTap: () => setState(() => _isUnderlined = !_isUnderlined),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Typography',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildFormatButton(
                icon: CupertinoIcons.textformat_size,
                label: 'Size',
                isActive: false,
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _buildFormatButton(
                icon: CupertinoIcons.textformat,
                label: 'Font',
                isActive: false,
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _buildFormatButton(
                icon: CupertinoIcons.textformat_alt,
                label: 'Case',
                isActive: false,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Color',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildFormatButton(
                icon: CupertinoIcons.color_filter,
                label: 'Text',
                isActive: false,
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _buildFormatButton(
                icon: CupertinoIcons.paintbrush,
                label: 'Highlight',
                isActive: false,
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _buildFormatButton(
                icon: CupertinoIcons.circle,
                label: 'Fill',
                isActive: false,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Alignment',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildFormatButton(
                icon: CupertinoIcons.text_alignleft,
                label: 'Left',
                isActive: false,
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _buildFormatButton(
                icon: CupertinoIcons.text_aligncenter,
                label: 'Center',
                isActive: false,
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _buildFormatButton(
                icon: CupertinoIcons.text_alignright,
                label: 'Right',
                isActive: false,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildFormatButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? CupertinoColors.activeBlue.withOpacity(0.15)
                : CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 24,
                color: isActive
                    ? CupertinoColors.activeBlue
                    : CupertinoColors.black,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isActive
                      ? CupertinoColors.activeBlue
                      : CupertinoColors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Native Sheet + UiKitView'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.textformat),
          onPressed: _showNativeFormattingSheet,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Ultimate Goal Achieved! 🎉',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CupertinoColors.systemGreen,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.checkmark_seal_fill,
                        color: CupertinoColors.systemGreen,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: const Text(
                          'Native Sheet + UiKitView',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.systemGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This implementation combines:\n'
                    '• Real UISheetPresentationController\n'
                    '• Custom Flutter widgets via UiKitView\n'
                    '• Non-modal interaction with background\n'
                    '• Native blur and animations',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CupertinoColors.systemGrey4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sample Text Editor',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _textContent,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                      fontStyle: _isItalic
                          ? FontStyle.italic
                          : FontStyle.normal,
                      decoration: _isUnderlined
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'How It Works:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              icon: CupertinoIcons.device_phone_portrait,
              title: 'Native Presentation',
              description:
                  'Uses UISheetPresentationController for authentic iOS sheet behavior with proper blur, shadows, and animations.',
            ),
            _buildInfoItem(
              icon: CupertinoIcons.square_stack_3d_down_right,
              title: 'UiKitView Integration',
              description:
                  'Embeds a UiKitView for the native header while the content area contains your custom Flutter widgets.',
            ),
            _buildInfoItem(
              icon: CupertinoIcons.hand_point_right,
              title: 'Non-Modal Magic',
              description:
                  'Set isModal: false to allow background interaction. Scroll this page, tap buttons, select text - all while the sheet is open!',
            ),
            _buildInfoItem(
              icon: CupertinoIcons.paintbrush,
              title: 'Full Customization',
              description:
                  'The content area is pure Flutter - use any widgets, layouts, animations, or interactions you want.',
            ),
            const SizedBox(height: 32),
            // Add more content to demonstrate scrolling
            ...List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Paragraph ${index + 1}: Try opening the formatting toolbar and then scrolling this background content. You\'ll see it works perfectly - this is the real non-modal behavior just like Apple Notes!',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 240), // Space for the sheet
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 24, color: CupertinoColors.systemBlue),
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
