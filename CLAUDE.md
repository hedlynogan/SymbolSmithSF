# SymbolSmithSF — Claude Code Project Guide

## Project Overview

**SymbolSmithSF** is a native macOS app (SwiftUI, macOS 14+) that creates app icons from SF Symbols and exports them as a complete Xcode AppIcon asset set. The goal: pick a symbol, customize colors and layout, preview the result, and export a ready-to-drop folder for any Xcode project's `Assets.xcassets`.

## Tech Stack

- **Language:** Swift 6 / SwiftUI
- **Platform:** macOS 14+ (Sonoma), Mac Catalyst is NOT needed
- **IDE:** Xcode 16+
- **Architecture:** MVVM — keep views, view models, and models in separate files
- **No external dependencies** — use only Apple frameworks (AppKit, CoreGraphics, CoreImage, UniformTypeIdentifiers)

## Project Structure

All Swift source files go in `SymbolSmithSF/SymbolSmithSF/` (the app target folder with `SymbolSmithSFApp.swift`). The Xcode project uses a **PBXFileSystemSynchronizedRootGroup**, so new files added to the folder on disk are automatically picked up by Xcode — no need to edit `project.pbxproj`.

Organize files like this:

```
SymbolSmithSF/
├── SymbolSmithSFApp.swift          # App entry point
├── ContentView.swift               # Main window layout
├── Views/
│   ├── SymbolPickerView.swift      # SF Symbol search & selection
│   ├── IconPreviewView.swift       # Live icon preview canvas
│   ├── GradientEditorView.swift    # Background color/gradient controls
│   └── ExportSettingsView.swift    # Export options & button
├── ViewModels/
│   └── IconViewModel.swift         # Central state & export logic
├── Models/
│   ├── IconConfiguration.swift     # Data model for icon settings
│   └── AppIconSize.swift           # Icon size definitions
├── Services/
│   └── IconExporter.swift          # Renders & writes PNG files + Contents.json
└── Assets.xcassets/
```

## Core Features (Build in This Order)

### 1. Icon Configuration Model
- SF Symbol name (String, default: "star.fill")
- Symbol color (Color, default: .white)
- Symbol size as percentage of canvas (CGFloat, 0.3–0.9, default: 0.6)
- Symbol weight (Font.Weight, default: .regular)
- Symbol vertical offset (CGFloat, for fine-tuning position)
- Background type: solid color OR linear gradient
- Background colors (Color primary + Color secondary for gradient)
- Gradient angle (Angle, default: .degrees(180) = top to bottom)
- Corner radius option: none (square) or continuous (iOS-style superellipse) — for preview only; iOS applies its own mask

### 2. SF Symbol Picker
- Text field to search/type an SF Symbol name
- Use `NSImage(systemSymbolName:accessibilityDescription:)` to validate that a name is real
- Show a grid or list of recently used / common symbols
- Display the selected symbol large in the picker area
- Support rendering modes: monochrome, hierarchical, palette, multicolor

### 3. Live Preview
- Render the icon at display resolution in a rounded-rect (iOS-style) preview
- Show it at multiple sizes side by side (e.g., 1024, 180, 120, 60) so the user can see how it reads at small sizes
- Update in real time as settings change

### 4. Background Editor
- Toggle between solid color and gradient
- Two ColorPickers for gradient stops
- Angle slider or dial for gradient direction
- Preset palettes (iOS system colors, common gradients)

### 5. Export to AppIcon Set
- Render the icon to a 1024×1024 PNG using `NSGraphicsContext` / `CGContext`
- Generate all required sizes for the selected platforms:
  - **iOS:** 1024×1024 (App Store), 180×180 (60pt @3x), 120×120 (60pt @2x, 40pt @3x), 80×80 (40pt @2x), 87×87 (29pt @3x), 58×58 (29pt @2x), 40×40 (20pt @2x), 60×60 (20pt @3x)
  - **macOS:** 1024×1024, 512×512, 256×256, 128×128, 64×64, 32×32, 16×16
- Generate a valid `Contents.json` matching Xcode's expected format
- Export to a user-chosen folder via `NSSavePanel` — output an `AppIcon.appiconset/` folder
- Option to also export a single 1024×1024 PNG

### 6. Nice-to-Haves (After Core Works)
- Save/load icon configurations as presets (JSON, stored in App Support)
- Drag-and-drop the preview directly into Xcode
- Symbol weight picker (ultraLight through black)
- Shadow/glow effect on the symbol
- Multiple symbol layers (e.g., a background symbol + foreground symbol)

## Rendering Approach

Use `NSImage` and `CGContext` for rendering (NOT SwiftUI `Image` snapshots — those are unreliable for exact pixel sizes):

```swift
// Pseudocode for rendering
func renderIcon(config: IconConfiguration, size: CGSize) -> NSImage {
    let image = NSImage(size: size)
    image.lockFocus()
    // 1. Draw background (solid or gradient) filling the full rect
    // 2. Get SF Symbol as NSImage via NSImage(systemSymbolName:...)
    //    Apply symbol configuration for weight, size, color
    // 3. Draw symbol centered (with optional vertical offset)
    image.unlockFocus()
    return image
}
```

For the SF Symbol, use:
```swift
let symbolConfig = NSImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
    .applying(.init(paletteColors: [symbolColor]))
let symbolImage = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)?
    .withSymbolConfiguration(symbolConfig)
```

## Contents.json Format

The exported `Contents.json` must match Xcode's expected format exactly:

```json
{
  "images": [
    {
      "filename": "icon-60@2x.png",
      "idiom": "iphone",
      "scale": "2x",
      "size": "60x60"
    }
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}
```

For modern Xcode (15+), a single 1024×1024 image is often sufficient:
```json
{
  "images": [
    {
      "filename": "AppIcon-1024.png",
      "idiom": "universal",
      "platform": "ios",
      "size": "1024x1024"
    }
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}
```

Support BOTH modes — let the user choose "Single icon (Xcode 15+)" or "All sizes (legacy)".

## Color Reference (from design notes)

Default orange gradient preset:
- Top: #FF9500 / RGB(255, 149, 0)
- Bottom: #FFC800 / RGB(255, 200, 0)
- Symbol: White, 60% of canvas size

## Code Style

- Use Swift concurrency (async/await) where appropriate (e.g., file export)
- Use `@Observable` (Observation framework) for the view model, not `ObservableObject`
- Prefer `guard` for early returns
- Use meaningful names — no abbreviations except common ones (URL, etc.)
- Mark views as `private` when they're subviews only used in one file
- Add `// MARK: -` section headers in longer files
- Keep each file under ~200 lines; split into extensions if needed

## What NOT to Do

- Do NOT use third-party packages or SPM dependencies
- Do NOT modify the `.xcodeproj` file — the project uses file system sync
- Do NOT use `UIKit` — this is a macOS app, use `AppKit` when SwiftUI isn't enough
- Do NOT render icons via SwiftUI `ImageRenderer` — use `NSImage`/`CGContext` for pixel-accurate output
- Do NOT add rounded corners to exported PNGs — iOS applies the mask automatically
