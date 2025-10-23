//
//  PortalView.swift
//  Portal
//
//  Runtime wrapper for private _UIPortalView API
//

import SwiftUI
import UIKit

// MARK: - Runtime Wrapper for _UIPortalView

/// A wrapper around the private _UIPortalView class using runtime APIs
public class PortalViewWrapper: UIView {
    private var portalView: UIView?

    public var sourceView: UIView? {
        didSet {
            updateSourceView()
            invalidateIntrinsicContentSize()
        }
    }

    public override var intrinsicContentSize: CGSize {
        // Try to get the actual size of the source view first
        if let sourceView = sourceView {
            // If the source has a valid frame size, use that
            if sourceView.frame.size.width > 0 && sourceView.frame.size.height > 0 {
                return sourceView.frame.size
            }
            // Otherwise fall back to intrinsic content size
            return sourceView.intrinsicContentSize
        }
        return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }

    public var hidesSourceView: Bool = false {
        didSet {
            portalView?.setValue(hidesSourceView, forKey: "hidesSourceView")
        }
    }

    public var matchesAlpha: Bool = true {
        didSet {
            portalView?.setValue(matchesAlpha, forKey: "matchesAlpha")
        }
    }

    public var matchesTransform: Bool = true {
        didSet {
            portalView?.setValue(matchesTransform, forKey: "matchesTransform")
        }
    }

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
        // Access _UIPortalView via runtime
        guard let portalClass = NSClassFromString("_UIPortalView") as? UIView.Type else {
            print("⚠️ _UIPortalView class not available")
            return
        }

        let portal = portalClass.init(frame: bounds)
        portal.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(portal)
        self.portalView = portal

        // Set default properties
        portal.setValue(true, forKey: "matchesAlpha")
        portal.setValue(true, forKey: "matchesTransform")
        portal.setValue(true, forKey: "matchesPosition")
    }

    private func updateSourceView() {
        portalView?.setValue(sourceView, forKey: "sourceView")
    }
}

// MARK: - UIViewRepresentable Wrapper

/// UIViewRepresentable wrapper for the portal view
public struct PortalViewRepresentable: UIViewRepresentable {
    let sourceView: UIView
    var hidesSourceView: Bool = false
    var matchesAlpha: Bool = true
    var matchesTransform: Bool = true
    var matchesPosition: Bool = true

    public func makeUIView(context: Context) -> PortalViewWrapper {
        let portal = PortalViewWrapper()
        portal.sourceView = sourceView
        portal.hidesSourceView = hidesSourceView
        portal.matchesAlpha = matchesAlpha
        portal.matchesTransform = matchesTransform
        portal.matchesPosition = matchesPosition
        return portal
    }

    public func updateUIView(_ uiView: PortalViewWrapper, context: Context) {
        uiView.sourceView = sourceView
        uiView.hidesSourceView = hidesSourceView
        uiView.matchesAlpha = matchesAlpha
        uiView.matchesTransform = matchesTransform
        uiView.matchesPosition = matchesPosition
    }
}

// MARK: - Source View Container

/// Container that holds a SwiftUI view in a UIHostingController
/// and exposes the UIView for portaling
@MainActor
public class SourceViewContainer<Content: View> {
    let hostingController: UIHostingController<Content>

    public var view: UIView {
        hostingController.view
    }

    public init(content: Content) {
        self.hostingController = UIHostingController(rootView: content)
        self.hostingController.view.backgroundColor = .clear
        // Use preferredContentSize instead of intrinsicContentSize for more flexible sizing
        self.hostingController.sizingOptions = .preferredContentSize

        // Don't lock the frame size here - let it be determined by the layout system
        hostingController.view.setNeedsLayout()
    }

    public func update(content: Content) {
        hostingController.rootView = content
        // Let the layout system determine the size
        hostingController.view.setNeedsLayout()
    }
}

/// Wrapper for source view with proper intrinsic sizing
public class SourceViewWrapper: UIView {
    let sourceView: UIView

    public init(sourceView: UIView) {
        self.sourceView = sourceView
        super.init(frame: .zero)

        sourceView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sourceView)
        NSLayoutConstraint.activate([
            sourceView.topAnchor.constraint(equalTo: topAnchor),
            sourceView.bottomAnchor.constraint(equalTo: bottomAnchor),
            sourceView.leadingAnchor.constraint(equalTo: leadingAnchor),
            sourceView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var intrinsicContentSize: CGSize {
        // Use the source view's actual bounds if available
        if sourceView.bounds.size.width > 0 && sourceView.bounds.size.height > 0 {
            return sourceView.bounds.size
        }
        return sourceView.intrinsicContentSize
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure the portal knows about size changes
        invalidateIntrinsicContentSize()
    }
}

/// UIViewRepresentable that displays the source view
public struct SourceViewRepresentable<Content: View>: UIViewRepresentable {
    let container: SourceViewContainer<Content>
    let content: Content

    public init(container: SourceViewContainer<Content>, content: Content) {
        self.container = container
        self.content = content
    }

    public func makeUIView(context: Context) -> SourceViewWrapper {
        SourceViewWrapper(sourceView: container.view)
    }

    public func updateUIView(_ uiView: SourceViewWrapper, context: Context) {
        container.update(content: content)
        uiView.invalidateIntrinsicContentSize()
    }
}

// MARK: - Portal View Helper

/// Creates a portal of a UIView from a SourceViewContainer
public struct PortalView<Content: View>: View {
    let source: SourceViewContainer<Content>
    var hidesSource: Bool = false
    var matchesAlpha: Bool = true
    var matchesTransform: Bool = true
    var matchesPosition: Bool = true

    public init(
        source: SourceViewContainer<Content>,
        hidesSource: Bool = false,
        matchesAlpha: Bool = true,
        matchesTransform: Bool = true,
        matchesPosition: Bool = true
    ) {
        self.source = source
        self.hidesSource = hidesSource
        self.matchesAlpha = matchesAlpha
        self.matchesTransform = matchesTransform
        self.matchesPosition = matchesPosition
    }

    public var body: some View {
        PortalViewRepresentable(
            sourceView: source.view,
            hidesSourceView: hidesSource,
            matchesAlpha: matchesAlpha,
            matchesTransform: matchesTransform,
            matchesPosition: matchesPosition
        )
    }
}
