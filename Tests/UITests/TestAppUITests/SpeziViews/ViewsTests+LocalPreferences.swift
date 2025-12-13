//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


final class LocalPreferenceTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }
    
    
    @MainActor
    func testBasicUsage() throws {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        app.open(target: "SpeziViews")
        
        app.collectionViews.firstMatch.swipeUp() // out of the window on visionOS and iPadOS
        
        XCTAssert(app.buttons["Local Preferences"].waitForExistence(timeout: 2.0))
        app.buttons["Local Preferences"].tap()
        app.buttons["Basic Usage"].tap()
        
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
    
    
    @MainActor
    func testAppStorageInterop1() throws {
        try runAppStorageInteropTest(id: 1)
    }
    
    @MainActor
    func testAppStorageInterop2() throws {
        try runAppStorageInteropTest(id: 2)
    }
    
    @MainActor
    func runAppStorageInteropTest(id: Int) throws {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        app.open(target: "SpeziViews")
        
        app.collectionViews.firstMatch.swipeUp() // out of the window on visionOS and iPadOS
        
        XCTAssert(app.buttons["Local Preferences"].waitForExistence(timeout: 2.0))
        app.buttons["Local Preferences"].tap()
        app.buttons["AppStorage Interop (\(id))"].tap()
        
        func assertAllCountersEqual(_ expected: Int) throws {
            let counterIds = ["counterA", "counterB"]
            for id in counterIds {
                let value = try XCTUnwrap(Int(XCTUnwrap(app.staticTexts[id].value as? String)))
                XCTAssertEqual(value, expected)
            }
        }
        
        try assertAllCountersEqual(0)
        
        app.buttons["Increment Counter A"].tap()
        try assertAllCountersEqual(1)
        app.buttons["Increment Counter B"].tap()
        try assertAllCountersEqual(2)
        app.buttons["Reset Counter A"].tap()
        try assertAllCountersEqual(0)
        app.buttons["Decrement Counter B"].tap()
        try assertAllCountersEqual(-1)
        
        app.buttons["Reset Counter B"].tap()
        try assertAllCountersEqual(0)
        
        app.buttons["Increment Counter A"].tap()
        try assertAllCountersEqual(1)
        app.buttons["Increment Counter A"].tap()
        try assertAllCountersEqual(2)
        app.buttons["Increment Counter B"].tap()
        try assertAllCountersEqual(3)
        app.buttons["Decrement Counter A"].tap()
        try assertAllCountersEqual(2)
        app.buttons["Reset Counter B"].tap()
        try assertAllCountersEqual(0)
    }
}
