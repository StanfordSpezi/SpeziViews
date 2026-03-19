//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if canImport(PencilKit) && !os(macOS)
import PencilKit
import SwiftUI


/// The ``CanvasView`` provides a SwiftUI wrapper around the PencilKit `PKCanvasView`.
///
/// You can use the ``CanvasSizePreferenceKey`` `PreferenceKey` to get the current canvas size to e.g. determine the
/// current canvas size using the SwiftUI preference mechanisms.
///
/// ```swift
/// @State var drawing = PKDrawing()
///
/// var body: some View {
///     CanvasView(drawing: $drawing)
/// }
/// ```
///
/// By default, the view uses a black pen of width 1. You can customise this, via the `tool` parameter.
/// By passing in a `Binding<any PKTool>`, you can also allow the user to change the active tool.
///
/// ```swift
/// @State var drawing = PKDrawing()
/// @State var tool: any PKTool = PKInkingTool(.pen, color: .red, width: 1)
/// @State var showToolPicker = true
///
/// var body: some View {
///     CanvasView(
///         drawing: $drawing,
///         tool: $tool,
///         drawingPolicy: .anyInput,
///         showToolPicker: $showToolPicker
///     )
/// }
/// ```
@available(macOS, unavailable)
@available(watchOS, unavailable)
public struct CanvasView: View {
    /// The ``CanvasSizePreferenceKey`` enables outer views to get access to the current canvas size of the ``CanvasView``
    /// using the SwiftUI preference mechanisms.
    public struct CanvasSizePreferenceKey: PreferenceKey, Equatable {
        public static let defaultValue: CGSize = .zero
        
        public static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
            value = nextValue()
        }
    }
    
    private let drawingPolicy: PKCanvasViewDrawingPolicy
    @Binding private var drawing: PKDrawing
    @Binding private var tool: any PKTool
    @Binding private var isDrawing: Bool
    @Binding private var showToolPicker: Bool
    
    
    public var body: some View {
        GeometryReader { geometry in
            Impl(
                drawing: $drawing,
                isDrawing: $isDrawing,
                tool: $tool,
                drawingPolicy: drawingPolicy,
                showToolPicker: $showToolPicker
            )
            .accessibilityIdentifier("Canvas")
            .preference(key: CanvasSizePreferenceKey.self, value: geometry.size)
        }
    }
    
    /// Creates a new ``CanvasView`` providing a SwiftUI wrapper around the PencilKit `PKCanvasView`
    ///
    /// - parameter drawing: A `Binding` containing the current `PKDrawing`
    /// - parameter isDrawing: A `Binding` indicating if the user is currently drawing.
    ///     Note that this only allows you to observe the state; it does not allow you to prevent the user from drawing.
    ///     (Use SwiftUI's `disabled(_:)` modifier for that.)
    /// - parameter tool: The current tool used by the canvas.
    /// - parameter drawingPolicy: The drawing policy as defined by the PencilKit `PKCanvasViewDrawingPolicy`
    /// - parameter showToolPicker: A `Binding` determining if the toolbox is currently show or hidden.
    public init(
        drawing: Binding<PKDrawing>,
        tool: Binding<any PKTool>,
        drawingPolicy: PKCanvasViewDrawingPolicy = .anyInput,
        isDrawing: Binding<Bool> = .constant(false),
        showToolPicker: Binding<Bool> = .constant(true)
    ) {
        self.drawingPolicy = drawingPolicy
        self._drawing = drawing
        self._isDrawing = isDrawing
        self._tool = tool
        self._showToolPicker = showToolPicker
    }
    
    /// Creates a new ``CanvasView`` providing a SwiftUI wrapper around the PencilKit `PKCanvasView`
    ///
    /// - parameter drawing: A `Binding` containing the current `PKDrawing`
    /// - parameter isDrawing: A `Binding` indicating if the user is currently drawing.
    ///     Note that this only allows you to observe the state; it does not allow you to prevent the user from drawing.
    ///     (Use SwiftUI's `disabled(_:)` modifier for that.)
    /// - parameter tool: The current tool used by the canvas.
    /// - parameter drawingPolicy: The drawing policy as defined by the PencilKit `PKCanvasViewDrawingPolicy`
    public init(
        drawing: Binding<PKDrawing>,
        isDrawing: Binding<Bool> = .constant(false),
        tool: PKInkingTool = PKInkingTool(.pen, color: .label, width: 1),
        drawingPolicy: PKCanvasViewDrawingPolicy = .anyInput
    ) {
        self.init(
            drawing: drawing,
            tool: .constant(tool),
            drawingPolicy: drawingPolicy,
            isDrawing: isDrawing,
            // we're using a fixed tool, so there is no point in allowing the tool picker be shown.
            showToolPicker: .constant(false)
        )
    }
    
    
    @_documentation(visibility: internal)
    @available(*, deprecated, message: "Please switch to one of the new, correct initializers.")
    public init(
        drawing: Binding<PKDrawing> = .constant(PKDrawing()),
        isDrawing: Binding<Bool> = .constant(false),
        tool: PKInkingTool = PKInkingTool(.pen, color: .label, width: 1),
        drawingPolicy: PKCanvasViewDrawingPolicy = .anyInput,
        showToolPicker: Binding<Bool> = .constant(true)
    ) {
        self.init(
            drawing: drawing,
            tool: .constant(tool),
            drawingPolicy: drawingPolicy,
            isDrawing: isDrawing,
            showToolPicker: showToolPicker
        )
    }
}


