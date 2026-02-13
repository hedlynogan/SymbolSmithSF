//
//  IconConfiguration.swift
//  SymbolSmithSF
//
//  Created by Claude Code on 2/13/26.
//

import SwiftUI

/// Data model for icon settings
@Observable
final class IconConfiguration {
    // MARK: - SF Symbol Properties

    /// SF Symbol name (e.g., "star.fill")
    var symbolName: String = "star.fill"

    /// Symbol color
    var symbolColor: Color = .white

    /// Symbol size as percentage of canvas (0.3 to 0.9)
    var symbolScale: CGFloat = 0.6

    /// Symbol weight
    var symbolWeight: Font.Weight = .regular

    /// Symbol vertical offset for fine-tuning position
    var symbolVerticalOffset: CGFloat = 0.0

    /// Symbol rendering mode
    var renderingMode: SymbolRenderingMode = .monochrome

    // MARK: - Background Properties

    /// Background type
    var backgroundType: BackgroundType = .gradient

    /// Primary background color (or solid color if backgroundType is .solid)
    var primaryColor: Color = Color(red: 1.0, green: 149/255, blue: 0.0) // #FF9500

    /// Secondary background color for gradient
    var secondaryColor: Color = Color(red: 1.0, green: 200/255, blue: 0.0) // #FFC800

    /// Gradient angle (default: top to bottom)
    var gradientAngle: Angle = .degrees(180)

    // MARK: - Preview Properties

    /// Corner radius option for preview
    var cornerRadiusStyle: CornerRadiusStyle = .continuous

    // MARK: - Initialization

    init() {}

    // MARK: - Nested Types

    enum BackgroundType: String, CaseIterable {
        case solid = "Solid"
        case gradient = "Gradient"
    }

    enum CornerRadiusStyle: String, CaseIterable {
        case none = "Square"
        case continuous = "Continuous (iOS-style)"
    }

    enum SymbolRenderingMode: String, CaseIterable {
        case monochrome = "Monochrome"
        case hierarchical = "Hierarchical"
        case palette = "Palette"
        case multicolor = "Multicolor"
    }
}
