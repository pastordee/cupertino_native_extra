import 'package:cupertino_native_extra/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class PopupMenuStylesDemo extends StatefulWidget {
  const PopupMenuStylesDemo({super.key});

  @override
  State<PopupMenuStylesDemo> createState() => _PopupMenuStylesDemoState();
}

class _PopupMenuStylesDemoState extends State<PopupMenuStylesDemo> {
  String _selectedAction = 'None';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Popup Menu Styles'),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            final selected = await showCupertinoModalPopup<int>(
              context: context,
              builder: (ctx) {
                return CupertinoActionSheet(
                  actions: [
                    CupertinoActionSheetAction(
                      onPressed: () => Navigator.of(ctx).pop(0),
                      child: const Text('Traditional Style'),
                    ),
                    CupertinoActionSheetAction(
                      onPressed: () => Navigator.of(ctx).pop(1),
                      child: const Text('Help'),
                    ),
                    CupertinoActionSheetAction(
                      onPressed: () => Navigator.of(ctx).pop(2),
                      child: const Text('About'),
                    ),
                  ],
                  cancelButton: CupertinoActionSheetAction(
                    onPressed: () => Navigator.of(ctx).pop(),
                    isDefaultAction: true,
                    child: const Text('Cancel'),
                  ),
                );
              },
            );
            if (selected != null) {
              final items = ['Traditional Style', 'Help', 'About'];
              setState(() {
                _selectedAction = 'Traditional: ${items[selected]}';
              });
            }
          },
          child: const Icon(CupertinoIcons.ellipsis_circle),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Popup Menu Style Comparison',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              
              // Traditional popup menu demo
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Traditional Popup Menu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Uses system overlays (like action sheets)',
                      style: TextStyle(color: CupertinoColors.systemGrey),
                    ),
                    const SizedBox(height: 16),
                    CupertinoButton.filled(
                      child: const Text('Traditional Menu'),
                      onPressed: () async {
                        final selected = await showCupertinoModalPopup<int>(
                          context: context,
                          builder: (ctx) {
                            return CupertinoActionSheet(
                              actions: [
                                CupertinoActionSheetAction(
                                  onPressed: () => Navigator.of(ctx).pop(0),
                                  child: const Text('Settings'),
                                ),
                                CupertinoActionSheetAction(
                                  onPressed: () => Navigator.of(ctx).pop(1),
                                  child: const Text('Help'),
                                ),
                                CupertinoActionSheetAction(
                                  onPressed: () => Navigator.of(ctx).pop(2),
                                  child: const Text('About'),
                                ),
                              ],
                              cancelButton: CupertinoActionSheetAction(
                                onPressed: () => Navigator.of(ctx).pop(),
                                isDefaultAction: true,
                                child: const Text('Cancel'),
                              ),
                            );
                          },
                        );
                        if (selected != null) {
                          final items = ['Settings', 'Help', 'About'];
                          setState(() {
                            _selectedAction = 'Traditional Demo: ${items[selected]}';
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              
              // CNPopupMenuButton demo
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'CNPopupMenuButton',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Native iOS/macOS popup menu button',
                      style: TextStyle(color: CupertinoColors.systemGrey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Text label version
                        CNPopupMenuButton(
                          buttonLabel: 'Menu Button',
                          items: const [
                            CNPopupMenuItem(
                              label: 'Settings',
                              icon: CNSymbol('gear'),
                            ),
                            CNPopupMenuItem(
                              label: 'Help',
                              icon: CNSymbol('questionmark.circle'),
                            ),
                            CNPopupMenuDivider(),
                            CNPopupMenuItem(
                              label: 'About',
                              icon: CNSymbol('info.circle'),
                            ),
                          ],
                          onSelected: (index) {
                            final items = ['Settings', 'Help', 'About'];
                            setState(() {
                              _selectedAction = 'CNPopupMenuButton: ${items[index >= 2 ? index - 1 : index]}';
                            });
                          },
                        ),
                        
                        // Icon version
                        CNPopupMenuButton.icon(
                          buttonIcon: CNSymbol('ellipsis.circle'),
                          items: const [
                            CNPopupMenuItem(
                              label: 'Duplicate',
                              icon: CNSymbol('doc.on.doc'),
                            ),
                            CNPopupMenuItem(
                              label: 'Move',
                              icon: CNSymbol('folder'),
                            ),
                            CNPopupMenuItem(
                              label: 'Delete',
                              icon: CNSymbol('trash'),
                            ),
                          ],
                          onSelected: (index) {
                            final items = ['Duplicate', 'Move', 'Delete'];
                            setState(() {
                              _selectedAction = 'CNPopupMenuButton Icon: ${items[index]}';
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.activeBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Last Selected:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedAction,
                      style: const TextStyle(
                        color: CupertinoColors.activeBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              const Text(
                'Compare the navigation bar popup menu\n(top right) with the buttons above',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 14,
                ),
              ),
            ],
        ),
      ),
    );
  }
}