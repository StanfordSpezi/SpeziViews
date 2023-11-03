//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


extension XCUIApplication {
    func open(target: String) {
        XCTAssertTrue(app.navigationBars.staticTexts["Targets"].waitForExistence(timeout: 6.0))
        XCTAssertTrue(app.buttons[target].waitForExistence(timeout: 0.5))
        app.buttons[target].tap()
    }
}

