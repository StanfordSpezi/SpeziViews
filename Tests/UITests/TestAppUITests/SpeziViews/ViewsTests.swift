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
    override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false
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
        app.launch()

        app.open(target: "SpeziViews")

        #if os(visionOS)
        // visionOS doesn't have the image anymore, this should be enough to check
        let penView = app.scrollViews.otherElements["Pen, black"]
        #else
        let penView = app.buttons["Pen"]
        #endif


        XCTAssert(app.collectionViews.buttons["Canvas"].waitForExistence(timeout: 2))
        app.collectionViews.buttons["Canvas"].tap()

        XCTAssert(app.staticTexts["Did Draw Anything: false"].waitForExistence(timeout: 2))
        XCTAssertFalse(penView.exists)

        let canvasView = app.scrollViews.firstMatch
        canvasView.swipeRight()
        canvasView.swipeDown()

        XCTAssert(app.staticTexts["Did Draw Anything: true"].waitForExistence(timeout: 2))

        XCTAssert(app.buttons["Show Tool Picker"].waitForExistence(timeout: 2))
        app.buttons["Show Tool Picker"].tap()

        XCTAssertTrue(penView.waitForExistence(timeout: 5))
        canvasView.swipeLeft()

        XCTAssertTrue(canvasView.waitForExistence(timeout: 2.0))
        app.buttons["Show Tool Picker"].tap()
        
        #if os(visionOS)
        return // the pencilKit toolbar cannot be hidden anymore on visionOS
        #endif

        XCTAssertTrue(penView.waitForNonExistence(timeout: 15))
        canvasView.swipeUp()
    }
    
    @MainActor
    func testGeometryReader() throws {
        let app = XCUIApplication()
        app.launch()

        app.open(target: "SpeziViews")

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
        app.launch()

        app.open(target: "SpeziViews")

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
        app.launch()

        app.open(target: "SpeziViews")

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
        app.launch()

        app.open(target: "SpeziViews")

        XCTAssert(app.buttons["Markdown View"].waitForExistence(timeout: 2))
        app.buttons["Markdown View"].tap()
        
        XCTAssert(app.staticTexts["This is a markdown example."].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["This is a markdown example taking 2 seconds to load."].waitForExistence(timeout: 5))
    }

    @MainActor
    func testButtonsView() throws {
        let app = XCUIApplication()
        app.launch()

        app.open(target: "SpeziViews")

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
#if os(visionOS)
        app.collectionViews.firstMatch.swipeUp() // on visionOS the AsyncButton is out of the frame due to the window size
#endif

        XCTAssert(app.buttons["Buttons"].waitForExistence(timeout: 2))
        app.buttons["Buttons"].tap()

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

        XCTAssert(app.buttons.matching(identifier: "info-button").firstMatch.exists)
        app.buttons.matching(identifier: "info-button").firstMatch.tap()

        XCTAssertFalse(alerts.staticTexts["Custom Error"].exists)

        XCTAssert(app.staticTexts["Action executed"].waitForExistence(timeout: 2))
        app.buttons["Reset"].tap()
    }

    @MainActor
    func testListRowAccessibility() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))

        app.open(target: "SpeziViews")

#if os(visionOS)
        app.collectionViews.firstMatch.swipeUp() // on visionOS the AsyncButton is out of the frame due to the window size
#endif

        XCTAssert(app.buttons["List Row"].waitForExistence(timeout: 2))
        app.buttons["List Row"].tap()

        XCTAssert(app.staticTexts["Hello, World"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testManagedViewUpdateTests() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        app.open(target: "SpeziViews")

        app.collectionViews.firstMatch.swipeUp() // out of the window on visionOS and iPadOs

        XCTAssert(app.buttons["Managed View Update"].waitForExistence(timeout: 2.0))
        app.buttons["Managed View Update"].tap()

        XCTAssert(app.navigationBars.staticTexts["Managed View Update"].waitForExistence(timeout: 2.0))
        XCTAssert(app.staticTexts["Value, 0"].exists)
        XCTAssert(app.buttons["Increment"].exists)

        app.buttons["Increment"].tap()
        XCTAssert(app.staticTexts["Value, 0"].waitForExistence(timeout: 2.0))
        XCTAssertFalse(app.staticTexts["Value, 1"].exists)

        XCTAssert(app.buttons["Refresh"].exists)
        app.buttons["Refresh"].tap()
        XCTAssert(app.staticTexts["Value, 1"].waitForExistence(timeout: 2.0))

        app.buttons["Increment"].tap()
        XCTAssert(app.staticTexts["Value, 1"].waitForExistence(timeout: 2.0))
        XCTAssertFalse(app.staticTexts["Value, 2"].exists)

        XCTAssert(app.buttons["Refresh in 2s"].exists)
        app.buttons["Refresh in 2s"].tap()
        XCTAssert(app.staticTexts["Value, 2"].waitForExistence(timeout: 4.0))
    }

    @MainActor
    func testPickers() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        app.open(target: "SpeziViews")

        app.collectionViews.firstMatch.swipeUp() // out of the window on visionOS and iPadOs

        XCTAssert(app.buttons["Picker"].waitForExistence(timeout: 2.0))
        app.buttons["Picker"].tap()

        XCTAssert(app.navigationBars.staticTexts["Picker"].waitForExistence(timeout: 2.0))

        XCTAssert(app.buttons["Selection, None"].exists)
        app.buttons["Selection, None"].tap()

        XCTAssert(app.buttons["None"].waitForExistence(timeout: 2.0))
        XCTAssert(app.buttons["First"].exists)
        XCTAssert(app.buttons["Second"].exists)

        app.buttons["First"].tap()

        XCTAssert(app.buttons["Selection, First"].waitForExistence(timeout: 2.0))

        // OPTION SET

#if os(visionOS)
        XCTAssert(app.staticTexts["nothing selected"].exists)
        app.staticTexts["nothing selected"].tap()
#else
        XCTAssert(app.buttons["Option Set, nothing selected"].exists)
        app.buttons["Option Set, nothing selected"].tap()
#endif

        XCTAssert(app.buttons["Option 1"].firstMatch.waitForExistence(timeout: 1.0))
        app.buttons["Option 1"].firstMatch.tap()
    }
}
