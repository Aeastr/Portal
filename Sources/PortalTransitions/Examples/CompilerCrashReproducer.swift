// Swift Compiler Crash Reproducer
//
// CRASH TRIGGER (Xcode 26.1+):
// The combination of:
// 1. @Binding var someItem: SomeIdentifiableType?
// 2. Calling a generic method with Identifiable constraint: func foo<T: Identifiable>(item: T)
// 3. Then assigning someItem = item AFTER the call
// ...causes a Swift compiler crash.
//
// FIX: Assign to the binding BEFORE calling the Identifiable generic method.
//
// CRASHES:
//   portalModel.transferActivePortal(from: oldItem, to: newItem)
//   portalItem = newItem  // <-- crash
//
// WORKS:
//   portalItem = newItem  // <-- assign first
//   portalModel.transferActivePortal(from: oldItem, to: newItem)

#if DEBUG
import SwiftUI

struct CompilerCrashWorkaroundExample: View {
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
            // FIX: Assign to binding BEFORE calling Identifiable overload
            portalItem = newItem
            portalModel.transferActivePortal(from: oldItem, to: newItem)
        }
    }
}
#endif
