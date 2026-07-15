//
//  PortalView.swift
//  UIPortalBridge
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

#if canImport(UIKit)
import UIKit

// MARK: - PortalViewRepresentable

/// A SwiftUI wrapper for `UIPortalView` when you have a direct `UIView` reference.
///
/// ```swift
/// PortalViewRepresentable(
///     sourceView: myUIView,
///     hidesSourceView: false,
///     matchesAlpha: true
/// )
/// ```
public struct PortalViewRepresentable: UIViewRepresentable {
    let sourceView: UIView?
    var hidesSourceView: Bool
    var matchesAlpha: Bool
    var matchesTransform: Bool
    var matchesPosition: Bool
    
    public init(
        sourceView: UIView?,
        hidesSourceView: Bool = false,
        matchesAlpha: Bool = true,
        matchesTransform: Bool = true,
        matchesPosition: Bool = false
    ) {
        self.sourceView = sourceView
        self.hidesSourceView = hidesSourceView
        self.matchesAlpha = matchesAlpha
        self.matchesTransform = matchesTransform
        self.matchesPosition = matchesPosition
    }
    
    public func makeUIView(context: Context) -> UIPortalView {
        let portal = UIPortalView()
        portal.sourceView = sourceView
        portal.hidesSourceView = hidesSourceView
        portal.matchesAlpha = matchesAlpha
        portal.matchesTransform = matchesTransform
        portal.matchesPosition = matchesPosition
        return portal
    }
    
    public func updateUIView(_ uiView: UIPortalView, context: Context) {
        uiView.sourceView = sourceView
        uiView.hidesSourceView = hidesSourceView
        uiView.matchesAlpha = matchesAlpha
        uiView.matchesTransform = matchesTransform
        uiView.matchesPosition = matchesPosition
    }
}

// MARK: - PortalSource

/// A reference object that captures a UIView for portal mirroring.
///
/// Create this as `@State` and share it between `PortalSourceView` and `PortalMirrorView`:
///
/// ```swift
/// struct ContentView: View {
///     @State private var source = PortalSource()
///
///     var body: some View {
///         VStack {
///             PortalSourceView(source) {
///                 Text("Hello, World!")
///                     .padding()
///                     .background(.blue)
///             }
///
///             PortalMirrorView(source)
///                 .frame(width: 100, height: 50)
///         }
///     }
/// }
/// ```
///
/// - Note: The `PortalSourceView` must appear before `PortalMirrorView` in the
///   view hierarchy for mirroring to work correctly.
@MainActor
public class PortalSource: ObservableObject {
    /// The captured UIView. Set automatically when the source view enters a window.
    public internal(set) var capturedView: UIView? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.isReady = self?.capturedView != nil
            }
        }
    }
    
    /// True when the source is ready to be mirrored
    @Published public internal(set) var isReady: Bool = false
    
    public init() {}
}

// MARK: - PortalSourceView

/// Displays SwiftUI content and captures it for portal mirroring.
///
/// The content is rendered normally and can be mirrored by any `PortalMirrorView`
/// that shares the same `PortalSource`.
///
/// ```swift
/// @State private var source = PortalSource()
///
/// PortalSourceView(source) {
///     MyComplexView()
/// }
/// ```
///
/// - Note: Must appear before `PortalMirrorView` in the view hierarchy.
public struct PortalSourceView<Content: View>: UIViewRepresentable {
    let source: PortalSource
    let content: Content
    
    public init(_ source: PortalSource, @ViewBuilder content: () -> Content) {
        self.source = source
        self.content = content()
    }
    
    public func makeUIView(context: Context) -> PortalSourceUIView<Content> {
        PortalSourceUIView(rootView: content, source: source)
    }
    
    public func updateUIView(_ uiView: PortalSourceUIView<Content>, context: Context) {
        uiView.updateContent(content)
    }
}

/// The UIView that hosts SwiftUI content and registers itself as the portal source.
public class PortalSourceUIView<Content: View>: UIView {
    private var hostingController: UIHostingController<Content>
    private weak var source: PortalSource?
    
