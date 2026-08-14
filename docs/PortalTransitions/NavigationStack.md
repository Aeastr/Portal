# PortalTransitions with NavigationStack

Use `navigationDestination(item:)` with one optional `Identifiable` selection to
coordinate portal transitions for every item in a programmatic `NavigationStack`.
The binding drives both navigation and the portal lifecycle, including an interactive
back gesture.

```swift
struct Product: Identifiable, Hashable {
    let id: UUID
    let name: String
}

struct ProductList: View {
    let products: [Product]
    @State private var portalItem: Product?
    @Namespace private var portalNamespace

    var body: some View {
        PortalContainer {
            NavigationStack {
                List(products) { product in
                    Text(product.name)
                        .portal(item: product, as: .source, in: portalNamespace)
                        .onTapGesture {
                            portalItem = product
                        }
                }
                .navigationDestination(item: $portalItem) { product in
                    ProductDetail(product: product)
                        .portal(item: product, as: .destination, in: portalNamespace)
                }
            }
            .portalTransition(item: $portalItem, in: portalNamespace) { product in
                Text(product.name)
            }
        }
    }
}
```

Setting `portalItem` starts both the push and forward transition. When the user pops
the detail, `navigationDestination(item:)` clears it and starts the reverse transition.
Because the transition is item-based, one modifier works for every product in the list.

When an app must use a heterogeneous `NavigationPath`, keep its route state separate
and update the portal item only in the explicit push and pop actions. Avoid clearing the
portal item from a destination's `onDisappear`, because that can also run when another
destination is pushed on top.
