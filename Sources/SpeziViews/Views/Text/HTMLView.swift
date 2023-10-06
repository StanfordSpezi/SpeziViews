//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import WebKit

/// An``HTMLView`` allows the display of HTML in a web view including the addition of a header and footer view.
///
/// ```
/// @State var viewState: ViewState = .idle
///
/// HTMLView(
///     asyncHTML: {
///         // Load your HTML from a remote source or disk storage ...
///         try? await Task.sleep(for: .seconds(5))
///         return Data("This is an <strong>HTML example</strong> taking 5 seconds to load.".utf8)
///     },
///     state: $viewState
/// )
/// ```
private struct WebView: UIViewRepresentable {
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView
        
        @Binding private var state: ViewState
        
        
        init(_ parent: WebView, state: Binding<ViewState>) {
            self.parent = parent
            self._state = state
        }
        
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
            Task { @MainActor in
                state = .idle
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
            Task { @MainActor in
                state = .error(AnyLocalizedError(error: error))
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: Error) {
            Task { @MainActor in
                state = .error(AnyLocalizedError(error: error))
            }
        }
    }
    
    
    let htmlContent: String
    
    @Binding var state: ViewState

    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, state: $state)
    }
}


public struct HTMLView: View {
    private let asyncHTML: () async -> Data

    @State private var html: Data?
    @Binding private var state: ViewState


    private var htmlString: String? {
        guard let html else {
            return nil
        }
        return String(decoding: html, as: UTF8.self)
    }

    public var body: some View {
        VStack {
            if html == nil {
                ProgressView()
                    .padding()
            } else {
                if let htmlString {
                    WebView(htmlContent: htmlString, state: $state)
                }
            }
        }
            .task {
                state = .processing
                html = await asyncHTML()
            }
    }

    /// Creates an ``HTMLView`` that displays HTML that is loaded asynchronously.
    /// - Parameters:
    ///   - asyncHTML: The async closure to load the html as a utf8 representation.
    ///   - state: A `Binding` to observe the ``ViewState`` of the ``HTMLView``.
    public init(
        asyncHTML: @escaping () async -> Data,
        state: Binding<ViewState> = .constant(.processing)
    ) {
        self.asyncHTML = asyncHTML
        self._state = state
    }

    /// Creates an ``HTMLView`` that displays the HTML content.
    /// - Parameters:
    ///   - html: A `Data` instance containing the html as an utf8 representation.
    ///   - state: A `Binding` to observe the ``ViewState`` of the ``HTMLView``.
    public init(
        html: Data,
        state: Binding<ViewState> = .constant(.processing)
    ) {
        self.init(
            asyncHTML: { html },
            state: state
        )
    }
}
