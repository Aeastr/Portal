## How to Use Portal

Portal makes it easy to "teleport" views between hierarchies. Install a single `PortalContainer` at your root view (App/Scene) and everything beneath it can participate. Here are the two primary ways to drive transitions: using a boolean state (`isActive`) or using an optional identifiable item (`item`).

---

### Method 1: Using `isActive` (Boolean Trigger)

This method is suitable for transitions controlled by a simple on/off state, often involving a single source and destination pair identified by a static string ID.

**Steps:**

1.  **Wrap in `PortalContainer`:** Install it once at your scene root (examples inline it for brevity).
2.  **Mark Source with ID:** Use `.portal(id:, .source)` on the starting view, providing a unique string ID.
3.  **Mark Destination with ID:** Use `.portal(id:, .destination)` on the target view, using the *same* string ID.
4.  **Attach Transition with `isActive`:** Use `.PortalTransitions(id:isActive:...)` on an ancestor view, binding it to your `Binding<Bool>` state and using the same string ID.

**Example Walkthrough:**

**1. Wrap View Hierarchy:**

```swift
import SwiftUI
import PortalTransitions

struct ExampleBooleanView: View {
    @State private var showSettingsSheet: Bool = false
    let portalID = "settingsIconTransition" // Define static ID

    var body: some View {
        PortalContainer { // <-- Wrap once at the root (Step 1)
            VStack {
                // Source view goes here (Step 2)
                Image(systemName: "gearshape.fill")
                    .font(.title)
                    .onTapGesture { showSettingsSheet = true } // Trigger state change
                Spacer()
            }
            .sheet(isPresented: $showSettingsSheet) {
                // Destination view goes here (Step 3)
                SettingsSheetView(portalID: portalID)
            }
            // Transition modifier goes here (Step 4)
        }
    }
}
```

**2. Mark Source:**

```swift
Image(systemName: "gearshape.fill")
    .font(.title)
    .portal(id: portalID, .source) // <-- Step 2: Use static ID
    .onTapGesture { showSettingsSheet = true }
```

**3. Mark Destination:**

```swift
// Inside SettingsSheetView (presented by the sheet)
struct SettingsSheetView: View {
    let portalID: String
    var body: some View {
        Image(systemName: "gearshape.fill")
            .font(.title)
            .portal(id: portalID, .destination) // <-- Step 3: Use matching static ID
    }
}
```

**4. Attach Transition:**

Use `.PortalTransitions(id:isActive:...)` with direct animation parameters:
*   `id`: The static string identifier used in steps 2 & 3.
*   `isActive`: Your `Binding<Bool>` state variable.
*   `animation`: The `Animation` to use (defaults to `.smooth(duration: 0.4)`).
*   `completionCriteria`: How to detect animation completion (defaults to `.removed`).
*   `in corners`: Optional `PortalCorners` for corner radius transitions.
*   `layerView`: A closure `() -> LayerView` defining the animating view.

```swift
// Applied to the VStack or another ancestor in ExampleBooleanView
.PortalTransitions(
    id: portalID, // <-- Step 4a: Use static ID
    isActive: $showSettingsSheet, // <-- Step 4b: Bind to Bool state
    animation: .spring(response: 0.4, dampingFraction: 0.8), // <-- Step 4c: Animation
    completionCriteria: .removed // <-- Step 4d: Completion detection
) { // <-- Step 4e: Define layer view (no arguments)
    Image(systemName: "gearshape.fill").font(.title)
}
```

**Complete `isActive` Example:**

```swift
import SwiftUI
import PortalTransitions

struct ExampleBooleanView: View {
    @State private var showSettingsSheet: Bool = false
    let portalID = "settingsIconTransition" // Static ID

    var body: some View {
        PortalContainer { // Step 1
            VStack {
                Image(systemName: "gearshape.fill")
                    .font(.title)
                    .portal(id: portalID, .source) // Step 2: New unified API
                    .onTapGesture { showSettingsSheet = true }
                Spacer()
            }
            .sheet(isPresented: $showSettingsSheet) {
                SettingsSheetView(portalID: portalID) // Contains Step 3
            }
            .PortalTransitions( // Step 4
                id: portalID,
                isActive: $showSettingsSheet,
                animation: .spring(response: 0.4, dampingFraction: 0.8)
            ) {
                Image(systemName: "gearshape.fill").font(.title)
            }
        }
    }
}

// Sheet Content View
struct SettingsSheetView: View {
    let portalID: String
    var body: some View {
        Image(systemName: "gearshape.fill")
            .font(.title)
            .portal(id: portalID, .destination) // Step 3: New unified API
    }
}
```

> Wrap `PortalContainer { ... }` once at the top of your hierarchy—typically in your `App` or `Scene`. Presented sheets, navigation pushes, and other descendants automatically reuse the overlay window.

---

### Method 2: Using `item` (Identifiable Trigger)

This method is ideal for data-driven transitions, especially list/grid -> detail scenarios. It uses an optional `Identifiable` item state to control the transition, automatically keying animations to the specific item's ID.

**Steps:**

