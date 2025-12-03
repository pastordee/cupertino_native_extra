import 'package:cupertino_native_extra/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

/// Demo page showcasing CNPopupMenuButton - native iOS popup menus.
/// 
/// Features demonstrated:
/// - Text button variant (labeled menu trigger)
/// - Icon button variant (compact, space-efficient)
/// - Menu items with labels and SF Symbol icons
/// - Menu dividers for logical grouping
/// - Disabled menu items (grayed out)
/// - Selection index callback
/// - Multiple button styles support
/// 
/// Use CNPopupMenuButton when:
/// - You need 3-10 related action options
/// - Space is limited (icon variant)
/// - Menu items are context-specific
/// - You want traditional menu appearance
/// 
/// Structure best practices:
/// - Most common actions first
/// - Use dividers to group 3-5 related items
/// - Destructive actions at bottom or separated
/// - Keep menu items under 6-8 words each
/// - Use clear, action-oriented labels
/// 
/// Example use cases:
/// - File operations (New, Open, Save, Delete)
/// - Edit operations (Cut, Copy, Paste, Delete)
/// - View options (Sort, Filter, Refresh)
/// - Account actions (Settings, Help, Logout)
class PopupMenuButtonDemoPage extends StatefulWidget {
  const PopupMenuButtonDemoPage({super.key});

  @override
  State<PopupMenuButtonDemoPage> createState() =>
      _PopupMenuButtonDemoPageState();
}

class _PopupMenuButtonDemoPageState extends State<PopupMenuButtonDemoPage> {
  int? _lastSelected;

  @override
  Widget build(BuildContext context) {
    final items = [
      CNPopupMenuItem(label: 'New File', icon: const CNSymbol('doc', size: 18)),
      CNPopupMenuItem(
        label: 'New Folder',
        icon: const CNSymbol('folder', size: 18),
      ),
      const CNPopupMenuDivider(),
      CNPopupMenuItem(
        label: 'Rename',
        icon: const CNSymbol('rectangle.and.pencil.and.ellipsis', size: 18),
      ),
      CNPopupMenuItem(
        label: 'Delete',
        icon: const CNSymbol('trash', size: 18),
        enabled: false,
      ),
    ];

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Popup Menu Button'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Text button'),
                Spacer(),
                CNPopupMenuButton(
                  buttonLabel: 'Actions',
                  items: items,
                  onSelected: (index) {
                    setState(() => _lastSelected = index);
                  },
                  buttonStyle: CNButtonStyle.plain,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Icon button'),
                Spacer(),
                CNPopupMenuButton.icon(
                  buttonIcon: const CNSymbol('ellipsis', size: 18),
                  size: 44,
                  items: items,
                  onSelected: (index) {
                    setState(() => _lastSelected = index);
                  },
                  buttonStyle: CNButtonStyle.glass,
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_lastSelected != null)
              Center(child: Text('Selected index: $_lastSelected')),
          ],
        ),
      ),
    );
  }
}
