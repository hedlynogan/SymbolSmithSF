//
//  ExportSettingsView.swift
//  SymbolSmithSF
//
//  Created by Claude Code on 2/13/26.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

/// Export options and button
struct ExportSettingsView: View {
    @Bindable var viewModel: IconViewModel

    @State private var exportMode: IconExporter.ExportMode = .singleIcon
    @State private var selectedPlatforms: Set<IconExporter.Platform> = [.iOS]
    @State private var isExporting = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccessAlert = false
    @State private var exportedPath = ""

    private let exporter = IconExporter()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            Text("Export")
                .font(.title2)
                .fontWeight(.semibold)

            // MARK: - Export Mode

            GroupBox {
                VStack(alignment: .leading, spacing: 16) {
                    Label("Export Mode", systemImage: "square.and.arrow.up.fill")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 12) {
                        // Single Icon (Xcode 15+)
                        Button(action: {
                            exportMode = .singleIcon
                        }) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: exportMode == .singleIcon ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(exportMode == .singleIcon ? .blue : .secondary)
                                    .font(.title3)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Single Icon (Recommended)")
                                        .font(.subheadline)
                                        .fontWeight(.medium)

                                    Text("One 1024×1024 image for Xcode 15+")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)

                        Divider()

                        // All Sizes (Legacy)
                        Button(action: {
                            exportMode = .allSizes
                        }) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: exportMode == .allSizes ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(exportMode == .allSizes ? .blue : .secondary)
                                    .font(.title3)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("All Sizes (Legacy)")
                                        .font(.subheadline)
                                        .fontWeight(.medium)

                                    Text("Complete set for older Xcode versions")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(12)
            }

            // MARK: - Platform Selection (only for all sizes mode)

            if exportMode == .allSizes {
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Platforms", systemImage: "apps.iphone")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 8) {
                            Toggle("iOS", isOn: Binding(
                                get: { selectedPlatforms.contains(.iOS) },
                                set: { isOn in
                                    if isOn {
                                        selectedPlatforms.insert(.iOS)
                                    } else {
                                        selectedPlatforms.remove(.iOS)
                                    }
                                }
                            ))

                            Toggle("macOS", isOn: Binding(
                                get: { selectedPlatforms.contains(.macOS) },
                                set: { isOn in
                                    if isOn {
                                        selectedPlatforms.insert(.macOS)
                                    } else {
                                        selectedPlatforms.remove(.macOS)
                                    }
                                }
                            ))
                        }
                    }
                    .padding(12)
                }
            }

            // MARK: - Export Buttons

            VStack(spacing: 12) {
                // Export AppIcon.appiconset
                Button(action: {
                    exportAppIconSet()
                }) {
                    Label("Export AppIcon.appiconset", systemImage: "folder.fill.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(isExporting || (exportMode == .allSizes && selectedPlatforms.isEmpty))

                // Export single PNG
                Button(action: {
                    exportSinglePNG()
                }) {
                    Label("Export 1024×1024 PNG", systemImage: "photo.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(isExporting)
            }

            if isExporting {
                ProgressView("Exporting...")
                    .frame(maxWidth: .infinity)
            }

            Spacer()
        }
        .padding()
        .alert("Export Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("Export Successful", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) { }
            Button("Show in Finder", action: showInFinder)
        } message: {
            Text("Icon exported to:\n\(exportedPath)")
        }
    }

    // MARK: - Export Methods

    private func exportAppIconSet() {
        let savePanel = NSSavePanel()
        savePanel.title = "Export AppIcon Set"
        savePanel.message = "Choose where to save AppIcon.appiconset"
        savePanel.nameFieldLabel = "Export As:"
        savePanel.nameFieldStringValue = "AppIcon.appiconset"
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false

        savePanel.begin { response in
            guard response == .OK, let url = savePanel.url else {
                return
            }

            Task { @MainActor in
                isExporting = true

                do {
                    // Remove .appiconset from the URL since exportAppIcon adds it
                    let destinationURL: URL
                    if url.lastPathComponent.hasSuffix(".appiconset") {
                        destinationURL = url.deletingLastPathComponent()
                    } else {
                        destinationURL = url
                    }

                    try await exporter.exportAppIcon(
                        configuration: viewModel.configuration,
                        mode: exportMode,
                        platforms: selectedPlatforms,
                        to: destinationURL
                    )

                    isExporting = false
                    exportedPath = destinationURL.appendingPathComponent("AppIcon.appiconset").path
                    showSuccessAlert = true

                } catch {
                    isExporting = false
                    errorMessage = "Export failed: \(error.localizedDescription)\n\nError: \(error)"
                    print("Export error: \(error)")
                    showError = true
                }
            }
        }
    }

    private func exportSinglePNG() {
        let savePanel = NSSavePanel()
        savePanel.title = "Export PNG"
        savePanel.message = "Choose where to save the icon"
        savePanel.nameFieldLabel = "Save As:"
        savePanel.nameFieldStringValue = "AppIcon-1024.png"
        savePanel.allowedContentTypes = [.png]
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false

        savePanel.begin { response in
            guard response == .OK, let url = savePanel.url else {
                return
            }

            Task { @MainActor in
                isExporting = true

                do {
                    try exporter.exportSinglePNG(
                        configuration: viewModel.configuration,
                        to: url
                    )

                    isExporting = false
                    exportedPath = url.path
                    showSuccessAlert = true

                } catch {
                    isExporting = false
                    errorMessage = "Export failed: \(error.localizedDescription)\n\nError: \(error)"
                    print("Export PNG error: \(error)")
                    showError = true
                }
            }
        }
    }

    private func showInFinder() {
        let url = URL(fileURLWithPath: exportedPath)
        NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: url.deletingLastPathComponent().path)
    }
}

// MARK: - Preview

#Preview {
    ExportSettingsView(viewModel: IconViewModel())
        .frame(width: 320, height: 600)
}
