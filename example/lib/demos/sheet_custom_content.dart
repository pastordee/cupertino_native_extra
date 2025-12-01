import 'package:flutter/cupertino.dart';
import 'package:cupertino_native_extra/cupertino_native.dart';

/// Demo page showing a custom content sheet like the Apple Notes formatting toolbar.
///
/// This demonstrates a non-modal sheet that allows you to interact with the
/// background content while displaying custom Flutter widgets in a native iOS sheet.
class SheetCustomContentDemoPage extends StatefulWidget {
  const SheetCustomContentDemoPage({super.key});

  @override
  State<SheetCustomContentDemoPage> createState() =>
      _SheetCustomContentDemoPageState();
}

class _SheetCustomContentDemoPageState
    extends State<SheetCustomContentDemoPage> {
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderlined = false;
  String _textContent =
      'Select some text and use the formatting toolbar below.';

  void _showFormattingSheet() {
    CNNativeSheet.showCustomContent(
      context: context,
      builder: (context) => _buildFormattingToolbar(),
      detents: [CNSheetDetent.custom(400)],
      prefersGrabberVisible: true,
      isModal: false,
      barrierDismissible: false,
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
            'Format',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          const Text(
            'List Style',
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
                icon: CupertinoIcons.list_bullet,
                label: 'Bullets',
                isActive: false,
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _buildFormatButton(
                icon: CupertinoIcons.list_number,
                label: 'Numbers',
                isActive: false,
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _buildFormatButton(
                icon: CupertinoIcons.arrow_right_arrow_left,
                label: 'Indent',
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
        middle: const Text('Custom Content Sheet'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.textformat),
          onPressed: _showFormattingSheet,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Non-Modal Sheet Demo',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'This demo shows a custom content sheet similar to the Apple Notes formatting toolbar. '
              'Tap the format button in the navigation bar to open the sheet.',
              style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
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
              'Features:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(
              '✓ Non-modal: You can scroll this background content while the sheet is open',
            ),
            _buildFeatureItem(
              '✓ Custom widgets: Full Flutter widget support inside the sheet',
            ),
            _buildFeatureItem(
              '✓ Native presentation: iOS-style blur and animations',
            ),
            _buildFeatureItem('✓ Draggable: Pull to dismiss or adjust height'),
            _buildFeatureItem(
              '✓ Scrollable: Both background and sheet content are independently scrollable',
            ),
            const SizedBox(height: 32),
            // Add more content to demonstrate scrolling
            ...List.generate(
              10,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Paragraph ${index + 1}: This is additional content to demonstrate that you can scroll the background while the sheet is open. Try scrolling this page while the formatting toolbar is visible!',
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

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, color: CupertinoColors.systemGrey),
      ),
    );
  }
}
