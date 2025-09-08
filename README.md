<div align="center">
  <img width="270" height="270" src="/assets/icon.png" alt="Portal Logo">
  <h1><b>Portal</b></h1>
  <p>
    Portal is a SwiftUI package for seamless element transitions between views—including across sheets and navigation pushes (NavigationStack, .navigationDestination, etc)—using a portal metaphor for maximum flexibility.
    <br>
    <i>Compatible with iOS 15.0 and later</i>
  </p>
</div>

<p align="center">
    <a href="https://www.apple.com/macos/"><img src="https://badgen.net/badge/macOS/14+/blue" alt="macOS"></a>
    <a href="https://developer.apple.com/xcode/"><img src="https://badgen.net/badge/Xcode/15+/blue" alt="Xcode"></a>
    <a href="https://swift.org"><img src="https://badgen.net/badge/Swift/5.9/orange" alt="Swift Version"></a>
    <a href="https://brew.sh"><img src="https://badgen.net/badge/Homebrew/required/yellow" alt="Homebrew"></a>
    <a href="LICENSE.md"><img src="https://badgen.net/badge/License/MIT/green" alt="License: MIT"></a>
</p>

## **Demo**

![Example](/assets/demo.gif)

<details>
  <summary><strong>Real Examples</strong></summary>

  https://github.com/user-attachments/assets/1658216e-dabd-442f-a7fe-7c2a19bf427d

  https://github.com/user-attachments/assets/7bba5836-f6e0-4d0b-95d7-f2c44c86c80a
</details>

---

## Documentation

Portal uses a hybrid documentation approach to provide the best developer experience:

- **Inline DocC comments** - Rich documentation that appears directly in Xcode while coding, providing immediate context and autocomplete assistance
- **Comprehensive wiki** - Extensive guides, examples, and deep-dive explanations available at the [Portal Wiki](https://github.com/Aeastr/Portal/wiki)

This approach keeps the codebase clean and focused while ensuring developers have both quick inline help and comprehensive resources when needed. 

---

## Features

- **Seamless Transitions**  
  Effortlessly animate floating overlays between source and destination views using simple view modifiers.

- **PortalFlowingHeader**  
  Smooth, scroll-based header transitions where content flows from the scroll view into the navigation bar. Perfect for polished, native-feeling iOS experiences. (iOS 18.0+)

- **Works with Standard Presentations**  
  Fully compatible with SwiftUI's built-in presentation methods like `.sheet` and `.navigationDestination`.

- **Flexible Anchoring**  
  Mark any view as a portal source or destination, keyed by static IDs or `Identifiable` items.

- **Easy Integration**  
  Add portal support to any view hierarchy with a single modifier or wrapper, no custom presentation code required.

- **Customizable Animations**  
  Fine-tune transitions with `PortalTransitionConfig` for control over timing, easing, and corner styling.

- **Modern SwiftUI Support**  
  Optimized for iOS 17+ with backward compatibility for iOS 15 and 16. 

---

## Examples

Portal includes several sample projects to help you get started:

- [Static ID](Sources/Portal/Examples/PortalExample_StaticID.swift)
- [Card Grid](Sources/Portal/Examples/PortalExample_CardGrid.swift)
- [List](Sources/Portal/Examples/PortalExample_List.swift)
- [Comparison](Sources/Portal/Examples/PortalExample_Comparison.swift)

You can find these in the [`Sources/Portal/Examples`](Sources/Portal/Examples) directory, or visit the [Examples documentation](https://github.com/Aeastr/Portal/wiki/Examples) for more details.

---

## License

This project is released under the MIT License. See [LICENSE](LICENSE.md) for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. Before you begin, take a moment to review the [Contributing Guide](CONTRIBUTING.md) for details on issue reporting, coding standards, and the PR process.

## Support

If you like this project, please consider giving it a ⭐️

---

## Where to find me:  
- here, obviously.  
- [Twitter](https://x.com/AetherAurelia)  
- [Threads](https://www.threads.net/@aetheraurelia)  
- [Bluesky](https://bsky.app/profile/aethers.world)  
- [LinkedIn](https://www.linkedin.com/in/willjones24)

---

<p align="center">Built with 🍏🌀🚪 by Aether</p>
