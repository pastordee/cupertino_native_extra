import 'package:flutter/cupertino.dart';
import 'package:cupertino_native_extra/cupertino_native.dart';

class PopupButtonDemo extends StatefulWidget {
  const PopupButtonDemo({super.key});

  @override
  State<PopupButtonDemo> createState() => _PopupButtonDemoState();
}

class _PopupButtonDemoState extends State<PopupButtonDemo> {
  // Repeat interval state
  int _repeatIndex = 1; // "Every Day"
  final List<String> _repeatOptions = [
    'Never',
    'Every Day',
    'Every Week',
    'Every 2 Weeks',
    'Every Month',
    'Every Year',
    'Custom',
  ];

  // Sort state
  int _sortIndex = 0; // "Date"
  final List<String> _sortOptions = [
    'Date',
    'Name',
    'Size',
    'Kind',
  ];

  // Filter state
  int _filterIndex = 0; // "All Items"
  final List<String> _filterOptions = [
    'All Items',
    'Documents',
    'Images',
    'Videos',
    'Music',
  ];

  // Priority state
  int _priorityIndex = 1; // "Medium"
  final List<String> _priorityOptions = [
    'Low',
    'Medium',
    'High',
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Pop-up Button'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6.resolveFrom(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Pop-up buttons let people choose from a set of mutually exclusive '
                'options. The button displays the currently selected option and '
                'updates when people make a new selection.',
                style: TextStyle(fontSize: 15),
              ),
            ),

            const SizedBox(height: 32),

            // Repeat Interval Example (Calendar-style)
            _buildSection(
              title: 'Calendar Repeat',
              description: 'Choose how often an event repeats',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Repeat',
                    style: TextStyle(fontSize: 17),
                  ),
                  SizedBox(
                    width: 150,
                    child: CNPopupButton(
                      options: _repeatOptions,
                      selectedIndex: _repeatIndex,
                      onSelected: (index) {
                        setState(() => _repeatIndex = index);
                      },
                      buttonStyle: CNButtonStyle.glass,
                      dividerIndices: const [5], // Divider before "Custom"
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sort Options (Finder-style)
            _buildSection(
              title: 'Finder Sort',
              description: 'Choose how to sort files',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sort by',
                    style: TextStyle(fontSize: 17),
                  ),
                  SizedBox(
                    width: 150,
                    child: CNPopupButton(
                      options: _sortOptions,
                      selectedIndex: _sortIndex,
                      onSelected: (index) {
                        setState(() => _sortIndex = index);
                      },
                      prefix: 'Sort by: ',
                      buttonStyle: CNButtonStyle.gray,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Filter Options
            _buildSection(
              title: 'Content Filter',
              description: 'Filter items by type',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Show',
                    style: TextStyle(fontSize: 17),
                  ),
                  SizedBox(
                    width: 150,
                    child: CNPopupButton(
                      options: _filterOptions,
                      selectedIndex: _filterIndex,
                      onSelected: (index) {
                        setState(() => _filterIndex = index);
                      },
                      buttonStyle: CNButtonStyle.tinted,
                      tint: CupertinoColors.systemBlue,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Priority with Icon Button
            _buildSection(
              title: 'Priority Selection',
              description: 'Set task priority using icon button',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Priority',
                    style: TextStyle(fontSize: 17),
                  ),
                  Row(
                    children: [
                      Text(
                        _priorityOptions[_priorityIndex],
                        style: TextStyle(
                          fontSize: 17,
                          color: CupertinoColors.systemGrey.resolveFrom(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CNPopupButton.icon(
                          options: _priorityOptions,
                          selectedIndex: _priorityIndex,
                          onSelected: (index) {
                            setState(() => _priorityIndex = index);
                          },
                          buttonIcon: CNSymbol('flag.fill', size: 20),
                          buttonStyle: CNButtonStyle.filled,
                          tint: _getPriorityColor(_priorityIndex),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Usage Tips
            Container(
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
                        CupertinoIcons.lightbulb,
                        color: CupertinoColors.systemYellow.resolveFrom(context),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Usage Tips',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Use pop-up buttons for mutually exclusive options\n'
                    '• The button label shows the current selection\n'
                    '• Selected items show a checkmark in the menu\n'
                    '• Avoid submenus - keep options in a flat list\n'
                    '• Use pull-down buttons for actions instead',
                    style: TextStyle(fontSize: 15, height: 1.4),
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
    return Container(
      // width: 300,
      // margin: const EdgeInsets.only(left: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.separator.resolveFrom(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey.resolveFrom(context),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Color _getPriorityColor(int index) {
    switch (index) {
      case 0:
        return CupertinoColors.systemGreen;
      case 1:
        return CupertinoColors.systemOrange;
      case 2:
        return CupertinoColors.systemRed;
      default:
        return CupertinoColors.systemGrey;
    }
  }
}
