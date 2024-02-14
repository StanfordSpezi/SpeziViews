//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import XCTestApp


struct SpeziViewsTargetsTests: View {
    @State var presentingSpeziViews = false
    @State var presentingSpeziPersonalInfo = false
    @State var presentingSpeziValidation = false


    var body: some View {
        NavigationStack {
            List {
                Button("SpeziViews") {
                    presentingSpeziViews = true
                }
                Button("SpeziPersonalInfo") {
                    presentingSpeziPersonalInfo = true
                }
                Button("SpeziValidation") {
                    presentingSpeziValidation = true
                }
                #if canImport(PencilKit) && !os(macOS)
                NavigationLink("CanvasTest") {
                    CanvasTestView()
                }
                #endif

                Section {
                    NavigationLink("ViewState") {
                        ViewStateExample()
                    }
                    NavigationLink("NameFields") {
                        NameFieldsExample()
                    }
                    NavigationLink("Validation TextField") {
                        ValidationExample()
                    }
                } header: {
                    Text("Examples")
                } footer: {
                    Text("Example Views to take screenshots for SpeziViews")
                }
            }
                .navigationTitle("Targets")
        }
            .sheet(isPresented: $presentingSpeziViews) {
                TestAppTestsView<SpeziViewsTests>(showCloseButton: true)
            }
            .sheet(isPresented: $presentingSpeziPersonalInfo) {
                TestAppTestsView<SpeziPersonalInfoTests>(showCloseButton: true)
            }
            .sheet(isPresented: $presentingSpeziValidation) {
                TestAppTestsView<SpeziValidationTests>(showCloseButton: true)
            }
    }
}


#if DEBUG
#Preview {
    SpeziViewsTargetsTests()
}
#endif
