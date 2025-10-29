# FlowingHeader

> **Experimental:** PortalFlowingHeader is currently experimental and in early development. Expect API changes and limitations with complex navigation scenarios.

**PortalFlowingHeader** provides smooth, scroll-based transitions where header content flows from the scroll view into the navigation bar as you scroll. Perfect for creating polished, native-feeling iOS experiences.

## Demo

![FlowingHeader Demo](demo.gif)

## Overview

FlowingHeader creates elegant transitions where:
- Header accessories (icons/images/custom views) scale and move to the navigation bar
- Bundle images (using `Image("name")`) can flow to the navigation bar
- Titles smoothly transition from large header text to navigation bar titles
- Custom accessories animate between positions with proper scaling
- Everything responds naturally to scroll gestures with momentum

## Requirements

- **iOS 18.0+** (uses advanced scroll tracking APIs)
- **Swift 6.0+**

## Installation

Add PortalFlowingHeader to your project:

```swift
import PortalTransitionsFlowingHeader
```

## Basic Usage

FlowingHeader uses a three-modifier pattern to create smooth scroll-based animations:

### Text-Only Header

The simplest header with just title and subtitle:

```swift
NavigationStack {
    ScrollView {
        FlowingHeaderView()

        // Your content here
        SettingsList()
    }
    .flowingHeaderDestination()
}
.flowingHeader(
    title: "Settings",
    subtitle: "Manage your preferences"
)
```

### Header with Accessory

Add a custom accessory view that flows with the title:

```swift
NavigationStack {
    ScrollView {
        FlowingHeaderView()

        ForEach(items) { item in
            ItemRow(item: item)
        }
    }
    .flowingHeaderDestination(displays: [.title, .accessory])
}
.flowingHeader(
    title: "Favorites",
    subtitle: "Your starred items",
    displays: [.title, .accessory]
) {
    Image(systemName: "star.fill")
        .font(.system(size: 64))
        .foregroundStyle(.yellow)
}
```

### Custom View with Layout Control

Control how accessories are positioned in the navigation bar:

```swift
NavigationStack {
    ScrollView {
        FlowingHeaderView()

        ProfileSettingsView()
    }
    .flowingHeaderDestination(displays: [.title, .accessory])
}
.flowingHeader(
    title: "Profile",
    subtitle: "Account settings",
    displays: [.title, .accessory],
    layout: .vertical  // Stack accessory above title
) {
    Image(systemName: "person.circle")
        .font(.system(size: 64))
        .foregroundStyle(.blue)
}
```

## Flow Control

FlowingHeader supports fine-grained control over which elements animate to the navigation bar using the `displays` parameter:

### Title Only
```swift
// Only title flows to navigation bar
.flowingHeader(
    title: "Settings",
    subtitle: "Manage your preferences",
    displays: [.title]  // Default behavior
)
```

### Title + Accessory Flow
```swift
// Both title and accessory flow to navigation bar
.flowingHeader(
    title: "Messages",
    subtitle: "Stay connected",
    displays: [.title, .accessory]
) {
    Image(systemName: "message.fill")
        .font(.system(size: 64))
}
```

### Controlling What Shows in Header vs Nav Bar

You can independently control what displays in the header and what flows to the nav bar:

```swift
NavigationStack {
    ScrollView {
        // Show both title and accessory in header
        FlowingHeaderView(displays: [.title, .accessory])
    }
    // Only title flows to nav bar (accessory stays in header)
    .flowingHeaderDestination(displays: [.title])
}
.flowingHeader(
    title: "Photos",
    subtitle: "Your collection",
    displays: [.title]  // Only title flows
) {
    Image(systemName: "photo.on.rectangle.angled")
        .font(.system(size: 64))
}
```

The `displays` parameter in `.flowingHeader()` and `.flowingHeaderDestination()` determines which components create anchor points for animation.

## Architecture

FlowingHeader uses a three-part system to create smooth animations by measuring precise positions:

1. **Source** - `FlowingHeaderView` provides the starting position and content
2. **Transition** - `.flowingHeader()` tracks scroll and animates between positions  
3. **Destination** - `.flowingHeaderDestination()` creates invisible anchors in the navigation bar

This system allows the animation to know exactly where elements start and where they should end up, creating pixel-perfect transitions that feel native to iOS.

### Modifier Placement

**Critical:** The modifiers must be placed correctly for the system to work:

```swift
NavigationStack {           // ← Navigation container
    ScrollView { ... }      
        .flowingHeaderDestination()  // ← Inside nav stack
}
.flowingHeader()            // ← Outside nav stack
```

