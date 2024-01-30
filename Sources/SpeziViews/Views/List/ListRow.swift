//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


public struct ListRow<Label: View, Content: View>: View {
    private let label: Label
    private let content: Content


    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize
    @State private var alignment: Alignment?


    public var body: some View {
        HStack {
            DynamicHStack(verticalAlignment: .leading) {
                label
                    .foregroundColor(.primary)
                    .lineLimit(alignment == .horizontal ? 1 : nil)

                if alignment == .horizontal {
                    Spacer()
                }

                content
                    .lineLimit(alignment == .horizontal ? 1 : nil)
                    .layoutPriority(1)
                    .foregroundColor(.secondary)
            }

            if alignment == .vertical {
                Spacer()
            }
        }
            .accessibilityElement(children: .combine)
            .onPreferenceChange(Alignment.self) { value in
                alignment = value
            }
    }


    public init(verbatim label: String, @ViewBuilder content: () -> Content) where Label == Text {
        self.init(label, content: content)
    }

    @_disfavoredOverload
    public init(_ label: String, @ViewBuilder content: () -> Content) where Label == Text {
        self.init({ Text(verbatim: label) }, content: content)
    }

    public init(_ label: LocalizedStringResource, @ViewBuilder content: () -> Content) where Label == Text {
        self.init({ Text(label) }, content: content)
    }


    public init(@ViewBuilder _ label: () -> Label, @ViewBuilder content: () -> Content) {
        self.label = label()
        self.content = content()
    }
}


#if DEBUG
#Preview {
    List {
        ListRow(verbatim: "Hello") {
            Text(verbatim: "World")
        }

        HStack {
            ListRow(verbatim: "Device") {
                EmptyView()
            }
            ProgressView()
        }

        HStack {
            ListRow(verbatim: "Device") {
                Text(verbatim: "World")
            }
            ProgressView()
                .padding(.leading, 6)
        }

        HStack {
            ListRow(verbatim: "Long Device Name") {
                Text(verbatim: "Long Description")
            }
            ProgressView()
                .padding(.leading, 4)
        }
    }
}
#endif
