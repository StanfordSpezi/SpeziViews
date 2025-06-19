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
    @State private var itemToShare: ShareSheetInput?
    @State private var itemsToShare: [ShareSheetInput] = []
    
    var body: some View {
        Form {
            Section {
                Button("Share Text") {
                    itemToShare = ShareSheetInput("Hello Spezi!")
                }
            }
            makeImageInputSection(imageName: "jellybeans_USC-SIPI", fileExtension: "tiff")
            makeImageInputSection(imageName: "PM5544", fileExtension: "png")
            Section {
                let url = Bundle.main.url(forResource: "spezi my beloved", withExtension: "pdf")! // swiftlint:disable:this force_unwrapping
                Button("Share PDF") {
                    guard let pdf = PDFDocument(url: url) else {
                        return
                    }
                    itemToShare = ShareSheetInput(pdf)
                }
                Button("Share PDF via Data") {
                    guard let pdf = PDFDocument(url: url),
                          let data = pdf.dataRepresentation() else {
                        return
                    }
                    itemToShare = ShareSheetInput(verbatim: data, id: \.self)
                }
                Button("Share PDF via URL") {
                    itemToShare = ShareSheetInput(url)
                }
                Button("Share 2 PDFs") {
                    itemsToShare = [
                        ShareSheetInput(url),
                        ShareSheetInput(url)
                    ]
                }
            }
        }
        .shareSheet(item: $itemToShare)
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
                itemToShare = ShareSheetInput(image)
            }
            Button("Share \(fileExtension.uppercased()) UIImage via URL") {
                guard let url = Bundle.main.url(forResource: imageName, withExtension: fileExtension) else {
                    return
                }
                itemToShare = ShareSheetInput(url)
            }
        }
    }
}
