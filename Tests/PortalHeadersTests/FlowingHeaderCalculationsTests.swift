//
//  PortalHeaderCalculationsTests.swift
//  PortalHeader
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import Testing
@testable import PortalHeaders
import CoreGraphics

@Suite("PortalHeader Calculations Tests")
struct PortalHeaderCalculationsTests {
    // MARK: - Progress Calculation Tests

    @Test("Progress calculation returns 0 before start offset")
    func progressBeforestartAt() {
        let progress = PortalHeaderCalculations.calculateProgress(
            scrollOffset: -30,
            startAt: -20,
            range: 40
        )
        #expect(progress == 0.0)
    }

    @Test("Progress calculation at start offset")
    func progressAtstartAt() {
        let progress = PortalHeaderCalculations.calculateProgress(
            scrollOffset: -20,
            startAt: -20,
            range: 40
        )
        #expect(progress == 0.0)
    }

    @Test("Progress calculation at midpoint")
    func progressAtMidpoint() {
        let progress = PortalHeaderCalculations.calculateProgress(
            scrollOffset: 0,
            startAt: -20,
            range: 40
        )
        #expect(progress == 0.5)
    }

    @Test("Progress calculation at end offset")
    func progressAtEndOffset() {
        let progress = PortalHeaderCalculations.calculateProgress(
            scrollOffset: 20,
            startAt: -20,
            range: 40
        )
        #expect(progress == 1.0)
    }

    @Test("Progress calculation clamped at maximum")
    func progressClampedAtMaximum() {
        let progress = PortalHeaderCalculations.calculateProgress(
            scrollOffset: 100,
            startAt: -20,
            range: 40
        )
        #expect(progress == 1.0)
    }

    @Test("Progress calculation with zero range")
    func progressWithZeroRange() {
        let progress = PortalHeaderCalculations.calculateProgress(
            scrollOffset: 0,
            startAt: 0,
            range: 0
        )
        // Zero range is guarded to return 1.0 (fully transitioned)
        #expect(progress == 1.0)
    }

    @Test("Progress calculation with negative range")
    func progressWithNegativeRange() {
        let progress = PortalHeaderCalculations.calculateProgress(
            scrollOffset: 10,
            startAt: 0,
            range: -40
        )
        // Negative range produces negative progress: (10 - 0) / -40 = -0.25
        // Clamped to 0.0 by max(0.0, min(1.0, -0.25))
        #expect(progress == 0.0)
    }

    @Test("Progress calculation with custom values")
    func progressWithCustomValues() {
        let progress = PortalHeaderCalculations.calculateProgress(
            scrollOffset: 50,
            startAt: 10,
            range: 100
        )
        #expect(progress == 0.4)
    }

    @Test("Progress calculation negative clamping")
    func progressNegativeClamping() {
        // Test that negative progress values are clamped to 0.0
        let progress = PortalHeaderCalculations.calculateProgress(
            scrollOffset: 50,
            startAt: 100,
            range: 10
        )
        // (50 - 100) / 10 = -5.0, clamped to 0.0
        #expect(progress == 0.0)
    }

    // MARK: - Negative Scroll Offset Edge Cases

    @Test("Progress with negative scroll offset")
    func progressWithNegativeScrollOffset() {
        let progress = PortalHeaderCalculations.calculateProgress(
            scrollOffset: -50,
            startAt: -20,
            range: 40
        )
        // scrollOffset (-50) < startAt (-20), should return 0.0
        #expect(progress == 0.0)
    }

    @Test("Progress when startAt equals scrollOffset")
    func progressWhenStartAtEqualsScrollOffset() {
        let progress = PortalHeaderCalculations.calculateProgress(
            scrollOffset: 100,
            startAt: 100,
            range: 40
        )
        // At exact start point: (100 - 100) / 40 = 0.0
        #expect(progress == 0.0)
    }

    // MARK: - Position Calculation Tests

