//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// Communicate non-present information.
///
/// This view provides a unified style to communicate information that is not present yet.
/// You communicate to the user why no information is shown with a short descriptive title and elaborate
/// on the steps necessary to add information in a more descriptive caption text.
///
/// In the example of the contacts app you could display a "No Contacts" header with a caption "Contacts
/// you've added will appear here." when no contacts were added to the list yet.
/// The below code demonstrates how to do this with the `NoInformationText`.
///
/// ```swift
/// struct ContactsList: View {
///     private let contacts: [Contact]
///
///     var body: some View {
///         if contacts.isEmpty {
///             NoInformationText(header: "No Contacts", caption: "Contacts you've added will appear here.")
///         } else {
///             // ...
///         }
///     }
///
///     init(_ contacts: [Contact]) {
///         self.contacts = contacts
///     }
/// }
/// ```
public struct NoInformationText<Header: View, Caption: View>: View {
    private let header: Header
    private let caption: Caption

    public var body: some View {
        VStack {
            header
                .font(.title2)
                .bold()
                .accessibilityAddTraits(.isHeader)
            caption
                .padding([.leading, .trailing], 25)
                .foregroundColor(.secondary)
        }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

    // TODO: docs
    public init(header: LocalizedStringResource, caption: LocalizedStringResource) where Header == Text, Caption == Text {
        self.init {
            Text(header)
        } caption: {
            Text(header)
        }
    }

    // TODO: docs
    public init(@ViewBuilder header: () -> Header, @ViewBuilder caption: () -> Caption) {
        self.header = header()
        self.caption = caption()
    }
}


#if DEBUG
#Preview {
    NoInformationText {
        Text(verbatim: "No Information")
    } caption: {
        Text(verbatim: "Please add information to show some information.")
    }
}

#Preview {
    GeometryReader { proxy in
        List {
            NoInformationText {
                Text(verbatim: "No Information")
            } caption: {
                Text(verbatim: "Please add information to show some information.")
            }
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.clear)
                .frame(height: proxy.size.height - 100)
        }
    }
}
#endif
