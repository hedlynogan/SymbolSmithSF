//
//  IconPreviewView.swift
//  SymbolSmithSF
//
//  Created by Claude Code on 2/13/26.
//

import SwiftUI

/// Live icon preview canvas showing multiple sizes
struct IconPreviewView: View {
    @Bindable var viewModel: IconViewModel

    // Preview sizes to display
    private let previewSizes: [PreviewSize] = [
        PreviewSize(dimension: 1024, label: "1024×1024", description: "App Store"),
        PreviewSize(dimension: 60, label: "60×60", description: "20pt @3x")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("Icon Preview")
                .font(.title2)
                .fontWeight(.semibold)

            // Main large preview
            VStack(spacing: 10) {
                Text("High Resolution")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                IconPreviewCanvas(
                    configuration: viewModel.configuration,
                    size: 120
                )
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            }

            Divider()

            // Multiple size previews
            VStack(alignment: .leading, spacing: 12) {
                Text("Size Preview")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                HStack(alignment: .top, spacing: 12) {
                    ForEach(previewSizes, id: \.dimension) { previewSize in
                        VStack(spacing: 6) {
                            IconPreviewCanvas(
                                configuration: viewModel.configuration,
                                size: previewSize.dimension == 1024 ? 60 : CGFloat(previewSize.dimension)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

                            VStack(spacing: 2) {
                                Text(previewSize.label)
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                Text(previewSize.description)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(.top, 20)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Icon Preview Canvas

/// Renders a single icon preview at the specified size
private struct IconPreviewCanvas: View {
    let configuration: IconConfiguration
    let size: CGFloat

    var body: some View {
        ZStack {
            // Background
            backgroundView
                .frame(width: size, height: size)

            // Symbol
            Image(systemName: configuration.symbolName)
                .font(.system(
                    size: size * configuration.symbolScale,
                    weight: configuration.symbolWeight
                ))
                .foregroundStyle(configuration.symbolColor)
                .symbolRenderingMode(renderingMode)
                .offset(y: configuration.symbolVerticalOffset * size)
        }
        .clipShape(roundedShape)
    }

    // MARK: - Computed Properties

    @ViewBuilder
    private var backgroundView: some View {
        switch configuration.backgroundType {
        case .solid:
            configuration.primaryColor

        case .gradient:
            LinearGradient(
                colors: [configuration.primaryColor, configuration.secondaryColor],
                startPoint: gradientStart,
                endPoint: gradientEnd
            )
        }
    }

    private var roundedShape: some InsettableShape {
        switch configuration.cornerRadiusStyle {
        case .none:
            return AnyInsettableShape(Rectangle())
        case .continuous:
            // iOS-style continuous corner radius (approximately 22.37% of size)
            let radius = size * 0.2237
            return AnyInsettableShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        }
    }

    private var renderingMode: SymbolRenderingMode {
        switch configuration.renderingMode {
        case .monochrome:
            return .monochrome
        case .hierarchical:
            return .hierarchical
        case .palette:
            return .palette
        case .multicolor:
            return .multicolor
        }
    }

    private var gradientStart: UnitPoint {
        angleToUnitPoint(configuration.gradientAngle, isStart: true)
    }

    private var gradientEnd: UnitPoint {
        angleToUnitPoint(configuration.gradientAngle, isStart: false)
    }

    // MARK: - Helper Methods

    /// Converts an angle to UnitPoint for gradient
    private func angleToUnitPoint(_ angle: Angle, isStart: Bool) -> UnitPoint {
        let radians = angle.radians
        let x = cos(radians - .pi / 2)
        let y = sin(radians - .pi / 2)

        if isStart {
            return UnitPoint(x: 0.5 - x / 2, y: 0.5 - y / 2)
        } else {
            return UnitPoint(x: 0.5 + x / 2, y: 0.5 + y / 2)
        }
    }
}

// MARK: - Preview Size Model

private struct PreviewSize {
    let dimension: CGFloat
    let label: String
    let description: String
}

// MARK: - Type-Erased Shape

/// Type-erased insettable shape wrapper for dynamic shape selection
@available(macOS 14.0, *)
private struct AnyInsettableShape: InsettableShape {
    private let _path: @Sendable (CGRect) -> Path
    private let _inset: @Sendable (CGFloat) -> AnyInsettableShape

    init<S: InsettableShape>(_ shape: S) where S: Sendable {
        _path = { rect in shape.path(in: rect) }
        _inset = { amount in AnyInsettableShape(shape.inset(by: amount)) }
    }

    func path(in rect: CGRect) -> Path {
        _path(rect)
    }

    func inset(by amount: CGFloat) -> AnyInsettableShape {
        _inset(amount)
    }
}

// MARK: - Preview

#Preview {
    IconPreviewView(viewModel: IconViewModel())
        .frame(width: 600, height: 700)
}
