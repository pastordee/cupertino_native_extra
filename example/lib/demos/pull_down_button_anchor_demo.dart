import 'package:cupertino_native_extra/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

/// Demo page showing CNPullDownButtonAnchor with anchored popup menus.
///
/// This demonstrates the anchored menu style where the menu appears
/// near the button with an arrow pointing to it, similar to UIMenu
/// with automatic presentation.
class PullDownButtonAnchorDemo extends StatefulWidget {
  const PullDownButtonAnchorDemo({super.key});

  @override
  State<PullDownButtonAnchorDemo> createState() => _PullDownButtonAnchorDemoState();
}

class _PullDownButtonAnchorDemoState extends State<PullDownButtonAnchorDemo> {
  String _lastAction = 'No action selected';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Pull-Down Button Anchor'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Description
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Text(
                'CNPullDownButtonAnchor creates popup menus that appear anchored to the button, '
                'similar to iOS Settings or toolbar menus. The menu appears near the button with '
                'an arrow pointing to it.',
                style: TextStyle(fontSize: 15, color: CupertinoColors.secondaryLabel),
              ),
            ),

            // Icon Button Example
            _buildSection(
              title: 'Icon Button with Anchored Menu',
              description: 'Tap the ellipsis button to see the anchored menu',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CNPullDownButtonAnchor.icon(
                    buttonIcon: const CNSymbol('ellipsis.circle'),
                    buttonStyle: CNButtonStyle.gray,
                    size: 44,
                    items: const [
                      CNPullDownMenuItem(
                        label: 'Settings',
                        icon: CNSymbol('gear'),
                      ),
                      CNPullDownMenuItem(
                        label: 'Help',
                        icon: CNSymbol('questionmark.circle'),
                      ),
                      CNPullDownMenuItem(
                        label: 'About',
                        icon: CNSymbol('info.circle'),
                      ),
                      CNPullDownMenuDivider(),
                      CNPullDownMenuItem(
                        label: 'Delete',
                        icon: CNSymbol('trash'),
                        isDestructive: true,
                      ),
                    ],
                    onSelected: (index) {
                      setState(() {
                        switch (index) {
                          case 0:
                            _lastAction = 'Settings selected';
                            break;
                          case 1:
                            _lastAction = 'Help selected';
                            break;
                          case 2:
                            _lastAction = 'About selected';
                            break;
                          case 4:
                            _lastAction = 'Delete selected';
                            break;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Text Button Example
            _buildSection(
              title: 'Text Button with Anchored Menu',
              description: 'Text-labeled button with popup menu',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CNPullDownButtonAnchor(
                    buttonLabel: 'Options',
                    buttonStyle: CNButtonStyle.tinted,
                    height: 36,
                    width: 120,
                    items: const [
                      CNPullDownMenuItem(
                        label: 'Copy',
                        icon: CNSymbol('doc.on.doc'),
                      ),
                      CNPullDownMenuItem(
                        label: 'Paste',
                        icon: CNSymbol('doc.on.clipboard'),
                      ),
                      CNPullDownMenuItem(
                        label: 'Share',
                        icon: CNSymbol('square.and.arrow.up'),
                      ),
                      CNPullDownMenuDivider(),
                      CNPullDownMenuItem(
                        label: 'Select All',
                        icon: CNSymbol('selection.pin.in.out'),
                      ),
                    ],
                    onSelected: (index) {
                      setState(() {
                        final actions = ['Copy', 'Paste', 'Share', '', 'Select All'];
                        if (index < actions.length && actions[index].isNotEmpty) {
                          _lastAction = '${actions[index]} selected';
                        }
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Multiple Buttons Example
            _buildSection(
              title: 'Multiple Anchored Buttons',
              description: 'Different styles and configurations',
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CNPullDownButtonAnchor.icon(
                        buttonIcon: const CNSymbol('plus.circle.fill'),
                        buttonStyle: CNButtonStyle.filled,
                        size: 40,
                        items: const [
                          CNPullDownMenuItem(label: 'New Note', icon: CNSymbol('doc.text')),
                          CNPullDownMenuItem(label: 'New Folder', icon: CNSymbol('folder.badge.plus')),
                          CNPullDownMenuItem(label: 'New Scan', icon: CNSymbol('doc.viewfinder')),
                        ],
                        onSelected: (index) {
                          setState(() {
                            final actions = ['New Note', 'New Folder', 'New Scan'];
                            _lastAction = '${actions[index]} selected';
                          });
                        },
                      ),
                      CNPullDownButtonAnchor.icon(
                        buttonIcon: const CNSymbol('square.and.arrow.up'),
                        buttonStyle: CNButtonStyle.tinted,
                        size: 40,
                        items: const [
                          CNPullDownMenuItem(label: 'AirDrop', icon: CNSymbol('airplayaudio')),
                          CNPullDownMenuItem(label: 'Message', icon: CNSymbol('message')),
                          CNPullDownMenuItem(label: 'Mail', icon: CNSymbol('envelope')),
                          CNPullDownMenuItem(label: 'Copy Link', icon: CNSymbol('link')),
                        ],
                        onSelected: (index) {
                          setState(() {
                            final actions = ['AirDrop', 'Message', 'Mail', 'Copy Link'];
                            _lastAction = '${actions[index]} selected';
                          });
                        },
                      ),
                      CNPullDownButtonAnchor.icon(
                        buttonIcon: const CNSymbol('ellipsis'),
                        buttonStyle: CNButtonStyle.plain,
                        size: 40,
                        items: const [
                          CNPullDownMenuItem(label: 'Edit', icon: CNSymbol('pencil')),
                          CNPullDownMenuItem(label: 'Duplicate', icon: CNSymbol('doc.on.doc')),
                          CNPullDownMenuItem(label: 'Move', icon: CNSymbol('folder')),
                          CNPullDownMenuDivider(),
                          CNPullDownMenuItem(label: 'Delete', icon: CNSymbol('trash'), isDestructive: true),
                        ],
                        onSelected: (index) {
                          setState(() {
                            final actions = ['Edit', 'Duplicate', 'Move', '', 'Delete'];
                            if (index < actions.length && actions[index].isNotEmpty) {
                              _lastAction = '${actions[index]} selected';
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Last Action Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Last Action:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _lastAction,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Info box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CupertinoColors.systemBlue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    CupertinoIcons.info_circle,
                    color: CupertinoColors.systemBlue,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'The anchored menu presentation style is iOS 14+. '
                      'On earlier versions or non-Apple platforms, it falls back to CupertinoActionSheet.',
                      style: TextStyle(
                        fontSize: 13,
                        color: CupertinoColors.systemBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(
            fontSize: 13,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: CupertinoColors.separator,
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ],
    );
  }
}
