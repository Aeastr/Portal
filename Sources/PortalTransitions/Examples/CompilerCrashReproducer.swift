// Swift Compiler Crash Reproducer
// Testing CrossModel.transferActivePortal with Identifiable overload

#if DEBUG
import SwiftUI

// CRASH TRIGGER:
// The combination of:
// 1. @Binding var portalItem: CarouselItem?
// 2. Calling portalModel.transferActivePortal(from: oldItem, to: newItem)
// 3. Then assigning portalItem = newItem
// ...causes a Swift compiler crash in Xcode 26.1+
struct CrashTestView: View {
    let items: [CarouselItem]
    @Binding var portalItem: CarouselItem?

    @State private var currentIndex = 0
    @Environment(CrossModel.self) private var portalModel

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                Text(item.title)
                    .tag(index)
            }
        }
        .onChange(of: currentIndex) { oldIndex, newIndex in
            let oldItem = items[oldIndex]
            let newItem = items[newIndex]
            // CRASHES: Both lines together cause compiler crash
            portalModel.transferActivePortal(from: oldItem, to: newItem)
            portalItem = newItem
        }
    }
}
#endif
