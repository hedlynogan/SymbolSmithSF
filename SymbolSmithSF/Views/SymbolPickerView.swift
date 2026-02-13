//
//  SymbolPickerView.swift
//  SymbolSmithSF
//
//  Created by Claude Code on 2/13/26.
//

import SwiftUI

/// SF Symbol search and selection view
struct SymbolPickerView: View {
    @Bindable var viewModel: IconViewModel

    @State private var searchText = ""
    @State private var isValidSymbol = true

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                Text("SF Symbol")
                    .font(.headline)

            // Search/Input Field
            VStack(alignment: .leading, spacing: 8) {
                TextField("Enter SF Symbol name", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: searchText) { _, newValue in
                        validateAndUpdateSymbol(newValue)
                    }

                if !isValidSymbol && !searchText.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("⚠️ Symbol '\(searchText)' not found")
                            .font(.caption)
                            .foregroundStyle(.red)
                        Text("Tip: Use the SF Symbols app to find valid names, or search below")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                // Current Symbol Display
                if isValidSymbol && !viewModel.configuration.symbolName.isEmpty {
                    HStack {
                        Spacer()
                        Image(systemName: viewModel.configuration.symbolName)
                            .font(.system(size: 64))
                            .foregroundStyle(viewModel.configuration.symbolColor)
                        Spacer()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }

            // Rendering Mode Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Rendering Mode")
                    .font(.subheadline)

                Picker("Rendering Mode", selection: $viewModel.configuration.renderingMode) {
                    ForEach(IconConfiguration.SymbolRenderingMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.radioGroup)
                .labelsHidden()
            }

            Divider()

            // Symbol Grid
            VStack(alignment: .leading, spacing: 8) {
                Text("Common Symbols")
                    .font(.subheadline)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 12) {
                    ForEach(displayedSymbols, id: \.self) { symbol in
                        SymbolButton(symbol: symbol, isSelected: symbol == viewModel.configuration.symbolName) {
                            selectSymbol(symbol)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            }
            .padding(.top, 20)
            .padding(.leading, 50)  // Increased workaround for macOS clipping bug
            .padding(.trailing, 20)  // Increased to prevent right-side clipping
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            searchText = viewModel.configuration.symbolName
        }
    }

    // MARK: - Computed Properties

    /// Symbols to display: recent symbols + common symbols, filtered by search if present
    private var displayedSymbols: [String] {
        let allSymbols = Array(Set(viewModel.recentSymbols + viewModel.commonSymbols))

        if searchText.isEmpty {
            return allSymbols
        } else {
            return allSymbols.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    // MARK: - Methods

    private func validateAndUpdateSymbol(_ name: String) {
        guard !name.isEmpty else {
            isValidSymbol = true
            return
        }

        isValidSymbol = viewModel.isValidSymbol(name)

        if isValidSymbol {
            viewModel.configuration.symbolName = name
            viewModel.addToRecent(name)
        }
    }

    private func selectSymbol(_ symbol: String) {
        searchText = symbol
        viewModel.configuration.symbolName = symbol
        viewModel.addToRecent(symbol)
        isValidSymbol = true
    }
}

// MARK: - Symbol Button

private struct SymbolButton: View {
    let symbol: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.system(size: 24))
                    .foregroundStyle(isSelected ? .white : .primary)
                    .frame(width: 50, height: 50)
            }
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.accentColor : Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    SymbolPickerView(viewModel: IconViewModel())
        .frame(width: 300)
}
