// Swift Compiler Crash Reproducer
//
// This file documents a compiler crash in Xcode 26.1+ when calling a generic method
// constrained to `Identifiable` that calls through to a generic method constrained
// to `Hashable`.
//
// ISSUE:
// - Calling `CrossModel.transferActivePortal(from: item, to: item)` (Identifiable overload)
//   from a SwiftUI view causes the Swift compiler to crash with:
//   "Please submit a bug report (https://swift.org/contributing/#reporting-bugs)"
//
// INTERESTING FINDING:
// - This nearly identical `ReproducerModel` class with the same generic method pattern
//   does NOT cause a crash when used in the same way. The crash appears specific to
//   `CrossModel` itself, possibly due to:
//   - The complexity of its member types (PortalInfo, AnyView, closures, etc.)
//   - Some type inference edge case in the compiler
//   - The combination of @Observable + @MainActor + the specific member layout
//
// WORKAROUND:
// Use `.id` explicitly instead of passing the item directly:
//   portalModel.transferActivePortal(from: oldItem.id, to: newItem.id)

#if DEBUG
import SwiftUI

// MARK: - Model (matches CarouselItem structure)

public struct ReproducerItem: Identifiable, Hashable {
    public let id = UUID()
    public let name: String
    public let color: Color

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: ReproducerItem, rhs: ReproducerItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Internal Info struct (matches PortalInfo structure)

public struct ReproducerInfo: Identifiable {
    public let id = UUID()
    public let infoID: AnyHashable
    public var initialized = false

    public init<ID: Hashable>(id: ID) {
        self.infoID = AnyHashable(id)
    }
}

// MARK: - Observable class with generic overloads (matches CrossModel structure)

@MainActor @Observable
public class ReproducerModel {
    public var info: [ReproducerInfo] = []

    public init() {}

    // Generic method taking any Hashable ID
    public func transferActivePortal<ID: Hashable>(from fromID: ID, to toID: ID) {
        let fromKey = AnyHashable(fromID)
        let toKey = AnyHashable(toID)

        guard fromKey != toKey else { return }

        guard let fromIndex = info.firstIndex(where: { $0.infoID == fromKey }) else {
            return
        }

        if let toIndex = info.firstIndex(where: { $0.infoID == toKey }) {
            info[toIndex].initialized = true
        } else {
            var newInfo = ReproducerInfo(id: toKey)
            newInfo.initialized = true
            info.append(newInfo)
        }

        info[fromIndex].initialized = false
    }

    // Generic method taking Identifiable items - THIS CAUSES THE CRASH
    // when called from a SwiftUI view's .onChange modifier
    public func transferActivePortal<Item: Identifiable>(from fromItem: Item, to toItem: Item) {
        transferActivePortal(from: fromItem.id, to: toItem.id)
    }
}

// MARK: - SwiftUI View that triggers the crash (matches PortalExampleGridCarousel)

struct ReproducerContentView: View {
    @State private var items: [ReproducerItem] = [
        ReproducerItem(name: "First", color: .red),
        ReproducerItem(name: "Second", color: .blue),
        ReproducerItem(name: "Third", color: .green)
    ]
    @State private var currentIndex = 0
    @Environment(ReproducerModel.self) private var model

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                Text(item.name)
                    .tag(index)
            }
        }
        .onChange(of: currentIndex) { oldIndex, newIndex in
            let oldItem = items[oldIndex]
            let newItem = items[newIndex]
            // This line causes the compiler crash in the real code:
            model.transferActivePortal(from: oldItem, to: newItem)
            // Workaround - use .id explicitly:
            // model.transferActivePortal(from: oldItem.id, to: newItem.id)
        }
    }
}
#endif
