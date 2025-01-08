//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

/// The view style for an `OptionSetPicker`.
public enum OptionSetPickerStyle {
    /// The picker is rendered inline (e.g., in a List view).
    case inline
    /// The picker is rendered as a menu.
    case menu
}


@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
private struct ViewBasedOnVisibility<Unlabeled: View, Labeled: View>: View {
    private let unlabeled: Unlabeled
    private let labeled: Labeled

    @Environment(\.labelsVisibility)
    private var labelsVisibility


    var body: some View {
        switch labelsVisibility {
        case .hidden:
            unlabeled
        case .automatic, .visible:
            labeled
        }
    }

    init(@ViewBuilder unlabeled: () -> Unlabeled, @ViewBuilder labeled: () -> Labeled) {
        self.unlabeled = unlabeled()
        self.labeled = labeled()
    }
}


/// Create a picker based on a `OptionSet` selection.
///
/// If you have a type that both conforms to [`OptionSet`](https://developer.apple.com/documentation/swift/optionset)  and
/// ``PickerValue`` you can use this Picker for your `selection` value.
///
/// - Note: `OptionSet` by definition allows the selection of multiple values. Therefore, `OptionSetPicker` is always implemented as an
///     inline Picker (e.g., as part of a List view) and allows to selection one or more entries.
///
/// - Note: Displaying labels is only supported on iOS 18 and newer.
public struct OptionSetPicker<Label: View, Value: OptionSet & PickerValue>: View
    where Value.AllCases: RandomAccessCollection, Value == Value.Element {
    private let allowEmptySelection: Bool
    private let style: OptionSetPickerStyle

    private let label: Label

    @Binding private var selection: Value

    private var selectionCount: Int {
        Value.allCases.count { value in
            selection.contains(value)
        }
    }

    private var singleSelection: Value? {
        Value.allCases.first { value in
            selection.contains(value)
        }
    }

    public var body: some View {
        switch style {
        case .inline:
            let view = ForEach(Value.allCases, id: \.self) { value in
                button(for: value)
            }

            if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) {
                ViewBasedOnVisibility {
                    view
                } labeled: {
                    Section {
                        view
                    } header: {
                        label
                    }
                }
            } else {
                view
            }
        case .menu:
            Menu {
                ForEach(Value.allCases, id: \.self) { value in
                    button(for: value)
                }
            } label: {
                LabeledContent {
                    HStack {
                        if selectionCount < 2 {
                            if let value = singleSelection {
                                Text(value.localizedStringResource)
                            } else {
                                Text("nothing selected")
                                    .italic()
                            }
                        } else {
                            Text("\(selectionCount) selected")
                        }
                        Image(systemName: "chevron.up.chevron.down")
                            .accessibilityHidden(true)
                            .font(.footnote)
                            .fontWeight(.medium)
                    }
                } label: {
                    if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) {
                        ViewBasedOnVisibility {
                            EmptyView()
                        } labeled: {
                            label
                                .foregroundStyle(Color.primary)
                        }
                    } else {
                        label
                            .foregroundStyle(Color.primary)
                    }
                }
            }
                .menuActionDismissBehavior(.disabled) // disable for multi selection
        }
    }

    
    /// Create a new picker for your selection.
    /// - Parameters:
    ///   - selection: The `OptionSet`-based selection.
    ///   - style: The style how the picker is displayed.
    ///   - allowEmptySelection: Flag indicating if an empty selection is allowed.
    ///   - label: The label view.
    public init(selection: Binding<Value>, style: OptionSetPickerStyle = .menu, allowEmptySelection: Bool = false, @ViewBuilder label: () -> Label) {
        self.style = style
        self.allowEmptySelection = allowEmptySelection
        self.label = label()
        self._selection = selection
    }
    
    /// Create a new picker for your selection.
    /// - Parameters:
    ///   - titleKey: The localized label.
    ///   - selection: The `OptionSet`-based selection.
    ///   - style: The style how the picker is displayed.
    ///   - allowEmptySelection: Flag indicating if an empty selection is allowed.
    public init(
        _ titleKey: LocalizedStringResource,
        selection: Binding<Value>,
        style: OptionSetPickerStyle = .menu,
        allowEmptySelection: Bool = false
    ) where Label == Text {
        self.init(selection: selection, style: style, allowEmptySelection: allowEmptySelection) {
            Text(titleKey)
        }
    }

    @ViewBuilder
    private func button(for value: Value) -> some View {
        Button {
            if selection.contains(value) {
                if selection != value || allowEmptySelection {
                    selection.remove(value)
                }
            } else {
                selection.insert(value)
            }
        } label: {
            HStack {
                Text(value.localizedStringResource)
                    .tint(.primary)
                Spacer()
                if selection.contains(value) {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentColor)
                        .fontWeight(.semibold)
                        .accessibilityHidden(true)
                }
            }
        }
    }
}


#if DEBUG
extension PreviewLayout {
    fileprivate struct Options: OptionSet, PickerValue {
        var rawValue: UInt8

        static let option1 = Options(rawValue: 1 << 0)
        static let option2 = Options(rawValue: 1 << 1)

        static let allCases: [Options] = [.option1, .option2]

        init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        var localizedStringResource: LocalizedStringResource {
            "Option \(rawValue)"
        }
    }
}

#Preview {
    @Previewable @State var selection: PreviewLayout.Options = []
    @Previewable @State var picker: String = ""

    List {
        OptionSetPicker("Test", selection: $selection)
        Picker("Test", selection: $picker) {
            Text("Empty").tag("")
        }
    }
}
#endif
