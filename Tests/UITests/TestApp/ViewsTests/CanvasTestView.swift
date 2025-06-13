//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if canImport(PencilKit) && !os(macOS)
import PencilKit
import SpeziFoundation
import SpeziViews
import SwiftUI


struct CanvasTestView: View {
    @State private var isDrawing = false
    @State private var showToolPicker = false
    @State private var drawing = PKDrawing()
    @State private var receivedSize: CGSize?
    @State private var enableDrawing = true
    @State private var values = AsyncStream.makeStream(of: CGSize.self)
    var didDrawAnything: Bool {
        !drawing.strokes.isEmpty
    }

    var body: some View {
        ZStack {
            VStack {
                Group {
                    Text("Did Draw Anything: \(didDrawAnything.description)")
                    if let receivedSize {
                        Text("Canvas Size: width \(receivedSize.width), height \(receivedSize.height)")
                    } else {
                        Text("Canvas Size: none")
                    }
                    Button("Show Tool Picker") {
                        showToolPicker.toggle()
                    }
                    HStack {
                        Button("Enable/Disable Canvas") {
                            enableDrawing.toggle()
                        }
                        Spacer()
                        Text(enableDrawing.description)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Enable/Disable Canvas, \(enableDrawing.description)")
                    Button("Clear Canvas") {
                        drawing.strokes.removeAll()
                    }
                }
                .padding(.horizontal)
                Divider()
                CanvasView(
                    drawing: $drawing,
                    isDrawing: $isDrawing,
                    tool: .init(.pencil, color: .red, width: 10),
                    drawingPolicy: .anyInput,
                    showToolPicker: $showToolPicker
                )
                .disabled(!enableDrawing)
            }
        }
            .navigationBarTitleDisplayMode(.inline)
            .onPreferenceChange(CanvasView.CanvasSizePreferenceKey.self) { size in
                if Thread.isMainThread {
                    MainActor.assumeIsolated {
                        self.receivedSize = size
                    }
                } else {
                    self.values.continuation.yield(size)
                }
            }
            .task {
                for await value in values.stream {
                    self.receivedSize = value
                }
                values = AsyncStream.makeStream()
            }
            .interactiveDismissDisabled()
    }
}


#if DEBUG
struct CanvasTestView_Previews: PreviewProvider {
    static var previews: some View {
        CanvasTestView()
    }
}
#endif
#endif
