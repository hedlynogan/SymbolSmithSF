//
//  ExportSettingsView.swift
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
    #if !os(macOS)
    @State private var showDocumentPicker = false
    @State private var pendingExportURL: URL?
    @State private var pendingExportIsIconSet = true
    #endif

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
            #if os(macOS)
            Button("Show in Finder", action: showInFinder)
            #else
            Button("Open in Files", action: openInFiles)
            #endif
        } message: {
            Text("Icon exported to:\n\(exportedPath)")
        }
        #if !os(macOS)
        .sheet(isPresented: $showDocumentPicker) {
            if let url = pendingExportURL {
                DocumentExporterView(
                    sourceURL: url,
                    isIconSet: pendingExportIsIconSet,
                    onCompletion: { destinationURL in
                        showDocumentPicker = false
                        if let dest = destinationURL {
                            exportedPath = dest.path
                            showSuccessAlert = true
                        }
                        isExporting = false
                    },
                    onError: { error in
                        showDocumentPicker = false
                        errorMessage = "Export failed: \(error.localizedDescription)"
                        showError = true
                        isExporting = false
                    }
                )
            }
        }
        #endif
    }

    // MARK: - Export Methods

    private func exportAppIconSet() {
        #if os(macOS)
        let savePanel = NSSavePanel()
        savePanel.title = "Export AppIcon Set"
        savePanel.message = "Choose where to save AppIcon.appiconset"
        savePanel.nameFieldLabel = "Export As:"
        savePanel.nameFieldStringValue = "AppIcon.appiconset"
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false

        savePanel.begin { response in
            guard response == .OK, let url = savePanel.url else { return }

            Task { @MainActor in
                isExporting = true
                do {
                    let destinationURL = url.lastPathComponent.hasSuffix(".appiconset")
                        ? url.deletingLastPathComponent()
                        : url

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
                    errorMessage = "Export failed: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
        #else
        Task { @MainActor in
            isExporting = true
            do {
                let tempDir = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                try await exporter.exportAppIcon(
                    configuration: viewModel.configuration,
                    mode: exportMode,
                    platforms: selectedPlatforms,
                    to: tempDir
                )
                pendingExportURL = tempDir.appendingPathComponent("AppIcon.appiconset")
                pendingExportIsIconSet = true
                showDocumentPicker = true
            } catch {
                isExporting = false
                errorMessage = "Export failed: \(error.localizedDescription)"
                showError = true
            }
        }
        #endif
    }

    private func exportSinglePNG() {
        #if os(macOS)
        let savePanel = NSSavePanel()
        savePanel.title = "Export PNG"
        savePanel.message = "Choose where to save the icon"
        savePanel.nameFieldLabel = "Save As:"
        savePanel.nameFieldStringValue = "AppIcon-1024.png"
        savePanel.allowedContentTypes = [.png]
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false

        savePanel.begin { response in
            guard response == .OK, let url = savePanel.url else { return }

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
                    errorMessage = "Export failed: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
        #else
        Task { @MainActor in
            isExporting = true
            do {
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent("AppIcon-1024.png")
                try exporter.exportSinglePNG(
                    configuration: viewModel.configuration,
                    to: tempURL
                )
                pendingExportURL = tempURL
                pendingExportIsIconSet = false
                showDocumentPicker = true
            } catch {
                isExporting = false
                errorMessage = "Export failed: \(error.localizedDescription)"
                showError = true
            }
        }
        #endif
    }

    private func showInFinder() {
        #if os(macOS)
        let url = URL(fileURLWithPath: exportedPath)
        NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: url.deletingLastPathComponent().path)
        #endif
    }

    private func openInFiles() {
        #if !os(macOS)
        guard let url = URL(string: "shareddocuments://") else { return }
        UIApplication.shared.open(url)
        #endif
    }
}

// MARK: - iOS Document Exporter

#if !os(macOS)
/// Wraps UIDocumentPickerViewController for exporting files/folders on iOS
private struct DocumentExporterView: UIViewControllerRepresentable {
    let sourceURL: URL
    let isIconSet: Bool
    let onCompletion: (URL?) -> Void
    let onError: (Error) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onCompletion: onCompletion, onError: onError)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forExporting: [sourceURL], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onCompletion: (URL?) -> Void
        let onError: (Error) -> Void

        init(onCompletion: @escaping (URL?) -> Void, onError: @escaping (Error) -> Void) {
            self.onCompletion = onCompletion
            self.onError = onError
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            onCompletion(urls.first)
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            onCompletion(nil)
        }
    }
}
#endif

// MARK: - Preview

#Preview {
    ExportSettingsView(viewModel: IconViewModel())
        #if os(macOS)
        .frame(width: 320, height: 600)
        #endif
}
