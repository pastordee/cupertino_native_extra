import Flutter
import UIKit
import ObjectiveC

/// A plain container that reports every layout pass.
///
/// The scrolling title view has to be clamped to the room actually left between
/// the bar's leading and trailing buttons, and that is only knowable once those
/// buttons have been laid out — so the clamp is applied here rather than at
/// construction time.
final class LayoutReportingView: UIView {
  var onLayout: (() -> Void)?

  override func layoutSubviews() {
    super.layoutSubviews()
    onLayout?()
  }
}

class CupertinoNavigationBarPlatformView: NSObject, FlutterPlatformView {
  /// Extra space between a menu item's icon and its label, in points.
  /// See where it is applied for why this goes through the alignment rect.
  private static let menuIconTitleGap: CGFloat = 6

  private let channel: FlutterMethodChannel
  private let container: UIView
  private let navigationBar: UINavigationBar
  private let navigationItem: UINavigationItem
  private var currentTitle: String = ""
  /// Width constraint on the scrolling segmented-control title, and the width
  /// that control would take if nothing constrained it.
  private var segmentedTitleWidthConstraint: NSLayoutConstraint?
  private var segmentedTitleIntrinsicWidth: CGFloat = 0
  private weak var segmentedTitleScrollView: UIScrollView?
  private weak var segmentedTitleControl: UISegmentedControl?
  private var segmentedControlWidthConstraint: NSLayoutConstraint?
  /// Width the control needs for every segment to hold the longest label.
  private var segmentedEqualWidth: CGFloat = 0
  /// Each label's rendered width, in segment order. Segment positions are
  /// derived from these rather than read off the control's subviews.
  private var segmentedLabelWidths: [CGFloat] = []
  /// Font the segment labels are measured with, kept so a replacement set of
  /// labels can be measured exactly as the original set was.
  private var segmentedMeasuringFont: UIFont = .systemFont(ofSize: 13)
  private var didInitialSegmentScroll = false
  private var currentTint: UIColor? = nil
  private var isTransparent: Bool = false
  private var leadingPopupMenus: [Any?] = []
  private var middlePopupMenus: [Any?] = []
  private var trailingPopupMenus: [Any?] = []
  private let registrar: FlutterPluginRegistrar

