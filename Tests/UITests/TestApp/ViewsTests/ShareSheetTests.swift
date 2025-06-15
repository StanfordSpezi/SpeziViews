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
        Form {
            makeImageInputSection(imageName: "jellybeans_USC-SIPI", fileExtension: "tiff")
            makeImageInputSection(imageName: "PM5544", fileExtension: "png")
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
    
    @ViewBuilder
    private func makeImageInputSection(imageName: String, fileExtension: String) -> some View {
        Section {
            Button("Share \(fileExtension.uppercased()) UIImage") {
                guard let url = Bundle.main.url(forResource: imageName, withExtension: fileExtension),
                      let image = UINSImage(contentsOfFile: url.path) else {
                    return
                }
                itemsToShare = [ShareSheetInput(image)]
            }
            Button("Share \(fileExtension.uppercased()) UIImage via URL") {
                guard let url = Bundle.main.url(forResource: imageName, withExtension: fileExtension) else {
                    return
                }
                itemsToShare = [ShareSheetInput(url)]
            }
        }
    }
}
