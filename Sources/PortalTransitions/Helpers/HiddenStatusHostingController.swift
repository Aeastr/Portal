//
//  HiddenStatusHostingController.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
#if canImport(UIKit)
import UIKit

/// A HostingController that always hides the status bar.
final class HiddenStatusHostingController<Content: View>: UIHostingController<Content> {
    override var prefersStatusBarHidden: Bool { true }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { .slide }
}
#endif
