# PortalHeaders - Basic Usage

PortalHeaders creates scroll-based header transitions that smoothly flow into the navigation bar, similar to native iOS apps like Music and Photos.

**Requires iOS 18+** due to advanced scroll tracking APIs.

## Quick Start

```swift
import PortalHeaders

NavigationStack {
    ScrollView {
        PortalHeaderView()

        // Your content here
        ForEach(items) { item in
            ItemRow(item: item)
        }
    }
    .portalHeaderDestination()
}
.portalHeader(title: "Favorites", subtitle: "Your starred items")
```

## How It Works

1. `.portalHeader()` - Configure the header on your NavigationStack
2. `PortalHeaderView()` - Place in your ScrollView where the header should appear
3. `.portalHeaderDestination()` - Apply to your ScrollView to create nav bar anchors

As the user scrolls, the title smoothly transitions from the inline header position to the navigation bar.

## Adding an Accessory

Include an icon or image that flows alongside the title:

```swift
NavigationStack {
    ScrollView {
        PortalHeaderView()
        // Content...
    }
    .portalHeaderDestination()
}
.portalHeader(
    title: "Photos",
    subtitle: "My Collection",
    displays: [.title, .accessory]
) {
    Image(systemName: "photo.on.rectangle.angled")
        .font(.system(size: 64))
        .foregroundStyle(.tint)
}
```

The accessory scales down and fades as it moves to the navigation bar.

## Display Components

Control what flows to the navigation bar with `displays`:

```swift
// Title only (default)
.portalHeader(title: "Title", subtitle: "Subtitle", displays: [.title])

// Title and accessory
.portalHeader(title: "Title", subtitle: "Subtitle", displays: [.title, .accessory]) {
    AccessoryView()
}

// Accessory only
.portalHeader(title: "Title", subtitle: "Subtitle", displays: [.accessory]) {
    AccessoryView()
}
```

## Layout Options

When showing both title and accessory, choose the layout:

```swift
// Side by side (default for title-only)
.portalHeader(title: "Title", subtitle: "Sub", layout: .horizontal)

// Stacked (default when accessory provided)
.portalHeader(title: "Title", subtitle: "Sub", layout: .vertical) {
    AccessoryView()
}
```

## Complete Example

```swift
struct PhotosView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                PortalHeaderView()
                    .padding(.top, 20)

                LazyVStack(spacing: 12) {
                    ForEach(photos) { photo in
                        PhotoRow(photo: photo)
                    }
                }
                .padding()
            }
            .portalHeaderDestination()
        }
        .portalHeader(
            title: "Photos",
            subtitle: "My Collection",
            displays: [.title, .accessory]
        ) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
        }
    }
}
```
