/// Visual styles for [CNButton] and related controls.
///
/// iOS provides several button styles following Apple's Human Interface Guidelines.
/// Each style has specific use cases and visual treatment. Choose the style based
/// on the button's role and importance in the UI hierarchy.
///
/// ## Style Guide
///
/// ### Minimal Emphasis
/// - [plain]: Text-only, minimal visual weight. Use for secondary or tertiary actions
///   that don't need prominence. Example: "Cancel" or "Learn More" links.
///
/// ### Subtle Background
/// - [gray]: Subtle gray background. Use for tertiary actions that need slightly
///   more visual weight than plain. Example: "Maybe Later" or "Skip".
///
/// ### Moderate Emphasis
/// - [tinted]: Uses the accent color for text. Moderate emphasis without background.
///   Use for main actions within grouped controls. Example: "Edit" in a list item.
///
/// ### Bordered Styles
/// - [bordered]: Clear border, no background fill. Use for important secondary actions.
///   Example: "Cancel" button paired with filled action button.
/// - [borderedProminent]: Bordered with accent color. High emphasis bordered style.
///   Example: "Delete" with confirmation border.
///
/// ### Filled Styles
/// - [filled]: Solid background with accent color. Primary action button.
///   Use only one per screen. Example: "Save", "Send", "Create".
/// - [glass]: Modern frosted glass effect with blur background (iOS 16+/macOS 13+).
///   Use for premium visual polish. Example: Overlay buttons on images.
/// - [prominentGlass]: More prominent glass effect. Use for primary actions
///   with glass aesthetic.
///
/// ## Best Practices
///
/// 1. **One Primary Button**: Use [filled] for the primary action only
/// 2. **Visual Hierarchy**: Use style to show importance - prominent > bordered > gray > plain
/// 3. **Grouping**: Use consistent styles for related buttons
/// 4. **Touch Targets**: Ensure all buttons meet 44pt minimum height (Apple guideline)
/// 5. **Disable Instead of Hide**: Use disabled state rather than removing unavailable buttons
///
/// ## Usage Example
///
/// ```dart
/// Row(
///   children: [
///     CNButton(
///       label: 'Cancel',
///       style: CNButtonStyle.plain,
///       onPressed: () {},
///     ),
///     CNButton(
///       label: 'Save',
///       style: CNButtonStyle.filled,
///       onPressed: () {},
///     ),
///   ],
/// )
/// ```
enum CNButtonStyle {
  /// Minimal, text-only style.
  plain,

  /// Subtle gray background style.
  gray,

  /// Tinted/filled text style.
  tinted,

  /// Bordered button style.
  bordered,

  /// Prominent bordered (accent-colored) style.
  borderedProminent,

  /// Filled background style.
  filled,

  /// Glass effect (iOS 16+/macOS 13+ look-alike).
  glass, // iOS 26+
  /// More prominent glass effect.
  prominentGlass, // iOS 26+
}
