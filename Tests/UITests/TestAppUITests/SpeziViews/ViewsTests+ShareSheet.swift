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
    func testShareSheet() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        app.open(target: "SpeziViews")
        
        app.collectionViews.firstMatch.swipeUp() // out of the window on visionOS and iPadOS

        XCTAssert(app.buttons["Share Sheet"].waitForExistence(timeout: 2.0))
        app.buttons["Share Sheet"].tap()
        
        app.buttons["Share Text"].tap()
        app.assertShareSheetHeader(.init(title: "Hello Spezi!", filetype: nil))
        app.buttons["header.closeButton"].tap()
        
        app.buttons["Share TIFF UIImage via URL"].tap()
        app.assertShareSheetHeader(.init(title: "jellybeans_USC-SIPI", filetype: "TIFF Image"))
        app.buttons["header.closeButton"].tap()
        
        app.buttons["Share PNG UIImage via URL"].tap()
        app.assertShareSheetHeader(.init(title: "PM5544", filetype: "PNG Image"))
        app.buttons["header.closeButton"].tap()
        
        app.collectionViews.firstMatch.swipeUp() // out of the window on visionOS and iPadOS
        
        app.buttons["Share PDF"].tap()
        app.assertShareSheetHeader(.init(title: "spezi my beloved", filetype: "PDF Document"))
        app.buttons["header.closeButton"].tap()
        
        app.buttons["Share PDF via URL"].tap()
        app.assertShareSheetHeader(.init(title: "spezi my beloved", filetype: "PDF Document"))
        app.buttons["header.closeButton"].tap()
        
        app.buttons["Share 2 PDFs"].tap()
        app.assertShareSheetHeader(.init(title: "2 Documents"))
        app.buttons["header.closeButton"].tap()
    }
}


extension XCUIApplication {
    struct ExpectedShareSheetHeader {
        /// The expected subject/title of the share sheet. when sharing a file, this typically is either the filename, or the "title" of the file (eg: something for PDFs).
        let title: String
        /// The expected filetype, if applicable.
        ///
        /// This is in the second line of the share sheet's title, and typically takes a format like `PNG Image · 23 KB`.
        /// Since the file size isn't guaranteed to be the same across different platforms and environments, we don't check for that and instead only look for the file type.
        let filetype: String?
        
        init(title: String, filetype: String? = nil) {
            self.title = title
            self.filetype = filetype
        }
    }
    
    func assertShareSheetHeader(_ expected: ExpectedShareSheetHeader, file: StaticString = #filePath, line: UInt = #line) {
        let shareSheet = otherElements["ShareSheet.RemoteContainerView"]
        XCTAssert(shareSheet.waitForExistence(timeout: 5), file: file, line: line)
        XCTAssert(
            staticTexts[expected.title].waitForExistence(timeout: 1) || otherElements[expected.title].waitForExistence(timeout: 1),
            "Unable to find share sheet title '\(expected.title)'",
            file: file,
            line: line
        )
        if let filetype = expected.filetype {
            let predicate = NSPredicate(format: "label BEGINSWITH %@", filetype + " · ")
            XCTAssert(
                // swiftlint:disable:next line_length
                staticTexts.matching(predicate).element.waitForExistence(timeout: 1) || otherElements.matching(predicate).element.waitForExistence(timeout: 1),
                "Unable to find share sheet filetype '\(filetype)'",
                file: file,
                line: line
            )
        }
    }
}
