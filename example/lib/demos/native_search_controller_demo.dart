import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';

class NativeSearchControllerDemo extends StatefulWidget {
  const NativeSearchControllerDemo({super.key});

  @override
  State<NativeSearchControllerDemo> createState() =>
      _NativeSearchControllerDemoState();
}

class _NativeSearchControllerDemoState
    extends State<NativeSearchControllerDemo> {
  final _searchController = CNNativeSearchController();
  String _lastSearchQuery = '';
  bool _isSearchOpen = false;

  void _openSearch() async {
    setState(() {
      _isSearchOpen = true;
    });

    await _searchController.show(
      placeholder: 'Search your items',
      keyboardType: CNKeyboardType.defaultType,
      onTextChanged: (query) {
        setState(() {
          _lastSearchQuery = query;
        });
        print('Search text changed: $query');
      },
      onSubmitted: (query) {
        print('Search submitted: $query');
        // Handle search submission
      },
      onCancelled: () {
        setState(() {
          _isSearchOpen = false;
        });
        print('Search cancelled');
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Native Search Controller'),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoButton.filled(
                onPressed: _openSearch,
                child: const Text('Open Search'),
              ),
              const SizedBox(height: 20),
              if (_isSearchOpen)
                Column(
                  children: [
                    const Text(
                      'Search Active',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    if (_lastSearchQuery.isNotEmpty)
                      Text(
                        'Last query: $_lastSearchQuery',
                        style: const TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                  ],
                )
              else
                const Text(
                  'Tap the button to open native search',
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
