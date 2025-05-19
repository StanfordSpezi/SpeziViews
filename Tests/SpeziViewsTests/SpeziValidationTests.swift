//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@testable import SpeziValidation
import Testing


struct SpeziValidationTests {
    @MainActor
    @Test("Validation Debounce")
    func validationDebounce() async throws {
        let engine = ValidationEngine(rules: .nonEmpty)

        engine.submit(input: "Valid")
        #expect(engine.inputValid)
        #expect(engine.validationResults.isEmpty)

        engine.submit(input: "", debounce: true)
        #expect(engine.inputValid)
        #expect(engine.validationResults.isEmpty)

        try await Task.sleep(for: .seconds(1))
        #expect(engine.inputValid == false)
        #expect(engine.validationResults.count == 1)

        engine.submit(input: "Valid", debounce: true)
        #expect(engine.inputValid) // valid state is reported instantly
        #expect(engine.validationResults.isEmpty)
    }
}
