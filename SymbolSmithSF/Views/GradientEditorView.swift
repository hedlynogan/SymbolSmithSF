//
//  GradientEditorView.swift
//  SymbolSmithSF
//
//  Created by Claude Code on 2/13/26.
//

import SwiftUI

/// Background color/gradient controls and symbol customization
struct GradientEditorView: View {
    @Bindable var viewModel: IconViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                Text("Customize Icon")
                    .font(.title2)
                    .fontWeight(.semibold)

                // MARK: - Symbol Customization

                GroupBox {
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Symbol", systemImage: "star.circle.fill")
                            .font(.headline)

                        // Symbol Color
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Color")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            ColorPicker("Symbol Color", selection: $viewModel.configuration.symbolColor, supportsOpacity: false)
                                .labelsHidden()
                        }

                        Divider()

                        // Symbol Size
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Size")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(Int(viewModel.configuration.symbolScale * 100))%")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .monospacedDigit()
                            }

                            Slider(value: $viewModel.configuration.symbolScale, in: 0.3...0.9, step: 0.05)
                        }

                        Divider()

                        // Symbol Weight
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Weight")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Picker("Weight", selection: $viewModel.configuration.symbolWeight) {
                                Text("Ultralight").tag(Font.Weight.ultraLight)
                                Text("Thin").tag(Font.Weight.thin)
                                Text("Light").tag(Font.Weight.light)
                                Text("Regular").tag(Font.Weight.regular)
                                Text("Medium").tag(Font.Weight.medium)
                                Text("Semibold").tag(Font.Weight.semibold)
                                Text("Bold").tag(Font.Weight.bold)
                                Text("Heavy").tag(Font.Weight.heavy)
                                Text("Black").tag(Font.Weight.black)
                            }
                            .pickerStyle(.menu)
                        }

                        Divider()

                        // Vertical Offset
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Vertical Offset")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(String(format: "%.2f", viewModel.configuration.symbolVerticalOffset))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .monospacedDigit()
                            }

                            HStack {
                                Slider(value: $viewModel.configuration.symbolVerticalOffset, in: -0.2...0.2, step: 0.01)
                                Button("Reset") {
                                    viewModel.configuration.symbolVerticalOffset = 0
                                }
                                .buttonStyle(.borderless)
                                .font(.caption)
                            }
                        }
                    }
                    .padding(12)
                }

                // MARK: - Background Type

                GroupBox {
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Background", systemImage: "paintpalette.fill")
                            .font(.headline)

                        // Background Type Toggle
                        Picker("Type", selection: $viewModel.configuration.backgroundType) {
                            Text("Solid").tag(IconConfiguration.BackgroundType.solid)
                            Text("Gradient").tag(IconConfiguration.BackgroundType.gradient)
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(12)
                }

                // MARK: - Color Controls

                GroupBox {
                    VStack(alignment: .leading, spacing: 16) {
                        if viewModel.configuration.backgroundType == .solid {
                            // Solid Color Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Background Color")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                ColorPicker("Background Color", selection: $viewModel.configuration.primaryColor, supportsOpacity: false)
                                    .labelsHidden()
                            }
                        } else {
                            // Gradient Color Pickers
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Top Color")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)

                                    ColorPicker("Top Color", selection: $viewModel.configuration.primaryColor, supportsOpacity: false)
                                        .labelsHidden()
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Bottom Color")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)

                                    ColorPicker("Bottom Color", selection: $viewModel.configuration.secondaryColor, supportsOpacity: false)
                                        .labelsHidden()
                                }

                                Divider()

                                // Gradient Angle
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Gradient Angle")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                        Text("\(Int(viewModel.configuration.gradientAngle.degrees))°")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .monospacedDigit()
                                    }

                                    HStack(spacing: 12) {
                                        Slider(value: Binding(
                                            get: { viewModel.configuration.gradientAngle.degrees },
                                            set: { viewModel.configuration.gradientAngle = .degrees($0) }
                                        ), in: 0...360, step: 15)

                                        // Quick angle buttons
                                        VStack(spacing: 4) {
                                            HStack(spacing: 4) {
                                                AngleButton(angle: 0, label: "→", viewModel: viewModel)
                                                AngleButton(angle: 90, label: "↓", viewModel: viewModel)
                                            }
                                            HStack(spacing: 4) {
                                                AngleButton(angle: 270, label: "↑", viewModel: viewModel)
                                                AngleButton(angle: 180, label: "←", viewModel: viewModel)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(12)
                }

                // MARK: - Color Presets

                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Presets", systemImage: "swatchpalette.fill")
                            .font(.headline)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 12) {
                            ForEach(ColorPreset.allPresets, id: \.name) { preset in
                                PresetButton(preset: preset, viewModel: viewModel)
                            }
                        }
                    }
                    .padding(12)
                }

                // MARK: - Preview Style

                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Preview Style", systemImage: "app.fill")
                            .font(.headline)

                        Picker("Corner Radius", selection: $viewModel.configuration.cornerRadiusStyle) {
                            Text("Square").tag(IconConfiguration.CornerRadiusStyle.none)
                            Text("Rounded (iOS)").tag(IconConfiguration.CornerRadiusStyle.continuous)
                        }
                        .pickerStyle(.segmented)

                        Text("Note: Exported icons are always square. iOS applies its own corner radius.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(12)
                }
            }
            .padding(.top, 20)
            .padding(.leading, 50)  // Increased workaround for macOS clipping bug
            .padding(.trailing, 16)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Angle Button

