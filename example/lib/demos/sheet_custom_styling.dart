import 'package:flutter/cupertino.dart';
import 'package:cupertino_native_extra/cupertino_native.dart';

/// Demo page showing advanced customization options for native sheets.
///
/// Demonstrates:
/// - Custom header colors (background, title, divider, close button)
/// - Custom fonts (size and weight)
/// - Different close button positions and icons
/// - Custom close button sizes
/// - Multiple styling examples
class SheetCustomStylingDemoPage extends StatefulWidget {
  const SheetCustomStylingDemoPage({super.key});

  @override
  State<SheetCustomStylingDemoPage> createState() =>
      _SheetCustomStylingDemoPageState();
}

class _SheetCustomStylingDemoPageState
    extends State<SheetCustomStylingDemoPage> {
  void _showDefaultSheet() {
    CNNativeSheet.showWithCustomHeaderUiKitView(
      context: context,
      title: 'Default Style',
      builder: (context) => _buildContent(
        'Default system styling with blur',
        'Non-modal - tap close button to dismiss',
      ),
      detents: [CNSheetDetent.custom(300)],
      prefersGrabberVisible: true,
      isModal: false,
    );
  }

  void _showCustomColorSheet() {
    CNNativeSheet.showWithCustomHeaderUiKitView(
      context: context,
      title: 'Custom Colors',
      builder: (context) => _buildContent(
        'Custom header and text colors',
        'Non-modal - close button works correctly',
      ),
      detents: [CNSheetDetent.custom(300)],
      prefersGrabberVisible: true,
      isModal: false,
      // Custom styling
      headerBackgroundColor: const Color(0xFF1E1E1E),
      headerTitleColor: CupertinoColors.systemYellow,
      headerDividerColor: CupertinoColors.systemYellow.withOpacity(0.3),
      closeButtonColor: CupertinoColors.systemYellow,
    );
  }

  void _showBrandedSheet() {
    CNNativeSheet.showWithCustomHeaderUiKitView(
      context: context,
      title: 'Premium Feature',
      builder: (context) => _buildContent(
        'Branded with custom colors',
        'Non-modal - background is interactive',
      ),
      detents: [CNSheetDetent.custom(300)],
      prefersGrabberVisible: true,
      isModal: false,
      // Brand styling
      headerBackgroundColor: CupertinoColors.systemPurple,
      headerTitleColor: CupertinoColors.white,
      headerTitleSize: 20,
      headerTitleWeight: FontWeight.bold,
      headerDividerColor: CupertinoColors.white.withOpacity(0.2),
      closeButtonColor: CupertinoColors.white,
      closeButtonSize: 20,
    );
  }

  void _showMinimalSheet() {
    CNNativeSheet.showWithCustomHeaderUiKitView(
      context: context,
      title: 'Minimal',
      builder: (context) => _buildContent(
        'Clean and minimal design',
        'Non-modal with chevron down button',
      ),
      detents: [CNSheetDetent.custom(300)],
      prefersGrabberVisible: false,
      isModal: false,
      // Minimal styling
      headerBackgroundColor: CupertinoColors.systemGrey6,
      headerTitleSize: 15,
      headerTitleWeight: FontWeight.w500,
      headerTitleColor: CupertinoColors.systemGrey,
      showHeaderDivider: false,
      closeButtonIcon: 'chevron.down',
      closeButtonColor: CupertinoColors.systemGrey,
      closeButtonSize: 14,
    );
  }

  void _showAlertStyleSheet() {
    CNNativeSheet.showWithCustomHeaderUiKitView(
      context: context,
      title: 'Warning',
      builder: (context) => _buildContent(
        'Alert-style header',
        'Modal - blocks background interaction',
      ),
      detents: [CNSheetDetent.custom(300)],
      prefersGrabberVisible: true,
      isModal: true, // Modal for alert
      // Alert styling
      headerBackgroundColor: const Color(0xFFFFEBEE),
      headerTitleColor: CupertinoColors.destructiveRed,
      headerTitleSize: 18,
      headerTitleWeight: FontWeight.w600,
      headerDividerColor: CupertinoColors.destructiveRed.withOpacity(0.3),
      closeButtonColor: CupertinoColors.destructiveRed,
      closeButtonIcon: 'xmark.circle.fill',
    );
  }

  void _showSuccessSheet() {
    CNNativeSheet.showWithCustomHeaderUiKitView(
      context: context,
      title: '✓ Success',
      builder: (context) => _buildContent(
        'Success confirmation',
        'Non-modal - try scrolling the list behind',
      ),
      detents: [CNSheetDetent.custom(300)],
      prefersGrabberVisible: true,
      isModal: false,
      // Success styling
      headerBackgroundColor: const Color(0xFFE8F5E9),
      headerTitleColor: CupertinoColors.systemGreen,
      headerTitleSize: 18,
      headerTitleWeight: FontWeight.w600,
      headerDividerColor: CupertinoColors.systemGreen.withOpacity(0.3),
      closeButtonColor: CupertinoColors.systemGreen,
      closeButtonIcon: 'checkmark.circle.fill',
    );
  }

  Widget _buildContent(String description, String behaviorNote) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(CupertinoIcons.info_circle,
                    color: CupertinoColors.systemGrey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    behaviorNote,
                    style: const TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'This demonstrates the powerful customization options available for native sheets. You can match your brand, create themed experiences, or implement design system colors.',
            style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(CupertinoIcons.hand_thumbsup_fill,
                    color: CupertinoColors.systemBlue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tap the close button to dismiss this sheet!',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Custom Sheet Styling'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Custom Styling Options',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Explore various customization options for native sheets. Each example demonstrates different styling capabilities.',
              style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
            ),
            const SizedBox(height: 32),
            _buildStyleCard(
              title: 'Default Style',
              description: 'System colors with blur effect',
              color: CupertinoColors.systemGrey6,
              icon: CupertinoIcons.circle_grid_3x3,
              onTap: _showDefaultSheet,
            ),
            _buildStyleCard(
              title: 'Custom Colors',
              description: 'Dark header with yellow accents',
              color: const Color(0xFF1E1E1E),
              textColor: CupertinoColors.systemYellow,
              icon: CupertinoIcons.paintbrush_fill,
              onTap: _showCustomColorSheet,
            ),
            _buildStyleCard(
              title: 'Branded',
              description: 'Purple brand theme',
              color: CupertinoColors.systemPurple,
              textColor: CupertinoColors.white,
              icon: CupertinoIcons.star_fill,
              onTap: _showBrandedSheet,
            ),
            _buildStyleCard(
              title: 'Minimal',
              description: 'Clean, understated design',
              color: CupertinoColors.systemGrey6,
              icon: CupertinoIcons.minus_circle,
              onTap: _showMinimalSheet,
            ),
            _buildStyleCard(
              title: 'Alert Style',
              description: 'Warning/error state',
              color: const Color(0xFFFFEBEE),
              textColor: CupertinoColors.destructiveRed,
              icon: CupertinoIcons.exclamationmark_triangle_fill,
              onTap: _showAlertStyleSheet,
            ),
            _buildStyleCard(
              title: 'Success',
              description: 'Confirmation state',
              color: const Color(0xFFE8F5E9),
              textColor: CupertinoColors.systemGreen,
              icon: CupertinoIcons.checkmark_seal_fill,
              onTap: _showSuccessSheet,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: CupertinoColors.systemBlue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(CupertinoIcons.sparkles,
                          color: CupertinoColors.systemBlue, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Customization Options',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem('Header background color'),
                  _buildFeatureItem('Title color, size, and weight'),
                  _buildFeatureItem('Divider color and visibility'),
                  _buildFeatureItem('Close button color, size, and icon'),
                  _buildFeatureItem('Button position (leading/trailing)'),
                  _buildFeatureItem('Automatic dark mode adaptation'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleCard({
    required String title,
    required String description,
    required Color color,
    Color textColor = CupertinoColors.black,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: CupertinoColors.systemGrey4),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: textColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.black,
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
              const Icon(
                CupertinoIcons.chevron_right,
                color: CupertinoColors.systemGrey3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(CupertinoIcons.check_mark_circled_solid,
              color: CupertinoColors.systemBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
