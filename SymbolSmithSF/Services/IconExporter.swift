//
//  IconExporter.swift
//  SymbolSmithSF
//
//  Created by Claude Code on 2/13/26.
//

import SwiftUI
import UniformTypeIdentifiers
#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// Renders and exports app icons to PNG files with Contents.json
final class IconExporter {

    enum ExportMode {
        case singleIcon  // Xcode 15+ - single 1024×1024
        case allSizes    // Legacy - all sizes
    }

    enum ExportError: LocalizedError {
        case renderingFailed
        case fileWriteFailed(String)
        case directoryCreationFailed

        var errorDescription: String? {
            switch self {
            case .renderingFailed:
                return "Failed to render icon image"
            case .fileWriteFailed(let filename):
                return "Failed to write file: \(filename)"
            case .directoryCreationFailed:
                return "Failed to create AppIcon.appiconset directory"
            }
        }
    }

    // MARK: - Public Methods

    /// Exports the icon to an AppIcon.appiconset folder
    func exportAppIcon(
        configuration: IconConfiguration,
        mode: ExportMode,
        platforms: Set<Platform>,
        to destinationURL: URL
    ) async throws {
        // Create AppIcon.appiconset directory
        let appiconsetURL = destinationURL.appendingPathComponent("AppIcon.appiconset")

        try FileManager.default.createDirectory(
            at: appiconsetURL,
            withIntermediateDirectories: true,
            attributes: nil
        )

        // Generate icons based on mode
        let sizes: [AppIconSize]
        let contentsJSON: String

        switch mode {
        case .singleIcon:
            sizes = [AppIconSize.singleIcon]
            contentsJSON = generateSingleIconContentsJSON()

        case .allSizes:
            sizes = platforms.flatMap { $0.sizes }
            contentsJSON = generateAllSizesContentsJSON(sizes: sizes)
        }

        // Render and save each size
        for iconSize in sizes {
            let pngData = try renderIconAsPNGData(configuration: configuration, size: iconSize.size)
            let fileURL = appiconsetURL.appendingPathComponent(iconSize.filename)

            do {
                try pngData.write(to: fileURL)
            } catch {
                throw ExportError.fileWriteFailed(iconSize.filename)
            }
        }

        // Write Contents.json
        let contentsURL = appiconsetURL.appendingPathComponent("Contents.json")
        try contentsJSON.write(to: contentsURL, atomically: true, encoding: .utf8)
    }

    /// Exports a single 1024×1024 PNG file
    func exportSinglePNG(
        configuration: IconConfiguration,
        to destinationURL: URL
    ) throws {
        let pngData = try renderIconAsPNGData(
            configuration: configuration,
            size: CGSize(width: 1024, height: 1024)
        )
        try pngData.write(to: destinationURL)
    }

    // MARK: - Rendering

    /// Renders an icon at the specified size and returns PNG data.
    /// Uses AppKit on macOS and UIKit on iOS/iPadOS/visionOS.
    func renderIconAsPNGData(configuration: IconConfiguration, size: CGSize) throws -> Data {
        #if os(macOS)
        return try renderIconMacOS(configuration: configuration, size: size)
        #else
        return try renderIconUIKit(configuration: configuration, size: size)
        #endif
    }

    // MARK: - macOS Rendering

    #if os(macOS)
    private func renderIconMacOS(configuration: IconConfiguration, size: CGSize) throws -> Data {
        guard let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(size.width),
            pixelsHigh: Int(size.height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else {
            throw ExportError.renderingFailed
        }

        NSGraphicsContext.saveGraphicsState()
        let graphicsContext = NSGraphicsContext(bitmapImageRep: bitmapRep)
        NSGraphicsContext.current = graphicsContext

        guard let cgContext = graphicsContext?.cgContext else {
            NSGraphicsContext.restoreGraphicsState()
            throw ExportError.renderingFailed
        }

        let rect = CGRect(origin: .zero, size: size)
        drawBackground(configuration: configuration, in: rect, context: cgContext)
        drawSymbolMacOS(configuration: configuration, in: rect, size: size)

        NSGraphicsContext.restoreGraphicsState()

        guard let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            throw ExportError.renderingFailed
        }
        return pngData
    }

