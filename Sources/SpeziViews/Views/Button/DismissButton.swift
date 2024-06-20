//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// Circular Dismiss button.
public struct DismissButton: View {
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
#if os(visionOS) || os(tvOS) || os(macOS)
        Button("Dismiss", systemImage: "xmark") {
            dismiss()
        }
#else
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 10, weight: .bold, design: .rounded))
#if !os(watchOS)
                .foregroundStyle(.secondary)
#endif
                .background {
                    Circle()
#if os(iOS)
                        .fill(Color(uiColor: .secondarySystemBackground))
#elseif os(watchOS)
                        .fill(Color(uiColor: .darkGray))
#endif
                        .frame(width: 25, height: 25)
                }
                .frame(width: 27, height: 27) // make the tap-able button region slightly larger
        }
            .accessibilityLabel("Dismiss")
            .buttonStyle(.plain)
#endif
    }
}


#if DEBUG
#Preview {
#if os(macOS) // cannot preview sheets in macOS
    NavigationStack {
        Text(verbatim: "Hello World")
            .toolbar {
                DismissButton()
            }
    }
        .frame(width: 500, height: 350)
#else
    Text(verbatim: "")
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                Text(verbatim: "Hello World")
                    .toolbar {
                        DismissButton()
                    }
            }
            .frame(width: 200, height: 200)
            .presentationDetents([.medium])
            .presentationCornerRadius(25)
        }
#endif
}
#endif
