//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziValidation
import Testing


@Suite("Validation Engine")
struct SpeziValidationTests {
    @MainActor
    @Test("Validation Debounce")
    func testValidationDebounce() async throws {
        let engine = ValidationEngine(rules: .nonEmpty)

        await withDiscardingTaskGroup { group in
            group.addTask {
                await engine.run()
            }

            try? await Task.sleep(for: .milliseconds(10))

            engine.submit(input: "Valid")
            #expect(engine.inputValid)
            #expect(engine.validationResults == [])

            engine.submit(input: "", debounce: true)
            #expect(engine.inputValid)
            #expect(engine.validationResults == [])

            try? await Task.sleep(for: .seconds(1))
            #expect(!engine.inputValid)
            #expect(engine.validationResults.count == 1)

            engine.submit(input: "Valid", debounce: true)
            #expect(engine.inputValid) // valid state is reported instantly
            #expect(engine.validationResults == [])

            group.cancelAll()
        }
    }
}
