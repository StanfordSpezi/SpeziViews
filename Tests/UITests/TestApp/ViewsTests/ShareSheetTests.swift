//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import PDFKit
import SpeziViews
import SwiftUI


struct ShareSheetTests: View {
    @State private var itemsToShare: [ShareSheetInput] = []
    
    var body: some View {
        Form { // swiftlint:disable:this closure_body_length
            Section {
                Button("Share UIImage") {
                    guard let url = Bundle.main.url(forResource: "jellybeans_USC-SIPI", withExtension: "tiff"),
                          let image = UINSImage(contentsOfFile: url.path) else {
                        return
                    }
                    itemsToShare = [ShareSheetInput(image)]
                }
                Button("Share UIImage via URL") {
                    guard let url = Bundle.main.url(forResource: "jellybeans_USC-SIPI", withExtension: "tiff") else {
                        return
                    }
                    itemsToShare = [ShareSheetInput(url)]
                }
            }
            Section {
                Button("Share PDF") {
                    guard let url = Bundle.main.url(forResource: "pepsi-arnell-021109", withExtension: "pdf"),
                          let pdf = PDFDocument(url: url) else {
                        return
                    }
                    itemsToShare = [ShareSheetInput(pdf)]
                }
                Button("Share PDF via Data") {
                    guard let url = Bundle.main.url(forResource: "pepsi-arnell-021109", withExtension: "pdf"),
                          let pdf = PDFDocument(url: url),
                          let data = pdf.dataRepresentation() else {
                        return
                    }
                    itemsToShare = [ShareSheetInput(verbatim: data, id: \.self)]
                }
                Button("Share PDF via URL") {
                    guard let url = Bundle.main.url(forResource: "pepsi-arnell-021109", withExtension: "pdf") else {
                        return
                    }
                    itemsToShare = [ShareSheetInput(url)]
                }
            }
            Section {
                Button("Share Text") {
                    itemsToShare = [ShareSheetInput("Hello Spezi!")]
                }
            }
        }
        .shareSheet(items: $itemsToShare)
    }
}
