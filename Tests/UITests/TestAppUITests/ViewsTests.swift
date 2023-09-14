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
    func testCanvas() throws {
#if targetEnvironment(simulator) && (arch(i386) || arch(x86_64))
        throw XCTSkip("PKCanvas view-related tests are currently skipped on Intel-based iOS simulators due to a metal bug on the simulator.")
#endif
        
        let app = XCUIApplication()
        app.launch()
        
        app.collectionViews.buttons["Canvas"].tap()
        
        XCTAssert(app.staticTexts["Did Draw Anything: false"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.scrollViews.otherElements.images["palette_tool_pencil_base"].waitForExistence(timeout: 2))
        
        let canvasView = app.scrollViews.firstMatch
        canvasView.swipeRight()
        canvasView.swipeDown()
        
        XCTAssert(app.staticTexts["Did Draw Anything: true"].exists)
        
        XCTAssert(app.buttons["Show Tool Picker"].waitForExistence(timeout: 2))
        app.buttons["Show Tool Picker"].tap()
        
        XCTAssert(app.scrollViews.otherElements.images["palette_tool_pencil_base"].waitForExistence(timeout: 2))
        canvasView.swipeLeft()
        
        XCTAssert(app.buttons["Show Tool Picker"].waitForExistence(timeout: 2))
        app.buttons["Show Tool Picker"].tap()
        
        sleep(6) // waitForExistence will otherwise return immediately
        XCTAssertFalse(app.scrollViews.otherElements.images["palette_tool_pencil_base"].waitForExistence(timeout: 2))
        canvasView.swipeUp()
    }
    
    func testNameFields() throws {
        let app = XCUIApplication()
        app.launch()
        
        app.collectionViews.buttons["Name Fields"].tap()
        
        XCTAssert(app.staticTexts["First Title"].waitForExistence(timeout: 1))
        XCTAssert(app.staticTexts["Second Title"].exists)
        XCTAssert(app.staticTexts["First Name"].exists)
        XCTAssert(app.staticTexts["Last Name"].exists)
        
        try app.textFields["First Placeholder"].enter(value: "Le")
        try app.textFields["Second Placeholder"].enter(value: "Stan")
        
        try app.textFields["Enter your first name ..."].enter(value: "land")
        try app.textFields["Enter your last name ..."].enter(value: "ford")
        
        XCTAssert(app.textFields["Leland"].exists)
        XCTAssert(app.textFields["Stanford"].exists)
    }
    
    func testUserProfile() throws {
        let app = XCUIApplication()
        app.launch()
        
        app.collectionViews.buttons["User Profile"].tap()
        
        XCTAssertTrue(app.staticTexts["PS"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.staticTexts["LS"].exists)
        
        XCTAssertTrue(app.images["person.crop.artframe"].waitForExistence(timeout: 3.5))
    }
    
    func testGeometryReader() throws {
        let app = XCUIApplication()
        app.launch()
        
        app.collectionViews.buttons["Geometry Reader"].tap()
        
        XCTAssert(app.staticTexts["300.000000"].exists)
        XCTAssert(app.staticTexts["200.000000"].exists)
    }
    
    func testLabel() throws {
        let app = XCUIApplication()
        app.launch()
        
        app.collectionViews.buttons["Label"].tap()

        sleep(2)
        
        // The string value needs to be searched for in the UI.
        // swiftlint:disable:next line_length
        let text = "This is a label ... An other text. This is longer and we can check if the justified text works as expected. This is a very long text."
        XCTAssertEqual(app.staticTexts.allElementsBoundByIndex.filter { $0.label.replacingOccurrences(of: "\n", with: " ").contains(text) }.count, 2)
    }
    
    func testLazyText() throws {
        let app = XCUIApplication()
        app.launch()
        
        app.collectionViews.buttons["Lazy Text"].tap()
        
        XCTAssert(app.staticTexts["This is a long text ..."].waitForExistence(timeout: 1))
        XCTAssert(app.staticTexts["And some more lines ..."].exists)
        XCTAssert(app.staticTexts["And a third line ..."].exists)
        XCTAssert(app.staticTexts["An other lazy text ..."].exists)
    }
    
    func testMarkdownView() throws {
        let app = XCUIApplication()
        app.launch()
        
        app.collectionViews.buttons["Markdown View"].tap()
        
        XCTAssert(app.staticTexts["This is a markdown example."].waitForExistence(timeout: 1))

        sleep(6)
        
        XCTAssert(app.staticTexts["This is a markdown example taking 5 seconds to load."].exists)
    }
    
    func testHTMLView() throws {
        let app = XCUIApplication()
        app.launch()
        
        app.collectionViews.buttons["HTML View"].tap()
        
        XCTAssert(app.webViews.staticTexts["This is an HTML example."].waitForExistence(timeout: 15))
        XCTAssert(app.staticTexts["This is an HTML example taking 5 seconds to load."].waitForExistence(timeout: 10))
    }

    func testAsyncButtonView() throws {
        let app = XCUIApplication()
        app.launch()

        app.collectionViews.buttons["Async Button"].tap()

        XCTAssert(app.collectionViews.buttons["Hello World"].waitForExistence(timeout: 1))
        app.collectionViews.buttons["Hello World"].tap()

        XCTAssert(app.collectionViews.staticTexts["Action executed"].waitForExistence(timeout: 2))
        app.collectionViews.buttons["Reset"].tap()

        XCTAssert(app.collectionViews.buttons["Hello Throwing World"].exists)
        app.collectionViews.buttons["Hello Throwing World"].tap()

        let alert = app.alerts.firstMatch.scrollViews.otherElements
        XCTAssert(alert.staticTexts["Custom Error"].waitForExistence(timeout: 1))
        XCTAssert(alert.staticTexts["Error was thrown!"].waitForExistence(timeout: 1))
        alert.buttons["OK"].tap()

        XCTAssert(app.collectionViews.buttons["Hello Throwing World"].isEnabled)
    }
}
