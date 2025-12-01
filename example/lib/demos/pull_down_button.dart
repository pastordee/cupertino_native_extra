import 'package:flutter/cupertino.dart';
import 'package:cupertino_native_extra/cupertino_native.dart';

/// Demo page showing CNPullDownButton functionality.
class PullDownButtonDemo extends StatefulWidget {
  const PullDownButtonDemo({super.key});

  @override
  State<PullDownButtonDemo> createState() => _PullDownButtonDemoState();
}

class _PullDownButtonDemoState extends State<PullDownButtonDemo> {
  String _selectedOption = 'No selection';

  void _handleMenuSelection(int index) {
    final options = [
      'Share',
      'Copy Link', 
      'Add to Favorites',
      'Download',
      'Delete'
    ];
    
    setState(() {
      _selectedOption = options[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // backgroundColor: CupertinoColors.systemCyan,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Pull-Down Button'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pull-Down Button Examples',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: CupertinoColors.systemYellow.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      CupertinoIcons.info_circle,
                      color: CupertinoColors.systemOrange,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Native implementation in progress. Scroll down for working fallback demo.',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.label,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              const Text(
                'Basic Pull-Down Button:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              
              CNPullDownButton(
                buttonLabel: 'Actions',
                items: [
                  CNPullDownMenuItem(
                    label: 'Edit',
                    icon: CNSymbol('pencil'),
                  ),
                  CNPullDownMenuItem(
                    label: 'Duplicate',
                    icon: CNSymbol('doc.on.doc'),
                  ),
                  CNPullDownMenuDivider(),
                  CNPullDownMenuItem(
                    label: 'Delete',
                    icon: CNSymbol('trash'),
                    isDestructive: true,
                  ),
                ],
                onSelected: _handleMenuSelection,
                height: 44.0,
              ),
              
              const SizedBox(height: 30),
              
              const Text(
                'Icon Pull-Down Button:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              
              CNPullDownButton.icon(
                buttonIcon: CNSymbol('gear'),
                items: [
                  CNPullDownMenuItem(
                    label: 'Settings',
                    icon: CNSymbol('gear'),
                  ),
                  CNPullDownMenuItem(
                    label: 'Preferences',
                    icon: CNSymbol('slider.horizontal.3'),
                  ),
                  CNPullDownMenuDivider(),
                  CNPullDownMenuItem(
                    label: 'About',
                    icon: CNSymbol('info.circle'),
                  ),
                ],
                onSelected: _handleMenuSelection,
                size: 44.0,
              ),
              
              const SizedBox(height: 30),
              
              const Text(
                'Pull-Down Menu with Submenu:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              
              CNPullDownButton(
                buttonLabel: 'File Options',
                items: [
                  CNPullDownMenuItem(
                    label: 'New File',
                    icon: CNSymbol('doc.badge.plus'),
                  ),
                  CNPullDownMenuItem(
                    label: 'Open',
                    icon: CNSymbol('folder'),
                  ),
                  CNPullDownMenuDivider(),
                  CNPullDownMenuSubmenu(
                    title: 'Export As...',
                    icon: CNSymbol('square.and.arrow.up'),
                    items: [
                      CNPullDownMenuItem(
                        label: 'PDF Document',
                        icon: CNSymbol('doc.text'),
                      ),
                      CNPullDownMenuItem(
                        label: 'PNG Image',
                        icon: CNSymbol('photo'),
                      ),
                      CNPullDownMenuItem(
                        label: 'JPEG Image',
                        icon: CNSymbol('photo.fill'),
                      ),
                      CNPullDownMenuDivider(),
                      CNPullDownMenuItem(
                        label: 'Plain Text',
                        icon: CNSymbol('doc.plaintext'),
                      ),
                      CNPullDownMenuItem(
                        label: 'Rich Text',
                        icon: CNSymbol('doc.richtext'),
                      ),
                    ],
                  ),
                  CNPullDownMenuSubmenu(
                    title: 'Share To...',
                    icon: CNSymbol('square.and.arrow.up.circle'),
                    items: [
                      CNPullDownMenuItem(
                        label: 'Messages',
                        icon: CNSymbol('message'),
                      ),
                      CNPullDownMenuItem(
                        label: 'Mail',
                        icon: CNSymbol('envelope'),
                      ),
                      CNPullDownMenuItem(
                        label: 'AirDrop',
                        icon: CNSymbol('airplayaudio'),
                      ),
                      CNPullDownMenuDivider(),
                      CNPullDownMenuItem(
                        label: 'More...',
                        icon: CNSymbol('ellipsis.circle'),
                      ),
                    ],
                  ),
                  CNPullDownMenuDivider(),
                  CNPullDownMenuItem(
                    label: 'Print',
                    icon: CNSymbol('printer'),
                  ),
                ],
                onSelected: _handleMenuSelection,
                height: 44.0,
              ),
              
              const SizedBox(height: 30),
              
              const Text(
                'Text Formatting Menu:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              
              CNPullDownButton.icon(
                buttonIcon: CNSymbol('textformat'),
                items: [
                  CNPullDownMenuSubmenu(
                    title: 'Font Style',
                    icon: CNSymbol('bold.italic.underline'),
                    items: [
                      CNPullDownMenuItem(
                        label: 'Bold',
                        icon: CNSymbol('bold'),
                      ),
                      CNPullDownMenuItem(
                        label: 'Italic',
                        icon: CNSymbol('italic'),
                      ),
                      CNPullDownMenuItem(
                        label: 'Underline',
                        icon: CNSymbol('underline'),
                      ),
                      CNPullDownMenuItem(
                        label: 'Strikethrough',
                        icon: CNSymbol('strikethrough'),
                      ),
                    ],
                  ),
                  CNPullDownMenuSubmenu(
                    title: 'Text Alignment',
                    icon: CNSymbol('text.alignleft'),
                    items: [
                      CNPullDownMenuItem(
                        label: 'Align Left',
                        icon: CNSymbol('text.alignleft'),
                      ),
                      CNPullDownMenuItem(
                        label: 'Align Center',
                        icon: CNSymbol('text.aligncenter'),
                      ),
                      CNPullDownMenuItem(
                        label: 'Align Right',
                        icon: CNSymbol('text.alignright'),
                      ),
                      CNPullDownMenuItem(
                        label: 'Justify',
                        icon: CNSymbol('text.justify'),
                      ),
                    ],
                  ),
                  CNPullDownMenuSubmenu(
                    title: 'List Style',
                    icon: CNSymbol('list.bullet'),
                    items: [
                      CNPullDownMenuItem(
                        label: 'Bullet List',
                        icon: CNSymbol('list.bullet'),
                      ),
                      CNPullDownMenuItem(
                        label: 'Numbered List',
                        icon: CNSymbol('list.number'),
                      ),
                      CNPullDownMenuItem(
                        label: 'Checklist',
                        icon: CNSymbol('checklist'),
                      ),
                    ],
                  ),
                  CNPullDownMenuDivider(),
                  CNPullDownMenuItem(
                    label: 'Clear Formatting',
                    icon: CNSymbol('trash'),
                    isDestructive: true,
                  ),
                ],
                onSelected: _handleMenuSelection,
                size: 44.0,
              ),
              
              const SizedBox(height: 40),
              
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Last Selected:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedOption,
                      style: const TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.systemBlue,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              const Text(
                'Fallback Implementation (Working Now):',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              
              // Fallback button using CupertinoButton + ActionSheet
              CupertinoButton.filled(
                onPressed: () async {
                  final result = await showCupertinoModalPopup<String>(
                    context: context,
                    builder: (BuildContext context) => CupertinoActionSheet(
                      title: const Text('Pull-Down Menu'),
                      actions: <CupertinoActionSheetAction>[
                        CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pop(context, 'Share');
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.share, size: 18),
                              SizedBox(width: 8),
                              Text('Share'),
                            ],
                          ),
                        ),
                        CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pop(context, 'Copy Link');
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.doc_on_doc, size: 18),
                              SizedBox(width: 8),
                              Text('Copy Link'),
                            ],
                          ),
                        ),
                        CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pop(context, 'Add to Favorites');
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.heart, size: 18),
                              SizedBox(width: 8),
                              Text('Add to Favorites'),
                            ],
                          ),
                        ),
                        CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pop(context, 'Delete');
                          },
                          isDestructiveAction: true,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.delete, size: 18),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                      cancelButton: CupertinoActionSheetAction(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                    ),
                  );
                  
                  if (result != null) {
                    setState(() {
                      _selectedOption = result;
                    });
                  }
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Tap for Menu'),
                    SizedBox(width: 8),
                    Icon(CupertinoIcons.chevron_down, size: 16),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              const Text(
                'Note: Pull-down buttons follow Apple Design Guidelines and show menus below the button. The CNPullDownButton widgets above will work once the native iOS implementation is complete. The fallback implementation above demonstrates the intended functionality using CupertinoActionSheet.',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}