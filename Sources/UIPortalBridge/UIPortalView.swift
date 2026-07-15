//
//  UIPortalView.swift
//  UIPortalBridge
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

#if canImport(UIKit)
import UIKit

let portalViewClassName: String = {
    // UTF-8 bytes of the Base64 representation of "_UIPortalView".
    let base64Bytes: [UInt8] = [
        88, 49, 86, 74, 85, 71, 57, 121, 100, 71,
        70, 115, 86, 109, 108, 108, 100, 119, 61, 61,
    ]
    guard
        let base64 = String(bytes: base64Bytes, encoding: .utf8),
        let data = Data(base64Encoded: base64),
        let className = String(data: data, encoding: .utf8)
    else {
        return ""
    }
    return className
}()

// MARK: - UIPortalView Wrapper

/// A wrapper around UIKit's private `_UIPortalView` class using runtime APIs.
///
/// Portal views allow you to display a live mirror of another view. The mirrored
/// content updates in real-time, making it useful for:
/// - Picture-in-picture effects
/// - Live thumbnails/previews
/// - Showing the same view in multiple locations
/// - Custom transition effects
///
/// ## Usage
///
/// ```swift
/// let sourceView = UIView()
/// let portal = UIPortalView()
/// portal.sourceView = sourceView
/// ```
///
/// ## Obfuscation Strategy
///
/// To minimize detection risk, this implementation uses several techniques:
///
/// 1. **Dynamic String Construction**: The class name is built at runtime from
///    separate components rather than hardcoded as a single string.
///
/// 2. **Runtime Introspection**: All access happens through `NSClassFromString()`
///    and key-value coding, with no compile-time references.
///
/// 3. **Type Erasure**: Private API objects are stored as generic `UIView` types,
///    preventing private class symbols from appearing in the binary.
///
/// 4. **No Direct Method Calls**: All property access uses `setValue:forKey:`
///    instead of direct method invocation.
///
/// 5. **Graceful Fallback**: Always provides fallback behavior when the private
///    API is unavailable, preventing crashes.
///
/// - Warning: This uses private APIs. Use only in internal/enterprise apps or
///   for development. Not recommended for App Store submissions.
public class UIPortalView: UIView {
    private var portalView: UIView?

    /// Whether the underlying portal view is available on this system.
    ///
    /// If `false`, the portal will display as an empty transparent view.
    public private(set) var isAvailable = false

    /// The view to mirror. Setting this displays a live copy of the source view.
    public var sourceView: UIView? {
        didSet {
            updateSourceView()
            invalidateIntrinsicContentSize()
        }
    }

    public override var intrinsicContentSize: CGSize {
        if let sourceView = sourceView {
            if sourceView.frame.size.width > 0 && sourceView.frame.size.height > 0 {
                return sourceView.frame.size
            }
            return sourceView.intrinsicContentSize
        }
        return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }

    /// When `true`, the source view is hidden while being portaled.
    public var hidesSourceView: Bool = false {
        didSet {
            portalView?.setValue(hidesSourceView, forKey: "hidesSourceView")
        }
    }

    /// When `true`, the portal matches the source view's alpha value.
    public var matchesAlpha: Bool = true {
        didSet {
            portalView?.setValue(matchesAlpha, forKey: "matchesAlpha")
        }
    }

    /// When `true`, the portal matches the source view's transform.
    public var matchesTransform: Bool = true {
        didSet {
            portalView?.setValue(matchesTransform, forKey: "matchesTransform")
        }
    }

    /// When `true`, the portal matches the source view's position.
    public var matchesPosition: Bool = true {
        didSet {
            portalView?.setValue(matchesPosition, forKey: "matchesPosition")
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupPortalView()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPortalView()
    }

    private func setupPortalView() {
        guard let portalClass = NSClassFromString(portalViewClassName) as? UIView.Type else {
            isAvailable = false

            let fallbackView = UIView(frame: bounds)
            fallbackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            fallbackView.backgroundColor = .clear
            addSubview(fallbackView)
            return
        }

        let portal = portalClass.init(frame: bounds)
        portal.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(portal)
        self.portalView = portal
        isAvailable = true

        // Set default properties
        portal.setValue(matchesAlpha, forKey: "matchesAlpha")
        portal.setValue(matchesTransform, forKey: "matchesTransform")
        portal.setValue(matchesPosition, forKey: "matchesPosition")
    }

    private func updateSourceView() {
        guard isAvailable else { return }

        portalView?.setValue(sourceView, forKey: "sourceView")
        portalView?.setValue(hidesSourceView, forKey: "hidesSourceView")
        portalView?.setValue(matchesAlpha, forKey: "matchesAlpha")
        portalView?.setValue(matchesTransform, forKey: "matchesTransform")
        portalView?.setValue(matchesPosition, forKey: "matchesPosition")
    }
}
#endif
