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
    #if canImport(PencilKit) && !os(macOS)
    case canvas = "Canvas"
    #endif
    case geometryReader = "Geometry Reader"
    #if !os(macOS)
    case label = "Label"
    #endif
    case lazyText = "Lazy Text"
    case markdownView = "Markdown View"
    case viewState = "View State"
    case operationState = "Operation State"
    case viewStateMapper = "View State Mapper"
    case conditionalModifier = "Conditional Modifier"
    case defaultErrorOnly = "Default Error Only"
    case defaultErrorDescription = "Default Error Description"
    case asyncButton = "Async Button"
    case listRow = "List Row"
    
    
    #if canImport(PencilKit) && !os(macOS)
    @ViewBuilder
    private var canvas: some View {
        CanvasTestView()
    }
    #endif

    @ViewBuilder
    private var geometryReader: some View {
        GeometryReaderTestView()
    }
    
    #if !os(macOS)
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
    #endif

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
    private var operationState: some View {
        OperationStateTestView()
    }
    
    @ViewBuilder
    private var viewStateMapper: some View {
        ViewStateMapperTestView()
    }
    
    @ViewBuilder
    private var conditionalModifier: some View {
        ConditionalModifierTestView()
    }

    @ViewBuilder
    private var defaultErrorOnly: some View {
        ViewStateTestView(testError: .init(errorDescription: "Some error occurred!"))
    }

    @ViewBuilder
    private var defaultErrorDescription: some View {
        DefaultErrorDescriptionTestView()
    }

    @ViewBuilder
    private var asyncButton: some View {
        AsyncButtonTestView()
    }

    @MainActor
    @ViewBuilder
    private var listRow: some View {
        List {
            ListRow(verbatim: "Hello") {
                Text(verbatim: "World")
            }
        }
    }

    func view(withNavigationPath path: Binding<NavigationPath>) -> some View {  // swiftlint:disable:this cyclomatic_complexity
        switch self {
        #if canImport(PencilKit) && !os(macOS)
        case .canvas:
            canvas
        #endif
        case .geometryReader:
            geometryReader
        #if !os(macOS)
        case .label:
            label
        #endif
        case .lazyText:
            lazyText
        case .markdownView:
            markdownView
        case .viewState:
            viewState
        case .operationState:
            operationState
        case .viewStateMapper:
            viewStateMapper
        case .conditionalModifier:
            conditionalModifier
        case .defaultErrorOnly:
            defaultErrorOnly
        case .defaultErrorDescription:
            defaultErrorDescription
        case .asyncButton:
            asyncButton
        case .listRow:
            listRow
        }
    }
}


#if DEBUG
#Preview {
    TestAppTestsView<SpeziViewsTests>()
}
#endif
