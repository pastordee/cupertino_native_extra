import 'package:cupertino_native_extra/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

/// Demo page showing native iOS Action Sheet and Alert examples
///
/// Demonstrates Apple HIG best practices:
/// - Alerts for important decisions requiring acknowledgment
/// - Action sheets for confirming intentional actions
/// - Destructive actions placed at top
/// - Cancel button at bottom
/// - Short, clear titles
/// - Optional descriptive message
class ActionSheetDemoPage extends StatefulWidget {
  const ActionSheetDemoPage({super.key});

  @override
  State<ActionSheetDemoPage> createState() => _ActionSheetDemoPageState();
}

class _ActionSheetDemoPageState extends State<ActionSheetDemoPage> {
  String _lastAction = 'No action taken';
  int _draftCount = 3;
  int _photoCount = 5;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Alerts & Action Sheets'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info section
            _buildInfoSection(),
            const SizedBox(height: 24),

            // ===== ALERTS SECTION =====
            _buildMainSectionHeader(
              'Native Alerts',
              icon: CupertinoIcons.exclamationmark_triangle,
            ),
            const SizedBox(height: 12),

            // Alert Example 1: Information Alert
            _buildSectionHeader('Information Alert'),
            _buildExampleCard(
              title: 'Wi-Fi Disconnected',
              description: 'Simple informational alert with OK button',
              onTap: () => _showWiFiAlert(),
            ),
            const SizedBox(height: 16),

            // Alert Example 2: Confirmation Alert
            _buildSectionHeader('Confirmation Alert'),
            _buildExampleCard(
              title: 'Clear Browser Data',
              description: 'Standard confirmation with Cancel and Confirm',
              onTap: () => _showClearDataAlert(),
            ),
            const SizedBox(height: 16),

            // Alert Example 3: Destructive Alert
            _buildSectionHeader('Destructive Alert'),
            _buildExampleCard(
              title: 'Delete Account',
              description: 'Destructive action that cannot be undone',
              onTap: () => _showDeleteAccountAlert(),
            ),
            const SizedBox(height: 16),

            // Alert Example 4: Three Button Alert
            _buildSectionHeader('Three Button Alert'),
            _buildExampleCard(
              title: 'Unsaved Changes',
              description: 'Multiple options: Don\'t Save, Cancel, Save',
              onTap: () => _showUnsavedChangesAlert(),
            ),
            const SizedBox(height: 32),

            // ===== ACTION SHEETS SECTION =====
            _buildMainSectionHeader(
              'Native Action Sheets',
              icon: CupertinoIcons.square_list,
            ),
            const SizedBox(height: 12),

            // Example 1: Mail - Delete or Save Draft
            _buildSectionHeader('Mail Style - Delete Draft'),
            _buildExampleCard(
              title: 'Delete or Save Draft',
              description:
                  'Common pattern in Mail app when canceling a message',
              onTap: () => _showDeleteDraftSheet(),
            ),
            const SizedBox(height: 16),

            // Example 2: Photos - Delete Photo
            _buildSectionHeader('Photos Style - Delete Photo'),
            _buildExampleCard(
              title: 'Delete Photo',
              description: 'Single destructive action with cancel option',
              onTap: () => _showDeletePhotoSheet(),
            ),
            const SizedBox(height: 16),

            // Example 3: Multiple Options
            _buildSectionHeader('Multiple Options'),
            _buildExampleCard(
              title: 'Share Options',
              description: 'Multiple non-destructive choices',
              onTap: () => _showShareOptionsSheet(),
            ),
            const SizedBox(height: 16),

            // Example 4: Confirmation Dialog
            _buildSectionHeader('Simple Confirmation'),
            _buildExampleCard(
              title: 'Sign Out',
              description: 'Using the convenience method for confirmation',
              onTap: () => _showSignOutConfirmation(),
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
                'Action Sheet Best Practices',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '• Use for choices related to intentional actions\n'
            '• Place destructive actions at top (red)\n'
            '• Always include Cancel button\n'
            '• Keep titles short (single line)\n'
            '• Add message only if necessary',
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
          const SizedBox(height: 12),
          // const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildCounter('Drafts', _draftCount),
              const SizedBox(width: 24),
              _buildCounter('Photos', _photoCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounter(String label, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.systemBlue,
          ),
        ),
      ],
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

  // ===== ALERT METHODS =====

  /// Example 1: Simple informational alert
  Future<void> _showWiFiAlert() async {
    await CNAlert.showInfo(
      title: 'Wi-Fi Connection Lost',
      message: 'Your device is no longer connected to Wi-Fi.',
    );
    setState(() => _lastAction = 'Wi-Fi alert dismissed');
  }

  /// Example 2: Standard confirmation
  Future<void> _showClearDataAlert() async {
    final confirmed = await CNAlert.showConfirmation(
      title: 'Clear Browsing Data?',
      message: 'This will clear your history, cookies, and cache.',
      confirmTitle: 'Clear Data',
      onConfirm: () {
        setState(() => _lastAction = 'Browser data cleared');
      },
    );

    if (!confirmed) {
      setState(() => _lastAction = 'Clear data cancelled');
    }
  }

