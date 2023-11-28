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
    case geometryReader = "Geometry Reader"
    case label = "Label"
    case lazyText = "Lazy Text"
    case markdownView = "Markdown View"
    case viewState = "View State"
    case viewStateMapper = "View State Mapper"
    case defaultErrorOnly = "Default Error Only"
    case defaultErrorDescription = "Default Error Description"
    case asyncButton = "Async Button"
    
    
    @ViewBuilder
    private var canvas: some View {
        CanvasTestView()
    }
    
    @ViewBuilder
    private var geometryReader: some View {
        GeometryReaderTestView()
    }
    
    @ViewBuilder
    private var label: some View {
        Label(
            "LABEL_TEXT",
            textAlignment: .justified,
            textColor: .blue
        )
            .border(.gray)
        Label(
            """
            This is a label ...
            An other text. This is longer and we can check if the justified text works as expected. This is a very long text.
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
    private var lazyText: some View {
        ScrollView {
            LazyText(
                verbatim: """
                This is a long text ...
                
                And some more lines ...
                
                And a third line ...
                """
            )
            LazyText("LAZY_TEXT")
        }
    }
    
    @ViewBuilder
    private var viewState: some View {
        ViewStateTestView()
    }

    @ViewBuilder
    private var defaultErrorOnly: some View {
        ViewStateTestView(testError: .init(errorDescription: "Some error occurred!"))
    }
    
    @ViewBuilder
    private var viewStateMapper: some View {
        ViewStateMapperTestView()
    }

    @ViewBuilder
    private var defaultErrorDescription: some View {
        DefaultErrorDescriptionTestView()
    }

    @ViewBuilder
    private var asyncButton: some View {
        AsyncButtonTestView()
    }
    

    func view(withNavigationPath path: Binding<NavigationPath>) -> some View {
        switch self {
        case .canvas:
            canvas
        case .geometryReader:
            geometryReader
        case .label:
            label
        case .lazyText:
            lazyText
        case .markdownView:
            markdownView
        case .viewState:
            viewState
        case .viewStateMapper:
            viewStateMapper
        case .defaultErrorOnly:
            defaultErrorOnly
        case .defaultErrorDescription:
            defaultErrorDescription
        case .asyncButton:
            asyncButton
        }
    }
}


#if DEBUG
#Preview {
    TestAppTestsView<SpeziViewsTests>()
}
#endif
