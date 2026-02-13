//
//  IconViewModel.swift
//  SymbolSmithSF
//
//  Created by Claude Code on 2/13/26.
//

import SwiftUI
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif

/// Central state management for icon configuration and export
@Observable
final class IconViewModel {
    // MARK: - Properties

    /// Current icon configuration
    var configuration = IconConfiguration()

    /// Recently used symbols
    var recentSymbols: [String] = ["star.fill", "heart.fill", "bolt.fill", "cloud.fill"]

    /// Common/featured symbols to show by default (SF Symbols 7 compatible)
    let commonSymbols = [
        "star.fill", "heart.fill", "bolt.fill", "cloud.fill",
        "envelope.fill", "phone.fill", "message.fill", "camera.fill",
        "book.fill", "bookmark.fill", "calendar", "clock.fill",
        "gear", "wrench.fill", "paintbrush.fill", "pencil",
        "folder.fill", "doc.fill", "chart.bar.fill", "briefcase.fill",
        "testtube.2", "flask.fill", "atom", "powerplug.fill"
    ]

    // MARK: - Methods

    /// Validates if an SF Symbol name exists (cross-platform)
    func isValidSymbol(_ name: String) -> Bool {
        // Use SwiftUI's Image API to validate symbol existence
        // If rendering fails, the symbol doesn't exist
        #if os(macOS)
        return NSImage(systemSymbolName: name, accessibilityDescription: nil) != nil
        #else
        return UIImage(systemName: name) != nil
        #endif
    }

    /// Adds a symbol to recent symbols list
    func addToRecent(_ symbolName: String) {
        // Remove if already exists
        recentSymbols.removeAll { $0 == symbolName }
        // Add to beginning
        recentSymbols.insert(symbolName, at: 0)
        // Keep only last 20
        if recentSymbols.count > 20 {
            recentSymbols.removeLast()
        }
    }

    /// Creates a SwiftUI Image configured with current settings (SF Symbols 7)
    func createSymbolImage(name: String) -> Image {
        Image(systemName: name)
    }

    /// Gets the SwiftUI rendering mode from configuration
    var swiftUIRenderingMode: SymbolRenderingMode {
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
}