  /// Example 3: Destructive confirmation
  Future<void> _showDeleteAccountAlert() async {
    final confirmed = await CNAlert.showDestructiveConfirmation(
      title: 'Delete Account?',
      message:
          'This action cannot be undone. All your data will be permanently deleted.',
      destructiveTitle: 'Delete Account',
      onDestroy: () {
        setState(() => _lastAction = 'Account deleted');
      },
    );

    if (!confirmed) {
      setState(() => _lastAction = 'Delete account cancelled');
    }
  }

  /// Example 4: Three-button alert (unsaved changes pattern)
  Future<void> _showUnsavedChangesAlert() async {
    final result = await CNAlert.show(
      title: 'Unsaved Changes',
      message: 'You have unsaved changes. What would you like to do?',
      actions: [
        CNAlertAction(
          title: 'Don\'t Save',
          style: CNAlertActionStyle.destructive,
          onPressed: () {
            setState(() => _lastAction = 'Changes discarded');
          },
        ),
        CNAlertAction(
          title: 'Cancel',
          style: CNAlertActionStyle.cancel,
          onPressed: () {
            setState(() => _lastAction = 'Save cancelled');
          },
        ),
        CNAlertAction(
          title: 'Save',
          style: CNAlertActionStyle.defaultStyle,
          onPressed: () {
            setState(() => _lastAction = 'Changes saved');
          },
        ),
      ],
      preferredActionIndex: 2, // Make "Save" the default button
    );

    if (result == null) {
      setState(() => _lastAction = 'Alert dismissed');
    }
  }

  // ===== ACTION SHEET METHODS =====

  // Example 1: Mail-style delete or save draft
  Future<void> _showDeleteDraftSheet() async {
    final result = await CNActionSheet.show(
      context: context,
      title: 'Save Draft?',
      message: 'You can save this draft to finish it later.',
      actions: [
        CNActionSheetAction(
          title: 'Delete Draft',
          style: CNActionSheetButtonStyle.destructive,
          onPressed: () {
            setState(() {
              if (_draftCount > 0) _draftCount--;
              _lastAction = 'Draft deleted';
            });
          },
        ),
        CNActionSheetAction(
          title: 'Save Draft',
          onPressed: () {
            setState(() {
              _lastAction = 'Draft saved';
            });
          },
        ),
      ],
      cancelAction: CNActionSheetAction(
        title: 'Cancel',
        style: CNActionSheetButtonStyle.cancel,
        onPressed: () {
          setState(() => _lastAction = 'Cancelled draft action');
        },
      ),
    );

    print('Action sheet result: $result');
  }

  // Example 2: Photos-style delete photo
  Future<void> _showDeletePhotoSheet() async {
    await CNActionSheet.show(
      context: context,
      title: 'Delete Photo?',
      message: 'This photo will be deleted permanently.',
      actions: [
        CNActionSheetAction(
          title: 'Delete Photo',
          style: CNActionSheetButtonStyle.destructive,
          onPressed: () {
            setState(() {
              if (_photoCount > 0) _photoCount--;
              _lastAction = 'Photo deleted';
            });
          },
        ),
      ],
      cancelAction: CNActionSheetAction(
        title: 'Cancel',
        onPressed: () {
          setState(() => _lastAction = 'Cancelled photo deletion');
        },
      ),
    );
  }

  // Example 3: Multiple share options
  Future<void> _showShareOptionsSheet() async {
    await CNActionSheet.show(
      context: context,
      title: 'Share',
      actions: [
        CNActionSheetAction(
          title: 'Copy Link',
          onPressed: () {
            setState(() => _lastAction = 'Link copied');
          },
        ),
        CNActionSheetAction(
          title: 'Share via Message',
          onPressed: () {
            setState(() => _lastAction = 'Shared via Message');
          },
        ),
        CNActionSheetAction(
          title: 'Share via Mail',
          onPressed: () {
            setState(() => _lastAction = 'Shared via Mail');
          },
        ),
        CNActionSheetAction(
          title: 'More Options...',
          onPressed: () {
            setState(() => _lastAction = 'Opened more options');
          },
        ),
      ],
      cancelAction: CNActionSheetAction(
        title: 'Cancel',
        onPressed: () {
          setState(() => _lastAction = 'Cancelled sharing');
        },
      ),
    );
  }

  // Example 4: Simple confirmation using convenience method
  Future<void> _showSignOutConfirmation() async {
    final confirmed = await CNActionSheet.showConfirmation(
      context: context,
      title: 'Sign Out?',
      message: 'You can sign back in at any time.',
      confirmTitle: 'Sign Out',
      cancelTitle: 'Cancel',
      onConfirm: () {
        setState(() => _lastAction = 'Signed out');
      },
    );

    if (!confirmed) {
      setState(() => _lastAction = 'Cancelled sign out');
    }
  }
}