    private func drawSymbolMacOS(configuration: IconConfiguration, in rect: CGRect, size: CGSize) {
        guard let symbolImage = NSImage(
            systemSymbolName: configuration.symbolName,
            accessibilityDescription: nil
        ) else { return }

        let pointSize = size.width * configuration.symbolScale
        let symbolConfig = NSImage.SymbolConfiguration(
            pointSize: pointSize,
            weight: nsWeight(from: configuration.symbolWeight)
        )

        let colorConfig: NSImage.SymbolConfiguration
        switch configuration.renderingMode {
        case .monochrome:
            colorConfig = .init(paletteColors: [NSColor(configuration.symbolColor)])
        case .hierarchical:
            colorConfig = .init(hierarchicalColor: NSColor(configuration.symbolColor))
        case .palette:
            colorConfig = .init(paletteColors: [NSColor(configuration.symbolColor)])
        case .multicolor:
            colorConfig = symbolConfig
        }

        let finalConfig = symbolConfig.applying(colorConfig)
        guard let configuredSymbol = symbolImage.withSymbolConfiguration(finalConfig) else { return }

        let symbolSize = configuredSymbol.size
        let x = (size.width - symbolSize.width) / 2
        let yOffset = configuration.symbolVerticalOffset * size.height
        let y = (size.height - symbolSize.height) / 2 + yOffset

        configuredSymbol.draw(in: CGRect(x: x, y: y, width: symbolSize.width, height: symbolSize.height))
    }

    private func nsWeight(from weight: Font.Weight) -> NSFont.Weight {
        switch weight {
        case .ultraLight: return .ultraLight
        case .thin: return .thin
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .heavy: return .heavy
        case .black: return .black
        default: return .regular
        }
    }
    #endif

    // MARK: - iOS/iPadOS/visionOS Rendering

    #if !os(macOS)
    private func renderIconUIKit(configuration: IconConfiguration, size: CGSize) throws -> Data {
        let renderer = UIGraphicsImageRenderer(size: size)
        let pngData = renderer.pngData { context in
            let cgContext = context.cgContext
            let rect = CGRect(origin: .zero, size: size)
            drawBackground(configuration: configuration, in: rect, context: cgContext)
            drawSymbolUIKit(configuration: configuration, in: rect, size: size)
        }
        return pngData
    }

    private func drawSymbolUIKit(configuration: IconConfiguration, in rect: CGRect, size: CGSize) {
        guard let symbolImage = UIImage(systemName: configuration.symbolName) else { return }

        let pointSize = size.width * configuration.symbolScale
        let symbolConfig = UIImage.SymbolConfiguration(
            pointSize: pointSize,
            weight: uiWeight(from: configuration.symbolWeight)
        )

        let colorConfig: UIImage.SymbolConfiguration
        switch configuration.renderingMode {
        case .monochrome:
            colorConfig = .init(paletteColors: [UIColor(configuration.symbolColor)])
        case .hierarchical:
            colorConfig = .init(hierarchicalColor: UIColor(configuration.symbolColor))
        case .palette:
            colorConfig = .init(paletteColors: [UIColor(configuration.symbolColor)])
        case .multicolor:
            colorConfig = symbolConfig
        }

        let finalConfig = symbolConfig.applying(colorConfig)
        guard let configuredSymbol = symbolImage.withConfiguration(finalConfig) as? UIImage else { return }

        let symbolSize = configuredSymbol.size
        let x = (size.width - symbolSize.width) / 2
        let yOffset = configuration.symbolVerticalOffset * size.height
        let y = (size.height - symbolSize.height) / 2 + yOffset

        configuredSymbol.draw(in: CGRect(x: x, y: y, width: symbolSize.width, height: symbolSize.height))
    }

