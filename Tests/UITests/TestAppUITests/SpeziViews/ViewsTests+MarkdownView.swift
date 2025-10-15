//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Algorithms
import XCTest
import XCTestExtensions


extension ViewsTests {
    @MainActor
    func testSimpleMarkdownView() throws {
        let app = XCUIApplication()
        app.launch()

        app.open(target: "SpeziViews")

        XCTAssert(app.buttons["Markdown View (Simple)"].waitForExistence(timeout: 2))
        app.buttons["Markdown View (Simple)"].tap()
        
        XCTAssert(app.staticTexts["This is a markdown example."].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["This is a markdown example taking 2 seconds to load."].waitForExistence(timeout: 5))
    }
    
    
    @MainActor
    func testAdvancedMarkdownView() throws {
        let app = XCUIApplication()
        app.launch()
        app.open(target: "SpeziViews")

        XCTAssert(app.buttons["Markdown View (Advanced)"].waitForExistence(timeout: 2))
        app.buttons["Markdown View (Advanced)"].tap()
        
        XCTAssert(app.navigationBars.staticTexts["Welcome to the Spezi Ecosystem"].waitForExistence(timeout: 2))
        XCTAssert(app.navigationBars.staticTexts["Jun 22, 2025 at 5:41 AM"].waitForExistence(timeout: 2))
        
        func assertTextExists(_ text: String, line: UInt = #line) {
            XCTAssert(app.staticTexts[text].waitForExistence(timeout: 1), line: line)
        }
        
        assertTextExists("Welcome to the Spezi Ecosystem")
        assertTextExists("This article aims to provide you with a broad overview of Spezi.")
        XCTAssert(app.otherElements["ayooooooo"].waitForExistence(timeout: 2))
        assertTextExists("Our Modules")
        assertTextExists("Spezi is architected to be a highly modular system, allowing your application to ...")
        
        do {
            continueAfterFailure = true
            defer {
                continueAfterFailure = false
            }
            var xCoords: [CGFloat] = []
            let image = app.otherElements["ayooooooo"].images.firstMatch
            XCTAssert(image.exists)
            for _ in 0..<10 {
                xCoords.append(image.frame.center.x)
                sleep(for: .seconds(0.5))
            }
            XCTAssertGreaterThan(Set(xCoords).count, 2, "xCoords: \(xCoords)")
        }
        
        app.scrollViews.firstMatch.swipeUp()
        // we can check for Bean2 bc that's a non-inline image;
        // Bean1 is inline and as a result gets subsumed into the AttributedString, and is not represented in the accessibility tree.
        XCTAssert(app.images["Bean2"].exists)
    }
}


extension CGRect {
    var center: CGPoint {
        CGPoint(
            x: minX + 0.5 * width,
            y: minY + 0.5 * height
        )
    }
}

extension CGPoint {
    var shortDebugDescription: String {
        let formatStyle = FloatingPointFormatStyle<Double>.number.precision(.fractionLength(2))
        return "(x: \(x.formatted(formatStyle)); y: \(y.formatted(formatStyle))"
    }
}
