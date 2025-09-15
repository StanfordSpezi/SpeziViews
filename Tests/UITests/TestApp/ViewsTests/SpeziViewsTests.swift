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
    case markdownViewSimple = "Markdown View (Simple)"
    case markdownViewAdvanced = "Markdown View (Advanced)"
    case viewState = "View State"
    case operationState = "Operation State"
    case viewStateMapper = "View State Mapper"
    case conditionalModifier = "Conditional Modifier"
    case defaultErrorOnly = "Default Error Only"
    case defaultErrorDescription = "Default Error Description"
    case button = "Buttons"
    case listRow = "List Row"
    case managedViewUpdate = "Managed View Update"
    case caseIterablePicker = "Picker"
    #if !os(tvOS)
    case shareSheet = "Share Sheet"
    #endif
    case dismissButton = "Dismiss Button"
    
    #if !os(macOS)
    @MainActor @ViewBuilder private var label: some View {
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
    
    @MainActor @ViewBuilder private var lazyText: some View {
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

    func view(withNavigationPath path: Binding<NavigationPath>) -> some View {  // swiftlint:disable:this cyclomatic_complexity
        switch self {
        #if canImport(PencilKit) && !os(macOS)
        case .canvas:
            CanvasTestView()
        #endif
        case .geometryReader:
            GeometryReaderTestView()
        #if !os(macOS)
        case .label:
            label
        #endif
        case .lazyText:
            lazyText
        case .markdownViewSimple:
            SimpleMarkdownViewTest()
        case .markdownViewAdvanced:
            AdvancedMarkdownViewTest()
        case .viewState:
            ViewStateTestView()
        case .operationState:
            OperationStateTestView()
        case .viewStateMapper:
            ViewStateMapperTestView()
        case .conditionalModifier:
            ConditionalModifierTestView()
        case .defaultErrorOnly:
            ViewStateTestView(testError: .init(errorDescription: "Some error occurred!"))
        case .defaultErrorDescription:
            DefaultErrorDescriptionTestView()
        case .button:
            ButtonTestView()
        case .listRow:
            List {
                ListRow(verbatim: "Hello") {
                    Text(verbatim: "World")
                }
            }
        case .managedViewUpdate:
            ManagedViewStateTests()
        case .caseIterablePicker:
            CaseIterablePickerTests()
        #if !os(tvOS)
        case .shareSheet:
            ShareSheetTests()
        #endif
        case .dismissButton:
            DismissButtonTestView()
        }
    }
}


#if DEBUG
#Preview {
    TestAppTestsView<SpeziViewsTests>()
}
#endif
