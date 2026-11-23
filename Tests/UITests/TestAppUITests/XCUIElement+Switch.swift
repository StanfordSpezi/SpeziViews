//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


extension XCUIElement {
    private var switchValue: String {
        "\(value ?? "")"
    }

    /// Taps the switch until it is in the specified state.
    ///
    /// Starting with iOS 27, a switch occasionally ignores a single synthesized tap.
    /// Since a switch might also only respond to a tap after a delay, this only taps the switch again
    /// if it still isn't in the requested state after waiting for the previous tap to take effect.
    func setSwitch(isOn: Bool, file: StaticString = #filePath, line: UInt = #line) {
        let expectedValue = isOn ? "1" : "0"
        for _ in 0..<3 {
            if switchValue == expectedValue {
                return
            }
            tap()
            // an expectation can only be waited on once, so each attempt needs its own
            let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == %@", expectedValue), object: self)
            if XCTWaiter().wait(for: [expectation], timeout: 5) == .completed {
                return
            }
        }
        XCTFail("Switch value is \(switchValue) instead of \(expectedValue)", file: file, line: line)
    }
}
