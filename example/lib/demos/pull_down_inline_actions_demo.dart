import 'package:cupertino_native_extra/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

/// Demo page showing pull-down buttons with inline actions.
///
/// Inline actions appear as horizontal icon buttons at the top of the menu,
/// similar to the iOS Notes app (Scan, Pin Note, Lock buttons).
class PullDownInlineActionsDemo extends StatefulWidget {
  const PullDownInlineActionsDemo({super.key});

  @override
  State<PullDownInlineActionsDemo> createState() =>
      _PullDownInlineActionsDemoState();
}

class _PullDownInlineActionsDemoState
    extends State<PullDownInlineActionsDemo> {
  String _lastAction = 'None';
  String _lastInlineAction = 'None';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Inline Actions Demo'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Pull-Down with Inline Actions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Inline actions appear as horizontal icon buttons at the top of the menu, similar to iOS Notes app.',
              style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
            ),
            const SizedBox(height: 24),

            // Example 1: Notes-style menu
            const Text(
              'Notes-Style Menu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            CNPullDownButton(
              tint: CupertinoColors.systemGreen,
              buttonLabel: 'Note Actions',
              buttonStyle: CNButtonStyle.tinted,
              // menuTitle: 'Note Actions',
              height: 44,
              onSelected: (index) {
                setState(() {
                  _lastAction = 'Menu item $index';
                });
              },
              onInlineActionSelected: (index) {
                final actions = ['Scan', 'Pin Note', 'Lock'];
                setState(() {
                  _lastInlineAction = actions[index];
                });
              },
              items: [
                // Inline actions at top (horizontal)
                CNPullDownMenuInlineActions(
                  actions: [
                    CNPullDownInlineAction(
                      label: 'Scan',
                      icon: CNSymbol(
                        'doc.text.viewfinder',
                        size: 24,
                      ),
                    ),
                    CNPullDownInlineAction(
                      label: 'Pin Note',
                      icon: CNSymbol(
                        'pin',
                        size: 24,
                      ),
                    ),
                    CNPullDownInlineAction(
                      label: 'Lock',
                      icon: CNSymbol(
                        'lock',
                        size: 24,
                      ),
                    ),
                  ],
                ),
                // Regular menu items below
                const CNPullDownMenuDivider(),
                CNPullDownMenuSubmenu(
                  title: 'Find in Note',
                  icon: CNSymbol('magnifyingglass'),
                  items: [
                    CNPullDownMenuItem(
                      label: 'Find in Note',
                      icon: CNSymbol('magnifyingglass'),
                    ),
                  ],
                ),
                CNPullDownMenuItem(
                  label: 'Move Note',
                  icon: CNSymbol('folder'),
                ),
                CNPullDownMenuSubmenu(
                  title: 'Recent Notes',
                  icon: CNSymbol('clock'),
                  items: [
                    CNPullDownMenuItem(
                      label: 'Work Notes',
                      icon: CNSymbol('briefcase'),
                    ),
                    CNPullDownMenuItem(
                      label: 'Personal',
                      icon: CNSymbol('house'),
                    ),
                  ],
                ),
                const CNPullDownMenuDivider(),
                CNPullDownMenuSubmenu(
                  title: 'Math Results',
                  subtitle: 'Suggest Results',
                  icon: CNSymbol('equal.circle'),
                  items: [
                    CNPullDownMenuItem(
                      label: 'Math Results',
                      icon: CNSymbol('equal.circle'),
                    ),
                  ],
                ),
                const CNPullDownMenuDivider(),
                CNPullDownMenuItem(
                  label: 'Lines and Grids',
                  icon: CNSymbol('square.grid.3x3'),
                ),
                CNPullDownMenuSubmenu(
                  title: 'Attachment View',
                  icon: CNSymbol('paperclip'),
                  items: [
                    CNPullDownMenuItem(
                      label: 'Gallery View',
                      icon: CNSymbol('square.grid.2x2'),
                    ),
                    CNPullDownMenuItem(
                      label: 'List View',
                      icon: CNSymbol('list.bullet'),
                    ),
                  ],
                ),
                const CNPullDownMenuDivider(),
                CNPullDownMenuItem(
                  label: 'Delete',
                  icon: CNSymbol('trash'),
                  isDestructive: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Last action: $_lastAction'),
            Text('Last inline action: $_lastInlineAction'),
            const SizedBox(height: 32),

            // Example 2: Photo editing actions
            const Text(
              'Photo Editor Menu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            CNPullDownButton.icon(
              buttonIcon: CNSymbol(
                'ellipsis.circle',
                size: 24,
              ),
              size: 44,
              onSelected: (index) {
                setState(() {
                  _lastAction = 'Edit menu item $index';
                });
              },
              onInlineActionSelected: (index) {
                final actions = ['Crop', 'Filter', 'Adjust'];
                setState(() {
                  _lastInlineAction = actions[index];
                });
              },
              items: [
                // Quick edit actions
                CNPullDownMenuInlineActions(
                  actions: [
                    CNPullDownInlineAction(
                      label: 'Crop',
                      icon: CNSymbol(
                        'crop',
                        size: 24,
                      ),
                    ),
                    CNPullDownInlineAction(
                      label: 'Filter',
                      icon: CNSymbol(
                        'camera.filters',
                        size: 24,
                      ),
                    ),
                    CNPullDownInlineAction(
                      label: 'Adjust',
                      icon: CNSymbol(
                        'slider.horizontal.3',
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const CNPullDownMenuDivider(),
                CNPullDownMenuItem(
                  label: 'Save to Photos',
                  icon: CNSymbol('square.and.arrow.down'),
                ),
                CNPullDownMenuItem(
                  label: 'Duplicate',
                  icon: CNSymbol('doc.on.doc'),
                ),
                const CNPullDownMenuDivider(),
                CNPullDownMenuItem(
                  label: 'Discard Changes',
                  icon: CNSymbol('xmark.circle'),
                  isDestructive: true,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Example 3: File management
            const Text(
              'File Management Menu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            CNPullDownButton(
              buttonLabel: 'Manage File',
              buttonStyle: CNButtonStyle.filled,
              onSelected: (index) {
                setState(() {
                  _lastAction = 'File action $index';
                });
              },
              onInlineActionSelected: (index) {
                final actions = ['Star', 'Tag', 'Info'];
                setState(() {
                  _lastInlineAction = actions[index];
                });
              },
              items: [
                // Quick file actions
                CNPullDownMenuInlineActions(
                  actions: [
                    CNPullDownInlineAction(
                      label: 'Star',
                      icon: CNSymbol(
                        'star',
                        size: 14,
                        mode: CNSymbolRenderingMode.multicolor,
                        paletteColors: [
                          CupertinoColors.systemRed,
                          CupertinoColors.systemGreen,
                        ],
                      ),
                    ),
                    CNPullDownInlineAction(
                      label: 'Tag',
                      icon: CNSymbol(
                        'tag',
                        size: 24,
                      ),
                    ),
                    CNPullDownInlineAction(
                      label: 'Info',
                      icon: CNSymbol(
                        'info.circle',
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const CNPullDownMenuDivider(),
                CNPullDownMenuItem(
                  label: 'Open',
                  icon: CNSymbol('doc'),
                ),
                CNPullDownMenuItem(
                  label: 'Rename',
                  icon: CNSymbol('pencil'),
                ),
                CNPullDownMenuItem(
                  label: 'Move',
                  icon: CNSymbol('folder'),
                ),
                const CNPullDownMenuDivider(),
                CNPullDownMenuItem(
                  label: 'Delete',
                  icon: CNSymbol('trash'),
                  isDestructive: true,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Info section
            const Text(
              'About Inline Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              'Inline actions are displayed as horizontal icon buttons at the top of pull-down menus. '
              'They provide quick access to common actions without requiring the user to scan through '
              'a long list of menu items. This pattern is commonly seen in iOS system apps like Notes, '
              'Photos, and Files.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Key Features:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Horizontal layout at menu top\n'
              '• Icon-first design with labels\n'
              '• Separated from regular menu items by divider\n'
              '• Native iOS 15+ displayInline behavior\n'
              '• Supports SF Symbols with custom styling',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
