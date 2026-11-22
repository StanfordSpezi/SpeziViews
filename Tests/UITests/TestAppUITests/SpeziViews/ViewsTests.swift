//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
import XCTest
import XCTestExtensions


final class ViewsTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
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
    func testButtonsView() throws {
        let app = XCUIApplication()
        app.launch()

        app.open(target: "SpeziViews")

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        app.collectionViews.firstMatch.swipeUp() // on visionOS and on iPads the AsyncButton is out of the frame due to the window size

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

        XCTAssert(app.buttons["State Captured"].exists)
        app.buttons["State Captured"].tap()

        XCTAssert(app.staticTexts["Captured Hello World"].waitForExistence(timeout: 0.5))
    }
    
    @MainActor
    func testAsyncButtonInToolbar() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        app.buttons["AsyncButton Toolbar Behaviour"].tap()
        XCTAssert(app.staticTexts["Did tap, false"].waitForExistence(timeout: 2))
        app.navigationBars["AsyncButtonInToolbar"].buttons["Tap Me!"].tap()
        XCTAssert(app.staticTexts["Did tap, true"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testListRowAccessibility() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        app.open(target: "SpeziViews")
        app.collectionViews.firstMatch.swipeUp() // out of the window on visionOS and iPadOS

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

        app.collectionViews.firstMatch.swipeUp() // out of the window on visionOS and iPadOS

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

        app.collectionViews.firstMatch.swipeUp() // out of the window on visionOS and iPadOS

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


// MARK: Utils

func sleep(for duration: Duration) {
    usleep(UInt32(duration.timeInterval * 1000000))
}
