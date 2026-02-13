//
//  ContentView.swift
//  SymbolSmithSF
//
//  Created by Edward Hogan on 2/13/26.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = IconViewModel()

    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack(alignment: .top, spacing: 0) {
                // Left Panel - Symbol Picker (Feature 2)
                SymbolPickerView(viewModel: viewModel)
                    .frame(width: 340)
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                    .background(controlBackgroundColor)

                Divider()

                // Middle Panel - Background Editor (Feature 4)
                GradientEditorView(viewModel: viewModel)
                    .frame(width: 340)
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                    .background(controlBackgroundColor)

                Divider()

                // Right Panel - Live Preview (Feature 3)
                IconPreviewView(viewModel: viewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .background(textBackgroundColor)

                Divider()

                // Far Right Panel - Export Settings (Feature 5)
                ExportSettingsView(viewModel: viewModel)
                    .frame(width: 320)
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                    .background(controlBackgroundColor)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        #if os(macOS)
        .frame(minWidth: 1400, minHeight: 750)
        #endif
    }
    
    // MARK: - Cross-Platform Colors
    
    private var controlBackgroundColor: Color {
        #if os(macOS)
        Color(nsColor: .controlBackgroundColor)
        #else
        Color(.systemGroupedBackground)
        #endif
    }
    
    private var textBackgroundColor: Color {
        #if os(macOS)
        Color(nsColor: .textBackgroundColor)
        #else
        Color(.systemBackground)
        #endif
    }
}

#Preview {
    ContentView()
}
