//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


final class ModelTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false

        let app = XCUIApplication()
        app.launch()

        app.open(target: "SpeziViews")
    }

    func testViewState() throws {
        let app = XCUIApplication()

        XCTAssert(app.buttons["View State"].waitForExistence(timeout: 2))
        app.buttons["View State"].tap()

        XCTAssert(app.staticTexts["View State: processing"].waitForExistence(timeout: 2))

        addUIInterruptionMonitor(withDescription: "Alerts") { element in
            print("There is a alert?")
            print(element.debugDescription)
            return false
        }
        sleep(12)

        #if os(macOS)
        let alerts = app.sheets
        #else
        let alerts = app.alerts
        #endif

        XCTAssert(alerts.staticTexts["Error Description"].exists)
        XCTAssert(alerts.staticTexts["Failure Reason\n\nHelp Anchor\n\nRecovery Suggestion"].exists)
        alerts.buttons["OK"].tap()

        XCTAssert(app.staticTexts["View State: idle"].waitForExistence(timeout: 2))
    }
    
    func testOperationState() throws {
        let app = XCUIApplication()

        XCTAssert(app.buttons["Operation State"].waitForExistence(timeout: 2))
        app.buttons["Operation State"].tap()

        XCTAssert(app.staticTexts["Operation State: someOperationStep"].waitForExistence(timeout: 2))

        sleep(12)

#if os(macOS)
        let alerts = app.sheets
#else
        let alerts = app.alerts
#endif

        XCTAssert(alerts.staticTexts["Error Description"].exists)
        XCTAssert(alerts.staticTexts["Failure Reason\n\nHelp Anchor\n\nRecovery Suggestion"].exists)
        alerts.buttons["OK"].tap()

        sleep(2)

        let textField = app.staticTexts["operationState"]
#if os(macOS)
        let content = try XCTUnwrap(XCTUnwrap(textField.value) as? String)
#else
        let content = textField.label
#endif
        XCTAssert(content.contains("Operation State: error"))
    }
    
    func testViewStateMapper() throws {
        let app = XCUIApplication()

        XCTAssert(app.buttons["View State Mapper"].waitForExistence(timeout: 2))
        app.buttons["View State Mapper"].tap()

        XCTAssert(app.staticTexts["View State: processing"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["Operation State: someOperationStep"].waitForExistence(timeout: 2))

        sleep(12)

#if os(macOS)
        let alerts = app.sheets
#else
        let alerts = app.alerts
#endif

        XCTAssert(alerts.staticTexts["Error Description"].exists)
        XCTAssert(alerts.staticTexts["Failure Reason\n\nHelp Anchor\n\nRecovery Suggestion"].exists)
        alerts.buttons["OK"].tap()

        sleep(2)

        XCTAssert(app.staticTexts["View State: idle"].waitForExistence(timeout: 2))
        // Operation state must stay in the old state as it is not influenced by the dismissal
        // of the error alert (which moves the ViewState back to idle)

        let textField = app.staticTexts["operationState"]
        #if os(macOS)
        let content = try XCTUnwrap(XCTUnwrap(textField.value) as? String)
        #else
        let content = textField.label
        #endif
        XCTAssert(content.contains("Operation State: error"))
    }
    
    func testConditionalModifier() throws {
        let app = XCUIApplication()

        XCTAssert(app.buttons["Conditional Modifier"].waitForExistence(timeout: 2))
        app.buttons["Conditional Modifier"].tap()

        XCTAssert(app.staticTexts["Condition present"].waitForExistence(timeout: 1))
        XCTAssert(app.staticTexts["Closure Condition present"].waitForExistence(timeout: 1))
        
        // Check regular condition
        XCTAssert(app.buttons["Toggle Condition"].waitForExistence(timeout: 1))
        app.buttons["Toggle Condition"].tap()
        
        XCTAssert(!app.staticTexts["Condition present"].waitForExistence(timeout: 2))
        
        XCTAssert(app.buttons["Toggle Condition"].waitForExistence(timeout: 1))
        app.buttons["Toggle Condition"].tap()
        
        XCTAssert(app.staticTexts["Condition present"].waitForExistence(timeout: 2))
        
        // Check closure condition
        XCTAssert(app.buttons["Toggle Closure Condition"].waitForExistence(timeout: 1))
        app.buttons["Toggle Closure Condition"].tap()
        
        XCTAssert(!app.staticTexts["Closure Condition present"].waitForExistence(timeout: 2))
        
        XCTAssert(app.buttons["Toggle Closure Condition"].waitForExistence(timeout: 1))
        app.buttons["Toggle Closure Condition"].tap()
        
        XCTAssert(app.staticTexts["Closure Condition present"].waitForExistence(timeout: 2))
    }

    func testDefaultErrorDescription() throws {
        let app = XCUIApplication()

        XCTAssert(app.buttons["Default Error Only"].waitForExistence(timeout: 2))
        app.buttons["Default Error Only"].tap()

        XCTAssert(app.staticTexts["View State: processing"].waitForExistence(timeout: 2))

        sleep(12)

#if os(macOS)
        let alerts = app.sheets
#else
        let alerts = app.alerts
#endif

        XCTAssert(alerts.staticTexts["Error"].exists)
        XCTAssert(alerts.staticTexts["Some error occurred!"].exists)
        alerts.buttons["OK"].tap()

        XCTAssert(app.staticTexts["View State: idle"].waitForExistence(timeout: 2))
    }
}
