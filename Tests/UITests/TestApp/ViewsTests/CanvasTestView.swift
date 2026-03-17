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
    @State private var tool: any PKTool = PKInkingTool(.pen, color: .red, width: 10)
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
                    LabeledContent("Did Draw Anything", value: didDrawAnything.description)
                    LabeledContent("Canvas Size", value: receivedSize?.debugDescription ?? "none")
                    LabeledContent("Tool", value: String(describing: tool))
                        .accessibilityIdentifier("ToolInfo")
                        .accessibilityValue(String(describing: tool))
                    Divider()
                    actionButtons
                    Divider()
                    HStack {
                        Button("Enable/Disable Canvas") {
                            enableDrawing.toggle()
                        }
                        Spacer()
                        Text(enableDrawing.description)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Enable/Disable Canvas, \(enableDrawing.description)")
                }
                .padding(.horizontal)
                Divider()
                CanvasView(
                    drawing: $drawing,
                    tool: $tool,
                    drawingPolicy: .anyInput,
                    isDrawing: $isDrawing,
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
    
    @ViewBuilder private var actionButtons: some View {
        HStack {
            Button("Random Tool") {
                tool = [
                    PKInkingTool(.crayon, color: .red),
                    PKInkingTool(.fountainPen, color: .orange),
                    PKInkingTool(.watercolor, color: .green),
                    PKEraserTool(.bitmap),
                    PKLassoTool()
                ].randomElement()! // swiftlint:disable:this force_unwrapping
            }
            Spacer()
            Button("Toggle Tool Picker") {
                showToolPicker.toggle()
            }
            Spacer()
            Button("Clear") {
                drawing.strokes.removeAll()
            }
        }
    }
}


#if DEBUG
#Preview {
    CanvasTestView()
}
#endif
#endif
