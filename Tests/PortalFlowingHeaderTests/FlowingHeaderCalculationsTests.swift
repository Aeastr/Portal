//
//  FlowingHeaderCalculationsTests.swift
//  PortalFlowingHeader
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import Testing
@testable import PortalFlowingHeader
import CoreGraphics

@Suite("FlowingHeader Calculations Tests")
struct FlowingHeaderCalculationsTests {

    // MARK: - Progress Calculation Tests

    @Test("Progress calculation returns 0 before start offset")
    func progressBeforeStartOffset() {
        let progress = FlowingHeaderCalculations.calculateProgress(
            scrollOffset: -30,
            startOffset: -20,
            range: 40
        )
        #expect(progress == 0.0)
    }

    @Test("Progress calculation at start offset")
    func progressAtStartOffset() {
        let progress = FlowingHeaderCalculations.calculateProgress(
            scrollOffset: -20,
            startOffset: -20,
            range: 40
        )
        #expect(progress == 0.0)
    }

    @Test("Progress calculation at midpoint")
    func progressAtMidpoint() {
        let progress = FlowingHeaderCalculations.calculateProgress(
            scrollOffset: 0,
            startOffset: -20,
            range: 40
        )
        #expect(progress == 0.5)
    }

    @Test("Progress calculation at end offset")
    func progressAtEndOffset() {
        let progress = FlowingHeaderCalculations.calculateProgress(
            scrollOffset: 20,
            startOffset: -20,
            range: 40
        )
        #expect(progress == 1.0)
    }

    @Test("Progress calculation clamped at maximum")
    func progressClampedAtMaximum() {
        let progress = FlowingHeaderCalculations.calculateProgress(
            scrollOffset: 100,
            startOffset: -20,
            range: 40
        )
        #expect(progress == 1.0)
    }

    @Test("Progress calculation with zero range")
    func progressWithZeroRange() {
        let progress = FlowingHeaderCalculations.calculateProgress(
            scrollOffset: 0,
            startOffset: 0,
            range: 0
        )
        // Should return infinity, but min(1.0, inf) = 1.0
        #expect(progress == 1.0)
    }

    @Test("Progress calculation with negative range")
    func progressWithNegativeRange() {
        let progress = FlowingHeaderCalculations.calculateProgress(
            scrollOffset: 10,
            startOffset: 0,
            range: -40
        )
        // Negative range produces negative progress: (10 - 0) / -40 = -0.25
        // min(1.0, -0.25) = -0.25 (not clamped since it's below 1.0)
        #expect(progress == -0.25)
    }

    @Test("Progress calculation with custom values")
    func progressWithCustomValues() {
        let progress = FlowingHeaderCalculations.calculateProgress(
            scrollOffset: 50,
            startOffset: 10,
            range: 100
        )
        #expect(progress == 0.4)
    }

    // MARK: - Dynamic Offset Tests

    @Test("Dynamic offset at start of transition")
    func dynamicOffsetAtStart() {
        let offset = FlowingHeaderCalculations.calculateDynamicOffset(
            progress: 0.0,
            baseOffset: 20
        )
        #expect(offset == 0.0)
    }

    @Test("Dynamic offset at middle of transition")
    func dynamicOffsetAtMiddle() {
        let offset = FlowingHeaderCalculations.calculateDynamicOffset(
            progress: 0.5,
            baseOffset: 20
        )
        // sin(0.5 * π) = 1.0, so offset = 20 * 1.0 = 20
        #expect(abs(offset - 20.0) < 0.001)
    }

    @Test("Dynamic offset at end of transition")
    func dynamicOffsetAtEnd() {
        let offset = FlowingHeaderCalculations.calculateDynamicOffset(
            progress: 1.0,
            baseOffset: 20
        )
        // sin(π) ≈ 0
        #expect(abs(offset) < 0.001)
    }

    @Test("Dynamic offset at quarter progress")
    func dynamicOffsetAtQuarter() {
        let offset = FlowingHeaderCalculations.calculateDynamicOffset(
            progress: 0.25,
            baseOffset: 20
        )
        // sin(0.25 * π) ≈ 0.707
        #expect(abs(offset - 14.142) < 0.01)
    }

    @Test("Dynamic offset at three-quarter progress")
    func dynamicOffsetAtThreeQuarters() {
        let offset = FlowingHeaderCalculations.calculateDynamicOffset(
            progress: 0.75,
            baseOffset: 20
        )
        // sin(0.75 * π) ≈ 0.707
        #expect(abs(offset - 14.142) < 0.01)
    }

    @Test("Dynamic offset with negative base offset")
    func dynamicOffsetWithNegativeBase() {
        let offset = FlowingHeaderCalculations.calculateDynamicOffset(
            progress: 0.5,
            baseOffset: -30
        )
        #expect(abs(offset - (-30.0)) < 0.001)
    }

    @Test("Dynamic offset with zero base offset")
    func dynamicOffsetWithZeroBase() {
        let offset = FlowingHeaderCalculations.calculateDynamicOffset(
            progress: 0.5,
            baseOffset: 0
        )
        #expect(offset == 0.0)
    }

