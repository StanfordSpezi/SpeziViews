//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


extension ViewsTests {
    @MainActor
    func testShareSheet() async throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        app.open(target: "SpeziViews")
        
        app.collectionViews.firstMatch.swipeUp() // out of the window on visionOS and iPadOS

        XCTAssert(app.buttons["Share Sheet"].waitForExistence(timeout: 2.0))
        app.buttons["Share Sheet"].tap()
        
        app.buttons["Share Text"].tap()
        app.assertShareSheetTextElementExists("Hello Spezi!")
        app.buttons["header.closeButton"].tap()
        
        app.buttons["Share TIFF UIImage via URL"].tap()
        app.assertShareSheetTextElementExists("jellybeans_USC-SIPI")
        app.assertShareSheetTextElementExists("TIFF Image · 197 KB")
        app.buttons["header.closeButton"].tap()
        
        app.buttons["Share PNG UIImage via URL"].tap()
        app.assertShareSheetTextElementExists("PM5544")
        app.assertShareSheetTextElementExists("PNG Image · 21 KB")
        app.buttons["header.closeButton"].tap()
    }
}


extension XCUIApplication {
    fileprivate func assertShareSheetTextElementExists(_ text: String, file: StaticString = #filePath, line: UInt = #line) {
        let exists = self.staticTexts[text].waitForExistence(timeout: 1) || self.otherElements[text].waitForExistence(timeout: 1)
        XCTAssert(exists, file: file, line: line)
    }
}