private struct AngleButton: View {
    let angle: Double
    let label: String
    let viewModel: IconViewModel

    var body: some View {
        Button(action: {
            viewModel.configuration.gradientAngle = .degrees(angle)
        }) {
            Text(label)
                .font(.caption)
                .frame(width: 28, height: 28)
        }
        .buttonStyle(.bordered)
    }
}

// MARK: - Preset Button

private struct PresetButton: View {
    let preset: ColorPreset
    let viewModel: IconViewModel

    var body: some View {
        Button(action: {
            applyPreset()
        }) {
            VStack(spacing: 6) {
                // Preview
                ZStack {
                    if let gradient = preset.gradient {
                        LinearGradient(
                            colors: [gradient.top, gradient.bottom],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    } else {
                        preset.primaryColor
                    }

                    Image(systemName: "star.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(preset.symbolColor)
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                )

                // Label
                Text(preset.name)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }

    private func applyPreset() {
        viewModel.configuration.symbolColor = preset.symbolColor
        viewModel.configuration.primaryColor = preset.primaryColor

        if let gradient = preset.gradient {
            viewModel.configuration.backgroundType = .gradient
            viewModel.configuration.secondaryColor = gradient.bottom
            viewModel.configuration.gradientAngle = .degrees(180)
        } else {
            viewModel.configuration.backgroundType = .solid
        }
    }
}

// MARK: - Color Preset Model

struct ColorPreset {
    let name: String
    let primaryColor: Color
    let symbolColor: Color
    let gradient: GradientColors?

    struct GradientColors {
        let top: Color
        let bottom: Color
    }

    static let allPresets: [ColorPreset] = [
        // Gradients
        ColorPreset(
            name: "Orange",
            primaryColor: Color(red: 1.0, green: 149/255, blue: 0.0),
            symbolColor: .white,
            gradient: GradientColors(
                top: Color(red: 1.0, green: 149/255, blue: 0.0),
                bottom: Color(red: 1.0, green: 200/255, blue: 0.0)
            )
        ),
        ColorPreset(
            name: "Blue",
            primaryColor: Color(red: 0/255, green: 122/255, blue: 1.0),
            symbolColor: .white,
            gradient: GradientColors(
                top: Color(red: 0/255, green: 122/255, blue: 1.0),
                bottom: Color(red: 100/255, green: 200/255, blue: 1.0)
            )
        ),
        ColorPreset(
            name: "Purple",
            primaryColor: Color(red: 175/255, green: 82/255, blue: 222/255),
            symbolColor: .white,
            gradient: GradientColors(
                top: Color(red: 175/255, green: 82/255, blue: 222/255),
                bottom: Color(red: 236/255, green: 95/255, blue: 251/255)
            )
        ),
        ColorPreset(
            name: "Pink",
            primaryColor: Color(red: 1.0, green: 45/255, blue: 85/255),
            symbolColor: .white,
            gradient: GradientColors(
                top: Color(red: 1.0, green: 45/255, blue: 85/255),
                bottom: Color(red: 1.0, green: 149/255, blue: 0.0)
            )
        ),
        ColorPreset(
            name: "Green",
            primaryColor: Color(red: 52/255, green: 199/255, blue: 89/255),
            symbolColor: .white,
            gradient: GradientColors(
                top: Color(red: 52/255, green: 199/255, blue: 89/255),
                bottom: Color(red: 48/255, green: 209/255, blue: 88/255)
            )
        ),
        ColorPreset(
            name: "Teal",
            primaryColor: Color(red: 90/255, green: 200/255, blue: 250/255),
            symbolColor: .white,
            gradient: GradientColors(
                top: Color(red: 90/255, green: 200/255, blue: 250/255),
                bottom: Color(red: 100/255, green: 210/255, blue: 255/255)
            )
        ),

        // Solid Colors
        ColorPreset(
            name: "Red",
            primaryColor: Color(red: 1.0, green: 59/255, blue: 48/255),
            symbolColor: .white,
            gradient: nil
        ),
        ColorPreset(
            name: "Indigo",
            primaryColor: Color(red: 88/255, green: 86/255, blue: 214/255),
            symbolColor: .white,
            gradient: nil
        ),
        ColorPreset(
            name: "Yellow",
            primaryColor: Color(red: 1.0, green: 204/255, blue: 0.0),
            symbolColor: Color(red: 0.2, green: 0.2, blue: 0.2),
            gradient: nil
        ),
        ColorPreset(
            name: "Gray",
            primaryColor: Color(red: 142/255, green: 142/255, blue: 147/255),
            symbolColor: .white,
            gradient: nil
        ),
        ColorPreset(
            name: "Black",
            primaryColor: Color(red: 28/255, green: 28/255, blue: 30/255),
            symbolColor: .white,
            gradient: nil
        ),
        ColorPreset(
            name: "White",
            primaryColor: .white,
            symbolColor: Color(red: 0.2, green: 0.2, blue: 0.2),
            gradient: nil
        ),
    ]
}

// MARK: - Preview

#Preview {
    GradientEditorView(viewModel: IconViewModel())
        .frame(width: 320, height: 800)
}
