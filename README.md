<div align="center">
  <img width="300" height="300" src="/assets/icon.png" alt="Portal Logo">
  <h1><b>Portal</b></h1>
  <p>
    Portal is a SwiftUI package for seamless element transitions between views—including across sheets and navigation pushes (NavigationStack, .navigationDestination, etc)—using a portal metaphor for maximum flexibility.
    <br>
    <i>Compatible with iOS 15.0 and later</i>
  </p>
</div>

<div align="center">
  <a href="https://swift.org">
<!--     <img src="https://img.shields.io/badge/Swift-6.0%20%7C%206-orange.svg" alt="Swift Version"> -->
    <img src="https://img.shields.io/badge/Swift-6.0-orange.svg" alt="Swift Version">
  </a>
  <a href="https://www.apple.com/ios/">
    <img src="https://img.shields.io/badge/iOS-15%2B-blue.svg" alt="iOS">
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License: MIT">
  </a>
</div>

## **Demo**

![Example](/assets/example1.gif)

<details>
  <summary><strong>Real Examples</strong></summary>

  https://github.com/user-attachments/assets/1658216e-dabd-442f-a7fe-7c2a19bf427d

  https://github.com/user-attachments/assets/7bba5836-f6e0-4d0b-95d7-f2c44c86c80a
</details>

---

## Features

- **DocC Documentation**

- **`PortalContainer { ... }`** \
  Manages the overlay window logic required for floating portal animations across hierarchies.

- **`.portalContainer()`** \
  View extension for easily wrapping any view hierarchy in a `PortalContainer`.

- **`.portalSource(id:)`** \
  Marks a view as the source anchor for a portal transition using a static string identifier.

- **`.portalSource(item:)`** \
  Marks a view as the source anchor for a portal transition, keyed by an `Identifiable` item's ID.

- **`.portalDestination(id:)`** \
  Marks a view as the destination anchor for a portal transition using a static string identifier.

- **`.portalDestination(item:)`** \
  Marks a view as the destination anchor for a portal transition, keyed by an `Identifiable` item's ID.

- **`.portalTransition(id: isActive: ...)`** \
  Drives the floating overlay animation based on a `Binding<Bool>` (`isActive`) and a static string `id` matching the source/destination.

- **`.portalTransition(item: ...)`** \
  Drives the floating overlay animation based on a `Binding<Optional<Item>>` (`item`), where `Item` is `Identifiable`. Automatically keys the transition to the item's ID

- **No custom presentation modifiers required** \
  Works directly with standard SwiftUI presentation methods (`.sheet`, `.navigationDestination`, etc.).

- **Detailed Configurable Logs** \
  Uses [LogOutLoud](https://github.com/Aeastr/LogOutLoud), check documentation for details

- **iOS 15+ support**

---

## 📚 Documentation

For full installation steps, usage guides, examples, and animation deep-dives, visit the [Portal Wiki](https://github.com/Aeastr/Portal/wiki):  

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
