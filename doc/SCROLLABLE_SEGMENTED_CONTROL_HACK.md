# The Incredible Scrollable Segmented Control Hack 🎯

## The Problem

When using a `CNNavigationBar` with a segmented control that has many segments or long labels, the control would be cut off or cramped, making it unusable.

## The Solution

We implemented a sophisticated scrollable segmented control system that:

1. **Wraps UISegmentedControl in UIScrollView**: The segmented control is placed inside a scroll view container, allowing horizontal scrolling when content exceeds available space.

2. **Extends Under Trailing Buttons**: The scroll view can extend beneath trailing action buttons with a gradient fade effect, maximizing available space.

3. **Auto-Scroll to Center**: When a segment is tapped (especially one at the edge), it automatically scrolls to center, revealing adjacent segments.

4. **Liquid Glass Effect**: The scrollable area maintains the navigation bar's translucent blur effect, with content scrolling beneath it.

## Implementation Details

### iOS Native (Swift)

**Container Structure**:
```
UIView (container)
  ├── UIScrollView
  │   └── UISegmentedControl (scrollable content)
  └── UIView (fade overlay with gradient)
      └── CAGradientLayer (fade effect)
```

**Auto-Scroll Algorithm**:
1. Detect segment selection
2. Calculate segment position and width
3. Compute center point of selected segment
4. Calculate scroll offset to center that segment
5. Animate scroll to target position

**Key Features**:
- `showsHorizontalScrollIndicator = false`: Clean appearance
- Gradient fade from clear to black (85% → 100% width)
- Uses view tags for reference management
- Smooth 0.3s ease-in-out animation

### Flutter Side

No changes needed! The existing `CNNavigationBar` API with `segmentedControlLabels` automatically gets scrollability when needed.

## Usage Example

```dart
CNNavigationBar(
  segmentedControlLabels: [
    'Notifications',
    'Buddy Requests', 
    'Grid Requests',
    'Messages',
    'Activity',
    'Settings',
  ],
  segmentedControlSelectedIndex: 0,
  onSegmentedControlValueChanged: (index) {
    print('Selected: $index');
  },
  segmentedControlTint: CupertinoColors.white,
  trailing: [
    CNNavigationBarAction(
      icon: CNSymbol('gear'),
      onPressed: () {},
    ),
  ],
)
```

## Edge Cases Handled

1. **Variable Width Segments**: Algorithm inspects UISegmentedControl subviews to get actual segment widths
2. **Scroll Bounds**: Clamps scroll offset to valid content range
3. **First/Last Segment**: Centers segments even at scroll boundaries
4. **Trailing Button Overlap**: Gradient fade prevents visual confusion
5. **Liquid Glass Blur**: Scrolling content appears beneath translucent navbar

## Performance

- ✅ Native scrolling performance (UIScrollView)
- ✅ Hardware-accelerated gradient (CAGradientLayer)
- ✅ Smooth animations (UIView.animate)
- ✅ No Flutter → Native bridge overhead during scrolling

## Browser Support

- ✅ iOS 13+ (selectedSegmentTintColor)
- ✅ macOS 10.15+ (NSSegmentedControl in toolbar)

## Future Enhancements

- [ ] Snap-to-segment behavior
- [ ] Configurable fade gradient color
- [ ] Scroll indicator (optional)
- [ ] Accessibility announcements for scrolled segments
- [ ] macOS implementation parity

---

**Status**: ✅ Implemented and tested
**Difficulty**: 🔥🔥🔥🔥🔥 (5/5 - The Most Incredible Hack!)
