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


final class CanvasViewTests: XCTestCase {
    override func setUpWithError() throws {
        #if !canImport(PencilKit) || os(macOS)
        throw XCTSkip("PencilKit is not supported on this platform")
        #endif
        #if targetEnvironment(simulator) && (arch(i386) || arch(x86_64))
        throw XCTSkip("PKCanvas view-related tests are currently skipped on Intel-based iOS simulators due to a metal bug on the simulator.")
        #endif
        try super.setUpWithError()
        continueAfterFailure = false
    }
    
    
    @MainActor
    func testCanvas() throws {
        let app = XCUIApplication()
        app.launch()
        app.staticTexts["CanvasTest"].tap()
        
        let toolPicker = app.otherElements["Drawing-Palette"]
        
        XCTAssert(app.staticTexts["Did Draw Anything, false"].waitForExistence(timeout: 2))
        XCTAssertFalse(toolPicker.exists)
        
        let canvasView = app.scrollViews["Canvas"].firstMatch
        canvasView.swipeRight()
        canvasView.swipeDown()
        
        XCTAssert(app.staticTexts["Did Draw Anything, true"].waitForExistence(timeout: 2))
        
        app.buttons["Toggle Tool Picker"].tap()
        XCTAssertTrue(toolPicker.waitForExistence(timeout: 5))
        canvasView.swipeLeft()
        XCTAssertTrue(canvasView.waitForExistence(timeout: 2.0))
        
        app.buttons["Toggle Tool Picker"].tap()
        XCTAssertTrue(toolPicker.waitForNonExistence(timeout: 5))
        canvasView.swipeUp()
    }
    
    
    // Tests:
    // - that the CanvasView properly respects the `.disabled(_:)` view modifier,
    // - that mutating the drawing through the binding causes the CanvasView to update its state.
    @MainActor
    func testCanvasDisableAndMutateThroughBinding() throws {
        let app = XCUIApplication()
        app.launch()
        app.staticTexts["CanvasTest"].tap()
        
        XCTAssert(app.staticTexts["Did Draw Anything, false"].waitForExistence(timeout: 2))
        
        let canvasView = app.scrollViews["Canvas"].firstMatch
        
        XCTAssert(app.buttons["Enable/Disable Canvas, true"].waitForExistence(timeout: 2))
        app.buttons["Enable/Disable Canvas"].tap()
        XCTAssert(app.buttons["Enable/Disable Canvas, false"].waitForExistence(timeout: 2))
        // the "swipe down" action here will, since the CanvasView is disabled, attempt to dismiss the sheet,
        // which will fail since we have explicitly disabled the CanvasTestView's interactive dismissal.
        canvasView.swipeDown()
        XCTAssert(app.staticTexts["Did Draw Anything, false"].waitForExistence(timeout: 2))
        
        app.buttons["Enable/Disable Canvas"].tap()
        XCTAssert(app.buttons["Enable/Disable Canvas, true"].waitForExistence(timeout: 2))
        canvasView.swipeRight()
        canvasView.swipeDown()
        XCTAssert(app.staticTexts["Did Draw Anything, true"].waitForExistence(timeout: 2))
        
        app.buttons["Clear"].tap()
        XCTAssert(app.staticTexts["Did Draw Anything, false"].waitForExistence(timeout: 2))
    }
    
    
    // Tests that:
    // - selecting a different tool via PencilKit's picker properly updates the binding
    // - selecting a different tool by updating the binding properly updated PencilKit's picker
    @MainActor
    func testCanvasToolBinding() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["CanvasTest"].waitForExistence(timeout: 5))
        app.staticTexts["CanvasTest"].tap()
        
        let toolInfo = app.staticTexts["ToolInfo"]
        let toolPicker = app.otherElements["Drawing-Palette"]
        var currentToolDesc: String {
            toolInfo.value as? String ?? ""
        }
        
        /// Waits for the tool info label to reflect the current tool, which the binding propagates asynchronously.
        func assertToolInfo(_ predicateFormat: String, _ args: Any..., line: UInt = #line) {
            let predicate = NSPredicate(format: predicateFormat, argumentArray: args)
            let expectation = XCTNSPredicateExpectation(predicate: predicate, object: toolInfo)
            XCTAssertEqual(XCTWaiter().wait(for: [expectation], timeout: 2), .completed, "actual: \(currentToolDesc)", line: line)
        }
        
        /// Selects a tool in the tool picker, waiting for the picker to make it available and to reflect the new selection.
        func selectTool(_ name: String, line: UInt = #line) {
            // Starting with iOS 27, the tool picker on iPhone initially is collapsed, only showing the selected tool.
            // Tapping that tool expands the tool picker to show the other tools.
            if toolPicker.buttons.count == 1 {
                toolPicker.buttons.firstMatch.tap()
            }
            let tool = toolPicker.buttons[name]
            XCTAssertTrue(tool.wait(for: \.isHittable, toEqual: true, timeout: 2), line: line)
            tool.tap()
            XCTAssertTrue(tool.wait(for: \.isSelected, toEqual: true, timeout: 2), line: line)
        }
        
        XCTAssertTrue(toolInfo.waitForExistence(timeout: 5))
        XCTAssertFalse(toolPicker.exists)
        
        app.buttons["Toggle Tool Picker"].tap()
        XCTAssertTrue(toolPicker.waitForExistence(timeout: 5))
        
        assertToolInfo("value CONTAINS %@", "PKInkingTool")
        assertToolInfo("value CONTAINS %@", "com.apple.ink.pen color=UIExtendedSRGBColorSpace 1 0 0 1 width=10")
        XCTAssertTrue(toolPicker.buttons["Pen"].isSelected)
        
        selectTool("Marker")
        XCTAssertFalse(toolPicker.buttons["Pen"].isSelected)
        XCTAssertFalse(toolPicker.buttons["Eraser"].isSelected)
        assertToolInfo("value CONTAINS %@", "PKInkingTool")
        assertToolInfo("value CONTAINS %@", "com.apple.ink.marker")
        
        selectTool("Eraser")
        XCTAssertFalse(toolPicker.buttons["Pen"].isSelected)
        XCTAssertFalse(toolPicker.buttons["Marker"].isSelected)
        assertToolInfo("value CONTAINS %@", "PKEraserTool")
        
        let oldTool = currentToolDesc
        app.buttons["Random Tool"].tap()
        assertToolInfo("NOT value == %@", oldTool)
    }
}
