//
//  IconExporter.swift
//  SymbolSmithSF
//
//  Created by Claude Code on 2/13/26.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

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
            let image = renderIcon(configuration: configuration, size: iconSize.size)
            let fileURL = appiconsetURL.appendingPathComponent(iconSize.filename)

            guard savePNG(image: image, to: fileURL) else {
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
        let image = renderIcon(configuration: configuration, size: CGSize(width: 1024, height: 1024))

        guard savePNG(image: image, to: destinationURL) else {
            throw ExportError.fileWriteFailed(destinationURL.lastPathComponent)
        }
    }

    // MARK: - Rendering

    /// Renders an icon at the specified size
    func renderIcon(configuration: IconConfiguration, size: CGSize) -> NSImage {
        print("🎨 Rendering icon at size: \(size)")
        
        // Create bitmap representation with explicit scale of 1.0 to avoid Retina 2x scaling
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
            print("❌ Failed to create bitmap representation")
            return NSImage(size: size)
        }
        
        print("✅ Created bitmap: \(bitmapRep.pixelsWide)x\(bitmapRep.pixelsHigh)")
        
        // Draw directly into the bitmap context instead of using NSImage lockFocus
        NSGraphicsContext.saveGraphicsState()
        let context = NSGraphicsContext(bitmapImageRep: bitmapRep)
        NSGraphicsContext.current = context
        
        guard let cgContext = context?.cgContext else {
            NSGraphicsContext.restoreGraphicsState()
            let image = NSImage(size: size)
            image.addRepresentation(bitmapRep)
            return image
        }

        let rect = CGRect(origin: .zero, size: size)

        // 1. Draw background
        drawBackground(configuration: configuration, in: rect, context: cgContext)

        // 2. Draw symbol
        drawSymbol(configuration: configuration, in: rect, size: size)

        NSGraphicsContext.restoreGraphicsState()
        
        // Create NSImage and add our bitmap representation
        let image = NSImage(size: size)
        image.addRepresentation(bitmapRep)

        return image
    }

    // MARK: - Private Drawing Methods

    private func drawBackground(configuration: IconConfiguration, in rect: CGRect, context: CGContext) {
        context.saveGState()

        switch configuration.backgroundType {
        case .solid:
            // Draw solid color
            NSColor(configuration.primaryColor).setFill()
            context.fill(rect)

        case .gradient:
            // Draw gradient
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [
                configuration.primaryColor.cgColor,
                configuration.secondaryColor.cgColor
            ] as CFArray

            guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 1.0]) else {
                return
            }

            // Calculate gradient start and end points based on angle
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

    private func drawSymbol(configuration: IconConfiguration, in rect: CGRect, size: CGSize) {
        // Get the symbol image
        guard let symbolImage = NSImage(
            systemSymbolName: configuration.symbolName,
            accessibilityDescription: nil
        ) else {
            return
        }

        // Configure symbol appearance
        let pointSize = size.width * configuration.symbolScale
        let symbolConfig = NSImage.SymbolConfiguration(
            pointSize: pointSize,
            weight: nsWeight(from: configuration.symbolWeight)
        )

        // Apply color based on rendering mode
        let colorConfig: NSImage.SymbolConfiguration
        switch configuration.renderingMode {
        case .monochrome:
            colorConfig = .init(paletteColors: [NSColor(configuration.symbolColor)])
        case .hierarchical:
            colorConfig = .init(hierarchicalColor: NSColor(configuration.symbolColor))
        case .palette:
            colorConfig = .init(paletteColors: [NSColor(configuration.symbolColor)])
        case .multicolor:
            // Multicolor uses the symbol's built-in colors
            colorConfig = symbolConfig
        }

        let finalConfig = symbolConfig.applying(colorConfig)
        let configuredSymbol = symbolImage.withSymbolConfiguration(finalConfig)

        // Calculate symbol drawing rect (centered with offset)
        let symbolSize = configuredSymbol?.size ?? CGSize(width: pointSize, height: pointSize)
        let x = (size.width - symbolSize.width) / 2
        let yOffset = configuration.symbolVerticalOffset * size.height
        let y = (size.height - symbolSize.height) / 2 + yOffset

        let symbolRect = CGRect(
            x: x,
            y: y,
            width: symbolSize.width,
            height: symbolSize.height
        )

        // Draw the symbol
        configuredSymbol?.draw(in: symbolRect)
    }

    // MARK: - Helper Methods

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

    private func savePNG(image: NSImage, to url: URL) -> Bool {
        print("💾 Saving PNG to: \(url.path)")
        print("📊 Image size: \(image.size), representations: \(image.representations.count)")
        
        // Use the bitmap representation we already created (not cgImage which may be 2x)
        guard let bitmapRep = image.representations.first as? NSBitmapImageRep else {
            print("❌ No bitmap representation found in image")
            print("   Available representations: \(image.representations)")
            return false
        }
        
        print("📐 Bitmap dimensions: \(bitmapRep.pixelsWide)x\(bitmapRep.pixelsHigh)")

        guard let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            print("❌ Failed to create PNG data")
            return false
        }
        
        print("✅ PNG data created: \(pngData.count) bytes")

        do {
            try pngData.write(to: url)
            print("✅ PNG saved successfully")
            return true
        } catch {
            print("❌ Error writing PNG: \(error)")
            return false
        }
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

            // For non-marketing icons, include scale and size
            if iconSize.idiom != "ios-marketing" && iconSize.idiom != "mac" {
                imageEntry["scale"] = iconSize.scaleString
                imageEntry["size"] = iconSize.sizeString
            } else if iconSize.idiom == "mac" {
                imageEntry["scale"] = iconSize.scaleString
                imageEntry["size"] = iconSize.sizeString
            } else {
                imageEntry["size"] = iconSize.sizeString
            }

            // Convert to JSON string
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
        NSColor(self).cgColor
    }
}