## Customization

### Transition Timing

Transition timing is controlled by `FlowingHeaderTokens` constants (currently not customizable via API):

- `transitionDuration: 0.4` - Animation duration for transitions
- `scrollAnimationDuration: 0.3` - Duration for scroll-driven updates
- `transitionRange: 40` - Distance over which transition occurs (in points)
- `accessoryStartDivisor: 3` - When accessory flows, transition starts at `accessoryHeight / 3`

### Header Styling

FlowingHeaderView automatically handles layout. Apply styling to the accessory view in the `.flowingHeader()` modifier:

```swift
.flowingHeader(
    title: "Messages",
    subtitle: "Stay connected",
    displays: [.title, .accessory]
) {
    Image(systemName: "message.circle.fill")
        .font(.system(size: 64))
        .foregroundStyle(.green)
}
```

### Accessory Layout

Control how accessories are positioned in the navigation bar:

```swift
.flowingHeader(
    title: "Profile",
    subtitle: "Settings",
    displays: [.title, .accessory],
    layout: .vertical  // Stack accessory above title
) {
    Image(systemName: "person.circle")
        .font(.system(size: 64))
}
```

**Layout Options:**
- `.horizontal` (default) - Accessory positioned side-by-side with title
- `.vertical` - Accessory stacked on top of title

### Snapping Behavior

Control how the header snaps when scrolling stops in the transition zone:

```swift
.flowingHeader(
    title: "Profile",
    subtitle: "Settings",
    snappingBehavior: .directional  // Snap based on scroll direction
)
```

**Snapping Options:**
- `.directional` (default) - Snaps based on scroll direction:
  - When scrolling **down** → snaps to destination (1.0)
  - When scrolling **up** → snaps to source (0.0)
  - Remembers snap state to prevent oscillation
- `.nearest` - Snaps to nearest position (0.0 or 1.0) based on midpoint (0.5)
- `.none` - No snapping, header stays at current scroll progress

**When Snapping Occurs:**
- Only when scroll stops in the transition zone (progress between 0.0 and 1.0)
- If already at 0.0 or 1.0, no snapping occurs

**Directional Behavior Details:**

The `.directional` snapping behavior prevents the header from bouncing back and forth:
- When you stop scrolling halfway through the transition, it snaps in the direction you were scrolling
- If you've snapped and continue scrolling in the same direction, the header stays snapped
- Only when you reverse scroll direction does the header resume animating

This creates a more predictable, less jarring user experience compared to always snapping to the nearest position.

### Progressive Enhancement

Start simple and add complexity as needed:

```swift
// Start with basics (text-only)
.flowingHeader(title: "Settings", subtitle: "Manage your preferences")

// Add an accessory
.flowingHeader(
    title: "Photos",
    subtitle: "Your memories",
    displays: [.title, .accessory]
) {
    Image(systemName: "camera.fill")
        .font(.system(size: 64))
}

// Add styling
.flowingHeader(
    title: "Messages",
    subtitle: "Stay connected",
    displays: [.title, .accessory]
) {
    Image(systemName: "message.circle.fill")
        .font(.system(size: 64))
        .foregroundStyle(.green)
}

// Customize snapping behavior
.flowingHeader(
    title: "Gallery",
    subtitle: "Your photos",
    snappingBehavior: .none  // No snapping
)

// Or go fully custom
.flowingHeader(
    title: "Profile",
    subtitle: "Your account",
    displays: [.title, .accessory],
    snappingBehavior: .directional
) {
    UserAvatar(user: user, size: 100)
}
```

## Common Patterns

### Static Header (Title Only Flows)

```swift
NavigationStack {
    ScrollView {
        FlowingHeaderView()
        // Content...
    }
    .flowingHeaderDestination()
}
.flowingHeader(
    title: "Photos",
    subtitle: "Your memories",
    displays: [.title]  // Only title flows
) {
    Image(systemName: "camera.fill")
        .font(.system(size: 64))
}
```

### Flowing Accessory (Everything Animates)

```swift
NavigationStack {
    ScrollView {
        FlowingHeaderView()
        // Content...
    }
    .flowingHeaderDestination(displays: [.title, .accessory])
}
.flowingHeader(
    title: "Gallery",
    subtitle: "Your collection",
    displays: [.title, .accessory]
) {
    Image(systemName: "photo.on.rectangle.angled")
        .font(.system(size: 64))
}
```

### Custom View Accessory

```swift
NavigationStack {
    ScrollView {
        FlowingHeaderView()
        // Content...
    }
    .flowingHeaderDestination(displays: [.title, .accessory])
}
.flowingHeader(
    title: "Profile",
    subtitle: "Settings",
    displays: [.title, .accessory]
) {
    UserAvatar(size: 64)
}
```

