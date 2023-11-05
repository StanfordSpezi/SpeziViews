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
            }
                .navigationTitle("Targets")
        }
            .sheet(isPresented: $presentingSpeziViews) {
                TestAppTestsView<SpeziViewsTests>()
            }
            .sheet(isPresented: $presentingSpeziPersonalInfo) {
                TestAppTestsView<SpeziPersonalInfoTests>()
            }
            .sheet(isPresented: $presentingSpeziValidation) {
                TestAppTestsView<SpeziValidationTests>()
            }
    }
}


#if DEBUG
#Preview {
    SpeziViewsTargetsTests()
}
#endif
