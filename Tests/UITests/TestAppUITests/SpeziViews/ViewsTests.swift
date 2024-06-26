//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


final class ViewsTests: XCTestCase {
    @MainActor
    override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false

        let app = XCUIApplication()
        app.launch()

        app.open(target: "SpeziViews")
    }

    @MainActor
    func testCanvas() throws {
#if !canImport(PencilKit) || os(macOS)
        throw XCTSkip("PencilKit is not supported on this platform")
#endif
        
#if targetEnvironment(simulator) && (arch(i386) || arch(x86_64))
        throw XCTSkip("PKCanvas view-related tests are currently skipped on Intel-based iOS simulators due to a metal bug on the simulator.")
#endif

        let app = XCUIApplication()


        XCTAssert(app.collectionViews.buttons["Canvas"].waitForExistence(timeout: 2))
        app.collectionViews.buttons["Canvas"].tap()

        XCTAssert(app.staticTexts["Did Draw Anything: false"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.images["palette_tool_pencil_base"].waitForExistence(timeout: 2))

        let canvasView = app.scrollViews.firstMatch
        canvasView.swipeRight()
        canvasView.swipeDown()
        
        XCTAssert(app.staticTexts["Did Draw Anything: true"].waitForExistence(timeout: 2))
        
        XCTAssert(app.buttons["Show Tool Picker"].waitForExistence(timeout: 2))
        app.buttons["Show Tool Picker"].tap()

        #if os(visionOS)
        // visionOS doesn't have the image anymore, this should be enough to check
        XCTAssert(app.scrollViews.otherElements["Pen, black"].waitForExistence(timeout: 2.0))
        #else
        XCTAssert(app.images["palette_tool_pencil_base"].waitForExistence(timeout: 10))
        #endif
        canvasView.swipeLeft()

        sleep(1)
        app.buttons["Show Tool Picker"].tap()
        
        #if os(visionOS)
        return // currently the pencilKit toolbar cannot be hidden anymore
        #endif

        sleep(15) // waitForExistence will otherwise return immediately
        XCTAssertFalse(app.images["palette_tool_pencil_base"].waitForExistence(timeout: 10))
        canvasView.swipeUp()
    }
    
    @MainActor
    func testGeometryReader() throws {
        let app = XCUIApplication()
        
        XCTAssert(app.buttons["Geometry Reader"].waitForExistence(timeout: 2))
        app.buttons["Geometry Reader"].tap()
        
        XCTAssert(app.staticTexts["300.000000"].exists)
        XCTAssert(app.staticTexts["200.000000"].exists)
    }
    
    @MainActor
    func testLabel() throws {
        #if os(macOS)
        throw XCTSkip("Label is not supported on non-UIKit platforms")
        #endif
        let app = XCUIApplication()
        
        XCTAssert(app.collectionViews.buttons["Label"].waitForExistence(timeout: 2))
        app.collectionViews.buttons["Label"].tap()

        sleep(2)
        
        // The string value needs to be searched for in the UI.
        // swiftlint:disable:next line_length
        let text = "This is a label ... An other text. This is longer and we can check if the justified text works as expected. This is a very long text."
        XCTAssertEqual(app.staticTexts.allElementsBoundByIndex.filter { $0.label.replacingOccurrences(of: "\n", with: " ").contains(text) }.count, 2)
    }
    
    @MainActor
    func testLazyText() throws {
        let app = XCUIApplication()
        
        XCTAssert(app.buttons["Lazy Text"].waitForExistence(timeout: 2))
        app.buttons["Lazy Text"].tap()
        
        XCTAssert(app.staticTexts["This is a long text ..."].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["And some more lines ..."].exists)
        XCTAssert(app.staticTexts["And a third line ..."].exists)
        XCTAssert(app.staticTexts["An other lazy text ..."].exists)
    }
    
    @MainActor
    func testMarkdownView() throws {
        let app = XCUIApplication()
        
        XCTAssert(app.buttons["Markdown View"].waitForExistence(timeout: 2))
        app.buttons["Markdown View"].tap()
        
        XCTAssert(app.staticTexts["This is a markdown example."].waitForExistence(timeout: 2))

        sleep(6)
        
        XCTAssert(app.staticTexts["This is a markdown example taking 5 seconds to load."].exists)
    }

    @MainActor
    func testAsyncButtonView() throws {
        let app = XCUIApplication()

        app.buttons["View State"].swipeUp() // on visionOS the AsyncButton is out of the frame due to the window size

        XCTAssert(app.buttons["Async Button"].waitForExistence(timeout: 2))
        app.buttons["Async Button"].tap()

        XCTAssert(app.buttons["Hello World"].waitForExistence(timeout: 2))
        app.buttons["Hello World"].tap()

        XCTAssert(app.staticTexts["Action executed"].waitForExistence(timeout: 2))
        app.buttons["Reset"].tap()

        XCTAssert(app.buttons["Hello Throwing World"].exists)
        app.buttons["Hello Throwing World"].tap()

#if os(macOS)
        let alerts = app.sheets
#else
        let alerts = app.alerts
#endif

        XCTAssert(alerts.staticTexts["Custom Error"].waitForExistence(timeout: 1))
        XCTAssert(alerts.staticTexts["Error was thrown!"].waitForExistence(timeout: 1))
        alerts.buttons["OK"].tap()

        XCTAssert(app.buttons["Hello Throwing World"].isEnabled)
    }

    @MainActor
    func testListRowAccessibility() throws {
        let app = XCUIApplication()

        app.buttons["View State"].swipeUp() // on visionOS the AsyncButton is out of the frame due to the window size

        XCTAssert(app.buttons["List Row"].waitForExistence(timeout: 2))
        app.buttons["List Row"].tap()

        XCTAssert(app.staticTexts["Hello, World"].waitForExistence(timeout: 2))
    }
}
