//
//  PortalPrivateTests.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import _PortalPrivate

final class PortalPrivateTests: XCTestCase {
    @MainActor
    func testPortalPrivateInfoDefaults() {
        let info = PortalPrivateInfo()

        XCTAssertNil(info.sourceContainer)
        XCTAssertFalse(info.isPrivatePortal)
    }

    @MainActor
    func testPortalPrivateInfoStoresSourceContainer() {
        let info = PortalPrivateInfo()
        let sourceContainer = NSObject()

        info.sourceContainer = sourceContainer
        info.isPrivatePortal = true

        XCTAssertTrue(info.sourceContainer === sourceContainer)
        XCTAssertTrue(info.isPrivatePortal)
    }
}
