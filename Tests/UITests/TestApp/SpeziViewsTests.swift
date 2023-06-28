//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI
import XCTestApp


enum SpeziViewsTests: String, TestAppTests {
    case canvas = "Canvas"
    case nameFields = "Name Fields"
    case userProfile = "User Profile"
    case geometryReader = "Geometry Reader"
    case label = "Label"
    case lazyText = "Lazy Text"
    case markdownView = "Markdown View"
    case htmlView = "HTML View"
    case viewState = "View State"
    case defaultErrorOnly = "Default Error Only"
    case defaultErrorDescription = "Default Error Description"
    
    
    @ViewBuilder
    private var canvas: some View {
        CanvasTestView()
    }
    
    @ViewBuilder
    private var nameFields: some View {
        NameFieldsTestView()
    }
    
    @ViewBuilder
    private var userProfile: some View {
        UserProfileView(
            name: PersonNameComponents(givenName: "Paul", familyName: "Schmiedmayer")
        )
            .frame(width: 100)
        UserProfileView(
            name: PersonNameComponents(givenName: "Leland", familyName: "Stanford"),
            imageLoader: {
                try? await Task.sleep(for: .seconds(1))
                return Image(systemName: "person.crop.artframe")
            }
        )
            .frame(width: 200)
    }
    
    @ViewBuilder
    private var geometryReader: some View {
        GeometryReaderTestView()
    }
    
    @ViewBuilder
    private var label: some View {
        Label(
            """
            This is a label ...
            An other text. This is longer and we can check if the justified text works as epxected. This is a very long text.
            """,
            textAlignment: .justified,
            textColor: .blue
        )
            .border(.gray)
        Label(
            """
            This is a label ...
            An other text. This is longer and we can check if the justified text works as epxected. This is a very long text.
            """,
            textAlignment: .right,
            textColor: .red
        )
            .border(.red)
    }
    
    @ViewBuilder
    private var markdownView: some View {
        MarkdownViewTestView()
    }

    @ViewBuilder
    private var htmlView: some View {
        HTMLViewTestView()
    }
    
    @ViewBuilder
    private var lazyText: some View {
        ScrollView {
            LazyText(
                text: """
                This is a long text ...
                
                And some more lines ...
                
                And a third line ...
                """
            )
        }
    }
    
    @ViewBuilder
    private var viewState: some View {
        ViewStateTestView()
    }

    @ViewBuilder
    private var defaultErrorOnly: some View {
        ViewStateTestView(testError: .init(errorDescription: "Some error occurred!"));
    }

    @ViewBuilder
    private var defaultErrorDescription: some View {
        DefaultErrorDescriptionTestView()
    }
    
    
    func view(withNavigationPath path: Binding<NavigationPath>) -> some View {
        switch self {
        case .canvas:
            canvas
        case .nameFields:
            nameFields
        case .userProfile:
            userProfile
        case .geometryReader:
            geometryReader
        case .label:
            label
        case .lazyText:
            lazyText
        case .markdownView:
            markdownView
        case .htmlView:
            htmlView
        case .viewState:
            viewState
        case .defaultErrorOnly:
            defaultErrorOnly
        case .defaultErrorDescription:
            defaultErrorDescription
        }
    }
}

#if DEBUG
struct SpeziViewsTests_Previews: PreviewProvider {
    static var previews: some View {
        TestAppTestsView<SpeziViewsTests>()
    }
}
#endif
