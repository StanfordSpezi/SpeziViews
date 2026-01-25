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


extension ViewsTests {
    @MainActor
    func testAnyLocalizedError() {
        let app = XCUIApplication()
        app.launch()
        app.open(target: "SpeziViews")
        app.collectionViews.firstMatch.swipeUp() // out of the window on visionOS and iPadOS
        app.staticTexts["AnyLocalizableError"].tap()
        
        func imp(_ buttonTitle: String, expectedTitle: String?, expectedMessages: [String]) {
            app.buttons[buttonTitle].tap()
            if let expectedTitle {
                XCTAssert(app.alerts.staticTexts[expectedTitle].waitForExistence(timeout: 2))
            }
            if !expectedMessages.isEmpty {
                let message = expectedMessages.joined(separator: "\n\n")
                XCTAssert(app.alerts.staticTexts[message].waitForExistence(timeout: 2))
            }
            app.alerts.buttons["OK"].tap()
        }
        
        imp("Swift Error (Simple)", expectedTitle: "Error", expectedMessages: [
            "Unexpected error occurred!"
        ])
        imp("Swift Error (Localized)", expectedTitle: "Localized Swift Error Desc", expectedMessages: [
            "Localized Swift Failure Reason",
            "Localized Swift Help Anchor",
            "Localized Swift Recovery Suggestion"
        ])
        imp("NSError (Simple 1)", expectedTitle: "Error", expectedMessages: [
            "The operation couldn’t be completed. (edu.stanford.SpeziViews error 123.)"
        ])
        imp("NSError (Simple 2)", expectedTitle: "Error", expectedMessages: [
            "NSError Localized Description Text"
        ])
        imp("NSError (Simple 3)", expectedTitle: "NSError Localized Description Text", expectedMessages: [
            "NSError Localized Failure Reason Text",
            "NSError Localized Help Anchor Text",
            "NSError Localized Recovery Suggestion Text"
        ])
    }
}
