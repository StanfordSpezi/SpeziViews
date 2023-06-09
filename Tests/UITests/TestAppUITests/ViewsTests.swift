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
        
        XCTAssert(app.staticTexts["Did Draw Anything: false"].waitForExistence(timeout: 1))
        XCTAssertFalse(app.scrollViews.otherElements.images["palette_tool_pencil_base"].waitForExistence(timeout: 1))
        
        let canvasView = app.scrollViews.firstMatch
        canvasView.swipeRight()
        canvasView.swipeDown()
        
        XCTAssert(app.staticTexts["Did Draw Anything: true"].exists)
        
        app.buttons["Show Tool Picker"].tap()
        
        XCTAssert(app.scrollViews.otherElements.images["palette_tool_pencil_base"].waitForExistence(timeout: 1))
        canvasView.swipeLeft()
        
        app.buttons["Show Tool Picker"].tap()
        
        XCTAssertFalse(app.scrollViews.otherElements.images["palette_tool_pencil_base"].waitForExistence(timeout: 1))
        canvasView.swipeUp()
    }
    
    func testNameFields() throws {
        let app = XCUIApplication()
        app.launch()
        
        app.collectionViews.buttons["Name Fields"].tap()
        
        XCTAssert(app.staticTexts["First Title"].exists)
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
        
        XCTAssertTrue(app.staticTexts["PS"].exists)
        XCTAssertTrue(app.staticTexts["LS"].exists)
        
        XCTAssertTrue(app.images["person.crop.artframe"].waitForExistence(timeout: 1.0))
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
        
        // The string value needs to be searched for in the UI.
        // swiftlint:disable:next line_length
        let text = "This is a label ... An other text. This is longer and we can check if the justified text works as expected. This is a very long text."
        XCTAssertEqual(app.staticTexts.allElementsBoundByIndex.filter { $0.label.contains(text) }.count, 2)
    }
    
    func testLazyText() throws {
        let app = XCUIApplication()
        app.launch()
        
        app.collectionViews.buttons["Lazy Text"].tap()
        
        XCTAssert(app.staticTexts["This is a long text ..."].exists)
        XCTAssert(app.staticTexts["And some more lines ..."].exists)
        XCTAssert(app.staticTexts["And a third line ..."].exists)
    }
    
    func testMarkdownView() throws {
        let app = XCUIApplication()
        app.launch()
        
        app.collectionViews.buttons["Markdown View"].tap()
        
        XCTAssert(app.staticTexts["This is a markdown example."].exists)
        
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
}
