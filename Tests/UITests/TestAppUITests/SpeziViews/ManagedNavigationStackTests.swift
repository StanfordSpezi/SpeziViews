//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


final class ManagedNavigationStackTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }

    @MainActor
    func testNavigation() throws { // swiftlint:disable:this function_body_length
        let app = XCUIApplication()
        app.launch()
        app.open(target: "ManagedNavigationStack")
        
        func checkIsAtStep(_ name: String, line: UInt = #line) {
            XCTAssertTrue(app.staticTexts[name].waitForExistence(timeout: 1), line: line)
        }
        
        // we start at step 1
        checkIsAtStep("Step 1")
        
        // go to step 2
        app.buttons["Next Step"].tap()
        checkIsAtStep("Step 2")
        
        // go to step 3
        app.buttons["Next Step"].tap()
        checkIsAtStep("Step 3")
        // make sure the "skip next step" toggle ie ON
        XCTAssertEqual(try XCTUnwrap(app.switches.firstMatch.value as? String), "1")
        
        // go to step 5, skipping step 4
        app.buttons["Next Step"].tap()
        checkIsAtStep("Step 5")
        
        // go back from step 5. since we skipped 4, we'll end up at 3
        app.navigationBars.buttons["Back"].tap()
        checkIsAtStep("Step 3")
        // check that the "skip next step" toggls is still ON
        XCTAssertEqual(try XCTUnwrap(app.switches.firstMatch.value as? String), "1")
        // turn the toggle off, so that we no longer skip step 4
        #if os(visionOS)
        app.switches.firstMatch.tap()
        #else
        app.switches.firstMatch.switches.firstMatch.tap()
        #endif
        
        // go to step 4
        app.buttons["Next Step"].tap()
        checkIsAtStep("Step 4")
        
        // go to step 5
        app.buttons["Next Step"].tap()
        checkIsAtStep("Step 5")
        
        // go to step 7, via path A (which does not include the intermediate steps)
        app.buttons["Go to Step 7 (A)"].tap()
        checkIsAtStep("Step 7")
        // go back to step 5
        app.navigationBars.buttons["Back"].tap()
        checkIsAtStep("Step 5")
        // go to step 7, via path B (which does include the intermediate steps)
        app.buttons["Go to Step 7 (B)"].tap()
        checkIsAtStep("Step 7")
        // go back to step 6
        app.navigationBars.buttons["Back"].tap()
        checkIsAtStep("Step 6")
        // go back to step 5
        app.navigationBars.buttons["Back"].tap()
        checkIsAtStep("Step 5")
        // push a custom view onto the stack
        app.buttons["Append Custom View"].tap()
        checkIsAtStep("Custom Step")
        // perform a normal navigation step, to step 6
        app.buttons["Next Step"].tap()
        checkIsAtStep("Step 6")
        // go to step 7
        app.buttons["Next Step"].tap()
        checkIsAtStep("Step 7")
        // go back to the step before the custom step
        app.navigationBars.buttons["Back"].tap()
        checkIsAtStep("Step 6")
        app.navigationBars.buttons["Back"].tap()
        checkIsAtStep("Custom Step")
        app.navigationBars.buttons["Back"].tap()
        checkIsAtStep("Step 5")
        // go forward using normal navigation. we expect the custom step to be removed form the stack.
        app.buttons["Next Step"].tap()
        checkIsAtStep("Step 6")
        // go to step 7
        app.buttons["Next Step"].tap()
        checkIsAtStep("Step 7")
        // go to step 8
        app.buttons["Next Step"].tap()
        checkIsAtStep("Step 8")
        // go to the next step. since the counter is currently even, we expect to get to "9A (even)"
        app.buttons["Next Step"].tap()
        checkIsAtStep("Step 9A (even)")
        // go back, increment the counter, go forward again.
        // we now expect to end up at "9B (odd)"
        app.navigationBars.buttons["Back"].tap()
        app.buttons["Increment Counter"].tap()
        app.buttons["Next Step"].tap()
        checkIsAtStep("Step 9B (odd)")
        // go back, increment, expect even
        app.navigationBars.buttons["Back"].tap()
        app.buttons["Increment Counter"].tap()
        app.buttons["Next Step"].tap()
        checkIsAtStep("Step 9A (even)")
        // go back, increment, expect odd
        app.navigationBars.buttons["Back"].tap()
        app.buttons["Increment Counter"].tap()
        app.buttons["Next Step"].tap()
        checkIsAtStep("Step 9B (odd)")
        app.navigationBars.buttons["Back"].tap()
        app.buttons["Increment Counter"].tap()
        app.buttons["Next Step"].tap()
        // go back, increment, expect even
        checkIsAtStep("Step 9A (even)")
        // go to final step.
        app.buttons["Next Step"].tap()
    }
}
