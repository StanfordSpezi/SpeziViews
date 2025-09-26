//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// Header view for Lists or Forms.
///  
/// A header view that can be used in List or Form views.
public struct ListHeader<Image: View, Title: View, Instructions: View>: View {
    private let image: Image
    private let title: Title
    private let instructions: Instructions


    @_documentation(visibility: internal)
    public var body: some View {
        VStack {
            VStack {
                image
                    .foregroundColor(.accentColor)
                    .symbolRenderingMode(.multicolor)
                    .font(.custom("XXL", size: 50, relativeTo: .title))
                    .accessibilityHidden(true)
                title
                    .accessibilityAddTraits(.isHeader)
                    .font(.title)
                    .bold()
                    .padding(.bottom, 4)
            }
                .accessibilityElement(children: .combine)
            instructions
                .padding([.leading, .trailing], 25)
        }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

    /// Create a new list header.
    /// - Parameters:
    ///   - image: The image view.
    ///   - title: The title view.
    public init(@ViewBuilder image: () -> Image, @ViewBuilder title: () -> Title) where Instructions == EmptyView {
        self.init(image: image, title: title) {
            EmptyView()
        }
    }
    
    /// Create a new list header.
    /// - Parameters:
    ///   - image: The image view.
    ///   - title: The title view.
    ///   - instructions: The instructions subheadline.
    public init(@ViewBuilder image: () -> Image, @ViewBuilder title: () -> Title, @ViewBuilder instructions: () -> Instructions) {
        self.image = image()
        self.title = title()
        self.instructions = instructions()
    }

    /// Create a new list header.
    /// - Parameters:
    ///   - systemImage: The name of the system symbol image.
    ///   - title: The title view.
    public init(systemImage: String, @ViewBuilder title: () -> Title) where Image == SwiftUI.Image, Instructions == EmptyView {
        // swiftlint:disable:next accessibility_label_for_image
        self.init(image: { SwiftUI.Image(systemName: systemImage) }, title: title) {
            EmptyView()
        }
    }

    /// Create a new list header.
    /// - Parameters:
    ///   - systemImage: The name of the system symbol image.
    ///   - title: The title view.
    ///   - instructions: The instructions subheadline.
    public init(systemImage: String, @ViewBuilder title: () -> Title, @ViewBuilder instructions: () -> Instructions) where Image == SwiftUI.Image {
        // swiftlint:disable:next accessibility_label_for_image
        self.init(image: { SwiftUI.Image(systemName: systemImage) }, title: title, instructions: instructions)
    }
}


#if DEBUG
#Preview {
    List {
        ListHeader(systemImage: "person.fill.badge.plus") {
            Text("Create a new Account", bundle: .module)
        } instructions: {
            Text("Please fill out the details below to create your new account.", bundle: .module)
        }
    }
}

#Preview {
    List {
        ListHeader(systemImage: "person.fill.badge.plus") {
            Text("Create a new Account", bundle: .module)
        }
    }
}
#endif
