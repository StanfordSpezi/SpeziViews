#if os(iOS)

import SnapshotTesting
@testable import SpeziViews
import SwiftUI
import XCTest

/// Snapshot tests for `MarkdownView`.
@MainActor
final class MarkdownViewSnapshotTests: XCTestCase {

    func testMarkdownView() async {
        let markdownView = MarkdownView(markdown: Data("*Clean* Coding".utf8))

        let host = UIHostingController(rootView: markdownView)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = host
        window.makeKeyAndVisible()

        host.view.layoutIfNeeded()
        await Task.yield()                 // or: try? await Task.sleep(nanoseconds: 50_000_000)
        host.view.layoutIfNeeded()

        assertSnapshot(
            of: window,
            as: .image,
            named: "iphone-regular",
            record: true
        )
    }
}
#endif
