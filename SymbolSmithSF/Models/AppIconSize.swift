//
//  AppIconSize.swift
//  SymbolSmithSF
//
//  Created by Claude Code on 2/13/26.
//

import Foundation

/// Icon size definitions for different platforms
struct AppIconSize {
    let size: CGSize
    let scale: Int
    let idiom: String
    let platform: String?
    let filename: String

    /// Computed property for size descriptor (e.g., "60x60")
    var sizeString: String {
        "\(Int(size.width))x\(Int(size.height))"
    }

    /// Computed property for scale string (e.g., "2x")
    var scaleString: String {
        "\(scale)x"
    }

    // MARK: - iOS Sizes

    static let iOSSizes: [AppIconSize] = [
        // App Store
        AppIconSize(size: CGSize(width: 1024, height: 1024), scale: 1, idiom: "ios-marketing", platform: "ios", filename: "icon-1024.png"),

        // 60pt icons (app icon on home screen)
        AppIconSize(size: CGSize(width: 180, height: 180), scale: 3, idiom: "iphone", platform: "ios", filename: "icon-60@3x.png"),
        AppIconSize(size: CGSize(width: 120, height: 120), scale: 2, idiom: "iphone", platform: "ios", filename: "icon-60@2x.png"),

        // 40pt icons (spotlight, settings)
        AppIconSize(size: CGSize(width: 120, height: 120), scale: 3, idiom: "iphone", platform: "ios", filename: "icon-40@3x.png"),
        AppIconSize(size: CGSize(width: 80, height: 80), scale: 2, idiom: "iphone", platform: "ios", filename: "icon-40@2x.png"),

        // 29pt icons (settings)
        AppIconSize(size: CGSize(width: 87, height: 87), scale: 3, idiom: "iphone", platform: "ios", filename: "icon-29@3x.png"),
        AppIconSize(size: CGSize(width: 58, height: 58), scale: 2, idiom: "iphone", platform: "ios", filename: "icon-29@2x.png"),

        // 20pt icons (notifications)
        AppIconSize(size: CGSize(width: 60, height: 60), scale: 3, idiom: "iphone", platform: "ios", filename: "icon-20@3x.png"),
        AppIconSize(size: CGSize(width: 40, height: 40), scale: 2, idiom: "iphone", platform: "ios", filename: "icon-20@2x.png"),
    ]

    // MARK: - macOS Sizes

    static let macOSSizes: [AppIconSize] = [
        AppIconSize(size: CGSize(width: 1024, height: 1024), scale: 1, idiom: "mac", platform: "macos", filename: "icon-1024.png"),
        AppIconSize(size: CGSize(width: 512, height: 512), scale: 2, idiom: "mac", platform: "macos", filename: "icon-512@2x.png"),
        AppIconSize(size: CGSize(width: 512, height: 512), scale: 1, idiom: "mac", platform: "macos", filename: "icon-512.png"),
        AppIconSize(size: CGSize(width: 256, height: 256), scale: 2, idiom: "mac", platform: "macos", filename: "icon-256@2x.png"),
        AppIconSize(size: CGSize(width: 256, height: 256), scale: 1, idiom: "mac", platform: "macos", filename: "icon-256.png"),
        AppIconSize(size: CGSize(width: 128, height: 128), scale: 2, idiom: "mac", platform: "macos", filename: "icon-128@2x.png"),
        AppIconSize(size: CGSize(width: 128, height: 128), scale: 1, idiom: "mac", platform: "macos", filename: "icon-128.png"),
        AppIconSize(size: CGSize(width: 64, height: 64), scale: 1, idiom: "mac", platform: "macos", filename: "icon-64.png"),
        AppIconSize(size: CGSize(width: 32, height: 32), scale: 2, idiom: "mac", platform: "macos", filename: "icon-32@2x.png"),
        AppIconSize(size: CGSize(width: 32, height: 32), scale: 1, idiom: "mac", platform: "macos", filename: "icon-32.png"),
        AppIconSize(size: CGSize(width: 16, height: 16), scale: 2, idiom: "mac", platform: "macos", filename: "icon-16@2x.png"),
        AppIconSize(size: CGSize(width: 16, height: 16), scale: 1, idiom: "mac", platform: "macos", filename: "icon-16.png"),
    ]

    // MARK: - Single Icon Mode (Xcode 15+)

    static let singleIcon = AppIconSize(
        size: CGSize(width: 1024, height: 1024),
        scale: 1,
        idiom: "universal",
        platform: "ios",
        filename: "AppIcon-1024.png"
    )
}