  init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger, registrar: FlutterPluginRegistrar) {
    self.registrar = registrar
    self.channel = FlutterMethodChannel(name: "CupertinoNativeNavigationBar_\(viewId)", binaryMessenger: messenger)
    self.container = LayoutReportingView(frame: frame)
    self.navigationBar = UINavigationBar(frame: .zero)
    self.navigationItem = UINavigationItem()

    var title: String = ""
    var titleSize: Double = 0
    var titleClickable: Bool = false
    var leadingIcons: [String] = []
    var leadingLabels: [String] = []
    var leadingPaddings: [Double] = []
    var leadingLabelSizes: [Double] = []
    var leadingIconSizes: [Double] = []
    var leadingSpacers: [String] = []
    var leadingTints: [Int] = []
    var leadingBadgeValues: [String] = []
    var leadingBadgeColors: [Int] = []
    var leadingImageAssets: [String] = []
    var middleIcons: [String] = []
    var middleLabels: [String] = []
    var middlePaddings: [Double] = []
    var middleSpacers: [String] = []
    var middleTints: [Int] = []
    var middleAlignment: String = "center"
    var trailingIcons: [String] = []
    var trailingLabels: [String] = []
    var trailingPaddings: [Double] = []
    var trailingLabelSizes: [Double] = []
    var trailingIconSizes: [Double] = []
    var trailingSpacers: [String] = []
    var trailingTints: [Int] = []
    var trailingBadgeValues: [String] = []
    var trailingBadgeColors: [Int] = []
    var trailingImageAssets: [String] = []
    var largeTitle: Bool = false
    var transparent: Bool = false
    var isDark: Bool = false
    var tint: UIColor? = nil
    var pillHeight: Double? = nil
    var hasSegmentedControl: Bool = false
    var segmentedControlLabels: [String] = []
    var segmentedControlSelectedIndex: Int = 0
    var segmentedControlHeight: Double = 28.0
    var segmentedControlLabelSize: Double = 0
    var segmentedControlTint: UIColor? = nil
    var segmentedControlSelectedColor: UIColor? = nil
    var segmentedControlLabelColor: UIColor? = nil
    var segmentedControlSelectedLabelColor: UIColor? = nil

    if let dict = args as? [String: Any] {
      title = (dict["title"] as? String) ?? ""
      titleSize = (dict["titleSize"] as? Double) ?? 0
      titleClickable = (dict["titleClickable"] as? Bool) ?? false
      leadingIcons = (dict["leadingIcons"] as? [String]) ?? []
      leadingLabels = (dict["leadingLabels"] as? [String]) ?? []
      leadingPaddings = (dict["leadingPaddings"] as? [Double]) ?? []
      leadingLabelSizes = (dict["leadingLabelSizes"] as? [Double]) ?? []
      leadingIconSizes = (dict["leadingIconSizes"] as? [Double]) ?? []
      leadingSpacers = (dict["leadingSpacers"] as? [String]) ?? []
      leadingTints = (dict["leadingTints"] as? [Int]) ?? []
      leadingBadgeValues = (dict["leadingBadgeValues"] as? [String]) ?? []
      leadingBadgeColors = (dict["leadingBadgeColors"] as? [Int]) ?? []
      leadingImageAssets = (dict["leadingImageAssets"] as? [String]) ?? []
      middleIcons = (dict["middleIcons"] as? [String]) ?? []
      middleLabels = (dict["middleLabels"] as? [String]) ?? []
      middlePaddings = (dict["middlePaddings"] as? [Double]) ?? []
      middleSpacers = (dict["middleSpacers"] as? [String]) ?? []
      middleTints = (dict["middleTints"] as? [Int]) ?? []
      middleAlignment = (dict["middleAlignment"] as? String) ?? "center"
      trailingIcons = (dict["trailingIcons"] as? [String]) ?? []
      trailingLabels = (dict["trailingLabels"] as? [String]) ?? []
      trailingPaddings = (dict["trailingPaddings"] as? [Double]) ?? []
      trailingLabelSizes = (dict["trailingLabelSizes"] as? [Double]) ?? []
      trailingIconSizes = (dict["trailingIconSizes"] as? [Double]) ?? []
      trailingSpacers = (dict["trailingSpacers"] as? [String]) ?? []
      trailingTints = (dict["trailingTints"] as? [Int]) ?? []
      trailingBadgeValues = (dict["trailingBadgeValues"] as? [String]) ?? []
      trailingBadgeColors = (dict["trailingBadgeColors"] as? [Int]) ?? []
      trailingImageAssets = (dict["trailingImageAssets"] as? [String]) ?? []
      leadingPopupMenus = (dict["leadingPopupMenus"] as? [Any?]) ?? []
      middlePopupMenus = (dict["middlePopupMenus"] as? [Any?]) ?? []
      trailingPopupMenus = (dict["trailingPopupMenus"] as? [Any?]) ?? []
      pillHeight = dict["pillHeight"] as? Double
      hasSegmentedControl = (dict["hasSegmentedControl"] as? Bool) ?? false
      segmentedControlLabels = (dict["segmentedControlLabels"] as? [String]) ?? []
      segmentedControlSelectedIndex = (dict["segmentedControlSelectedIndex"] as? Int) ?? 0
      segmentedControlHeight = (dict["segmentedControlHeight"] as? Double) ?? 28.0
      segmentedControlLabelSize = (dict["segmentedControlLabelSize"] as? Double) ?? 0
      if let tintValue = dict["segmentedControlTint"] as? NSNumber {
        segmentedControlTint = Self.colorFromARGB(tintValue.intValue)
      }
      if let v = dict["segmentedControlSelectedColor"] as? NSNumber {
        segmentedControlSelectedColor = Self.colorFromARGB(v.intValue)
      }
      if let v = dict["segmentedControlLabelColor"] as? NSNumber {
        segmentedControlLabelColor = Self.colorFromARGB(v.intValue)
      }
      if let v = dict["segmentedControlSelectedLabelColor"] as? NSNumber {
        segmentedControlSelectedLabelColor = Self.colorFromARGB(v.intValue)
      }
      if let v = dict["largeTitle"] as? NSNumber { largeTitle = v.boolValue }
      if let v = dict["transparent"] as? NSNumber { transparent = v.boolValue }
      if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
      if let style = dict["style"] as? [String: Any], let n = style["tint"] as? NSNumber {
        tint = Self.colorFromARGB(n.intValue)
      }
    }

    super.init()

    container.backgroundColor = .clear
    if #available(iOS 13.0, *) {
      container.overrideUserInterfaceStyle = isDark ? .dark : .light
    }

    // Configure navigation bar with translucent blur effect
    navigationBar.translatesAutoresizingMaskIntoConstraints = false
    
    if #available(iOS 13.0, *) {
      let appearance = UINavigationBarAppearance()
      if transparent {
        appearance.configureWithTransparentBackground()
        // Remove ALL background effects so only our pill backgrounds show
        appearance.backgroundEffect = nil
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
      } else {
        appearance.configureWithDefaultBackground()
        // Enable blur effect with more translucent material for better liquid glass effect
        appearance.backgroundEffect = UIBlurEffect(style: isDark ? .systemThinMaterialDark : .systemThinMaterialLight)
      }
      
      // Configure title text attributes
      var titleAttributes: [NSAttributedString.Key: Any] = [:]
      var largeTitleAttributes: [NSAttributedString.Key: Any] = [:]
      
      if let tintColor = tint {
        titleAttributes[.foregroundColor] = tintColor
        largeTitleAttributes[.foregroundColor] = tintColor
      }
      
      if titleSize > 0 {
        titleAttributes[.font] = UIFont.systemFont(ofSize: CGFloat(titleSize))
        // For large titles, make them proportionally larger
        largeTitleAttributes[.font] = UIFont.systemFont(ofSize: CGFloat(titleSize * 1.5))
      }
      
      appearance.titleTextAttributes = titleAttributes
      appearance.largeTitleTextAttributes = largeTitleAttributes
      
      navigationBar.standardAppearance = appearance
      navigationBar.scrollEdgeAppearance = appearance
      navigationBar.compactAppearance = appearance
      if #available(iOS 15.0, *) {
        navigationBar.compactScrollEdgeAppearance = appearance
      }
    } else {
      if transparent {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
      } else {
        navigationBar.isTranslucent = true
      }
    }
    
    if #available(iOS 11.0, *) {
      navigationBar.prefersLargeTitles = largeTitle
      navigationItem.largeTitleDisplayMode = largeTitle ? .always : .never
    }

        // Leading buttons - group consecutive items, split on flexibleSpace
    if !leadingIcons.isEmpty || !leadingLabels.isEmpty {
      var barItems: [UIBarButtonItem] = []
      let count = max(leadingIcons.count, leadingLabels.count)

      var currentGroupIcons: [String] = []
      var currentGroupLabels: [String] = []
      var currentGroupPaddings: [Double] = []
      var currentGroupLabelSizes: [Double] = []
      var currentGroupIconSizes: [Double] = []
      var currentGroupIndices: [Int] = []
      var currentGroupTints: [Int] = []
      var currentGroupBadgeValues: [String] = []
      var currentGroupBadgeColors: [Int] = []
      var currentGroupImageAssets: [String] = []
      var pendingSpacing: Double = 0.0  // Track spacing to add to next button

      func finalizeCurrentGroup() {
        if !currentGroupIcons.isEmpty || !currentGroupLabels.isEmpty {
          let buttonGroup = createButtonGroup(
            icons: currentGroupIcons,
            labels: currentGroupLabels,
            paddings: currentGroupPaddings,
            labelSizes: currentGroupLabelSizes,
            iconSizes: currentGroupIconSizes,
            imageAssets: currentGroupImageAssets,
            pillHeight: pillHeight,
            tint: tint,
            tints: currentGroupTints,
            badgeValues: currentGroupBadgeValues,
            badgeColors: currentGroupBadgeColors,
            isDark: isDark,
            target: self,
            action: #selector(leadingTapped(_:)),
            popupMenus: leadingPopupMenus,
            location: "leading"
          )

          // Set tags for all buttons in the group
          let buttons = findAllButtons(in: buttonGroup)
          for (idx, button) in buttons.enumerated() {
            if idx < currentGroupIndices.count {
              button.tag = currentGroupIndices[idx]
            }
          }

          let barItem = UIBarButtonItem(customView: buttonGroup)
          barItems.append(barItem)

          currentGroupIcons = []
          currentGroupLabels = []
          currentGroupPaddings = []
          currentGroupLabelSizes = []
          currentGroupIconSizes = []
          currentGroupIndices = []
          currentGroupTints = []
          currentGroupImageAssets = []
          pendingSpacing = 0.0
        }
      }

      for i in 0..<count {
        let spacerType = i < leadingSpacers.count ? leadingSpacers[i] : ""

        if spacerType == "flexible" {
          // Finalize current group and add flexible space
          finalizeCurrentGroup()
          let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
          barItems.append(flexibleSpace)
        } else if spacerType == "fixed" {
          // Fixed space - split between previous and next button
          let fixedSpaceWidth = i < leadingPaddings.count ? leadingPaddings[i] : 0
          let halfSpace = fixedSpaceWidth / 2.0

          // Add half to the previous button if it exists
          if !currentGroupPaddings.isEmpty {
            let lastIndex = currentGroupPaddings.count - 1
            currentGroupPaddings[lastIndex] += halfSpace
          }

          // Store the other half for the next button
          pendingSpacing = halfSpace
        } else {
          // Regular button - add to current group
          let icon = i < leadingIcons.count ? leadingIcons[i] : ""
          let label = i < leadingLabels.count ? leadingLabels[i] : ""
          var padding = i < leadingPaddings.count ? leadingPaddings[i] : 0.0
          let labelSize = i < leadingLabelSizes.count ? leadingLabelSizes[i] : 0.0
          let iconSize = i < leadingIconSizes.count ? leadingIconSizes[i] : 0.0
          let tintValue = i < leadingTints.count ? leadingTints[i] : 0

          // Add any pending spacing from a previous fixedSpace
          padding += pendingSpacing
          pendingSpacing = 0.0

          currentGroupIcons.append(icon)
          currentGroupLabels.append(label)
          currentGroupPaddings.append(padding)
          currentGroupLabelSizes.append(labelSize)
          currentGroupIconSizes.append(iconSize)
          currentGroupIndices.append(i)
          currentGroupTints.append(tintValue)
          currentGroupImageAssets.append(i < leadingImageAssets.count ? leadingImageAssets[i] : "")

          let badgeValue = i < leadingBadgeValues.count ? leadingBadgeValues[i] : ""
          let badgeColor = i < leadingBadgeColors.count ? leadingBadgeColors[i] : 0
          currentGroupBadgeValues.append(badgeValue)
          currentGroupBadgeColors.append(badgeColor)
        }
      }

      // Finalize any remaining group
      finalizeCurrentGroup()

      navigationItem.leftBarButtonItems = barItems
    }

    // Middle buttons - group consecutive items, split on flexibleSpace
    if !middleIcons.isEmpty || !middleLabels.isEmpty {
      var middleBarItems: [UIBarButtonItem] = []
      let count = max(middleIcons.count, middleLabels.count)
      
      var currentGroupIcons: [String] = []
      var currentGroupLabels: [String] = []
      var currentGroupPaddings: [Double] = []
      var currentGroupIndices: [Int] = []
      var currentGroupTints: [Int] = []
      var currentGroupBadgeValues: [String] = []
      var currentGroupBadgeColors: [Int] = []
      var pendingSpacing: Double = 0.0  // Track spacing to add to next button
      
      func finalizeCurrentGroup() {
        if !currentGroupIcons.isEmpty || !currentGroupLabels.isEmpty {
          let buttonGroup = createButtonGroup(
            icons: currentGroupIcons,
            labels: currentGroupLabels,
            paddings: currentGroupPaddings,
            labelSizes: [], // Middle section doesn't use custom sizes in navigation bar
            iconSizes: [], // Middle section doesn't use custom sizes in navigation bar
            pillHeight: pillHeight,
            tint: tint,
            tints: currentGroupTints,
            badgeValues: currentGroupBadgeValues,
            badgeColors: currentGroupBadgeColors,
            isDark: isDark,
            target: self,
            action: #selector(middleTapped(_:)),
            popupMenus: middlePopupMenus,
            location: "middle"
          )
          
          // Set tags for all buttons in the group
          let buttons = findAllButtons(in: buttonGroup)
          for (idx, button) in buttons.enumerated() {
            if idx < currentGroupIndices.count {
              button.tag = 1000 + currentGroupIndices[idx]
            }
          }
          
          let barItem = UIBarButtonItem(customView: buttonGroup)
          middleBarItems.append(barItem)
          
          currentGroupIcons = []
          currentGroupLabels = []
          currentGroupPaddings = []
          currentGroupIndices = []
          currentGroupTints = []
          pendingSpacing = 0.0
        }
      }
      
      for i in 0..<count {
        let spacerType = i < middleSpacers.count ? middleSpacers[i] : ""
        
        if spacerType == "flexible" {
          // Finalize current group and add flexible space
          finalizeCurrentGroup()
          let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
          middleBarItems.append(flexibleSpace)
        } else if spacerType == "fixed" {
          // Fixed space - split between previous and next button
          let fixedSpaceWidth = i < middlePaddings.count ? middlePaddings[i] : 0
          let halfSpace = fixedSpaceWidth / 2.0
          
          // Add half to the previous button if it exists
          if !currentGroupPaddings.isEmpty {
            let lastIndex = currentGroupPaddings.count - 1
            currentGroupPaddings[lastIndex] += halfSpace
          }
          
          // Store the other half for the next button
          pendingSpacing = halfSpace
        } else {
          // Regular button - add to current group
          let icon = i < middleIcons.count ? middleIcons[i] : ""
          let label = i < middleLabels.count ? middleLabels[i] : ""
          var padding = i < middlePaddings.count ? middlePaddings[i] : 0
          let tintValue = i < middleTints.count ? middleTints[i] : 0
          
          // Add any pending spacing from a previous fixedSpace
          padding += pendingSpacing
          pendingSpacing = 0.0
          
          currentGroupIcons.append(icon)
          currentGroupLabels.append(label)
          currentGroupPaddings.append(padding)
          currentGroupIndices.append(i)
          currentGroupTints.append(tintValue)
          
          let badgeValue = i < leadingBadgeValues.count ? leadingBadgeValues[i] : ""
          let badgeColor = i < leadingBadgeColors.count ? leadingBadgeColors[i] : 0
          currentGroupBadgeValues.append(badgeValue)
          currentGroupBadgeColors.append(badgeColor)
        }
      }
      
      // Finalize any remaining group
      finalizeCurrentGroup()
      
      let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
      
      let hasLeading = navigationItem.leftBarButtonItems != nil && !navigationItem.leftBarButtonItems!.isEmpty
      let hasTrailing = !trailingIcons.isEmpty || !trailingLabels.isEmpty
      
      // Apply alignment based on middleAlignment parameter
      if middleAlignment == "leading" && hasLeading {
        // Position close to leading - append right after leading, then add flexible space
        navigationItem.leftBarButtonItems?.append(contentsOf: middleBarItems)
        navigationItem.leftBarButtonItems?.append(flexibleSpace)
      } else if middleAlignment == "trailing" && hasTrailing {
        // Position close to trailing - add flexible space first, then middle to right items
        if hasLeading {
          navigationItem.leftBarButtonItems?.append(flexibleSpace)
        } else {
          navigationItem.leftBarButtonItems = [flexibleSpace]
        }
        navigationItem.rightBarButtonItems = middleBarItems
      } else {
        // Center alignment (default) - flexible space on both sides
        // Also use center if alignment is leading/trailing but no leading/trailing exists
        let flexibleSpace2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        if hasLeading {
          navigationItem.leftBarButtonItems?.append(flexibleSpace)
          navigationItem.leftBarButtonItems?.append(contentsOf: middleBarItems)
          navigationItem.leftBarButtonItems?.append(flexibleSpace2)
        } else {
          navigationItem.leftBarButtonItems = [flexibleSpace] + middleBarItems + [flexibleSpace2]
        }
      }
    }
    
    // Clear title since we're using bar button items
    if !middleIcons.isEmpty || !middleLabels.isEmpty {
      navigationItem.title = nil
      navigationItem.titleView = nil
    } else if hasSegmentedControl && !segmentedControlLabels.isEmpty {
      // THE INCREDIBLE HACK: Scrollable Segmented Control
      // Create a scroll view container for the segmented control
      let scrollView = UIScrollView()
      scrollView.showsHorizontalScrollIndicator = false
      scrollView.showsVerticalScrollIndicator = false
      scrollView.bounces = true
      scrollView.translatesAutoresizingMaskIntoConstraints = false
      // Keep the pill a pill. Where the control is wider than the room it has,
      // the scroll view's edge is what you see — and a square cut hard against
      // a bar button reads as a control running underneath it rather than one
      // you can scroll. Rounding the clip to the control's own corner radius
      // makes the boundary look like the end of a pill, which is what it is.
      scrollView.layer.cornerRadius = CGFloat(segmentedControlHeight) / 2
      scrollView.clipsToBounds = true
      
      // Create segmented control
      let segmentedControl = UISegmentedControl(items: segmentedControlLabels)
      segmentedControl.selectedSegmentIndex = segmentedControlSelectedIndex
      segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
      segmentedControl.translatesAutoresizingMaskIntoConstraints = false
      
      // Apply label size if specified
      if segmentedControlLabelSize > 0 {
        if #available(iOS 13.0, *) {
          var attrs = segmentedControl.titleTextAttributes(for: .normal) ?? [:]
          attrs[.font] = UIFont.systemFont(ofSize: CGFloat(segmentedControlLabelSize))
          segmentedControl.setTitleTextAttributes(attrs, for: .normal)
        }
      }
      
      // Overall control ("track") background. `segmentedControlTint` matches
      // Android's semantics where it colors the whole control background.
      if let segTint = segmentedControlTint {
        segmentedControl.backgroundColor = segTint
      }

      // Selected-segment ("thumb") background. Only set when explicitly given so
      // an unset value keeps iOS's default selected appearance.
      if let segSelected = segmentedControlSelectedColor {
        segmentedControl.selectedSegmentTintColor = segSelected
      }

      // Per-state label colors. Only override the attribute that was provided so
      // unset states keep the system default.
      if let normalColor = segmentedControlLabelColor {
        var attrs = segmentedControl.titleTextAttributes(for: .normal) ?? [:]
        attrs[.foregroundColor] = normalColor
        segmentedControl.setTitleTextAttributes(attrs, for: .normal)
      }
      if let selectedColor = segmentedControlSelectedLabelColor {
        var attrs = segmentedControl.titleTextAttributes(for: .selected) ?? [:]
        attrs[.foregroundColor] = selectedColor
        segmentedControl.setTitleTextAttributes(attrs, for: .selected)
      }

      // Add segmented control to scroll view
      scrollView.addSubview(segmentedControl)
      
      // Measure the labels directly rather than asking the control.
      //
      // UISegmentedControl's fitting sizes are not dependable here:
      // layoutFittingCompressedSize is the width it will squeeze DOWN to, not
      // the width it wants, and intrinsicContentSize disagreed with both — which
      // put the mode choice below on the wrong side of the comparison and left
      // "Sermons" clipped in a pill with room to spare. The labels and the font
      // are known, so measure them.
      let measuringFont = UIFont.systemFont(
        ofSize: segmentedControlLabelSize > 0 ? CGFloat(segmentedControlLabelSize) : 13
      )
      segmentedMeasuringFont = measuringFont
      // Room either side of each label, covering the control's own insets.
      let perSegmentPadding: CGFloat = 26
      var totalLabels: CGFloat = 0
      segmentedLabelWidths = []
      for label in segmentedControlLabels {
        let width = (label as NSString).size(withAttributes: [.font: measuringFont]).width
        segmentedLabelWidths.append(width)
        totalLabels += width
      }
      let count = CGFloat(max(1, segmentedControlLabels.count))
      segmentedEqualWidth = totalLabels + perSegmentPadding * count

      // Each segment takes the width its own label needs, and the control is
      // left at that width. Stretching a control in this mode is what broke the
      // layout: given more width than its content needs it hands almost all of
      // the surplus to the first segment and pushes the rest out of view.
      segmentedControl.apportionsSegmentWidthsByContent = true
      // Refuse to be squeezed. Without this the control gives up its intrinsic
      // width to fit the scroll view's frame and truncates the last label
      // ("All Prayer") — and having shrunk to fit, there is no overflow left to
      // scroll. Holding its full width makes the overflow real, so the selected
      // segment can be scrolled into view instead.
      segmentedControl.setContentCompressionResistancePriority(.required, for: .horizontal)
      let segmentWidth = segmentedEqualWidth
      
      // Pin the control to the scroll view's CONTENT guide, not its frame.
      //
      // These anchors used to go to scrollView.leading/trailing/top/bottom,
      // which are the frame's edges. Pinning all four of those and then fixing
      // the width forced the scroll view's FRAME to be segmentWidth wide, so it
      // could never scroll — and it dragged the title view out past the space
      // between the bar's buttons, where the navigation bar clipped it. That is
      // why a four-segment control came out sliced flat down its right edge.
      //
      // Against the content guide the width describes what there is to scroll,
      // and the frame is free to be narrower than it.
      let contentGuide = scrollView.contentLayoutGuide
      let frameGuide = scrollView.frameLayoutGuide
      // Pin the control to the width IT says it needs.
      //
      // Measuring the labels ourselves made it slightly too narrow and
      // UISegmentedControl truncated the last one ("All Pr…"); leaving it
      // unconstrained was no better, because something in the scroll view's
      // constraint chain still compressed it and it shaved the final character.
      // intrinsicContentSize is the control's own answer, taken after its
      // titles and font are set, so it is by definition enough to draw every
      // label — and pinning to it makes the overflow real for the scroll view.
      let naturalWidth = segmentedControl.intrinsicContentSize.width
      let naturalWidthConstraint =
        segmentedControl.widthAnchor.constraint(equalToConstant: naturalWidth)
      naturalWidthConstraint.isActive = true
      // Kept so a later change of labels can repin it — otherwise the control
      // holds the width it needed for the labels it was born with.
      segmentedControlWidthConstraint = naturalWidthConstraint
      let segmentedHeight =
        segmentedControl.heightAnchor.constraint(equalToConstant: CGFloat(segmentedControlHeight))
      // Priority 999, not required. UIKit sizes a navigation bar's title and
      // button areas on a first pass with placeholder geometry — you can see it
      // as '_UITemporaryLayoutHeight' in the unsatisfiable-constraint logs —
      // before the real space is known. A required constraint of ours in that
      // pass is a flat contradiction with UIKit's own required one, so it logs
      // and gets broken; at 999 it simply yields for that pass and applies
      // normally once the true geometry arrives. Still above every content
      // hugging and compression priority, so nothing about the settled layout
      // changes.
      segmentedHeight.priority = .required - 1
      NSLayoutConstraint.activate([
        segmentedControl.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor),
        segmentedControl.trailingAnchor.constraint(equalTo: contentGuide.trailingAnchor),
        segmentedControl.topAnchor.constraint(equalTo: contentGuide.topAnchor),
        segmentedControl.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor),
        segmentedHeight,
        // Only the height is shared with the frame; the width is free to differ,
        // which is exactly what makes horizontal scrolling possible.
        frameGuide.heightAnchor.constraint(equalTo: contentGuide.heightAnchor)
      ])
      
      // Create a container view to hold scroll view and fade overlay
      let containerView = UIView()
      containerView.translatesAutoresizingMaskIntoConstraints = false
      containerView.addSubview(scrollView)
      
      // Scroll view fills the container
      let scrollHeight =
        scrollView.heightAnchor.constraint(equalToConstant: CGFloat(segmentedControlHeight))
      // Same first-pass reason as segmentedHeight above.
      scrollHeight.priority = .required - 1
      NSLayoutConstraint.activate([
        scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
        scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        scrollView.topAnchor.constraint(equalTo: containerView.topAnchor),
        scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        scrollHeight
      ])

      // Clamp the title view to the room actually left between the bar's
      // buttons, so it can never be drawn underneath them.
      //
      // Left to itself the title view takes whatever width its content wants
      // and the navigation bar lets it run under the trailing buttons, clipping
      // it — a four-segment control came out sliced flat down its right edge
      // with its last segment hidden. The width is set for real (not as a
      // preference) and recomputed on every layout pass by
      // updateSegmentedTitleWidth(), because how much room is left only becomes
      // known once the leading and trailing buttons have been laid out.
      containerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
      containerView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
      scrollView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

      let titleWidth = containerView.widthAnchor.constraint(equalToConstant: segmentWidth)
      // 999 rather than required. The width above is a best guess until the
      // leading and trailing buttons have been laid out, and on the first pass
      // it is routinely wider than the room the bar actually has — a required
      // constraint there contradicts UIKit's own and logs. It still outranks
      // hugging and compression, so the clamp this exists for is intact, and
      // updateSegmentedTitleWidth() corrects the constant once the real space
      // is known.
      titleWidth.priority = .required - 1
      titleWidth.isActive = true
      segmentedTitleWidthConstraint = titleWidth
      segmentedTitleIntrinsicWidth = segmentWidth
      segmentedTitleScrollView = scrollView
      segmentedTitleControl = segmentedControl
      
      // Note: Gradient fade overlay temporarily removed for debugging
      // Will add back once scrolling behavior is perfected
      
      navigationItem.titleView = containerView
      navigationItem.title = nil
    } else if !title.isEmpty {
      if titleClickable {
        // Create a clickable title button
        let titleButton = UIButton(type: .system)
        titleButton.setTitle(title, for: .normal)
        titleButton.addTarget(self, action: #selector(titleTapped), for: .touchUpInside)
        titleButton.titleLabel?.textAlignment = .center
        titleButton.sizeToFit()
        
        // Apply custom title size and appearance if specified
        var titleAttributes: [NSAttributedString.Key: Any] = [:]
        if titleSize > 0 {
          titleAttributes[.font] = UIFont.systemFont(ofSize: CGFloat(titleSize), weight: .semibold)
        } else {
          titleAttributes[.font] = UIFont.systemFont(ofSize: 17, weight: .semibold)
        }
        
        // Apply tint color if specified
        if let tintColor = tint {
          titleButton.setTitleColor(tintColor, for: .normal)
        }
        
        // Set the attributed title
        let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
        titleButton.setAttributedTitle(attributedTitle, for: .normal)
        
        navigationItem.titleView = titleButton
        navigationItem.title = nil
      } else {
        navigationItem.title = title
        navigationItem.titleView = nil
      }
    }
    
    currentTitle = title
    currentTint = tint
    isTransparent = transparent

    if let tintColor = tint {
      navigationBar.tintColor = tintColor
    }

    // Trailing buttons - group consecutive items, split on flexibleSpace
    if !trailingIcons.isEmpty || !trailingLabels.isEmpty {
      var trailingBarItems: [UIBarButtonItem] = []
      let count = max(trailingIcons.count, trailingLabels.count)

      var currentGroupIcons: [String] = []
      var currentGroupLabels: [String] = []
      var currentGroupPaddings: [Double] = []
      var currentGroupLabelSizes: [Double] = []
      var currentGroupIconSizes: [Double] = []
      var currentGroupIndices: [Int] = []
      var currentGroupTints: [Int] = []
      var currentGroupBadgeValues: [String] = []
      var currentGroupBadgeColors: [Int] = []
      var currentGroupImageAssets: [String] = []
      var pendingSpacing: Double = 0.0  // Track spacing to add to next button

      func finalizeCurrentGroup() {
        if !currentGroupIcons.isEmpty || !currentGroupLabels.isEmpty {
          let buttonGroup = createButtonGroup(
            icons: currentGroupIcons,
            labels: currentGroupLabels,
            paddings: currentGroupPaddings,
            labelSizes: currentGroupLabelSizes,
            iconSizes: currentGroupIconSizes,
            imageAssets: currentGroupImageAssets,
            pillHeight: pillHeight,
            tint: tint,
            tints: currentGroupTints,
            badgeValues: currentGroupBadgeValues,
            badgeColors: currentGroupBadgeColors,
            isDark: isDark,
            target: self,
            action: #selector(trailingTapped(_:)),
            popupMenus: trailingPopupMenus,
            location: "trailing"
          )

          // Set tags for all buttons in the group
          let buttons = findAllButtons(in: buttonGroup)
          for (idx, button) in buttons.enumerated() {
            if idx < currentGroupIndices.count {
              button.tag = 2000 + currentGroupIndices[idx]
            }
          }

          let barItem = UIBarButtonItem(customView: buttonGroup)
          trailingBarItems.append(barItem)

          currentGroupIcons = []
          currentGroupLabels = []
          currentGroupPaddings = []
          currentGroupLabelSizes = []
          currentGroupIconSizes = []
          currentGroupIndices = []
          currentGroupTints = []
          currentGroupImageAssets = []
          pendingSpacing = 0.0
        }
      }

      for i in 0..<count {
        let spacerType = i < trailingSpacers.count ? trailingSpacers[i] : ""

        if spacerType == "flexible" {
          // Finalize current group and add flexible space
          finalizeCurrentGroup()
          let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
          trailingBarItems.append(flexibleSpace)
        } else if spacerType == "fixed" {
          // Fixed space - split between previous and next button
          let fixedSpaceWidth = i < trailingPaddings.count ? trailingPaddings[i] : 0
          let halfSpace = fixedSpaceWidth / 2.0

          // Add half to the previous button if it exists
          if !currentGroupPaddings.isEmpty {
            let lastIndex = currentGroupPaddings.count - 1
            currentGroupPaddings[lastIndex] += halfSpace
          }

          // Store the other half for the next button
          pendingSpacing = halfSpace
        } else {
          // Regular button - add to current group
          let icon = i < trailingIcons.count ? trailingIcons[i] : ""
          let label = i < trailingLabels.count ? trailingLabels[i] : ""
          var padding = i < trailingPaddings.count ? trailingPaddings[i] : 0
          let labelSize = i < trailingLabelSizes.count ? trailingLabelSizes[i] : 0.0
          let iconSize = i < trailingIconSizes.count ? trailingIconSizes[i] : 0.0
          let tintValue = i < trailingTints.count ? trailingTints[i] : 0

          // Add any pending spacing from a previous fixedSpace
          padding += pendingSpacing
          pendingSpacing = 0.0

          currentGroupIcons.append(icon)
          currentGroupLabels.append(label)
          currentGroupPaddings.append(padding)
          currentGroupLabelSizes.append(labelSize)
          currentGroupIconSizes.append(iconSize)
          currentGroupIndices.append(i)
          currentGroupTints.append(tintValue)
          currentGroupImageAssets.append(i < trailingImageAssets.count ? trailingImageAssets[i] : "")

          let badgeValue = i < trailingBadgeValues.count ? trailingBadgeValues[i] : ""
          let badgeColor = i < trailingBadgeColors.count ? trailingBadgeColors[i] : 0
          currentGroupBadgeValues.append(badgeValue)
          currentGroupBadgeColors.append(badgeColor)
        }
      }

      // Finalize any remaining group
      finalizeCurrentGroup()
      
      if middleAlignment == "trailing" && navigationItem.rightBarButtonItems != nil {
        // Middle is positioned close to trailing, append trailing after middle
        navigationItem.rightBarButtonItems?.append(contentsOf: trailingBarItems)
      } else {
        // Standard trailing position
        navigationItem.rightBarButtonItems = trailingBarItems
      }
    }

    navigationBar.items = [navigationItem]
    (container as? LayoutReportingView)?.onLayout = { [weak self] in
      guard let self = self else { return }
      // Lay the bar out first. This callback fires on the platform view's own
      // layout pass, which happens BEFORE the navigation bar positions its
      // title view and buttons — so without this everything measured below
      // reads zero: the buttons take no width, the scroll view has no bounds
      // and no contentSize, and the clamp "fits" the title into nearly the
      // whole bar while the scroll logic can never see anything to scroll.
      self.navigationBar.layoutIfNeeded()
      self.updateSegmentedTitleWidth()
    }
    container.addSubview(navigationBar)

    NSLayoutConstraint.activate([
      navigationBar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      navigationBar.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      navigationBar.topAnchor.constraint(equalTo: container.topAnchor),
      navigationBar.bottomAnchor.constraint(equalTo: container.bottomAnchor),
    ])

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "getIntrinsicSize":
        let height = self.navigationBar.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).height
        result(["height": Double(height)])
      case "setTitle":
        if let args = call.arguments as? [String: Any], let title = args["title"] as? String {
          self.navigationItem.title = title
          self.currentTitle = title
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing title", details: nil))
        }
      case "setStyle":
        if let args = call.arguments as? [String: Any] {
          if let n = args["tint"] as? NSNumber {
            let tintColor = Self.colorFromARGB(n.intValue)
            self.navigationBar.tintColor = tintColor
            self.currentTint = tintColor
            if #available(iOS 13.0, *) {
              let appearance = self.navigationBar.standardAppearance
              appearance.titleTextAttributes = [.foregroundColor: tintColor]
              appearance.largeTitleTextAttributes = [.foregroundColor: tintColor]
              self.navigationBar.standardAppearance = appearance
              self.navigationBar.scrollEdgeAppearance = appearance
              self.navigationBar.compactAppearance = appearance
            }
          }
          if let t = args["transparent"] as? NSNumber {
            self.isTransparent = t.boolValue
            if #available(iOS 13.0, *) {
              let appearance = UINavigationBarAppearance()
              if self.isTransparent {
                appearance.configureWithTransparentBackground()
              } else {
                appearance.configureWithDefaultBackground()
                let isDark = self.container.traitCollection.userInterfaceStyle == .dark
                appearance.backgroundEffect = UIBlurEffect(style: isDark ? .systemMaterialDark : .systemMaterialLight)
              }
              if let tint = self.currentTint {
                appearance.titleTextAttributes = [.foregroundColor: tint]
                appearance.largeTitleTextAttributes = [.foregroundColor: tint]
              }
              self.navigationBar.standardAppearance = appearance
              self.navigationBar.scrollEdgeAppearance = appearance
              self.navigationBar.compactAppearance = appearance
            }
          }
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing style", details: nil))
        }
      case "setSegments":
        if let args = call.arguments as? [String: Any],
           let labels = args["labels"] as? [String] {
          self.updateSegments(
            labels: labels,
            selectedIndex: (args["selectedIndex"] as? NSNumber)?.intValue ?? 0
          )
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing labels", details: nil))
        }
      case "setBadges":
        if let args = call.arguments as? [String: Any] {
          self.updateBadges(
            leadingValues: (args["leadingBadgeValues"] as? [String]) ?? [],
            leadingColors: (args["leadingBadgeColors"] as? [Int]) ?? [],
            trailingValues: (args["trailingBadgeValues"] as? [String]) ?? [],
            trailingColors: (args["trailingBadgeColors"] as? [Int]) ?? []
          )
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing badges", details: nil))
        }
      case "setBrightness":
        if let args = call.arguments as? [String: Any], let isDark = (args["isDark"] as? NSNumber)?.boolValue {
          if #available(iOS 13.0, *) {
            self.container.overrideUserInterfaceStyle = isDark ? .dark : .light
            // Update blur effect for new brightness
            let appearance = self.navigationBar.standardAppearance
            if !self.isTransparent {
              appearance.backgroundEffect = UIBlurEffect(style: isDark ? .systemMaterialDark : .systemMaterialLight)
            }
            self.navigationBar.standardAppearance = appearance
            self.navigationBar.scrollEdgeAppearance = appearance
            self.navigationBar.compactAppearance = appearance
          }
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  /// Narrows the scrolling segmented-control title to the space left between
  /// the leading and trailing buttons, so it never renders beneath them.
  ///
  /// Anything wider than that space stays as scrollable content: the control
  /// keeps its full width inside the scroll view, and the part that does not
  /// fit is reached by swiping rather than by overlapping the buttons.
  private func updateSegmentedTitleWidth() {
    guard let widthConstraint = segmentedTitleWidthConstraint else { return }

    let barWidth = navigationBar.bounds.width
    guard barWidth > 0 else { return }

    // The bar button items are custom views we built, so their laid-out widths
    // are the honest measure of how much of the bar they have taken.
    let leading = (navigationItem.leftBarButtonItems ?? [])
      .reduce(CGFloat(0)) { $0 + ($1.customView?.bounds.width ?? 0) }
    let trailing = (navigationItem.rightBarButtonItems ?? [])
      .reduce(CGFloat(0)) { $0 + ($1.customView?.bounds.width ?? 0) }

    // Breathing room so the control stops short of the buttons rather than
    // touching them.
    let gutter: CGFloat = 24
    let available = max(0, barWidth - leading - trailing - gutter)
    guard available > 0 else { return }

    // The pill takes the whole space between the buttons. Hugging its content
    // instead left it looking undersized, and left no slack for a longer label
    // or another segment — the first one that did not fit would start
    // scrolling straight away.
    if abs(widthConstraint.constant - available) > 0.5 {
      widthConstraint.constant = available
    }

    // The pink track is the control's own background, so widening the scroll
    // view alone would leave a narrow pill sitting inside a wider clip. The
    // control has to be stretched too — but only in the mode that survives it.
    //
    // With equal-width segments the control divides whatever width it is given
    // evenly, so it can be stretched to fill the space. With segments sized by
    // content it cannot: given more width than its content needs, it hands
    // almost all of the surplus to the first segment and pushes the rest out of
    // view — which is what made "Sermons" disappear.
    //
    // So: while the labels fit evenly, fill the space. Once they no longer do,
    // switch to content-sized segments at their natural width, where every
    // label is drawn in full and the overflow scrolls.
    // The control keeps its natural width. It is never stretched to fill the
    // bar: content-sized segments misdistribute any surplus width, and
    // equal-width segments would have to be as wide as the longest label in
    // every segment, which starts scrolling far sooner. Where the content is
    // narrower than the bar, the pill simply sits centred with air either side.

    // Bring the starting selection into view once the scroll view has a size.
    // The tap handler already centres the selection when someone picks a
    // segment, but a tab change rebuilds this whole view from Flutter with the
    // selection preset — no tap happens, so without this the selected segment
    // can start life outside the viewport, which is precisely the one you want
    // to see.
    // Wait for the layout pass where the content is genuinely wider than the
    // frame. Marking this done as soon as contentSize was merely non-zero fired
    // it on an early pass — before the width clamp had narrowed the frame — so
    // there was nothing to scroll yet, and the one attempt was spent.
    if !didInitialSegmentScroll,
       let scrollView = segmentedTitleScrollView,
       scrollView.bounds.width > 0,
       scrollView.contentSize.width > scrollView.bounds.width {
      didInitialSegmentScroll = true
      centerSelectedSegment(animated: false)
    }
  }

  /// Replaces the segmented control's titles in place.
  ///
  /// The titles arrive with the platform view's creation params, so a set of
  /// labels that changes later — the Warriors tabs after you edit which
  /// warriors you follow — never reached the bar: the tabs below updated while
  /// the control above kept its original titles until the whole screen was
  /// rebuilt. Everything derived from the labels is recomputed here, because
  /// the widths and the scroll geometry are only as good as the labels they
  /// were measured from.
  private func updateSegments(labels: [String], selectedIndex: Int) {
    guard let control = segmentedTitleControl, !labels.isEmpty else { return }

    control.removeAllSegments()
    for (index, label) in labels.enumerated() {
      control.insertSegment(withTitle: label, at: index, animated: false)
    }
    control.selectedSegmentIndex = max(0, min(selectedIndex, labels.count - 1))

    var longestLabel: CGFloat = 0
    var totalLabels: CGFloat = 0
    segmentedLabelWidths = []
    for label in labels {
      let width = (label as NSString)
        .size(withAttributes: [.font: segmentedMeasuringFont]).width
      segmentedLabelWidths.append(width)
      longestLabel = max(longestLabel, width)
      totalLabels += width
    }
    let perSegmentPadding: CGFloat = 26
    let count = CGFloat(labels.count)
    segmentedEqualWidth = totalLabels + perSegmentPadding * count

    // A different number of segments means a different natural width, so let
    // the starting selection be scrolled into view again.
    didInitialSegmentScroll = false
    control.invalidateIntrinsicContentSize()
    // Repin to the width the NEW labels need. Left alone this still holds the
    // width the original labels needed, so a shorter set would sit in an
    // oversized control and a longer one would be truncated.
    segmentedControlWidthConstraint?.constant = control.intrinsicContentSize.width
    container.setNeedsLayout()
  }

  /// Scrolls the selected segment into view, centring it where there is room.
  private func centerSelectedSegment(animated: Bool) {
    guard let scrollView = segmentedTitleScrollView,
          let control = segmentedTitleControl else { return }

    let count = control.numberOfSegments
    let index = control.selectedSegmentIndex
    guard count > 0, index >= 0 else { return }

    let scrollWidth = scrollView.bounds.width
    let contentWidth = scrollView.contentSize.width
    // Nothing to do when everything already fits.
    guard scrollWidth > 0, contentWidth > scrollWidth else { return }

    // Work out where the segment sits from the label widths, not from the
    // control's subviews.
    //
    // Sorting subviews by x and indexing by selectedIndex looked reasonable but
    // is not: the subviews include the selected-segment indicator, which sits at
    // exactly the same x as the selected segment. With that tie the order is
    // undefined and shifts with the selection, so the offset came out right for
    // some tabs and wrong for others — the first and last ones ended up
    // half-hidden, which is the opposite of the point.
    //
    // Segments are content-apportioned, so each takes a share of the content
    // width proportional to its label.
    let segmentX: CGFloat
    let segmentWidth: CGFloat
    let totalLabels = segmentedLabelWidths.reduce(0, +)
    if index < segmentedLabelWidths.count, totalLabels > 0 {
      let before = segmentedLabelWidths.prefix(index).reduce(0, +)
      segmentX = contentWidth * (before / totalLabels)
      segmentWidth = contentWidth * (segmentedLabelWidths[index] / totalLabels)
    } else {
      segmentWidth = contentWidth / CGFloat(count)
      segmentX = CGFloat(index) * segmentWidth
    }

    let centred = (segmentX + segmentWidth / 2) - scrollWidth / 2
    let clamped = min(max(0, centred), contentWidth - scrollWidth)
    scrollView.setContentOffset(CGPoint(x: clamped, y: 0), animated: animated)
  }

  func view() -> UIView { container }

  // Helper function to find a UIButton in a view hierarchy
  private func findButton(in view: UIView) -> UIButton? {
    if let button = view as? UIButton {
      return button
    }
    for subview in view.subviews {
      if let button = findButton(in: subview) {
        return button
      }
    }
    return nil
  }
  
  // Helper function to find all UIButtons in a view hierarchy
  private static let badgeViewTag = 987654

  /// Adds, updates or removes a button's badge.
  ///
  /// The badge is drawn into an image rather than built from a UILabel. The
  /// navigation bar re-renders bar-button content as a template, which drops a
  /// label's backgroundColor and paints the whole pill flat in its textColor —
  /// that is why the badge used to come out solid white whatever colour was
  /// asked for. An .alwaysOriginal image keeps the colours it was drawn with.
  private func applyBadge(to button: UIButton, value: String, argb: Int) {
    button.viewWithTag(Self.badgeViewTag)?.removeFromSuperview()
    guard !value.isEmpty else { return }

    let badgeColor: UIColor = argb != 0 ? UIColor(argb: argb) : .systemRed
    let badgeFont = UIFont.systemFont(ofSize: 11, weight: .semibold)
    let minWidth: CGFloat = 18
    let badgeHeight: CGFloat = 18
    let textWidth = (value as NSString).size(withAttributes: [.font: badgeFont]).width
    let badgeWidth = max(minWidth, textWidth + 10)
    let badgeSize = CGSize(width: badgeWidth, height: badgeHeight)

    let badgeImage = UIGraphicsImageRenderer(size: badgeSize).image { _ in
      badgeColor.setFill()
      UIBezierPath(
        roundedRect: CGRect(origin: .zero, size: badgeSize),
        cornerRadius: badgeHeight / 2
      ).fill()

      let paragraph = NSMutableParagraphStyle()
      paragraph.alignment = .center
      let attributes: [NSAttributedString.Key: Any] = [
        .font: badgeFont,
        .foregroundColor: UIColor.white,
        .paragraphStyle: paragraph,
      ]
      let textHeight = (value as NSString).size(withAttributes: attributes).height
      (value as NSString).draw(
        in: CGRect(
          x: 0,
          y: (badgeHeight - textHeight) / 2,
          width: badgeWidth,
          height: textHeight
        ),
        withAttributes: attributes
      )
    }.withRenderingMode(.alwaysOriginal)

    let badgeView = UIImageView(image: badgeImage)
    badgeView.tag = Self.badgeViewTag
    badgeView.translatesAutoresizingMaskIntoConstraints = false
    button.addSubview(badgeView)

    NSLayoutConstraint.activate([
      badgeView.widthAnchor.constraint(equalToConstant: badgeWidth),
      badgeView.heightAnchor.constraint(equalToConstant: badgeHeight),
      badgeView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -4),
      badgeView.topAnchor.constraint(equalTo: button.topAnchor, constant: 2),
    ])
  }

  /// Re-applies badges to bar buttons that already exist. The bar items are
  /// built once from the platform view's creation params, so a badge that
  /// appears or changes after the first frame — an unread count arriving from
  /// the network, say — would otherwise never reach the screen.
  ///
  /// Buttons carry their action index in `tag`, offset by section: leading from
  /// 0, middle from 1000, trailing from 2000. Indices outside the supplied
  /// arrays belong to another section and are skipped.
  private func updateBadges(
    leadingValues: [String],
    leadingColors: [Int],
    trailingValues: [String],
    trailingColors: [Int]
  ) {
    func apply(
      _ items: [UIBarButtonItem]?,
      tagOffset: Int,
      values: [String],
      colors: [Int]
    ) {
      guard let items = items else { return }
      for item in items {
        guard let customView = item.customView else { continue }
        for button in findAllButtons(in: customView) {
          let index = button.tag - tagOffset
          guard index >= 0, index < values.count else { continue }
          applyBadge(
            to: button,
            value: values[index],
            argb: index < colors.count ? colors[index] : 0
          )
        }
      }
    }

    apply(navigationItem.leftBarButtonItems, tagOffset: 0,
          values: leadingValues, colors: leadingColors)
    apply(navigationItem.rightBarButtonItems, tagOffset: 2000,
          values: trailingValues, colors: trailingColors)
  }

  private func findAllButtons(in view: UIView) -> [UIButton] {
    var buttons: [UIButton] = []
    if let button = view as? UIButton {
      buttons.append(button)
    }
    for subview in view.subviews {
      buttons.append(contentsOf: findAllButtons(in: subview))
    }
    return buttons
  }

  @objc private func leadingTapped(_ sender: UIButton) {
    let index = sender.tag
    
    // Only handle regular button taps - popup menus are handled natively
    channel.invokeMethod("leadingTapped", arguments: ["index": index])
  }

  @objc private func middleTapped(_ sender: UIButton) {
    let index = sender.tag - 1000
    
    // Only handle regular button taps - popup menus are handled natively
    channel.invokeMethod("middleTapped", arguments: ["index": index])
  }

  @objc private func trailingTapped(_ sender: UIButton) {
    let index = sender.tag - 2000
    
    // Only handle regular button taps - popup menus are handled natively
    channel.invokeMethod("trailingTapped", arguments: ["index": index])
  }
  
  @objc private func titleTapped() {
    channel.invokeMethod("titleTapped", arguments: [:])
  }
  
  @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
    // One implementation for both paths: a tap here, and a selection that
    // arrives preset when Flutter rebuilds the bar.
    centerSelectedSegment(animated: true)

    // Notify Flutter about the selection change
    channel.invokeMethod("segmentedControlChanged", arguments: ["selectedIndex": sender.selectedSegmentIndex])
  }

  
  @objc private func buttonTouchDown(_ sender: UIButton) {
    // Animate button press with scale and alpha like UIBarButtonItem
    UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
      sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
      sender.alpha = 0.6
    })
  }
  
  @objc private func buttonTouchUp(_ sender: UIButton) {
    // Animate button release back to normal
    UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
      sender.transform = .identity
      sender.alpha = 1.0
    })
  }
  
  private func setupButtonMenu(button: UIButton, menuItems: [[String: Any]], actionIndex: Int, location: String) {
    if #available(iOS 14.0, *) {
      // Each entry (item, divider, submenu parent, and every submenu child) is
      // assigned a flat depth-first index — parent before its children — so the
      // Dart side can map the reported `menuIndex` back to an action. A flat
      // menu (no submenus) keeps the same indices as before (backward compatible).
      var flatIndex = 0
      // At the top level, a divider ends the current inline section (a native
      // `.displayInline` UIMenu), which draws a separator between groups so the
      // menu reads as sections instead of one cramped list. Submenu children are
      // built flat (`sectioned: false`). Row height itself is system-controlled.
      func build(_ items: [[String: Any]], sectioned: Bool) -> [UIMenuElement] {
        var out: [UIMenuElement] = []
        var current: [UIMenuElement] = []
        func flush() {
          if sectioned && !current.isEmpty {
            out.append(UIMenu(title: "", options: .displayInline, children: current))
            current = []
          }
        }
        func emit(_ el: UIMenuElement) {
          if sectioned { current.append(el) } else { out.append(el) }
        }
        for item in items {
          let type = item["type"] as? String ?? "item"
          let iconName = item["icon"] as? String ?? ""
          // UIMenu derives the gap between an item's icon and its label from
          // the image's alignment rect, and the system default sits tight
          // against the text. Widening the rect on the trailing edge is the
          // only lever -- neither UIMenu nor UIAction exposes a spacing
          // property. Applied here so submenu rows get it too.
          var image: UIImage? = iconName.isEmpty ? nil : UIImage(systemName: iconName)
          // Per-item point size. SF Symbols differ in width at the same size --
          // a three-person glyph is much wider than a single one -- so an item
          // can ask for a smaller size to sit level with its neighbours.
          if let img = image, let s = item["iconSize"] as? NSNumber, s.doubleValue > 0 {
            image = img.applyingSymbolConfiguration(
              UIImage.SymbolConfiguration(pointSize: CGFloat(s.doubleValue))
            )
          }
          image = image?.withAlignmentRectInsets(
            UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -Self.menuIconTitleGap)
          )

          if type == "divider" {
            flatIndex += 1  // occupies a slot to mirror the Dart flattening
            flush()         // end the current section
          } else if type == "submenu" {
            let title = item["label"] as? String ?? ""
            flatIndex += 1  // submenu parent occupies a slot
            let children = item["children"] as? [[String: Any]] ?? []
            let childElements = build(children, sectioned: false)
            emit(UIMenu(title: title, image: image, children: childElements))
          } else {
            let label = item["label"] as? String ?? ""
            let enabled = item["enabled"] as? Bool ?? true
            // The standing choice in a menu of alternatives carries a
            // checkmark, the way iOS marks one everywhere else.
            let selected = item["selected"] as? Bool ?? false
            let myIndex = flatIndex
            flatIndex += 1
            // A second line describing what the row does. UIAction.subtitle
            // is iOS 15+ and this package still supports 14, so the guard is
            // load-bearing — same shape the pull-down button uses.
            let subtitle = item["subtitle"] as? String
            let handler: (UIAction) -> Void = { [weak self] _ in
              self?.channel.invokeMethod("popupMenuSelected", arguments: [
                "location": location,
                "actionIndex": actionIndex,
                "menuIndex": myIndex
              ])
            }
            let action: UIAction
            if #available(iOS 15.0, *), let subtitle, !subtitle.isEmpty {
              action = UIAction(
                title: label,
                subtitle: subtitle,
                image: image,
                state: selected ? .on : .off,
                handler: handler
              )
            } else {
              action = UIAction(
                title: label,
                image: image,
                state: selected ? .on : .off,
                handler: handler
              )
            }
            action.attributes = enabled ? [] : [.disabled]
            emit(action)
          }
        }
        flush()
        return out
      }

      let menu = UIMenu(title: "", children: build(menuItems, sectioned: true))
      button.menu = menu
      button.showsMenuAsPrimaryAction = true
    }
  }
  
  private func createButtonGroup(
    icons: [String],
    labels: [String],
    paddings: [Double],
    labelSizes: [Double],
    iconSizes: [Double],
    imageAssets: [String] = [],
    pillHeight: Double?,
    tint: UIColor?,
    tints: [Int] = [],
    badgeValues: [String] = [],
    badgeColors: [Int] = [],
    isDark: Bool,
    target: Any?,
    action: Selector,
    popupMenus: [Any?] = [],
    location: String = ""
  ) -> UIView {
    let count = max(icons.count, labels.count)
    if count == 0 { return UIView(frame: .zero) }
    
    // Use custom pill height if provided, otherwise calculate from padding
    let customHeight = pillHeight != nil ? CGFloat(pillHeight!) : nil
    
    // Calculate widths and paddings
    var buttonWidths: [CGFloat] = []
    var buttonPaddings: [UIEdgeInsets] = []
    let defaultWidth: CGFloat = 36
    let defaultHeight: CGFloat = 36
    
    for i in 0..<count {
      let padding = i < paddings.count ? CGFloat(paddings[i]) : 0
      buttonWidths.append(defaultWidth + padding * 2)
      buttonPaddings.append(UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
    }
    
    let totalWidth = buttonWidths.reduce(0, +)
    
    // Calculate the blur view height - use custom height if provided, otherwise calculate from padding
    let blurViewHeight: CGFloat
    if let customHeight = customHeight {
      blurViewHeight = customHeight
    } else {
      let maxPadding = buttonPaddings.map { $0.top + $0.bottom }.max() ?? 0
      blurViewHeight = defaultHeight + maxPadding
    }
    
    // Create pill background view - all pills are identical and transparent
    // UIBarButtonItem will add its own background automatically
    let pillView = UIView()
    pillView.backgroundColor = .clear
    pillView.layer.cornerRadius = blurViewHeight / 2
    pillView.layer.masksToBounds = true
    
    // Create a container view to hold both pill background and content
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(pillView)
    pillView.translatesAutoresizingMaskIntoConstraints = false
    
    // Selection indicator removed - no longer showing highlight on tap
    
    // Create stack view for buttons
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 0
    stackView.distribution = .fill
    // Centre, not the default .fill. The stack is pinned to all four edges of a
    // containerView pegged to blurViewHeight (the pill), while each button below
    // gets a required height of its own — 36 plus its padding. Under .fill the
    // stack also pins every arranged subview top and bottom, demanding the
    // button be as tall as the pill, and the two required constraints cannot
    // both hold: a 48pt pill around a 40pt button logged an unsatisfiable
    // constraint every time a bar was built, and UIKit recovered by breaking
    // the button's height. Centring leaves the button its own height and puts
    // it in the middle of the pill, which is what the two numbers meant all
    // along.
    stackView.alignment = .center
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    // Create buttons
    var buttons: [UIButton] = []
    for i in 0..<count {
      let button = UIButton(type: .system)
      button.tag = i
      button.addTarget(target, action: action, for: .touchUpInside)
      
      // Add touch effect handlers for visual feedback
      button.addTarget(target, action: #selector(buttonTouchDown(_:)), for: .touchDown)
      button.addTarget(target, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
      
      if i < imageAssets.count, !imageAssets[i].isEmpty {
        let key = registrar.lookupKey(forAsset: imageAssets[i])
        if let path = Bundle.main.path(forResource: key, ofType: nil),
           let image = UIImage(contentsOfFile: path) {
          let size = i < iconSizes.count && iconSizes[i] > 0 ? CGFloat(iconSizes[i]) : 24
          let scaled = UIGraphicsImageRenderer(size: CGSize(width: size, height: size)).image { _ in
            image.draw(in: CGRect(origin: .zero, size: CGSize(width: size, height: size)))
          }
          let hasTint = (i < tints.count && tints[i] != 0) || tint != nil
          let renderingMode: UIImage.RenderingMode = hasTint ? .alwaysTemplate : .alwaysOriginal
          button.setImage(scaled.withRenderingMode(renderingMode), for: .normal)
        }
      } else if i < icons.count, !icons[i].isEmpty, let image = UIImage(systemName: icons[i]) {
        let iconSize = i < iconSizes.count && iconSizes[i] > 0 ? CGFloat(iconSizes[i]) : 17
        let config = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .semibold)
        button.setImage(image.withConfiguration(config), for: .normal)
      } else if i < labels.count, !labels[i].isEmpty {
        let labelSize = i < labelSizes.count && labelSizes[i] > 0 ? CGFloat(labelSizes[i]) : 17
        button.setTitle(labels[i], for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: labelSize, weight: .semibold)
      }
      
      // Apply individual tint color if available, otherwise use global tint
      if i < tints.count && tints[i] != 0 {
        button.tintColor = UIColor(argb: tints[i])
      } else if let tintColor = tint {
        button.tintColor = tintColor
      }
      
      // Set up popup menu if available
      if i < popupMenus.count, let menuItems = popupMenus[i] as? [[String: Any]], !menuItems.isEmpty {
        if #available(iOS 14.0, *) {
          setupButtonMenu(button: button, menuItems: menuItems, actionIndex: i, location: location)
        }
      }
      
      // Apply badge if available
      applyBadge(
        to: button,
        value: i < badgeValues.count ? badgeValues[i] : "",
        argb: i < badgeColors.count ? badgeColors[i] : 0
      )
      
      // Ensure button has no background - only the pill blur view should show
      button.backgroundColor = .clear
      
      // Don't apply contentEdgeInsets - just make the button bigger
      // The icon/text will be centered automatically
      
      button.translatesAutoresizingMaskIntoConstraints = false
      stackView.addArrangedSubview(button)
      buttons.append(button)
      
      // Calculate button height - use custom height if provided, otherwise use default + padding
      let buttonHeight: CGFloat
      if let customHeight = customHeight {
        buttonHeight = customHeight
      } else {
        buttonHeight = defaultHeight + buttonPaddings[i].top + buttonPaddings[i].bottom
      }
      
      let buttonHeightConstraint =
        button.heightAnchor.constraint(equalToConstant: buttonHeight)
      // 999: on iOS 26 the bar hands its item wrapper a placeholder height (36)
      // on the first pass, which a required 40 or 48 here flatly contradicts.
      buttonHeightConstraint.priority = .required - 1
      let buttonWidthConstraint =
        button.widthAnchor.constraint(equalToConstant: buttonWidths[i])
      // 999 for the width too. These are summed into totalWidth below and the
      // container pinned to it, but UIKit measures the bar's item area itself
      // and its answer does not land on the same fraction -- three buttons of
      // 42.5 + 42 + 42 make 126.5 against a platter of 126.667. Two required
      // constraints a sixth of a point apart is still a contradiction, and it
      // logged one every time a bar with actions was built.
      buttonWidthConstraint.priority = .required - 1
      NSLayoutConstraint.activate([
        buttonWidthConstraint,
        buttonHeightConstraint,
      ])
    }
    
    containerView.addSubview(stackView)  // Add to container, not blurView.contentView
    
    // Store button references (selection view removed)
    objc_setAssociatedObject(containerView, "buttons", buttons, .OBJC_ASSOCIATION_RETAIN)
    objc_setAssociatedObject(containerView, "buttonWidths", buttonWidths, .OBJC_ASSOCIATION_RETAIN)
    
    let pillHeightConstraint =
      containerView.heightAnchor.constraint(equalToConstant: blurViewHeight)
    // 999, for the same first-pass reason as the button height below it.
    pillHeightConstraint.priority = .required - 1
    let pillWidthConstraint =
      containerView.widthAnchor.constraint(equalToConstant: totalWidth)
    // And the width, which is the sum of the button widths above and so
    // inherits their disagreement with the platter's own measurement.
    pillWidthConstraint.priority = .required - 1

    NSLayoutConstraint.activate([
      // Pill view fills the container
      pillView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      pillView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      pillView.topAnchor.constraint(equalTo: containerView.topAnchor),
      pillView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      
      // Stack view positioned within container
      stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
      stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      
      // Container size
      pillHeightConstraint,
      pillWidthConstraint,
    ])
    
    // Wrap in a centering container for vertical centering in navigation bar
    let wrapperView = UIView()
    wrapperView.translatesAutoresizingMaskIntoConstraints = false
    wrapperView.addSubview(containerView)
    
    NSLayoutConstraint.activate([
      containerView.centerYAnchor.constraint(equalTo: wrapperView.centerYAnchor),
      containerView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor),
      containerView.topAnchor.constraint(greaterThanOrEqualTo: wrapperView.topAnchor),
      containerView.bottomAnchor.constraint(lessThanOrEqualTo: wrapperView.bottomAnchor),
    ])
    
    return wrapperView  // Return wrapper for proper vertical centering
  }

  private static func colorFromARGB(_ argb: Int) -> UIColor {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return UIColor(red: r, green: g, blue: b, alpha: a)
  }
}
