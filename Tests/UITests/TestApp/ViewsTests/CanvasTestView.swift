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
    @State var isDrawing = false
    @State var didDrawAnything = false
    @State var showToolPicker = false
    @State var drawing = PKDrawing()
    @State var receivedSize: CGSize?
    @State var enableDrawing = true

    @State private var values: (stream: AsyncStream<CGSize>, continuation: AsyncStream<CGSize>.Continuation) = AsyncStream.makeStream()

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
            .onChange(of: isDrawing) {
                if isDrawing {
                    didDrawAnything = true
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
