import 'package:cupertino_ui/cupertino_ui.dart';

/// A native iOS bottom toolbar with expandable search.
///
/// This component implements the "Search in a bottom toolbar" pattern from Apple HIG.
/// When search is tapped, it expands to fill the toolbar while showing the current context.
///
/// Example:
/// ```dart
/// CNBottomToolbar(
///   leadingAction: CNToolbarAction.button(
///     icon: CupertinoIcons.line_horizontal_3,
///     onTap: () => showMenu(),
///   ),
///   searchPlaceholder: 'Search',
///   onSearchChanged: (text) => updateResults(text),
///   trailingAction: CNToolbarAction.button(
///     icon: CupertinoIcons.square_pencil,
///     onTap: () => compose(),
///   ),
///   currentTabIcon: CupertinoIcons.house_fill, // Shows context when searching
///   currentTabLabel: 'Home',
/// )
/// ```
class CNBottomToolbar extends StatefulWidget {
  /// Creates a bottom toolbar with expandable search.
  const CNBottomToolbar({
    super.key,
    this.leadingAction,
    this.trailingAction,
    this.searchPlaceholder = 'Search',
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onSearchFocusChanged,
    this.currentTabIcon,
    this.currentTabLabel,
    this.height = 50.0,
    this.backgroundColor,
  });

  /// Optional leading button (e.g., menu, filter)
  final Widget? leadingAction;

  /// Optional trailing button (e.g., compose, add)
  final Widget? trailingAction;

  /// Placeholder text for the search field
  final String searchPlaceholder;

  /// Called when search text changes
  final ValueChanged<String>? onSearchChanged;

  /// Called when search is submitted
  final ValueChanged<String>? onSearchSubmitted;

  /// Called when search field gains/loses focus
  final ValueChanged<bool>? onSearchFocusChanged;

  /// Icon to show when search is expanded (current tab context)
  final IconData? currentTabIcon;

  /// Label to show when search is expanded (current tab context)
  final String? currentTabLabel;

  /// Toolbar height
  final double height;

  /// Background color
  final Color? backgroundColor;

  @override
  State<CNBottomToolbar> createState() => _CNBottomToolbarState();
}

class _CNBottomToolbarState extends State<CNBottomToolbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _searchExpandAnimation;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textController = TextEditingController();
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchExpandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _isSearchExpanded = _focusNode.hasFocus;
    });

    if (_focusNode.hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    widget.onSearchFocusChanged?.call(_focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        widget.backgroundColor ?? CupertinoTheme.of(context).barBackgroundColor;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(
            color: CupertinoColors.separator.resolveFrom(context),
            width: 0.5,
          ),
        ),
      ),
      child: AnimatedBuilder(
        animation: _searchExpandAnimation,
        builder: (context, child) {
          return Row(
            children: [
              // Leading: Menu button OR current tab icon when expanded
              _buildLeadingArea(),

              // Search field (expands when focused)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  child: CupertinoSearchTextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    placeholder: widget.searchPlaceholder,
                    onChanged: widget.onSearchChanged,
                    onSubmitted: widget.onSearchSubmitted,
                    backgroundColor: CupertinoColors.tertiarySystemFill
                        .resolveFrom(context),
                  ),
                ),
              ),

              // Trailing button (fades out when search expands)
              if (widget.trailingAction != null)
                Opacity(
                  opacity: 1.0 - (_searchExpandAnimation.value * 0.5),
                  child: _buildTrailingButton(),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLeadingArea() {
    if (_isSearchExpanded && widget.currentTabIcon != null) {
      // Show current tab icon when search is expanded
      return Padding(
        padding: const EdgeInsets.only(left: 12, right: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.currentTabIcon,
              size: 24,
              color: CupertinoColors.systemBlue.resolveFrom(context),
            ),
            if (widget.currentTabLabel != null) ...[
              const SizedBox(height: 2),
              Text(
                widget.currentTabLabel!,
                style: TextStyle(
                  fontSize: 10,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Show leading button when not searching
    if (widget.leadingAction != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 8),
        child: SizedBox(width: 44, height: 44, child: widget.leadingAction!),
      );
    }

    return const SizedBox(width: 8);
  }

  Widget _buildTrailingButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: SizedBox(width: 44, height: 44, child: widget.trailingAction!),
    );
  }
}
