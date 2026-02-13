# SymbolSmithSF

<img src="https://img.shields.io/badge/platform-macOS%2014%2B-blue" alt="Platform: macOS 14+">
<img src="https://img.shields.io/badge/Swift-6.0-orange" alt="Swift 6.0">
<img src="https://img.shields.io/badge/Xcode-16%2B-blue" alt="Xcode 16+">
<img src="https://img.shields.io/badge/license-MIT-green" alt="License: MIT">

A native macOS app that creates beautiful app icons from SF Symbols with custom gradients and exports them as production-ready Xcode AppIcon.appiconset folders.

![SymbolSmithSF Screenshot](docs/screenshot-placeholder.png)
*Design, preview, and export professional app icons in seconds*

## ✨ Features

### 🎨 **Complete Design Control**
- **2,000+ SF Symbols** - Search and select from Apple's entire SF Symbols library
- **Custom Colors** - Full color picker for symbols and backgrounds
- **Beautiful Gradients** - Linear gradients with 360° angle control
- **12 Preset Palettes** - Professional gradient and solid color presets
- **Symbol Customization** - Adjust size (30%-90%), weight (9 options), and position

### 👁️ **Live Preview**
- **5 Size Preview** - See your icon at 1024px, 180px, 120px, and 60px simultaneously
- **Real-time Updates** - Every change reflects instantly across all previews
- **iOS-Style Corners** - Preview with authentic iOS superellipse rounded corners
- **Gradient Visualization** - See exactly how gradients will look at each size

### 📦 **Professional Export**
- **Single Icon Mode** - One 1024×1024 PNG for Xcode 15+ (recommended)
- **All Sizes Mode** - Complete iOS/macOS icon sets for legacy projects
- **Platform Selection** - Export for iOS, macOS, or both
- **Xcode-Ready** - Valid Contents.json with proper AppIcon.appiconset structure
- **One-Click Export** - Save and import directly into your Xcode projects

## 🚀 Quick Start

### Requirements
- macOS 14.0 (Sonoma) or later
- Xcode 16+ (for building)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/hedlynogan/SymbolSmithSF.git
cd SymbolSmithSF
```

2. Open in Xcode:
```bash
open SymbolSmithSF.xcodeproj
```

3. Build and run (⌘R)

### Usage

1. **Pick a Symbol** - Search or browse SF Symbols in the left panel
2. **Customize** - Adjust colors, size, and style in the middle panel
3. **Preview** - See real-time updates at multiple sizes in the center
4. **Export** - Click "Export AppIcon.appiconset" in the right panel
5. **Use in Xcode** - Drag the exported folder into your project's Assets.xcassets

## 📐 Architecture

Built with **MVVM architecture** and modern SwiftUI patterns:

```
SymbolSmithSF/
├── Models/                    # Data models
│   ├── IconConfiguration      # Icon settings and state
│   └── AppIconSize           # Icon size definitions
├── ViewModels/               # Business logic
│   └── IconViewModel         # Central state management
├── Views/                    # UI components
│   ├── SymbolPickerView      # Symbol search & selection
│   ├── IconPreviewView       # Live multi-size preview
│   ├── GradientEditorView    # Color & style controls
│   └── ExportSettingsView    # Export options & actions
└── Services/                 # Core functionality
    └── IconExporter          # Rendering & file export
```

## 🎯 Key Technical Features

- **Pure SwiftUI** - No UIKit/AppKit in views, modern declarative UI
- **Observation Framework** - Uses `@Observable` instead of `ObservableObject`
- **Pixel-Perfect Rendering** - Direct `NSBitmapImageRep` rendering prevents Retina scaling issues
- **No Dependencies** - Built entirely with Apple frameworks (AppKit, CoreGraphics, UniformTypeIdentifiers)
- **File System Sync** - Xcode project uses `PBXFileSystemSynchronizedRootGroup` for automatic file discovery
- **Swift 6 Compliant** - Full Swift concurrency support with `async/await`

## 🎨 Preset Palettes

The app includes 12 professionally designed presets:

**Gradients:**
- 🟠 Orange (iOS App Store style)
- 🔵 Blue (iOS system blue)
- 🟣 Purple (vibrant)
- 🩷 Pink (sunset)
- 🟢 Green (fresh)
- 🩵 Teal (bright)

**Solid Colors:**
- 🔴 Red, 🟣 Indigo, 🟡 Yellow
- ⚫ Gray, ⬛ Black, ⬜ White

## 📦 Export Formats

### Single Icon Mode (Recommended for Xcode 15+)
```
AppIcon.appiconset/
├── AppIcon-1024.png
└── Contents.json
```

### All Sizes Mode (Legacy Support)

**iOS** (9 sizes):
- 1024×1024 (App Store)
- 180×180, 120×120 (Home screen @3x, @2x)
- 87×87, 80×80, 58×58 (Settings, Spotlight)
- 60×60, 40×40 (Notifications)

**macOS** (12 sizes):
- 1024×1024 down to 16×16
- @1x and @2x variants

## 🛠️ Development

### Building from Source

```bash
# Clone the repository
git clone https://github.com/hedlynogan/SymbolSmithSF.git
cd SymbolSmithSF

# Open in Xcode
open SymbolSmithSF.xcodeproj

# Build (⌘B) or Run (⌘R)
```

### Project Structure

- **No external dependencies** - All Apple frameworks
- **Swift 6** - Modern Swift features
- **macOS 14+** - Latest SwiftUI capabilities
- **MVVM pattern** - Clear separation of concerns

## 📚 Documentation

Detailed documentation available in the `docs/` folder:

- [Feature 1 & 2: Models & Symbol Picker](docs/FEATURES_1_2_COMPLETE.md)
- [Feature 3: Live Preview](docs/FEATURE_3_COMPLETE.md)
- [Feature 4: Background Editor](docs/FEATURE_4_COMPLETE.md)
- [Feature 5: Export System](docs/FEATURE_5_COMPLETE.md)
- [Implementation Plan](.claude/IMPLEMENTATION_PLAN.md)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Built with [SF Symbols](https://developer.apple.com/sf-symbols/) by Apple
- Developed using [Claude Code](https://claude.ai/claude-code)
- Inspired by the need for quick, beautiful app icon generation

## 💡 Future Enhancements

Potential features for future releases:
- Save/load icon configurations as presets
- Drag-and-drop export to Xcode
- Shadow and glow effects
- Multiple symbol layers
- Batch export multiple icons

---

**Made with ❤️ for iOS/macOS developers who want beautiful icons fast**