## Advanced Usage

### Dynamic Headers

Control which components flow based on state:

```swift
@State private var showAccessory = true

.flowingHeader(
    title: "Title",
    subtitle: "Subtitle",
    displays: showAccessory ? [.title, .accessory] : [.title]
) {
    if showAccessory {
        Image(systemName: "star.fill")
            .font(.system(size: 64))
    }
}
```

### Multiple Headers (Not Supported)

FlowingHeader currently supports only one flowing header per NavigationStack. For complex screens, use one FlowingHeader and standard section headers:

```swift
NavigationStack {
    ScrollView {
        FlowingHeaderView()

        // Section headers (non-flowing)
        SectionHeader("Recent Activity")
        ActivityFeed()

        SectionHeader("Quick Actions")
        ActionGrid()
    }
    .flowingHeaderDestination()
}
.flowingHeader(
    title: "Dashboard",
    subtitle: "Welcome back"
)
```

### Dynamic Content

Headers that update based on data:

```swift
.flowingHeader(
    title: viewModel.categoryName,
    subtitle: "\(viewModel.items.count) items",
    displays: [.title, .accessory]
) {
    Image(systemName: viewModel.categoryIcon)
        .font(.system(size: 64))
        .foregroundStyle(viewModel.categoryColor)
}
```

## Limitations

### Navigation Stack Compatibility

FlowingHeader works best with **simple NavigationStack hierarchies**. It may have issues with:

- **Navigation pushes** (`.navigationDestination`) - The header system can become confused when navigating between views
- **Complex navigation hierarchies** - Deep navigation stacks may break anchor tracking

**Recommended approach:**
```swift
// ✅ Good - Simple navigation
NavigationStack {
    ScrollView { ... }
    .flowingHeaderDestination("Title")
}
.flowingHeader("Title")

// ⚠️ Problematic - May break on navigation
NavigationStack {
    ScrollView { ... }
    .navigationDestination(for: Item.self) { item in
        DetailView(item: item)  // Header may not work properly here
    }
    .flowingHeaderDestination("Title")
}
.flowingHeader("Title")
```

**Workarounds:**
- Use FlowingHeader only on root/main views in your navigation hierarchy
- Disable FlowingHeader when deep navigation is required

### Other Limitations

- **iOS 18+ only** - Uses scroll tracking APIs not available in earlier versions
- **ScrollView dependent** - Designed specifically for ScrollView, may not work with List
- **Single header per NavigationStack** - Multiple FlowingHeaders are not supported
- **Performance with complex custom views** - Very complex custom views may cause frame drops
- **No frame modifiers on accessories** - Sizing is handled automatically, don't apply `.frame()` to accessory views

## Performance Notes

- Headers are optimized for smooth 120fps scrolling
- Anchor calculations are cached during scroll
- Custom accessory views should be lightweight for best performance
- The destination anchors are invisible and only used for positioning

## Troubleshooting

### Header Not Animating

1. **Check modifier placement** - `.flowingHeader()` must be outside `NavigationStack`, `.flowingHeaderDestination()` inside
2. **Verify FlowingHeaderView exists** - Must have `FlowingHeaderView()` in your ScrollView
3. **Ensure iOS 18+** - FlowingHeader requires iOS 18.0 or later
4. **Check displays parameter** - Components in `displays` need anchors in both source and destination to flow
5. **Navigation conflicts** - Remove FlowingHeader from views with `.navigationDestination`

### Header Breaks After Navigation

This is a **known limitation**. FlowingHeader may stop working after:
- Navigating with `.navigationDestination`
- Pushing/popping views in NavigationStack
- Presenting modals over navigation views

**Solutions:**
- Use FlowingHeader only on root views
- Switch to Portal's core transitions for navigation scenarios
- Recreate the header system after navigation if needed

### Jerky Animations

- Reduce custom accessory view complexity
- Use `.drawingGroup()` for complex custom views
- Ensure consistent frame rates

### Accessory Not Appearing in Nav Bar

- Verify `displays` includes `.accessory` in both `.flowingHeader()` and `.flowingHeaderDestination()`
- Ensure accessory view is provided in `.flowingHeader()` closure
- Check that `FlowingHeaderView()` is present in ScrollView

## See Also

- [Portal Core Documentation](./Usage) - For view-to-view transitions
- [Examples](./Examples) - More Portal usage patterns
- [How Portal Works](./How-Portal-Works) - Understanding the anchor system
