//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
import SwiftUI


/// A picker view for case-iterable types.
///  
/// A type that conforms to ``PickerValue`` can be automatically rendered as a picker.
///  
/// ```swift
/// enum Version: PickerValue {
///     case versionA
///     case versionB
///  
///     var localizedStringResource: LocalizedStringResource {
///         switch self {
///         case .versionA:
///             "A"
///         case .versionB:
///             "B"
///         }
///     }
/// }
///  
/// struct VersionPicker: View {
///     @State private var version: Version? = .versionA
///     var body: some View {
///         CaseIterablePicker("Version", value: $version)
///     }
/// }
/// ```
///  
/// - Note: If you pass an optional ``PickerValue``, the picker automatically renders the "none" case at the top, separated from value values.
///
/// ## Topics
///
/// ### Supporting Types
/// - ``PickerValue``
public struct CaseIterablePicker<Value: PickerValue, Label: View>: View where Value.AllCases: RandomAccessCollection {
    // swiftlint:disable:previous file_types_order
    private let label: Label
    private let noneValue: Value?

    @Binding private var value: Value

    public var body: some View {
        Picker(selection: $value) {
            if let noneValue {
                Text(noneValue.localizedStringResource)
                    .tag(noneValue)
                Divider()

                ForEach(Value.allCases.filter { $0 != noneValue }, id: \.hashValue) { value in
                    Text(value.localizedStringResource)
                        .tag(value)
                }
            } else {
                ForEach(Value.allCases, id: \.hashValue) { value in
                    Text(value.localizedStringResource)
                        .tag(value)
                }
            }
        } label: {
            label
        }
    }
    
    /// Create a new case-iterable picker.
    /// - Parameters:
    ///   - value: The value binding.
    ///   - label: The picker label.
    @_disfavoredOverload
    public init(
        value: Binding<Value>,
        @ViewBuilder label: () -> Label
    ) {
        self._value = value
        self.noneValue = nil
        self.label = label()
    }

    /// Create a new case-iterable picker.
    /// - Parameters:
    ///   - titleKey: The picker label.
    ///   - value: The value binding.
    @_disfavoredOverload
    public init(_ titleKey: LocalizedStringResource, value: Binding<Value>) where Label == Text {
        self.init(value: value) {
            Text(titleKey)
        }
    }
    
    /// Create a new case-iterable picker.
    /// - Parameters:
    ///   - value: The value binding.
    ///   - noneValue: The value that represents the none value.
    ///   - label: The picker label.
    public init(
        value: Binding<Value>,
        none noneValue: Value,
        @ViewBuilder label: () -> Label
    ) {
        self._value = value
        self.noneValue = noneValue
        self.label = label()
    }

    /// Create a new case-iterable picker.
    /// - Parameters:
    ///   - titleKey: The picker label.
    ///   - value: The value binding.
    ///   - noneValue: The value that represents the none value.
    public init(_ titleKey: LocalizedStringResource, value: Binding<Value>, none noneValue: Value) where Label == Text {
        self.init(value: value, none: noneValue) {
            Text(titleKey)
        }
    }
}


extension CaseIterablePicker where Value: AnyOptional { // swiftlint:disable:this file_types_order
    /// Create a new case-iterable picker.
    /// - Parameters:
    ///   - value: The value binding.
    ///   - label: The picker label.
    public init(
        value: Binding<Value>,
        @ViewBuilder label: () -> Label
    ) {
        self._value = value
        self.noneValue = Value(nilLiteral: ())
        self.label = label()
    }

    /// Create a new case-iterable picker.
    /// - Parameters:
    ///   - titleKey: The picker label.
    ///   - value: The value binding.
    public init(_ titleKey: LocalizedStringResource, value: Binding<Value>) where Label == Text {
        self.init(value: value) {
            Text(titleKey)
        }
    }
}


#if DEBUG
private enum Version: PickerValue {
    case versionA
    case versionB

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .versionA:
            "A"
        case .versionB:
            "B"
        }
    }
}

#Preview {
    @Previewable @State var version: Version? = .versionA
    List {
        CaseIterablePicker("Version", value: $version)
    }
}
#endif
