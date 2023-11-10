//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@testable import SpeziValidation
import XCTest


final class SpeziValidationTests: XCTestCase {
    @MainActor
    func testValidationDebounce() {
        let engine = ValidationEngine(rules: .nonEmpty)

        engine.submit(input: "Valid")
        XCTAssertTrue(engine.inputValid)
        XCTAssertEqual(engine.validationResults, [])

        engine.submit(input: "", debounce: true)
        XCTAssertTrue(engine.inputValid)
        XCTAssertEqual(engine.validationResults, [])

        sleep(1)
        XCTAssertFalse(engine.inputValid)
        XCTAssertEqual(engine.validationResults.count, 1)

        engine.submit(input: "Valid", debounce: true)
        XCTAssertTrue(engine.inputValid) // valid state is reported instantly
        XCTAssertEqual(engine.validationResults, [])
    }
}
