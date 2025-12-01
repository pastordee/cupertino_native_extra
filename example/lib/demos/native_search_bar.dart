import 'package:flutter/cupertino.dart';
import 'package:cupertino_native_extra/cupertino_native.dart';

class NativeSearchBarDemoPage extends StatefulWidget {
  const NativeSearchBarDemoPage({super.key});

  @override
  State<NativeSearchBarDemoPage> createState() =>
      _NativeSearchBarDemoPageState();
}

class _NativeSearchBarDemoPageState extends State<NativeSearchBarDemoPage> {
  String _searchText = '';
  int _selectedScope = 0;
  String _lastAction = 'None';

  final List<String> _scopeTitles = ['All Mailboxes', 'Current Mailbox'];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Native iOS Search Bar'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Native UISearchBar
            CNSearchBar(
              placeholder: 'Search in Mail',
              showsCancelButton: true,
              showsScopeBar: true,
              scopeButtonTitles: _scopeTitles,
              selectedScopeIndex: _selectedScope,
              searchBarStyle: CNSearchBarStyle.prominent,
              keyboardType: CNKeyboardType.defaultType,
              returnKeyType: CNReturnKeyType.search,
              autocapitalizationType: CNAutocapitalizationType.none,
              autocorrectionType: CNAutocorrectionType.yes,
              onTextChanged: (text) {
                setState(() {
                  _searchText = text;
                  _lastAction = 'Text changed';
                });
              },
              onSearchButtonClicked: (text) {
                setState(() {
                  _searchText = text;
                  _lastAction = 'Search button clicked';
                });
              },
              onCancelButtonClicked: () {
                setState(() {
                  _searchText = '';
                  _lastAction = 'Cancel button clicked';
                });
              },
              onScopeChanged: (index) {
                setState(() {
                  _selectedScope = index;
                  _lastAction = 'Scope changed to ${_scopeTitles[index]}';
                });
              },
            ),

            // Status display
            Expanded(
              child: Container(
                color: CupertinoColors.systemGroupedBackground,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildInfoCard('Native iOS Implementation', [
                      '✓ Real UISearchBar (not Flutter widget)',
                      '✓ Native iOS search behavior',
                      '✓ Native keyboard handling',
                      '✓ Native scope bar (segmented control)',
                      '✓ Native cancel button animation',
                      '✓ Platform channel communication',
                    ]),
                    const SizedBox(height: 16),
                    _buildInfoCard('Current State', [
                      'Search Text: "${_searchText.isEmpty ? "(empty)" : _searchText}"',
                      'Selected Scope: ${_scopeTitles[_selectedScope]}',
                      'Last Action: $_lastAction',
                    ]),
                    const SizedBox(height: 16),
                    _buildInfoCard('Apple HIG Features', [
                      '✓ Descriptive placeholder ("Search in Mail")',
                      '✓ Scope bar for filtering categories',
                      '✓ Cancel button for quick dismissal',
                      '✓ Search button in return key',
                      '✓ Auto-correction enabled',
                      '✓ No auto-capitalization (for emails)',
                    ]),
                    const SizedBox(height: 16),
                    _buildInfoCard('Try These Features', [
                      '• Type to search - text updates immediately',
                      '• Tap Search button on keyboard',
                      '• Switch between scopes',
                      '• Tap Cancel to clear and dismiss',
                      '• Notice the native iOS animations',
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<String> items) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: CupertinoColors.separator.resolveFrom(context),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ...items.map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.separator.resolveFrom(context),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 15,
                        color: item.startsWith('✓')
                            ? CupertinoColors.activeGreen
                            : CupertinoColors.label.resolveFrom(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