    private func uiWeight(from weight: Font.Weight) -> UIImage.SymbolWeight {
        switch weight {
        case .ultraLight: return .ultraLight
        case .thin: return .thin
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .heavy: return .heavy
        case .black: return .black
        default: return .regular
        }
    }
    #endif

    // MARK: - Shared Drawing (CoreGraphics - platform agnostic)

    private func drawBackground(configuration: IconConfiguration, in rect: CGRect, context: CGContext) {
        context.saveGState()

        switch configuration.backgroundType {
        case .solid:
            #if os(macOS)
            NSColor(configuration.primaryColor).setFill()
            #else
            UIColor(configuration.primaryColor).setFill()
            #endif
            context.fill(rect)

        case .gradient:
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [
                configuration.primaryColor.cgColor,
                configuration.secondaryColor.cgColor
            ] as CFArray

            guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 1.0]) else {
                return
            }

            let (startPoint, endPoint) = gradientPoints(for: configuration.gradientAngle, in: rect)
            context.drawLinearGradient(
                gradient,
                start: startPoint,
                end: endPoint,
                options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
            )
        }

        context.restoreGState()
    }

    private func gradientPoints(for angle: Angle, in rect: CGRect) -> (CGPoint, CGPoint) {
        let radians = angle.radians
        let x = cos(radians - .pi / 2)
        let y = sin(radians - .pi / 2)

        let centerX = rect.width / 2
        let centerY = rect.height / 2
        let radius = max(rect.width, rect.height)

        let startPoint = CGPoint(
            x: centerX - x * radius / 2,
            y: centerY - y * radius / 2
        )
        let endPoint = CGPoint(
            x: centerX + x * radius / 2,
            y: centerY + y * radius / 2
        )

        return (startPoint, endPoint)
    }

    // MARK: - Contents.json Generation

    private func generateSingleIconContentsJSON() -> String {
        """
        {
          "images" : [
            {
              "filename" : "AppIcon-1024.png",
              "idiom" : "universal",
              "platform" : "ios",
              "size" : "1024x1024"
            }
          ],
          "info" : {
            "author" : "xcode",
            "version" : 1
          }
        }
        """
    }

    private func generateAllSizesContentsJSON(sizes: [AppIconSize]) -> String {
        var imagesJSON: [String] = []

        for iconSize in sizes {
            var imageEntry: [String: String] = [:]

            imageEntry["filename"] = iconSize.filename
            imageEntry["idiom"] = iconSize.idiom

            if let platform = iconSize.platform {
                imageEntry["platform"] = platform
            }

            if iconSize.idiom != "ios-marketing" && iconSize.idiom != "mac" {
                imageEntry["scale"] = iconSize.scaleString
                imageEntry["size"] = iconSize.sizeString
            } else if iconSize.idiom == "mac" {
                imageEntry["scale"] = iconSize.scaleString
                imageEntry["size"] = iconSize.sizeString
            } else {
                imageEntry["size"] = iconSize.sizeString
            }

            let jsonString = imageEntry.map { "      \"\($0.key)\" : \"\($0.value)\"" }
                .sorted()
                .joined(separator: ",\n")

            imagesJSON.append("    {\n\(jsonString)\n    }")
        }

        return """
        {
          "images" : [
        \(imagesJSON.joined(separator: ",\n"))
          ],
          "info" : {
            "author" : "xcode",
            "version" : 1
          }
        }
        """
    }

    // MARK: - Platform Support

    enum Platform: String, CaseIterable {
        case iOS = "iOS"
        case macOS = "macOS"

        var sizes: [AppIconSize] {
            switch self {
            case .iOS:
                return AppIconSize.iOSSizes
            case .macOS:
                return AppIconSize.macOSSizes
            }
        }
    }
}

// MARK: - Color Extension

private extension Color {
    var cgColor: CGColor {
        #if os(macOS)
        NSColor(self).cgColor
        #else
        UIColor(self).cgColor
        #endif
    }
}