    @Test("Dynamic offset symmetry check")
    func dynamicOffsetSymmetry() {
        let offsetAt25 = FlowingHeaderCalculations.calculateDynamicOffset(
            progress: 0.25,
            baseOffset: 100
        )
        let offsetAt75 = FlowingHeaderCalculations.calculateDynamicOffset(
            progress: 0.75,
            baseOffset: 100
        )
        // Should be equal due to sine curve symmetry
        #expect(abs(offsetAt25 - offsetAt75) < 0.001)
    }

    // MARK: - Position Calculation Tests

    @Test("Position calculation at start")
    func positionAtStart() {
        let source = CGRect(x: 0, y: 0, width: 100, height: 100)
        let destination = CGRect(x: 200, y: 400, width: 50, height: 50)

        let position = FlowingHeaderCalculations.calculatePosition(
            sourceRect: source,
            destinationRect: destination,
            progress: 0.0
        )

        #expect(position.x == 50.0) // source midX
        #expect(position.y == 50.0) // source midY
    }

    @Test("Position calculation at end")
    func positionAtEnd() {
        let source = CGRect(x: 0, y: 0, width: 100, height: 100)
        let destination = CGRect(x: 200, y: 400, width: 50, height: 50)

        let position = FlowingHeaderCalculations.calculatePosition(
            sourceRect: source,
            destinationRect: destination,
            progress: 1.0
        )

        #expect(position.x == 225.0) // destination midX
        #expect(position.y == 425.0) // destination midY
    }

    @Test("Position calculation at midpoint")
    func positionAtMidpoint() {
        let source = CGRect(x: 0, y: 0, width: 100, height: 100)
        let destination = CGRect(x: 200, y: 400, width: 50, height: 50)

        let position = FlowingHeaderCalculations.calculatePosition(
            sourceRect: source,
            destinationRect: destination,
            progress: 0.5
        )

        #expect(position.x == 137.5) // halfway between 50 and 225
        #expect(position.y == 237.5) // halfway between 50 and 425
    }

    @Test("Position calculation with horizontal offset")
    func positionWithHorizontalOffset() {
        let source = CGRect(x: 0, y: 0, width: 100, height: 100)
        let destination = CGRect(x: 200, y: 400, width: 50, height: 50)

        let position = FlowingHeaderCalculations.calculatePosition(
            sourceRect: source,
            destinationRect: destination,
            progress: 0.5,
            horizontalOffset: 20
        )

        #expect(position.x == 157.5) // 137.5 + 20
        #expect(position.y == 237.5) // unchanged
    }

    @Test("Position calculation with negative offset")
    func positionWithNegativeOffset() {
        let source = CGRect(x: 0, y: 0, width: 100, height: 100)
        let destination = CGRect(x: 200, y: 400, width: 50, height: 50)

        let position = FlowingHeaderCalculations.calculatePosition(
            sourceRect: source,
            destinationRect: destination,
            progress: 0.5,
            horizontalOffset: -30
        )

        #expect(position.x == 107.5) // 137.5 - 30
        #expect(position.y == 237.5)
    }

    @Test("Position calculation with identical rects")
    func positionWithIdenticalRects() {
        let rect = CGRect(x: 100, y: 100, width: 50, height: 50)

        let position = FlowingHeaderCalculations.calculatePosition(
            sourceRect: rect,
            destinationRect: rect,
            progress: 0.5
        )

        #expect(position.x == 125.0) // midX stays constant
        #expect(position.y == 125.0) // midY stays constant
    }

    @Test("Position calculation with negative coordinates")
    func positionWithNegativeCoordinates() {
        let source = CGRect(x: -100, y: -200, width: 50, height: 50)
        let destination = CGRect(x: 100, y: 200, width: 50, height: 50)

        let position = FlowingHeaderCalculations.calculatePosition(
            sourceRect: source,
            destinationRect: destination,
            progress: 0.5
        )

        #expect(position.x == 0.0) // halfway between -75 and 125
        #expect(position.y == 0.0) // halfway between -175 and 225
    }

    // MARK: - Scale Calculation Tests

    @Test("Scale calculation at start")
    func scaleAtStart() {
        let source = CGSize(width: 100, height: 100)
        let destination = CGSize(width: 50, height: 50)

        let scale = FlowingHeaderCalculations.calculateScale(
            sourceSize: source,
            destinationSize: destination,
            progress: 0.0
        )

        #expect(scale.x == 1.0)
        #expect(scale.y == 1.0)
    }

    @Test("Scale calculation at end")
    func scaleAtEnd() {
        let source = CGSize(width: 100, height: 100)
        let destination = CGSize(width: 50, height: 50)

        let scale = FlowingHeaderCalculations.calculateScale(
            sourceSize: source,
            destinationSize: destination,
            progress: 1.0
        )

        #expect(scale.x == 0.5)
        #expect(scale.y == 0.5)
    }

