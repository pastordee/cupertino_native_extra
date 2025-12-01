import 'package:flutter/cupertino.dart';
import 'package:cupertino_native_extra/cupertino_native.dart';

class PopupMenuDemo extends StatefulWidget {
  const PopupMenuDemo({super.key});

  @override
  State<PopupMenuDemo> createState() => _PopupMenuDemoState();
}

class _PopupMenuDemoState extends State<PopupMenuDemo> {
  void _showAlert(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Menu Selection'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CupertinoColors.systemBlue,
                  CupertinoColors.systemPurple,
                  CupertinoColors.systemPink,
                ],
              ),
            ),
          ),

          // Scrollable content
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 60, // Make room for navigation bar
                bottom: 16,
              ),
              children: [
                const SizedBox(height: 20),

                // Demo content
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground
                        .resolveFrom(context)
                        .withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Popup Menu Integration',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'CNNavigationBar and CNToolbar now support popup menus! Tap the ellipsis button in the navigation bar or the buttons in the toolbar below to see popup menus in action.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Toolbar with popup menu
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground
                        .resolveFrom(context)
                        .withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Toolbar with Popup Menus',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CNToolbar(
                        leading: [
                          CNToolbarAction.popupMenu(
                            icon: CNSymbol('folder'),
                            popupMenuItems: [
                              const CNPopupMenuItem(
                                label: 'New Folder',
                                icon: CNSymbol('folder.badge.plus'),
                              ),
                              const CNPopupMenuItem(
                                label: 'New File',
                                icon: CNSymbol('doc.badge.plus'),
                              ),
                              const CNPopupMenuDivider(),
                              const CNPopupMenuItem(
                                label: 'Import',
                                icon: CNSymbol('square.and.arrow.down'),
                              ),
                            ],
                            onPopupMenuSelected: (index) {
                              final items = [
                                'New Folder',
                                'New File',
                                'Import',
                              ];
                              if (index < items.length) {
                                _showAlert(context, 'Selected: ${items[index]}');
                              }
                            },
                          ),
                        ],
                        middle: [
                          CNToolbarAction.popupMenu(
                            icon: CNSymbol('paintbrush'),
                            popupMenuItems: [
                              const CNPopupMenuItem(
                                label: 'Red',
                                icon: CNSymbol('circle.fill'),
                              ),
                              const CNPopupMenuItem(
                                label: 'Blue',
                                icon: CNSymbol('circle.fill'),
                              ),
                              const CNPopupMenuItem(
                                label: 'Green',
                                icon: CNSymbol('circle.fill'),
                              ),
                            ],
                            onPopupMenuSelected: (index) {
                              final colors = ['Red', 'Blue', 'Green'];
                              if (index < colors.length) {
                                _showAlert(context, 'Color: ${colors[index]}');
                              }
                            },
                          ),
                        ],
                        trailing: [
                          CNToolbarAction.popupMenu(
                            icon: CNSymbol('ellipsis'),
                            popupMenuItems: [
                              const CNPopupMenuItem(
                                label: 'Settings',
                                icon: CNSymbol('gear'),
                              ),
                              const CNPopupMenuItem(
                                label: 'Help',
                                icon: CNSymbol('questionmark.circle'),
                              ),
                              const CNPopupMenuDivider(),
                              const CNPopupMenuItem(
                                label: 'About',
                                icon: CNSymbol('info.circle'),
                              ),
                            ],
                            onPopupMenuSelected: (index) {
                              final items = ['Settings', 'Help', 'About'];
                              if (index < items.length) {
                                _showAlert(context, 'Selected: ${items[index]}');
                              }
                            },
                          ),
                        ],
                        height: 50,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Features list
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground
                        .resolveFrom(context)
                        .withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Features',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFeature(
                        '📱',
                        'Native Integration',
                        'Popup menus work with native navigation bars and toolbars',
                      ),
                      _buildFeature(
                        '🎯',
                        'Flexible Items',
                        'Support for text, icons, and dividers in popup menus',
                      ),
                      _buildFeature(
                        '🔗',
                        'Easy Integration',
                        'Simply use CNNavigationBarAction.popupMenu() or CNToolbarAction.popupMenu()',
                      ),
                      _buildFeature(
                        '⚡',
                        'Responsive',
                        'Popup menus automatically position themselves appropriately',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),

          // Native navigation bar positioned on top
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SafeArea(
              bottom: false,
              child: CNNavigationBar(
                leading: [
                  CNNavigationBarAction(
                    icon: CNSymbol('chevron.left'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
                title: 'Popup Menu Demo',
                trailing: [
                  CNNavigationBarAction.popupMenu(
                    icon: CNSymbol('ellipsis.circle'),
                    popupMenuItems: [
                      const CNPopupMenuItem(
                        label: 'Copy',
                        icon: CNSymbol('doc.on.doc'),
                      ),
                      const CNPopupMenuItem(
                        label: 'Paste',
                        icon: CNSymbol('doc.on.clipboard'),
                      ),
                      const CNPopupMenuDivider(),
                      const CNPopupMenuItem(
                        label: 'Delete',
                        icon: CNSymbol('trash'),
                      ),
                    ],
                    onPopupMenuSelected: (index) {
                      final actions = ['Copy', 'Paste', 'Delete'];
                      if (index < actions.length) {
                        _showAlert(context, 'Action: ${actions[index]}');
                      }
                    },
                  ),
                ],
                tint: CupertinoColors.label,
                transparent: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
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
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
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