    @Test("Position calculation at start")
    func positionAtStart() {
        let source = CGRect(x: 0, y: 0, width: 100, height: 100)
        let destination = CGRect(x: 200, y: 400, width: 50, height: 50)

        let position = PortalHeaderCalculations.calculatePosition(
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

        let position = PortalHeaderCalculations.calculatePosition(
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

        let position = PortalHeaderCalculations.calculatePosition(
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

        let position = PortalHeaderCalculations.calculatePosition(
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

        let position = PortalHeaderCalculations.calculatePosition(
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

        let position = PortalHeaderCalculations.calculatePosition(
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

        let position = PortalHeaderCalculations.calculatePosition(
            sourceRect: source,
            destinationRect: destination,
            progress: 0.5
        )

        // source.midX = -100 + 25 = -75
        // destination.midX = 100 + 25 = 125
        // halfway: -75 + (125 - (-75)) * 0.5 = -75 + 100 = 25
        #expect(position.x == 25.0)

        // source.midY = -200 + 25 = -175
        // destination.midY = 200 + 25 = 225
        // halfway: -175 + (225 - (-175)) * 0.5 = -175 + 200 = 25
        #expect(position.y == 25.0)
    }

    // MARK: - Scale Calculation Tests

    @Test("Scale calculation at start")
    func scaleAtStart() {
        let source = CGSize(width: 100, height: 100)
        let destination = CGSize(width: 50, height: 50)

        let scale = PortalHeaderCalculations.calculateScale(
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

        let scale = PortalHeaderCalculations.calculateScale(
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

        let scale = PortalHeaderCalculations.calculateScale(
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

        let scale = PortalHeaderCalculations.calculateScale(
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

        let scale = PortalHeaderCalculations.calculateScale(
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

        let scale = PortalHeaderCalculations.calculateScale(
            sourceSize: source,
            destinationSize: destination,
            progress: 0.5
        )

        #expect(scale.x == 0.5)
        #expect(scale.y == 0.5)
    }

    @Test("Scale calculation with zero source size")
    func scaleWithZeroSource() {
        let source = CGSize(width: 0, height: 0)
        let destination = CGSize(width: 100, height: 100)

        let scale = PortalHeaderCalculations.calculateScale(
            sourceSize: source,
            destinationSize: destination,
            progress: 0.5
        )

        // Should return identity scale (1.0, 1.0) to avoid division by zero
        #expect(scale.x == 1.0)
        #expect(scale.y == 1.0)
    }

    @Test("Scale calculation with partially zero source size")
    func scaleWithPartiallyZeroSource() {
        // Zero width only
        let sourceZeroWidth = CGSize(width: 0, height: 100)
        let destination = CGSize(width: 50, height: 50)

        let scaleZeroWidth = PortalHeaderCalculations.calculateScale(
            sourceSize: sourceZeroWidth,
            destinationSize: destination,
            progress: 0.5
        )

        #expect(scaleZeroWidth.x == 1.0)
        #expect(scaleZeroWidth.y == 1.0)

        // Zero height only
        let sourceZeroHeight = CGSize(width: 100, height: 0)

        let scaleZeroHeight = PortalHeaderCalculations.calculateScale(
            sourceSize: sourceZeroHeight,
            destinationSize: destination,
            progress: 0.5
        )

        #expect(scaleZeroHeight.x == 1.0)
        #expect(scaleZeroHeight.y == 1.0)
    }

    @Test("Scale calculation with identical sizes")
    func scaleWithIdenticalSizes() {
        let size = CGSize(width: 100, height: 100)

        let scale = PortalHeaderCalculations.calculateScale(
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

        let scaleAt25 = PortalHeaderCalculations.calculateScale(
            sourceSize: source,
            destinationSize: destination,
            progress: 0.25
        )
        let scaleAt75 = PortalHeaderCalculations.calculateScale(
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
        let startAt: CGFloat = 0
        let range: CGFloat = 20

        let progress = PortalHeaderCalculations.calculateProgress(
            scrollOffset: scrollOffset,
            startAt: startAt,
            range: range
        )
        #expect(progress == 0.5)

        let position = PortalHeaderCalculations.calculatePosition(
            sourceRect: source,
            destinationRect: destination,
            progress: CGFloat(progress)
        )
        // source.midX = 0 + 50 = 50, destination.midX = 200 + 25 = 225
        // halfway: 50 + (225 - 50) * 0.5 = 50 + 87.5 = 137.5 ✓
        #expect(position.x == 137.5)

        // source.midY = 100 + 50 = 150, destination.midY = 50 + 25 = 75
        // halfway: 150 + (75 - 150) * 0.5 = 150 + (-37.5) = 112.5
        #expect(position.y == 112.5)

        let scale = PortalHeaderCalculations.calculateScale(
            sourceSize: source.size,
            destinationSize: destination.size,
            progress: CGFloat(progress)
        )
        #expect(scale.x == 0.75)
        #expect(scale.y == 0.75)
    }

    // MARK: - Extreme Value Tests

    @Test("Position with extremely large coordinates")
    func positionWithExtremeLargeCoordinates() {
        let source = CGRect(x: 10000, y: 10000, width: 100, height: 100)
        let destination = CGRect(x: 20000, y: 20000, width: 50, height: 50)

        let position = PortalHeaderCalculations.calculatePosition(
            sourceRect: source,
            destinationRect: destination,
            progress: 0.5
        )

        // source.midX = 10050, destination.midX = 20025
        // halfway: 10050 + (20025 - 10050) * 0.5 = 15037.5
        #expect(position.x == 15037.5)
        #expect(position.y == 15037.5)
    }

    @Test("Scale with very small source size")
    func scaleWithVerySmallSourceSize() {
        let source = CGSize(width: 0.1, height: 0.1)
        let destination = CGSize(width: 100, height: 100)

        let scale = PortalHeaderCalculations.calculateScale(
            sourceSize: source,
            destinationSize: destination,
            progress: 0.5
        )

        // Should calculate normally for positive non-zero values
        #expect(scale.x > 1.0)
        #expect(scale.y > 1.0)
    }

    @Test("Progress with floating point precision")
    func progressWithFloatingPointPrecision() {
        let progress = PortalHeaderCalculations.calculateProgress(
            scrollOffset: 1.0 / 3.0,
            startAt: 0.0,
            range: 1.0
        )
        #expect(abs(progress - 0.333333) < 0.0001)
    }

    // MARK: - Accessory Fade Calculation Tests

    @Test("Accessory fade at start of transition")
    func accessoryFadeAtStart() {
        let fade = PortalHeaderCalculations.calculateAccessoryFade(
            progress: 0.0,
            fadeMultiplier: 4.0
        )
        // 1 - (0.0 * 4) = 1.0
        #expect(fade == 1.0)
    }

    @Test("Accessory fade at 10% progress")
    func accessoryFadeAt10Percent() {
        let fade = PortalHeaderCalculations.calculateAccessoryFade(
            progress: 0.1,
            fadeMultiplier: 4.0
        )
        // 1 - (0.1 * 4) = 0.6, clamped to minimum 0.6
        #expect(fade == 0.6)
    }

    @Test("Accessory fade at 25% progress")
    func accessoryFadeAt25Percent() {
        let fade = PortalHeaderCalculations.calculateAccessoryFade(
            progress: 0.25,
            fadeMultiplier: 4.0
        )
        // 1 - (0.25 * 4) = 0.0, clamped to minimum 0.6
        #expect(fade == 0.6)
    }

    @Test("Accessory fade at 50% progress")
    func accessoryFadeAt50Percent() {
        let fade = PortalHeaderCalculations.calculateAccessoryFade(
            progress: 0.5,
            fadeMultiplier: 4.0
        )
        // 1 - (0.5 * 4) = -1.0, clamped to minimum 0.6
        #expect(fade == 0.6)
    }

    @Test("Accessory fade at end of transition")
    func accessoryFadeAtEnd() {
        let fade = PortalHeaderCalculations.calculateAccessoryFade(
            progress: 1.0,
            fadeMultiplier: 4.0
        )
        // 1 - (1.0 * 4) = -3.0, clamped to minimum 0.6
        #expect(fade == 0.6)
    }

    @Test("Accessory fade with custom multiplier")
    func accessoryFadeWithCustomMultiplier() {
        let fade = PortalHeaderCalculations.calculateAccessoryFade(
            progress: 0.1,
            fadeMultiplier: 2.0
        )
        // 1 - (0.1 * 2) = 0.8
        #expect(fade == 0.8)
    }

    @Test("Accessory fade with custom minimum")
    func accessoryFadeWithCustomMinimum() {
        let fade = PortalHeaderCalculations.calculateAccessoryFade(
            progress: 0.5,
            fadeMultiplier: 4.0,
            minimumValue: 0.3
        )
        // 1 - (0.5 * 4) = -1.0, clamped to minimum 0.3
        #expect(fade == 0.3)
    }

    @Test("Accessory fade maintains minimum floor")
    func accessoryFadeMaintainsMinimum() {
        // Test various progress values all result in minimum
        let progressValues: [Double] = [0.3, 0.5, 0.75, 1.0]

        for progress in progressValues {
            let fade = PortalHeaderCalculations.calculateAccessoryFade(
                progress: progress,
                fadeMultiplier: 4.0,
                minimumValue: 0.6
            )
            #expect(fade >= 0.6, "Fade should never go below minimum at progress \(progress)")
        }
    }

    @Test("Accessory fade with zero multiplier")
    func accessoryFadeWithZeroMultiplier() {
        let fade = PortalHeaderCalculations.calculateAccessoryFade(
            progress: 0.5,
            fadeMultiplier: 0.0
        )
        // 1 - (0.5 * 0) = 1.0
        #expect(fade == 1.0)
    }

    @Test("Accessory fade accelerates correctly")
    func accessoryFadeAcceleration() {
        // Verify fade accelerates faster than linear progress
        let fade5 = PortalHeaderCalculations.calculateAccessoryFade(
            progress: 0.05,
            fadeMultiplier: 4.0
        )
        let fade10 = PortalHeaderCalculations.calculateAccessoryFade(
            progress: 0.1,
            fadeMultiplier: 4.0
        )

        // At 5%: 1 - (0.05 * 4) = 0.8
        #expect(fade5 == 0.8)
        // At 10%: 1 - (0.1 * 4) = 0.6 (clamped)
        #expect(fade10 == 0.6)
        // Should decrease as progress increases
        #expect(fade5 > fade10)
    }
}
