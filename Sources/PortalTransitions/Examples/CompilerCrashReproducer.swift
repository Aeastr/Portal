// Swift Compiler Crash Reproducer
// Testing CrossModel.transferActivePortal with Identifiable overload

#if DEBUG
import SwiftUI

// Simple item for testing
struct TestItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
}

// Test view using CrossModel directly with the Identifiable overload
struct CrashTestView: View {
    @State private var items: [TestItem] = [
        TestItem(name: "First"),
        TestItem(name: "Second"),
        TestItem(name: "Third")
    ]
    @State private var currentIndex = 0
    @Environment(CrossModel.self) private var portalModel

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
            // Testing if this crashes:
            portalModel.transferActivePortal(from: oldItem, to: newItem)
        }
    }
}
#endif
