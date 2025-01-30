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

#if os(macOS)
    @MainActor
    private var idealWidth: CGFloat {
        guard let width = NSApp.keyWindow?.contentView?.bounds.width else {
            return 500
        }
        return max(width - 100, 300)
    }

    @MainActor
    private var idealHeight: CGFloat {
        guard let height = NSApp.keyWindow?.contentView?.bounds.height else {
            return 400
        }
        return max(height - 50, 250)
    }
#endif


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
                    NavigationLink("Tiles") {
                        TileExample()
                    }
                    NavigationLink("SkeletonLoading") {
                        SkeletonLoadingExample()
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
#if os(macOS)
                    .frame(minWidth: idealWidth, minHeight: idealHeight)
#endif
            }
            .sheet(isPresented: $presentingSpeziPersonalInfo) {
                TestAppTestsView<SpeziPersonalInfoTests>(showCloseButton: true)
#if os(macOS)
                    .frame(minWidth: idealWidth, minHeight: idealHeight)
#endif
            }
            .sheet(isPresented: $presentingSpeziValidation) {
                TestAppTestsView<SpeziValidationTests>(showCloseButton: true)
#if os(macOS)
                    .frame(minWidth: idealWidth, minHeight: idealHeight)
#endif
            }
    }
}


#if DEBUG
#Preview {
    SpeziViewsTargetsTests()
}
#endif
