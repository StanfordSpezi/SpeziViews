//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziValidation
import XCTest


final class SpeziValidationTests: XCTestCase {
    @MainActor
    func testValidationDebounce() async throws {
        let engine = ValidationEngine(rules: .nonEmpty)

        await withDiscardingTaskGroup { group in
            group.addTask {
                await engine.run()
            }

            try? await Task.sleep(for: .milliseconds(10))

            engine.submit(input: "Valid")
            XCTAssert(engine.inputValid)
            XCTAssert(engine.validationResults.isEmpty)

            engine.submit(input: "", debounce: true)
            XCTAssert(engine.inputValid)
            XCTAssert(engine.validationResults.isEmpty)

            try? await Task.sleep(for: .seconds(1))
            XCTAssert(!engine.inputValid)
            XCTAssertEqual(engine.validationResults.count, 1)

            engine.submit(input: "Valid", debounce: true)
            XCTAssert(engine.inputValid) // valid state is reported instantly
            XCTAssert(engine.validationResults.isEmpty)

            group.cancelAll()
        }
    }
}
