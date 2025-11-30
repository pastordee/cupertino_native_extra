import 'package:flutter/cupertino.dart';
import '../style/sf_symbol.dart';

/// Callback for search text changes with search results.
typedef SearchResultsBuilder =
    Widget Function(BuildContext context, String searchText);

/// Configuration for search integration in native components.
///
/// Used with search-enabled constructors like:
/// - `CNToolbar.search()`
/// - `CNNavigationBar.search()`
/// - `CNTabBar.search()`
class CNSearchConfig {
  /// Creates a search configuration.
  const CNSearchConfig({
    this.placeholder = 'Search',
    this.searchIcon = const CNSymbol('magnifyingglass'),
    this.showsCancelButton = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.searchBarHeight = 50.0,
    this.onSearchActivated,
    this.onSearchTextChanged,
    this.onSearchSubmitted,
    this.onSearchCancelled,
    this.resultsBuilder,
    this.showResultsOverlay = true,
  });

  /// Placeholder text for the search bar.
  final String placeholder;

  /// Icon to display for the search button/tab.
  final CNSymbol searchIcon;

  /// Whether to show the cancel button in the search bar.
  final bool showsCancelButton;

  /// Duration of expand/collapse animation.
  final Duration animationDuration;

  /// Height of the search bar when expanded.
  final double searchBarHeight;

  /// Called when search bar is activated/focused (tapped).
  final VoidCallback? onSearchActivated;

  /// Called when search text changes.
  final ValueChanged<String>? onSearchTextChanged;

  /// Called when search is submitted (return key pressed).
  final ValueChanged<String>? onSearchSubmitted;

  /// Called when search is cancelled.
  final VoidCallback? onSearchCancelled;

  /// Builder for search results overlay.
  final SearchResultsBuilder? resultsBuilder;

  /// Whether to show results overlay as user types.
  final bool showResultsOverlay;
}
