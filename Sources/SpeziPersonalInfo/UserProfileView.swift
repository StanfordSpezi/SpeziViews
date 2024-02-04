//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// A ``UserProfileView`` allows you to display a user image and name in a circular profile view.
public struct UserProfileView: View {
    private let name: PersonNameComponents
    private let imageLoader: () async -> Image?
    
    @State private var image: Image?

    @Environment(\.colorScheme)
    private var colorScheme

    private var systemBackgroundWhite: Color {
        #if os(macOS)
        return Color(nsColor: .windowBackgroundColor)
        #elseif os(watchOS) || os(tvOS)
        return Color(uiColor: .gray)
        #else
        return Color(uiColor: .systemBackground)
        #endif
    }

    private var letterCircleColor: Color {
        #if os(macOS)
        return .gray
        #elseif os(watchOS) || os(tvOS)
        return Color(uiColor: .darkGray)
        #else
        return Color(uiColor: .systemGray2)
        #endif
    }


    public var body: some View {
        GeometryReader { context in
            ZStack {
                if let image {
                    Circle()
                        .foregroundColor(systemBackgroundWhite)
                    image.resizable()
                        .clipShape(Circle())
                } else {
                    Circle()
                        .foregroundColor(letterCircleColor)
                    Text(name.formatted(.name(style: .abbreviated)))
                        .foregroundColor(colorScheme == .dark ? .secondary : systemBackgroundWhite)
                        .font(
                            .system(
                                size: min(context.size.height, context.size.width) * 0.45,
                                weight: .medium,
                                design: .rounded
                            )
                        )
                }
            }.frame(
                width: min(context.size.height, context.size.width),
                height: min(context.size.height, context.size.width)
            )
        }
            .aspectRatio(1, contentMode: .fit)
            .contentShape(Circle())
            .task {
                self.image = await imageLoader()
            }
    }
    
    
    /// Creates a new instance with a name and a possible image provided by an async closure.
    /// - Parameters:
    ///   - name: The name that should be displayed and transformed to its initials.
    ///   - imageLoader: An optional closure delivering an image that can be displayed instead of the name initials.
    public init(name: PersonNameComponents, imageLoader: @escaping () async -> Image? = { nil }) {
        self.name = name
        self.imageLoader = imageLoader
    }
}


#if DEBUG
#Preview {
    UserProfileView(
        name: PersonNameComponents(givenName: "Paul", familyName: "Schmiedmayer")
    )
        .frame(width: 100, height: 100)
        .padding()
}

#Preview {
    UserProfileView(
        name: PersonNameComponents(
            namePrefix: "Prof.",
            givenName: "Oliver",
            middleName: "Oppers",
            familyName: "Aalami"
        )
    )
        .frame(width: 100, height: 100)
        .padding()
        .preferredColorScheme(.dark)
}

#Preview {
    UserProfileView(
        name: PersonNameComponents(givenName: "Vishnu", familyName: "Ravi"),
        imageLoader: {
            try? await Task.sleep(for: .seconds(2))
            return Image(systemName: "person.crop.circle")
        }
    )
        .frame(width: 50, height: 100)
        .padding()
}
#endif