1.  **Wrap in `PortalContainer`:** Install it once at the root (examples inline it for clarity).
2.  **Mark Source with Item:** Use `.portal(item:, .source)` on the starting view within your list/grid, passing the specific `Identifiable` item instance.
3.  **Mark Destination with Item:** Use `.portal(item:, .destination)` on the target view (usually in the presented detail view), passing the corresponding `Identifiable` item instance.
4.  **Attach Transition with `item`:** Use `.PortalTransitions(item:...)` on an ancestor view, binding it to your `Binding<Optional<Item>>` state.

**Example Walkthrough:**

**1. Define Identifiable Item:**

```swift
struct CardInfo: Identifiable {
    let id = UUID()
    let title: String
    let gradientColors: [Color]
}
```

**2. Complete `item` Example:**

```swift
import SwiftUI
import PortalTransitions

struct CardGridView: View {
    @State private var selectedCard: CardInfo? = nil
    let cardData: [CardInfo] = [
        CardInfo(title: "Card 1", gradientColors: [.blue, .purple]),
        CardInfo(title: "Card 2", gradientColors: [.red, .orange]),
        // ... more cards
    ]
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)

    var body: some View {
        PortalContainer {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(cardData) { card in
                        VStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: card.gradientColors),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(height: 120)
                                .portal(item: card, .source) // Step 2: New unified API
                            Text(card.title).font(.headline)
                        }
                        .padding(.bottom, 12)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
                        .onTapGesture { selectedCard = card }
                    }
                }
                .padding()
            }
            .sheet(item: $selectedCard) { card in
                CardDetailView(card: card) // Contains Step 3
            }
            .PortalTransitions( // Step 4
                item: $selectedCard,
                animation: .smooth(duration: 0.4, extraBounce: 0.1)
            ) { card in // <-- Closure receives item
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: card.gradientColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            }
        }
    }
}

// Detail View (Sheet Content)
struct CardDetailView: View {
    let card: CardInfo
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    gradient: Gradient(colors: card.gradientColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 240, height: 240)
                .portalDestination(item: card) // Step 3: Pass the item
            Text(card.title).font(.title)
            Spacer()
        }
        .padding()
    }
}
```

---

### Advanced Configuration

Portal provides direct parameter control for animation and styling, with optional corner radius transitions.

**Basic Animation (Default):**

```swift
// Simple animation with defaults
.PortalTransitions(id: "myPortal", isActive: $isActive) {
    MyLayerView()
}

// Custom animation
.PortalTransitions(
    id: "myPortal",
    isActive: $isActive,
    animation: .spring(response: 0.5, dampingFraction: 0.8)
) {
    MyLayerView()
}
```

**With Corner Transitions:**

```swift
// Animation with corner radius morphing
.PortalTransitions(
    id: "myPortal",
    isActive: $isActive,
    in: PortalCorners(
        source: 8,
        destination: 16,
        style: .continuous
    ),
    animation: .spring(response: 0.5, dampingFraction: 0.8)
) {
    MyLayerView()
}
```

**Completion Handling:**

Portal transitions support completion callbacks to notify you when animations finish:

```swift
.PortalTransitions(
    id: "myPortal",
    isActive: $isActive,
    animation: .smooth(duration: 0.5),
    completion: { success in
        if success {
            print("Forward transition completed")
            // Perform post-transition actions
        } else {
            print("Reverse transition completed")
        }
    }
) {
    MyLayerView()
}
```

The completion handler receives a `Bool` parameter:
- `true` - Forward transition completed (item became active)
- `false` - Reverse transition completed (item became inactive)

**Completion Criteria:**

For advanced control over when the completion fires, use `completionCriteria`:

```swift
.PortalTransitions(
    id: "myPortal",
    isActive: $isActive,
    animation: .smooth(duration: 0.5),
    completionCriteria: .logicallyComplete, // Fires earlier
    completion: { success in
        // Called when animation is logically complete
    }
) {
    MyLayerView()
}
```

**Completion Criteria Options:**
- **`.removed`** (default): Waits for animation to fully complete and be removed - most reliable
- **`.logicallyComplete`**: Fires when animation logically completes - faster but may be less stable

**Configuration Parameters:**
- **`animation`**: SwiftUI `Animation` value (defaults to `.smooth(duration: 0.4)`)
- **`completionCriteria`**: When to fire the completion handler (defaults to `.removed`)
- **`completion`**: Handler called when transition finishes (defaults to no-op)
- **`in corners`**: Optional `PortalCorners` configuration
  - **When provided**: Clips views and transitions between source and destination corner radii
  - **When `nil` (default)**: No clipping is applied, content can extend beyond frame boundaries

---

### Method 3: Using Portal Groups (Multi-Item Transitions)

For coordinating multiple items animating together, see the dedicated [Portal Groups](./Portal-Groups) guide.

---

### Debugging

Portal includes a visual debug indicator to help verify the overlay is working correctly. The pink "PortalContainerOverlay" badge appears automatically in DEBUG builds. See the [Debugging Guide](./Debugging) for details.

---

👉 For full API documentation, see the source code DocC comments.

➡️ [Continue to Portal Groups](./Portal-Groups) | [View Examples](./Examples) | [Debugging Guide](./Debugging)