    init(rootView: Content, source: PortalSource) {
        self.hostingController = UIHostingController(rootView: rootView)
        self.source = source
        super.init(frame: .zero)
        
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            source?.capturedView = self
        }
    }
    
    func updateContent(_ content: Content) {
        hostingController.rootView = content
    }
    
    public override var intrinsicContentSize: CGSize {
        hostingController.view.intrinsicContentSize
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }
}

// MARK: - PortalMirrorView

/// Displays a live mirror of a `PortalSource`'s captured view.
///
/// The mirror updates in real-time as the source content changes.
///
/// ```swift
/// @State private var source = PortalSource()
///
/// VStack {
///     PortalSourceView(source) {
///         Text("Original")
///     }
///
///     // This mirrors the content above
///     PortalMirrorView(source)
///         .scaleEffect(0.5)
///         .blur(radius: 10)
/// }
/// ```
///
/// - Note: The `PortalSourceView` must appear before this view in the hierarchy.
public struct PortalMirrorView: View {
    @ObservedObject var source: PortalSource
    var hidesSource: Bool
    var matchesAlpha: Bool
    var matchesTransform: Bool
    var matchesPosition: Bool
    
    public init(
        _ source: PortalSource,
        hidesSource: Bool = false,
        matchesAlpha: Bool = true,
        matchesTransform: Bool = true,
        matchesPosition: Bool = false
    ) {
        self._source = ObservedObject(wrappedValue: source)
        self.hidesSource = hidesSource
        self.matchesAlpha = matchesAlpha
        self.matchesTransform = matchesTransform
        self.matchesPosition = matchesPosition
    }
    
    public var body: some View {
        if source.isReady, let captured = source.capturedView {
            PortalViewRepresentable(
                sourceView: captured,
                hidesSourceView: hidesSource,
                matchesAlpha: matchesAlpha,
                matchesTransform: matchesTransform,
                matchesPosition: matchesPosition
            )
        }
    }
}

// MARK: - Private Portal Helpers

/// Container that holds a SwiftUI view in a UIHostingController and exposes the UIView for portaling.
@MainActor
public final class SourceViewContainer<Content: View> {
    let hostingController: UIHostingController<Content>

    public var view: UIView {
        hostingController.view
    }

    public init(content: Content) {
        self.hostingController = UIHostingController(rootView: content)
        self.hostingController.view.backgroundColor = .clear

        if #available(iOS 16, *) {
            self.hostingController.sizingOptions = .preferredContentSize
        }

        hostingController.view.setNeedsLayout()
    }

    public func update(content: Content) {
        hostingController.rootView = content
        hostingController.view.setNeedsLayout()
    }
}

public final class SourceViewWrapper: UIView {
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
        if sourceView.bounds.size.width > 0, sourceView.bounds.size.height > 0 {
            return sourceView.bounds.size
        }

        return sourceView.intrinsicContentSize
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }
}

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

#else
public final class SourceViewContainer<Content: View> {
    public let content: Content

    public init(content: Content) {
        self.content = content
    }
}

public struct PortalView<Content: View>: View {
    public init(
        source: SourceViewContainer<Content>,
        hidesSourceView: Bool = false,
        matchesAlpha: Bool = true,
        matchesTransform: Bool = true,
        matchesPosition: Bool = false
    ) {}

    public var body: some View {
        EmptyView()
    }
}

public struct SourceViewRepresentable<Content: View>: View {
    public init(container: SourceViewContainer<Content>, content: Content) {}

    public var body: some View {
        EmptyView()
    }
}

public extension PortalView {
    init(
        source: SourceViewContainer<Content>,
        hidesSource: Bool = false,
        matchesAlpha: Bool = true,
        matchesTransform: Bool = true,
        matchesPosition: Bool = false
    ) {
        self.init(
            source: source,
            hidesSourceView: hidesSource,
            matchesAlpha: matchesAlpha,
            matchesTransform: matchesTransform,
            matchesPosition: matchesPosition
        )
    }
}
#endif
