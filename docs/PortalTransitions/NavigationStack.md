# PortalTransitions with NavigationStack

Use one optional `Identifiable` selection to coordinate portal transitions for every
item in a programmatic `NavigationStack`. The navigation path selects the destination;
the portal selection identifies the item currently animating.

```swift
struct Product: Identifiable, Hashable {
    let id: UUID
    let name: String
}

struct ProductList: View {
    let products: [Product]
    @State private var path = NavigationPath()
    @State private var portalItem: Product?
    @Namespace private var portalNamespace

    var body: some View {
        PortalContainer {
            NavigationStack(path: $path) {
                List(products) { product in
                    Text(product.name)
                        .portal(item: product, as: .source, in: portalNamespace)
                        .onTapGesture {
                            portalItem = product
                            path.append(product.id)
                        }
                }
                .navigationDestination(for: Product.ID.self) { productID in
                    if let product = products.first(where: { $0.id == productID }) {
                        ProductDetail(product: product)
                            .portal(item: product, as: .destination, in: portalNamespace)
                            .onDisappear {
                                if portalItem?.id == product.id {
                                    portalItem = nil
                                }
                            }
                    }
                }
            }
            .portalTransition(item: $portalItem, in: portalNamespace) { product in
                Text(product.name)
            }
        }
    }
}
```

`portalItem` is separate from `path`: it starts the forward transition before the
destination appears, and clearing it when the detail disappears starts the reverse
transition. Because the transition is item-based, one modifier works for every product
in the list.

