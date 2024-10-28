//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct TileExample: View {
    @State private var alignment: HorizontalAlignment = .leading
    @State private var photoTime = false
    var body: some View {
        List {
            SimpleTile(alignment: alignment) {
                TileHeader(alignment: alignment) {
                    Image(systemName: "book.pages.fill")
                        .foregroundStyle(.teal)
                        .font(.custom("Task Icon", size: 30, relativeTo: .headline))
                        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                        .accessibilityHidden(true)
                } title: {
                    Text("Clean Code")
                } subheadline: {
                    Text("by Robert C. Martin")
                }
            } body: {
                Text("A book by Robert C. Martin")
            } footer: {
                Button {
                } label: {
                    Text("Buy")
                        .frame(maxWidth: .infinity, minHeight: 30)
                }
                .buttonStyle(.borderedProminent)
            }

            if !photoTime {
                Section {
                    Picker("Alignment", selection: $alignment) {
                        Text("Leading").tag(HorizontalAlignment.leading)
                        Text("Center").tag(HorizontalAlignment.center)
                        Text("Trailing").tag(HorizontalAlignment.trailing)
                    }
                }
            }
        }
            .navigationTitle("Recommendations")
            .navigationBarBackButtonHidden(photoTime)
            .onChange(of: alignment) {
                photoTime = true
                Task {
                    try? await Task.sleep(for: .seconds(5))
                    photoTime = false
                }
            }
    }
}


extension HorizontalAlignment: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.key)
    }
}


#if DEBUG
#Preview {
    TileExample()
}
#endif
