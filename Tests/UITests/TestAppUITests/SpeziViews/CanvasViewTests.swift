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
        app.staticTexts["CanvasTest"].tap()
        
        let toolPicker = app.otherElements["Drawing-Palette"]
        var currentToolDesc: String {
            app.staticTexts["ToolInfo"].value as? String ?? ""
        }
        
        XCTAssertFalse(toolPicker.exists)
        
        app.buttons["Toggle Tool Picker"].tap()
        XCTAssertTrue(toolPicker.waitForExistence(timeout: 5))
        
        XCTAssert(currentToolDesc.contains("PKInkingTool"))
        XCTAssert(currentToolDesc.contains("com.apple.ink.pen color=UIExtendedSRGBColorSpace 1 0 0 1 width=10"))
        XCTAssert(toolPicker.buttons["Pen"].isSelected)
        
        toolPicker.buttons["Marker"].tap()
        XCTAssertFalse(toolPicker.buttons["Pen"].isSelected)
        XCTAssertFalse(toolPicker.buttons["Eraser"].isSelected)
        XCTAssert(toolPicker.buttons["Marker"].isSelected)
        XCTAssert(currentToolDesc.contains("PKInkingTool"))
        XCTAssert(currentToolDesc.contains("com.apple.ink.marker"), "actual: \(currentToolDesc)")
        
        toolPicker.buttons["Eraser"].tap()
        XCTAssertFalse(toolPicker.buttons["Pen"].isSelected)
        XCTAssertFalse(toolPicker.buttons["Marker"].isSelected)
        XCTAssert(toolPicker.buttons["Eraser"].isSelected)
        XCTAssert(currentToolDesc.contains("PKEraserTool"))
        
        do {
            let oldTool = currentToolDesc
            app.buttons["Random Tool"].tap()
            sleep(for: .seconds(0.2)) // give it time to update
            let newTool = currentToolDesc
            XCTAssertNotEqual(newTool, oldTool)
        }
    }
}
