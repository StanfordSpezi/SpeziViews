//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


@dynamicMemberLookup
public struct CapturedValidationState<FocusValue> {
    private let engine: ValidationEngine
    private let input: String
    let fieldIdentifier: FocusValue?

    init(engine: ValidationEngine, input: String, field fieldIdentifier: FocusValue?) {
        self.engine = engine
        self.input = input
        self.fieldIdentifier = fieldIdentifier
    }

    @MainActor public func runValidation() {
        engine.runValidation(input: input)
    }

    public subscript<Value>(dynamicMember keyPath: KeyPath<ValidationEngine, Value>) -> Value {
        engine[keyPath: keyPath]
    }
}


extension CapturedValidationState: Equatable {
    public static func == (lhs: CapturedValidationState, rhs: CapturedValidationState) -> Bool {
        lhs.engine === rhs.engine && lhs.input == rhs.input
    }
}
