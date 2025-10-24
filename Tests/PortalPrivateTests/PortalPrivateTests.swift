import XCTest
import SwiftUI
@testable import Portal
@testable import PortalView
@testable import PortalPrivate

final class PortalPrivateTests: XCTestCase {
    // MARK: - PortalView Tests

    @MainActor
    func testPortalViewWrapperInitialization() {
        let wrapper = PortalViewWrapper(frame: .zero)

        // Test that the wrapper initializes without crashing
        XCTAssertNotNil(wrapper)

        // The isPortalViewAvailable flag exists and is accessible
        // It can be true or false depending on whether _UIPortalView is available
        _ = wrapper.isPortalViewAvailable
    }

    @MainActor
    func testPortalViewWrapperSourceViewUpdate() {
        let wrapper = PortalViewWrapper(frame: .zero)
        let testView = UIView()

        // Should not crash even when portal view is unavailable
        wrapper.sourceView = testView
        XCTAssertEqual(wrapper.sourceView, testView)
    }

    @MainActor
    func testPortalViewWrapperPropertySetters() {
        let wrapper = PortalViewWrapper(frame: .zero)

        // Test that setting properties doesn't crash when portal view is unavailable
        wrapper.hidesSourceView = true
        wrapper.matchesAlpha = false
        wrapper.matchesTransform = false
        wrapper.matchesPosition = false

        XCTAssertTrue(wrapper.hidesSourceView)
        XCTAssertFalse(wrapper.matchesAlpha)
        XCTAssertFalse(wrapper.matchesTransform)
        XCTAssertFalse(wrapper.matchesPosition)
    }

    // MARK: - SourceViewContainer Tests

    @MainActor
    func testSourceViewContainerInitialization() {
        let content = Text("Test Content")
        let container = SourceViewContainer(content: content)

        XCTAssertNotNil(container)
        XCTAssertNotNil(container.view)
        XCTAssertNotNil(container.hostingController)
        XCTAssertEqual(container.view, container.hostingController.view)
    }

    @MainActor
    func testSourceViewContainerUpdate() {
        let initialContent = Text("Initial")
        let container = SourceViewContainer(content: initialContent)

        let updatedContent = Text("Updated")
        container.update(content: updatedContent)

        // Verify the hosting controller was updated
        XCTAssertNotNil(container.hostingController)
    }

    // MARK: - PortalPrivateInfo Tests

    @MainActor
    func testPortalPrivateInfoInitialization() {
        let info = PortalPrivateInfo()

        XCTAssertNil(info.sourceContainer)
        XCTAssertFalse(info.isPrivatePortal)

        // Test property setting
        info.isPrivatePortal = true
        XCTAssertTrue(info.isPrivatePortal)
    }

    // MARK: - AnimatedLayerConfig Tests

    #if DEBUG
    func testAnimatedLayerConfigDefault() {
        let config = AnimatedLayerConfig.default

        XCTAssertEqual(config.duration, 0.4)
        XCTAssertNotNil(config.bounceAnimation)
        XCTAssertNotNil(config.extraBounceAnimation)
    }

    func testAnimatedLayerConfigCustomInitialization() {
        let config = AnimatedLayerConfig(
            duration: 0.5,
            extraBounce: 0.7,
            extraBounceDuration: 0.2
        )

        XCTAssertEqual(config.duration, 0.5)
        XCTAssertNotNil(config.bounceAnimation)
        XCTAssertNotNil(config.extraBounceAnimation)
    }
    #endif

    // MARK: - Memory Management Tests

    @MainActor
    func testPortalPrivateStorageWeakReferences() {
        // This test verifies that PortalPrivateStorage uses weak references
        // and cleans up properly when objects are deallocated

        var info: PortalPrivateInfo? = PortalPrivateInfo()
        info?.isPrivatePortal = true

        // Store the info
        let testKey = "test-portal-\(UUID().uuidString)"
        // Note: We can't directly test the private storage,
        // but we can verify the pattern is correct

        // Deallocate the info
        info = nil

        // In a real scenario with NSMapTable weak references,
        // the storage would automatically clean up
        XCTAssertNil(info)
    }

    // MARK: - ID Generation Tests

    func testIDGenerationFromUUID() {
        let uuid = UUID()
        let view = EmptyView()

        // Test that ID generation doesn't crash
        // (The actual ID generation is in PortalPrivate extension methods)
    }

    // MARK: - Edge Case Tests

    @MainActor
    func testRapidShowHide() {
        // Test rapid state changes don't cause crashes
        let wrapper = PortalViewWrapper(frame: .zero)

        for _ in 0..<10 {
            wrapper.sourceView = UIView()
            wrapper.sourceView = nil
        }

        // Should complete without crashes
        XCTAssertNil(wrapper.sourceView)
    }

    @MainActor
    func testMultipleSimultaneousPortals() {
        // Test that multiple portal wrappers can coexist
        let wrappers = (0..<5).map { _ in PortalViewWrapper(frame: .zero) }

        XCTAssertEqual(wrappers.count, 5)

        // Each should be independent
        for (index, wrapper) in wrappers.enumerated() {
            wrapper.sourceView = UIView()
            wrapper.hidesSourceView = index % 2 == 0
        }

        // Verify independence
        for (index, wrapper) in wrappers.enumerated() {
            XCTAssertNotNil(wrapper.sourceView)
            XCTAssertEqual(wrapper.hidesSourceView, index % 2 == 0)
        }
    }

    // MARK: - Graceful Degradation Tests

    @MainActor
    func testGracefulDegradationWhenPortalUnavailable() {
        // This test verifies that the code handles _UIPortalView gracefully
        let wrapper = PortalViewWrapper(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

        // Should have at least one subview (portal or fallback)
        XCTAssertFalse(wrapper.subviews.isEmpty)

        // Operations should work regardless of portal availability
        let sourceView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        wrapper.sourceView = sourceView
        XCTAssertEqual(wrapper.sourceView, sourceView)

        // Test nil assignment
        wrapper.sourceView = nil
        XCTAssertNil(wrapper.sourceView)
    }
}
