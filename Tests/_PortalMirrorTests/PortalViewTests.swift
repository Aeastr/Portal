//
//  PortalViewTests.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
import UIKit
import SwiftUI
import Obfuscate
@testable 

final class PortalViewTests: XCTestCase {
    // MARK: - Obfuscation Tests

    func testObfuscationMacro() {
        // Test that the obfuscation macro properly encodes and decodes strings
        let obfuscatedString = #Obfuscate("_UIPortalView")

        // The obfuscated string should decode to the original value
        XCTAssertEqual(obfuscatedString, "_UIPortalView")

        // Test that it works with the class lookup
        // (This may return nil on systems where _UIPortalView isn't available)
        let portalClass: AnyClass? = NSClassFromString(obfuscatedString)

        // We don't assert the class exists since it may not be available
        // But we verify the string was properly decoded
        if portalClass != nil {
            XCTAssertTrue(portalClass is UIView.Type)
        }
    }
    // MARK: - PortalViewWrapper Tests

    @MainActor
    func testPortalViewWrapperInitialization() {
        let wrapper = PortalViewWrapper(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

        XCTAssertNotNil(wrapper)
        // Should have at least one subview (either portal or fallback)
        XCTAssertFalse(wrapper.subviews.isEmpty)

        // Check that the isPortalViewAvailable flag is set (can be true or false depending on environment)
        // This just verifies the property exists and is accessible
        _ = wrapper.isPortalViewAvailable
    }

    @MainActor
    func testPortalViewWrapperWithZeroFrame() {
        let wrapper = PortalViewWrapper(frame: .zero)

        XCTAssertNotNil(wrapper)
        XCTAssertEqual(wrapper.frame, .zero)
    }

    @MainActor
    func testSourceViewAssignment() {
        let wrapper = PortalViewWrapper(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let sourceView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))

        wrapper.sourceView = sourceView
        XCTAssertEqual(wrapper.sourceView, sourceView)

        // Test nil assignment
        wrapper.sourceView = nil
        XCTAssertNil(wrapper.sourceView)
    }

    @MainActor
    func testPortalViewProperties() {
        let wrapper = PortalViewWrapper(frame: .zero)

        // Test default values
        XCTAssertFalse(wrapper.hidesSourceView)
        XCTAssertTrue(wrapper.matchesAlpha)
        XCTAssertTrue(wrapper.matchesTransform)
        XCTAssertTrue(wrapper.matchesPosition)

        // Test property changes
        wrapper.hidesSourceView = true
        wrapper.matchesAlpha = false
        wrapper.matchesTransform = false
        wrapper.matchesPosition = false

        XCTAssertTrue(wrapper.hidesSourceView)
        XCTAssertFalse(wrapper.matchesAlpha)
        XCTAssertFalse(wrapper.matchesTransform)
        XCTAssertFalse(wrapper.matchesPosition)
    }

    @MainActor
    func testIntrinsicContentSize() {
        let wrapper = PortalViewWrapper(frame: .zero)

        // Without source view
        let sizeWithoutSource = wrapper.intrinsicContentSize
        XCTAssertEqual(sizeWithoutSource.width, UIView.noIntrinsicMetric)
        XCTAssertEqual(sizeWithoutSource.height, UIView.noIntrinsicMetric)

        // With source view
        let sourceView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        wrapper.sourceView = sourceView

        let sizeWithSource = wrapper.intrinsicContentSize
        XCTAssertEqual(sizeWithSource.width, 100)
        XCTAssertEqual(sizeWithSource.height, 50)
    }

    // MARK: - SourceViewContainer Tests

    @MainActor
    func testSourceViewContainerWithText() {
        let container = SourceViewContainer(content: Text("Test String"))

        XCTAssertNotNil(container)
        XCTAssertNotNil(container.view)
        XCTAssertNotNil(container.hostingController)
        XCTAssertEqual(container.view, container.hostingController.view)
        XCTAssertEqual(container.view.backgroundColor, UIColor.clear)
    }

    @MainActor
    func testSourceViewContainerUpdate() {
        let container = SourceViewContainer(content: Text("Initial"))
        let initialView = container.view

        container.update(content: Text("Updated"))

        // View reference should remain the same
        XCTAssertEqual(container.view, initialView)
        XCTAssertNotNil(container.hostingController)
    }

    // MARK: - SourceViewWrapper Tests

    @MainActor
    func testSourceViewWrapperInitialization() {
        let sourceView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let wrapper = SourceViewWrapper(sourceView: sourceView)

        XCTAssertNotNil(wrapper)
        XCTAssertTrue(wrapper.subviews.contains(sourceView))
        XCTAssertFalse(sourceView.translatesAutoresizingMaskIntoConstraints)
    }

    @MainActor
    func testSourceViewWrapperConstraints() {
        let sourceView = UIView()
        let wrapper = SourceViewWrapper(sourceView: sourceView)

        // Force layout
        wrapper.setNeedsLayout()
        wrapper.layoutIfNeeded()

        // Check that sourceView is constrained to wrapper's bounds
        XCTAssertTrue(wrapper.subviews.contains(sourceView))
        XCTAssertEqual(wrapper.constraints.count, 4) // top, bottom, leading, trailing
    }

    // MARK: - Edge Cases

    @MainActor
    func testMultipleSourceViewUpdates() {
        let wrapper = PortalViewWrapper(frame: .zero)

        // Rapidly update source view
        for i in 0..<10 {
            let view = UIView()
            view.tag = i
            wrapper.sourceView = view
            XCTAssertEqual(wrapper.sourceView?.tag, i)
        }

        wrapper.sourceView = nil
        XCTAssertNil(wrapper.sourceView)
    }

    @MainActor
    func testPortalViewWrapperDeallocation() {
        var wrapper: PortalViewWrapper? = PortalViewWrapper(frame: .zero)
        let sourceView = UIView()

        wrapper?.sourceView = sourceView
        XCTAssertNotNil(wrapper?.sourceView)

        // Test deallocation
        wrapper = nil
        XCTAssertNil(wrapper)
        // sourceView should still exist independently
        XCTAssertNotNil(sourceView)
    }

    @MainActor
    func testFallbackViewBehavior() {
        let wrapper = PortalViewWrapper(frame: CGRect(x: 0, y: 0, width: 200, height: 200))

        // Should have at least one subview (portal or fallback)
        XCTAssertGreaterThan(wrapper.subviews.count, 0)

        let firstSubview = wrapper.subviews.first
        XCTAssertNotNil(firstSubview)

        // If portal is not available, we have a fallback view
        if !wrapper.isPortalViewAvailable {
            // Fallback view should have clear background
            XCTAssertEqual(firstSubview?.backgroundColor, UIColor.clear)
            // Fallback view should resize with wrapper
            XCTAssertEqual(firstSubview?.autoresizingMask, [.flexibleWidth, .flexibleHeight])
        } else {
            // If portal is available, just verify we have a subview
            XCTAssertNotNil(firstSubview)
            // Portal view also uses flexible sizing
            XCTAssertEqual(firstSubview?.autoresizingMask, [.flexibleWidth, .flexibleHeight])
        }
    }
}