extension CanvasView {
    private struct Impl: UIViewRepresentable {
        final class Coordinator: NSObject, PKCanvasViewDelegate, PKToolPickerObserver {
            let parent: Impl
            
            init(parent: Impl) {
                self.parent = parent
            }
            
            func canvasViewDidBeginUsingTool(_ pkCanvasView: PKCanvasView) {
                parent.isDrawing = true
            }
            
            func canvasViewDidEndUsingTool(_ pkCanvasView: PKCanvasView) {
                parent.isDrawing = false
            }
            
            func canvasViewDrawingDidChange(_ pkCanvasView: PKCanvasView) {
                let oldDrawing = parent.drawing
                let newDrawing = pkCanvasView.drawing
                guard oldDrawing != newDrawing && !(oldDrawing.isEmpty && newDrawing.isEmpty) else {
                    // empty drawings don't necessarily compare equal to each other (FB22283461)
                    return
                }
                parent.drawing = newDrawing
            }
            
            func toolPickerSelectedToolDidChange(_ toolPicker: PKToolPicker) {
                handleToolDidChange(toolPicker)
            }
            
            @available(iOS 18.0, visionOS 2.0, *)
            func toolPickerSelectedToolItemDidChange(_ toolPicker: PKToolPicker) {
                handleToolDidChange(toolPicker)
            }
            
            @MainActor
            private func handleToolDidChange(_ toolPicker: PKToolPicker) {
                if #available(iOS 26, visionOS 26, *) {
                    // we don't support custom items, so we should never run into a nil value here?
                    parent.tool = toolPicker.selectedToolItem.tool ?? toolPicker.selectedTool
                } else {
                    parent.tool = toolPicker.selectedTool
                }
            }
        }
        
        
        let drawingPolicy: PKCanvasViewDrawingPolicy
        @State private var toolPicker = PKToolPicker()
        
        @Binding private var drawing: PKDrawing
        @Binding private var tool: any PKTool
        @Binding private var isDrawing: Bool
        @Binding private var showToolPicker: Bool
        
        init(
            drawing: Binding<PKDrawing>,
            isDrawing: Binding<Bool>,
            tool: Binding<any PKTool>,
            drawingPolicy: PKCanvasViewDrawingPolicy,
            showToolPicker: Binding<Bool>
        ) {
            self._drawing = drawing
            self._isDrawing = isDrawing
            self._tool = tool
            self.drawingPolicy = drawingPolicy
            self._showToolPicker = showToolPicker
        }
                          
        
        func makeUIView(context: Context) -> PKCanvasView {
            let canvasView = PKCanvasView()
            canvasView.delegate = context.coordinator
            canvasView.backgroundColor = .clear
            canvasView.isOpaque = false
            toolPicker.addObserver(context.coordinator)
            return canvasView
        }
        
        func updateUIView(_ canvasView: PKCanvasView, context: Context) {
            if canvasView.drawing != drawing {
                canvasView.drawing = drawing
            }
            toolPicker.selectedTool = tool
            canvasView.drawingPolicy = drawingPolicy
            toolPicker.addObserver(canvasView)
            toolPicker.setVisible(showToolPicker, forFirstResponder: canvasView)
            if showToolPicker {
                canvasView.becomeFirstResponder()
            }
            if #available(iOS 18.0, visionOS 2.0, *) {
                canvasView.isDrawingEnabled = context.environment.isEnabled
            }
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(parent: self)
        }
    }
}


#if DEBUG
#Preview {
    @Previewable @State var drawing = PKDrawing()
    @Previewable @State var isDrawing = false
    @Previewable @State var tool: any PKTool = PKInkingTool(.pen, color: .red)
    
    VStack {
        VStack {
            LabeledContent("is drawing", value: isDrawing.description)
            LabeledContent("tool") {
                Text(String(describing: tool))
                    .font(.caption)
            }
        }
        .padding(.horizontal)
        Divider()
        CanvasView(
            drawing: $drawing,
            tool: $tool,
            isDrawing: $isDrawing
        )
    }
}

#endif
#endif