    @Test("Scale calculation at midpoint")
    func scaleAtMidpoint() {
        let source = CGSize(width: 100, height: 100)
        let destination = CGSize(width: 50, height: 50)

        let scale = FlowingHeaderCalculations.calculateScale(
            sourceSize: source,
            destinationSize: destination,
            progress: 0.5
        )

        #expect(scale.x == 0.75)
        #expect(scale.y == 0.75)
    }

    @Test("Scale calculation with non-uniform scaling")
    func scaleWithNonUniformScaling() {
        let source = CGSize(width: 100, height: 200)
        let destination = CGSize(width: 50, height: 50)

        let scale = FlowingHeaderCalculations.calculateScale(
            sourceSize: source,
            destinationSize: destination,
            progress: 0.5
        )

        #expect(scale.x == 0.75) // (100 + (50-100)*0.5) / 100 = 75/100
        #expect(scale.y == 0.625) // (200 + (50-200)*0.5) / 200 = 125/200
    }

    @Test("Scale calculation growing size")
    func scaleGrowing() {
        let source = CGSize(width: 50, height: 50)
        let destination = CGSize(width: 100, height: 100)

        let scale = FlowingHeaderCalculations.calculateScale(
            sourceSize: source,
            destinationSize: destination,
            progress: 0.5
        )

        #expect(scale.x == 1.5)
        #expect(scale.y == 1.5)
    }

    @Test("Scale calculation with zero destination size")
    func scaleWithZeroDestination() {
        let source = CGSize(width: 100, height: 100)
        let destination = CGSize(width: 0, height: 0)

        let scale = FlowingHeaderCalculations.calculateScale(
            sourceSize: source,
            destinationSize: destination,
            progress: 0.5
        )

        #expect(scale.x == 0.5)
        #expect(scale.y == 0.5)
    }

    @Test("Scale calculation with identical sizes")
    func scaleWithIdenticalSizes() {
        let size = CGSize(width: 100, height: 100)

        let scale = FlowingHeaderCalculations.calculateScale(
            sourceSize: size,
            destinationSize: size,
            progress: 0.5
        )

        #expect(scale.x == 1.0)
        #expect(scale.y == 1.0)
    }

    @Test("Scale calculation maintains aspect ratio when uniform")
    func scaleMaintainsAspectRatio() {
        let source = CGSize(width: 64, height: 64)
        let destination = CGSize(width: 32, height: 32)

        let scaleAt25 = FlowingHeaderCalculations.calculateScale(
            sourceSize: source,
            destinationSize: destination,
            progress: 0.25
        )
        let scaleAt75 = FlowingHeaderCalculations.calculateScale(
            sourceSize: source,
            destinationSize: destination,
            progress: 0.75
        )

        // Both x and y should remain equal throughout
        #expect(scaleAt25.x == scaleAt25.y)
        #expect(scaleAt75.x == scaleAt75.y)
    }

    // MARK: - Edge Cases and Integration Tests

    @Test("Full transition integration test")
    func fullTransitionIntegration() {
        // Simulate a full transition from source to destination
        let source = CGRect(x: 0, y: 100, width: 100, height: 100)
        let destination = CGRect(x: 200, y: 50, width: 50, height: 50)
        let scrollOffset: CGFloat = 10
        let startOffset: CGFloat = 0
        let range: CGFloat = 20

        let progress = FlowingHeaderCalculations.calculateProgress(
            scrollOffset: scrollOffset,
            startOffset: startOffset,
            range: range
        )
        #expect(progress == 0.5)

        let position = FlowingHeaderCalculations.calculatePosition(
            sourceRect: source,
            destinationRect: destination,
            progress: CGFloat(progress)
        )
        #expect(position.x == 137.5)
        #expect(position.y == 125.0)

        let scale = FlowingHeaderCalculations.calculateScale(
            sourceSize: source.size,
            destinationSize: destination.size,
            progress: CGFloat(progress)
        )
        #expect(scale.x == 0.75)
        #expect(scale.y == 0.75)
    }

    @Test("Dynamic offset creates smooth arc")
    func dynamicOffsetSmoothArc() {
        // Test that offset follows expected sine curve pattern
        let baseOffset: CGFloat = 100

        let offsets: [(CGFloat, CGFloat)] = [
            (0.0, 0.0),
            (0.1, 30.9), // sin(0.1π) ≈ 0.309
            (0.2, 58.78), // sin(0.2π) ≈ 0.588
            (0.3, 80.9), // sin(0.3π) ≈ 0.809
            (0.4, 95.11), // sin(0.4π) ≈ 0.951
            (0.5, 100.0), // sin(0.5π) = 1.0
            (0.6, 95.11), // sin(0.6π) ≈ 0.951
            (0.7, 80.9), // sin(0.7π) ≈ 0.809
            (0.8, 58.78), // sin(0.8π) ≈ 0.588
            (0.9, 30.9), // sin(0.9π) ≈ 0.309
            (1.0, 0.0)
        ]

        for (progress, expected) in offsets {
            let offset = FlowingHeaderCalculations.calculateDynamicOffset(
                progress: progress,
                baseOffset: baseOffset
            )
            #expect(abs(offset - expected) < 0.1, "At progress \(progress), expected \(expected), got \(offset)")
        }
    }
}
