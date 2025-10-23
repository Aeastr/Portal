<div align="center">
  <img width="270" height="270" src="/assets/icon.png" alt="Portal Logo">
  <h1><b>Portal</b></h1>
  <p>
    Portal is a SwiftUI package for seamless element transitions between views—including across sheets and navigation pushes (NavigationStack, .navigationDestination, etc)—using a portal metaphor for maximum flexibility.
    <br>
    <i>Compatible with iOS 17.0 and later*</i>
  </p>
</div>

<p align="center">
  <a href="https://developer.apple.com/ios/"><img src="https://img.shields.io/badge/iOS-17%2B-purple.svg" alt="iOS 17+"></a>
  <a href="https://swift.org/"><img src="https://img.shields.io/badge/Swift-6.0-orange.svg" alt="Swift 6.0"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License: MIT"></a>
</p>

## **Demo**

![Example](/assets/example1.gif)

<details>
  <summary><strong>Real Examples</strong></summary>

  https://github.com/user-attachments/assets/1658216e-dabd-442f-a7fe-7c2a19bf427d

  https://github.com/user-attachments/assets/7bba5836-f6e0-4d0b-95d7-f2c44c86c80a
</details>

---

## Documentation

For full installation steps, usage guides, and examples, visit the [Portal Wiki](https://github.com/Aeastr/Portal/wiki):

> Targeting iOS 15/16? Pin your dependency to `v2.1.0` or the `legacy/ios15` branch.

### Package Targets

Portal includes optional targets for advanced use cases:

- **`Portal`** (default) – Core transition system using standard SwiftUI APIs. **App Store safe.**
- **`PortalView`** (optional) – Low-level wrapper for `_UIPortalView`, Apple's private API for view mirroring. **⚠️ Uses private APIs.**
- **`PortalPrivate`** (optional) – Portal transitions reimplemented with PortalView. Depends on both Portal and PortalView. **⚠️ Uses private APIs.**

**For most users:** Just `import Portal`. The other targets are experimental and intended for advanced scenarios requiring view instance sharing.

---

## Features

- **Seamless Transitions**  
  Effortlessly animate floating overlays between source and destination views using simple view modifiers.

- **Works with Standard Presentations**  
  Fully compatible with SwiftUI’s built-in presentation methods like `.sheet` and `.navigationDestination`.

- **Flexible Anchoring**  
  Mark any view as a portal source or destination, keyed by static IDs or `Identifiable` items.

- **Easy Integration**  
  Install `PortalContainer` once at your root view and every sheet/navigation stack automatically gains portal support—no custom presentation code required.

- **Customizable Animations**  
  Fine-tune transitions with `PortalTransitionConfig` and drive bespoke transition layers via the `AnimatedPortalLayer` protocol.

- **Modern SwiftUI Support**  
  Built for iOS 17+ with the latest SwiftUI APIs and animation completion criteria

- **Structured Logging**  
  Diagnose portal lifecycle events via the bundled `PortalLogs` integration powered by [LogOutLoud](https://github.com/Aeastr/LogOutLoud).

---

## Debugging & Development

Portal includes comprehensive visual debug indicators (only in DEBUG builds) to help you verify the portal system is working correctly:

- 🩷 **Container Overlay**: Pink badge at bottom-right showing overlay window is installed
- 🟦 **Source Views**: Blue border + badge on portal source views
- 🟧 **Destination Views**: Orange border + badge on portal destination views
- 🟩 **Portal Layers**: Green badge on animating layers during transitions
- **Automatic**: Enabled in DEBUG builds (Xcode Previews, Debug configurations)
- **Production**: Automatically hidden in Release builds—zero performance impact

These visual indicators help troubleshoot portal transitions, anchor positioning, and overlay lifecycle issues. For more details, see the [Debugging Guide](https://github.com/Aeastr/Portal/wiki/Debugging).

### Logging & Diagnostics

Portal now ships with a dedicated [LogOutLoud](https://github.com/Aeastr/LogOutLoud) logger instance. Fetch it anywhere inside your app or tests:

```swift
import Portal

PortalLogs.logger.log("Overlay installed", level: .info, tags: [PortalLogs.Tags.overlay])
```

- `PortalLogs` is preconfigured to allow all log levels in DEBUG and notice+ in RELEASE.
- Call `PortalLogs.configure(allowedLevels:)` early in your app if you need custom filtering.
- Need an in-app console? Add the `LogOutLoudConsole` product to your app target and enable it:

```swift
import Portal
import LogOutLoudConsole
import SwiftUI

@main
struct PortalDemoApp: App {
    @State private var showConsole = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .toolbar { Button("Console") { showConsole = true } }
                .sheet(isPresented: $showConsole) { LogConsolePanel() }
                .logConsole(enabled: true, logger: PortalLogs.logger, maxEntries: 1_000)
                .task { PortalLogs.logger.log("Portal ready", level: .debug) }
        }
    }
}
```

Present `LogConsolePanel()` (or your own console UI) wherever you need to surface the live log stream in app, or check the Xcode debug output. The `.logConsole` modifier wires the shared Portal logger into the console automatically.

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
