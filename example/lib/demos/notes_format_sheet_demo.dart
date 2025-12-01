import 'package:cupertino_native_extra/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

/// Demo page showing Notes-style formatting sheet with inline action buttons.
///
/// This replicates the iOS Notes app formatting sheet with:
/// - Horizontal rows of formatting buttons (Bold, Italic, Underline, etc.)
/// - Non-modal behavior (can interact with background while sheet is open)
/// - Native sheet presentation with custom Flutter widget content
class NotesFormatSheetDemo extends StatefulWidget {
  const NotesFormatSheetDemo({super.key});

  @override
  State<NotesFormatSheetDemo> createState() => _NotesFormatSheetDemoState();
}

class _NotesFormatSheetDemoState extends State<NotesFormatSheetDemo> {
  String _noteContent = '''Monday Morning Meeting

#Policy #Housing #Art

Thesis: Public Art's Development Benefits for Kids 👨‍🎓⭐

– Co-authored by Nisha Kumar and Jay Mung
– Research support from Schoberl College MA students
– Split focus between
  – art placed in public space (i.e. large sculptures, murals)
  – art accessible by the public (free museums)
– First draft under review
– Send paper through review once this group has reviewed second draft''';

  // Formatting state
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;
  bool _isStrikethrough = false;

  void _showFormatSheet() async {
    final selectedIndex = await CNNativeSheet.showWithCustomHeader(
      context: context,
      title: 'Format',
      message: '',
      subtitle: 'Text Formatting Options',
      headerTitleAlignment: 'center',
      isModal: false, // Non-modal - can interact with note while sheet is open!
      detents: [CNSheetDetent.custom(260), CNSheetDetent.medium,],
      prefersGrabberVisible: true,
      headerHeight: 52,
      headerTitleSize: 17,
      headerTitleWeight: FontWeight.w600,
      closeButtonIcon: 'xmark',
      closeButtonSize: 15,
      onInlineActionSelected: (rowIndex, actionIndex) {
        setState(() {
          if (rowIndex == 0) {
            // First row: Text formatting buttons
            switch (actionIndex) {
              case 0: _isBold = !_isBold; break;
              case 1: _isItalic = !_isItalic; break;
              case 2: _isUnderline = !_isUnderline; break;
              case 3: _isStrikethrough = !_isStrikethrough; break;
              case 4: 
                // Draw action
                _showMessage('Draw tool selected');
                break;
              case 5:
                // Color action
                _showMessage('Color picker selected');
                break;
              case 6:
                // Second Draw action
                _showMessage('Sketch tool selected');
                break;
              case 7:
                // Second Color action
                _showMessage('Highlight color selected');
                break;
            }
          } else if (rowIndex == 1) {
            // Second row: List and alignment buttons
            switch (actionIndex) {
              case 0: _showMessage('Bullet list applied'); break;
              case 1: _showMessage('Numbered list applied'); break;
              case 2: _showMessage('Checklist applied'); break;
              case 3: _showMessage('Text indented'); break;
              case 4: _showMessage('Text outdented'); break;
              case 5: _showMessage('Table inserted'); break;
            }
          }
        });
        // Reshow the sheet to reflect updated toggle states
        Future.delayed(const Duration(milliseconds: 100), () {
          _showFormatSheet();
        });
      },
      inlineActions: [
        // First row: Text formatting buttons - Tightly grouped (spacing: 0) with custom widths
        CNSheetInlineActions(
          spacing: 4, // Tightly grouped like iOS Notes!
          horizontalPadding: 8,
          verticalPadding: 4,
          height: 80,
          actions: [
            CNSheetInlineAction(
              label: 'B',
              icon: 'bold',
              isToggled: _isBold,
              width: 75, // Slightly wider
              iconSize: 26,
              labelSize: 14,
              cornerRadius: 14,
            ),
            CNSheetInlineAction(
              label: 'I',
              icon: 'italic',
              isToggled: _isItalic,
              width: 65,
              iconSize: 24,
            ),
            CNSheetInlineAction(
              label: 'U',
              icon: 'underline',
              isToggled: _isUnderline,
              width: 65,
            ),
            CNSheetInlineAction(
              label: 'S',
              icon: 'strikethrough',
              isToggled: _isStrikethrough,
              width: 65,
            ),
            CNSheetInlineAction(
              label: 'Draw',
              icon: 'pencil.tip',
              width: 70,
            ),
            CNSheetInlineAction(
              label: 'Color',
              icon: 'circle.fill',
              backgroundColor: CupertinoColors.systemRed.withOpacity(0.2),
              width: 70,
            ),
             CNSheetInlineAction(
              label: 'Draw',
              icon: 'pencil.tip',
              width: 70,
            ),
            CNSheetInlineAction(
              label: 'Color',
              icon: 'circle.fill',
              backgroundColor: CupertinoColors.systemBlue.withOpacity(0.2),
              width: 70,
            ),
          ],
        ),
        // Second row: List and alignment buttons - Standard spacing with custom styling
        CNSheetInlineActions(
          spacing: 8, // Smaller spacing for visual grouping
          horizontalPadding: 12,
          actions: [
            CNSheetInlineAction(
              label: 'Bullets',
              icon: 'list.bullet',
              width: 75,
              iconSize: 22,
              labelSize: 12,
            ),
            CNSheetInlineAction(
              label: 'Numbers',
              icon: 'list.number',
              width: 75,
              iconSize: 22,
              labelSize: 12,
            ),
            CNSheetInlineAction(
              label: 'Checklist',
              icon: 'checkmark.circle',
              width: 80, // Wider for longer label
              iconSize: 22,
              labelSize: 12,
            ),
            CNSheetInlineAction(
              label: 'Indent',
              icon: 'increase.indent',
              width: 70,
              iconSize: 22,
              labelSize: 12,
            ),
            CNSheetInlineAction(
              label: 'Outdent',
              icon: 'decrease.indent',
              width: 75,
              iconSize: 22,
              labelSize: 12,
            ),
            CNSheetInlineAction(
              label: 'Table',
              icon: 'tablecells',
              backgroundColor: CupertinoColors.systemGreen.withOpacity(0.2),
              width: 70,
              iconSize: 22,
              labelSize: 12,
              cornerRadius: 10, // Slightly rounded
            ),
          ],
        ),
      ],
      items: [
        CNSheetItem(
          title: 'Bold',
          icon: 'bold',
          dismissOnTap: _isBold,
          backgroundColor: CupertinoColors.systemGrey6,
          height: 56,
          fontSize: 18,
          iconSize: 24,
          fontWeight: FontWeight.w600,
        ),
        CNSheetItem(
          title: 'Italic',
          icon: 'italic',
          dismissOnTap: _isItalic,
          textColor: CupertinoColors.systemBlue,
          iconColor: CupertinoColors.systemBlue,
          height: 56,
        ),
        CNSheetItem(
          title: 'Underline',
          icon: 'underline',
          dismissOnTap: _isUnderline,
          backgroundColor: CupertinoColors.systemPurple.withOpacity(0.1),
          textColor: CupertinoColors.systemPurple,
          iconColor: CupertinoColors.systemPurple,
          height: 56,
        ),
        CNSheetItem(
          title: 'Strikethrough',
          icon: 'strikethrough',
          dismissOnTap: _isStrikethrough,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 56,
        ),
      ],
      itemRows: [
        // Example: Two buttons side-by-side with custom styling
        CNSheetItemRow(
          spacing: 12,
          height: 60,
          items: [
            CNSheetItem(
              title: 'Reset All',
              icon: 'arrow.counterclockwise',
              dismissOnTap: true,
              backgroundColor: CupertinoColors.systemRed.withOpacity(0.15),
              textColor: CupertinoColors.systemRed,
              iconColor: CupertinoColors.systemRed,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            CNSheetItem(
              title: 'Copy Text',
              icon: 'doc.on.doc',
              dismissOnTap: true,
              backgroundColor: CupertinoColors.systemGreen.withOpacity(0.15),
              textColor: CupertinoColors.systemGreen,
              iconColor: CupertinoColors.systemGreen,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ],
      onItemSelected: (index) {
        setState(() {
          switch (index) {
            case 0: 
              _isBold = !_isBold;
              _showMessage('Bold ${_isBold ? 'enabled' : 'disabled'}');
              break;
            case 1: 
              _isItalic = !_isItalic;
              _showMessage('Italic ${_isItalic ? 'enabled' : 'disabled'}');
              break;
            case 2: 
              _isUnderline = !_isUnderline;
              _showMessage('Underline ${_isUnderline ? 'enabled' : 'disabled'}');
              break;
            case 3: 
              _isStrikethrough = !_isStrikethrough;
              _showMessage('Strikethrough ${_isStrikethrough ? 'enabled' : 'disabled'}');
              break;
            case 4:
              // Reset All button (first item in row)
              _isBold = false;
              _isItalic = false;
              _isUnderline = false;
              _isStrikethrough = false;
              _showMessage('All formatting reset');
              break;
            case 5:
              // Copy Text button (second item in row)
              _showMessage('Text copied to clipboard');
              break;
          }
        });
      },
      showHeaderDivider: false,
      headerBackgroundColor: CupertinoColors.systemBackground.resolveFrom(context).withOpacity(0.95),
      itemBackgroundColor: CupertinoColors.secondarySystemBackground.resolveFrom(context),
      itemTextColor: CupertinoColors.label.resolveFrom(context),
      itemTintColor: CupertinoColors.activeBlue.resolveFrom(context),
    );
  }

  void _showMessage(String message) {
    // Simple feedback for non-toggle actions
    print('Action: $message');
  }

  // Old widget building code removed - using native inline actions now!
  
  TextDecoration _buildTextDecoration() {
    final decorations = <TextDecoration>[];
    if (_isUnderline) decorations.add(TextDecoration.underline);
    if (_isStrikethrough) decorations.add(TextDecoration.lineThrough);
    
    return decorations.isEmpty 
        ? TextDecoration.none 
        : TextDecoration.combine(decorations);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Notes Format Sheet'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Note content area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'iOS Notes-Style Format Sheet',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap "Show Format Sheet" to see a non-modal formatting sheet. '
                      'You can continue editing the note while the sheet is open!',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Mock note content
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: CupertinoColors.separator,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _noteContent,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                              fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
                              decoration: _buildTextDecoration(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Features list
                    const Text(
                      'Key Features:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• Non-modal sheet (background stays interactive)\n'
                      '• Horizontal formatting button rows\n'
                      '• Toggle states for formatting options\n'
                      '• Native iOS sheet presentation\n'
                      '• Custom Flutter widget content\n'
                      '• Draggable with custom detents',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            
            // Show Format Sheet button at bottom
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: _showFormatSheet,
                  child: const Text('Show Format Sheet'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
