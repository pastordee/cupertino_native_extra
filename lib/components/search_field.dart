import 'package:cupertino_ui/cupertino_ui.dart';

/// An iOS-style search field that follows Apple HIG best practices.
///
/// **Apple HIG Best Practices:**
/// - Use descriptive placeholder text (e.g., "Shows, Movies, and More")
/// - Search immediately as user types (searchImmediately: true)
/// - Show suggested search terms before or while typing
/// - Provide scope controls for filtering categories
/// - Support tokens for filtering by common terms
///
/// Example:
/// ```dart
/// CNSearchField(
///   placeholder: 'Shows, Movies, and More',
///   showSuggestions: true,
///   suggestions: ['Popular', 'New Releases', 'Trending'],
///   scopeOptions: ['All', 'Movies', 'TV Shows', 'Documentaries'],
///   onSearchChanged: (text) => performSearch(text),
///   onSuggestionTapped: (suggestion) => searchFor(suggestion),
/// )
/// ```
class CNSearchField extends StatefulWidget {
  /// Creates an iOS-style search field.
  const CNSearchField({
    super.key,
    this.placeholder = 'Search',
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onFocusChanged,
    this.showSuggestions = false,
    this.suggestions = const [],
    this.onSuggestionTapped,
    this.scopeOptions = const [],
    this.selectedScope = 0,
    this.onScopeChanged,
    this.searchImmediately = true,
    this.showMicButton = false,
    this.onMicPressed,
    this.autofocus = false,
  });

  /// Placeholder text describing what can be searched
  /// Use descriptive text like "Shows, Movies, and More" instead of just "Search"
  final String placeholder;

  /// Text editing controller
  final TextEditingController? controller;

  /// Focus node
  final FocusNode? focusNode;

  /// Called when search text changes
  final ValueChanged<String>? onChanged;

  /// Called when search is submitted
  final ValueChanged<String>? onSubmitted;

  /// Called when focus state changes
  final ValueChanged<bool>? onFocusChanged;

  /// Whether to show search suggestions
  final bool showSuggestions;

  /// List of suggested search terms
  final List<String> suggestions;

  /// Called when a suggestion is tapped
  final ValueChanged<String>? onSuggestionTapped;

  /// Scope control options (e.g., ['All', 'Movies', 'TV Shows'])
  final List<String> scopeOptions;

  /// Currently selected scope index
  final int selectedScope;

  /// Called when scope changes
  final ValueChanged<int>? onScopeChanged;

  /// Whether to search immediately as user types (default: true per Apple HIG)
  final bool searchImmediately;

  /// Whether to show microphone button
  final bool showMicButton;

  /// Called when microphone button is pressed
  final VoidCallback? onMicPressed;

  /// Whether to autofocus the field
  final bool autofocus;

  @override
  State<CNSearchField> createState() => _CNSearchFieldState();
}

class _CNSearchFieldState extends State<CNSearchField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _ownsController = false;
  bool _ownsFocusNode = false;

  @override
  void initState() {
    super.initState();

    if (widget.controller == null) {
      _controller = TextEditingController();
      _ownsController = true;
    } else {
      _controller = widget.controller!;
    }

    if (widget.focusNode == null) {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    } else {
      _focusNode = widget.focusNode!;
    }

    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    widget.onFocusChanged?.call(_focusNode.hasFocus);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Scope control (if provided)
        if (widget.scopeOptions.isNotEmpty && _focusNode.hasFocus)
          _buildScopeControl(),

        // Search field
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // Search icon
              const Padding(
                padding: EdgeInsets.only(left: 8, right: 6),
                child: Icon(
                  CupertinoIcons.search,
                  size: 18,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),

              // Text field
              Expanded(
                child: CupertinoTextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: widget.autofocus,
                  placeholder: widget.placeholder,
                  placeholderStyle: const TextStyle(
                    fontSize: 17,
                    color: CupertinoColors.secondaryLabel,
                  ),
                  style: const TextStyle(
                    fontSize: 17,
                    color: CupertinoColors.label,
                  ),
                  decoration: null,
                  padding: EdgeInsets.zero,
                  onChanged: widget.searchImmediately ? widget.onChanged : null,
                  onSubmitted: (value) {
                    widget.onSubmitted?.call(value);
                    if (!widget.searchImmediately) {
                      widget.onChanged?.call(value);
                    }
                  },
                ),
              ),

              // Clear button
              if (_controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                    widget.onChanged?.call('');
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      CupertinoIcons.clear_circled_solid,
                      size: 18,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ),

              // Microphone button
              if (widget.showMicButton)
                GestureDetector(
                  onTap: widget.onMicPressed,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 4, right: 8),
                    child: Icon(
                      CupertinoIcons.mic,
                      size: 18,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Suggestions (if focused and available)
        if (widget.showSuggestions &&
            _focusNode.hasFocus &&
            widget.suggestions.isNotEmpty &&
            _controller.text.isEmpty)
          _buildSuggestions(),
      ],
    );
  }

  Widget _buildScopeControl() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: CupertinoSlidingSegmentedControl<int>(
        groupValue: widget.selectedScope,
        onValueChanged: (value) {
          if (value != null) {
            widget.onScopeChanged?.call(value);
          }
        },
        children: Map.fromEntries(
          widget.scopeOptions.asMap().entries.map(
            (entry) => MapEntry(
              entry.key,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(entry.value),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: CupertinoColors.separator.resolveFrom(context),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Suggestions header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(
                  'Suggestions',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ),

          // Suggestion items
          ...widget.suggestions.map(
            (suggestion) => _buildSuggestionItem(suggestion),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(String suggestion) {
    return GestureDetector(
      onTap: () {
        widget.onSuggestionTapped?.call(suggestion);
        _controller.text = suggestion;
        widget.onChanged?.call(suggestion);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: CupertinoColors.separator.resolveFrom(context),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.search,
              size: 16,
              color: CupertinoColors.secondaryLabel,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                suggestion,
                style: const TextStyle(
                  fontSize: 17,
                  color: CupertinoColors.label,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
