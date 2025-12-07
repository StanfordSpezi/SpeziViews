//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


extension ViewsTests {
    @MainActor
    func testLocalPreferences() throws {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        app.open(target: "SpeziViews")
        
        app.collectionViews.firstMatch.swipeUp() // out of the window on visionOS and iPadOS
        
        XCTAssert(app.buttons["Local Preferences"].waitForExistence(timeout: 2.0))
        app.buttons["Local Preferences"].tap()
        
        func assertAllCountersEqual(_ expected: Int) throws {
            let counterIds = ["counter1", "counter2", "counterBinding"]
            for id in counterIds {
                let value = try XCTUnwrap(Int(XCTUnwrap(app.staticTexts[id].value as? String)))
                XCTAssertEqual(value, expected)
            }
        }
        
        try assertAllCountersEqual(0)
        
        app.buttons["Increment"].tap()
        try assertAllCountersEqual(1)
        app.buttons["Increment"].tap()
        try assertAllCountersEqual(2)
        app.buttons["Reset"].tap()
        try assertAllCountersEqual(0)
        app.buttons["Decrement"].tap()
        try assertAllCountersEqual(-1)
        
        app.buttons["Reset via UserDefaults API"].tap()
        try assertAllCountersEqual(0)
        
        app.buttons["Increment via Binding"].tap()
        try assertAllCountersEqual(1)
        app.buttons["Increment via Binding"].tap()
        try assertAllCountersEqual(2)
        app.buttons["Increment via Binding"].tap()
        try assertAllCountersEqual(3)
        app.buttons["Decrement via Binding"].tap()
        try assertAllCountersEqual(2)
        app.buttons["Reset via Binding"].tap()
        try assertAllCountersEqual(0)
    }
}
