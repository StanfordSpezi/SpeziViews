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
    @available(watchOS, unavailable)
    case menu

    /// The default style for the platform.
    public static var automatic: OptionSetPickerStyle {
#if os(watchOS)
        .inline
#else
        .menu
#endif
    }
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
/// `OptionSet` by definition allows the selection of multiple values.
///
/// - Note: Displaying labels is only supported on iOS 18 and newer.
///
/// ## Topics
///
/// ### Styling
/// - ``OptionSetPickerStyle``
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
#if !os(watchOS)
        case .menu:
            menu
#endif
        }
    }

    @ViewBuilder private var menu: some View {
#if os(visionOS)
        LabeledContent {
            let menu = Menu {
                menuContent
            } label: {
                menuContentLabel
            }
            if #available(visionOS 2, *) {
                menu
                    .accessibilityLabel { label in
                        label
                        menuLabel
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityAddTraits(.isButton)
            } else {
                menu
            }
        } label: {
            menuLabel
                .accessibilityHidden(true)
        }
            .menuActionDismissBehavior(.disabled) // disable for multi selection
#else
        Menu {
            menuContent
        } label: {
            LabeledContent {
                menuContentLabel
            } label: {
                menuLabel
            }
        }
#if !os(macOS)
        .menuActionDismissBehavior(.disabled) // disable for multi selection
#endif
#endif
    }

    @ViewBuilder private var menuLabel: some View {
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

    @ViewBuilder private var menuContent: some View {
        ForEach(Value.allCases, id: \.self) { value in
            toggle(for: value)
        }
    }

    @ViewBuilder private var menuContentLabel: some View {
        HStack {
            selectionLabel
            Image(systemName: "chevron.up.chevron.down")
                .accessibilityHidden(true)
                .font(.footnote)
                .fontWeight(.medium)
        }
    }

    private var selectionLabel: Text {
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
    }

    
    /// Create a new picker for your selection.
    /// - Parameters:
    ///   - selection: The `OptionSet`-based selection.
    ///   - style: The style how the picker is displayed.
    ///   - allowEmptySelection: Flag indicating if an empty selection is allowed.
    ///   - label: The label view.
    public init(
        selection: Binding<Value>,
        style: OptionSetPickerStyle = .automatic,
        allowEmptySelection: Bool = false,
        @ViewBuilder label: () -> Label
    ) {
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
        style: OptionSetPickerStyle = .automatic,
        allowEmptySelection: Bool = false
    ) where Label == Text {
        self.init(selection: selection, style: style, allowEmptySelection: allowEmptySelection) {
            Text(titleKey)
        }
    }


    @ViewBuilder
    private func button(for value: Value) -> some View {
        Button {
            buttonAction(for: value)
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

    @ViewBuilder
    private func toggle(for value: Value) -> some View {
        let binding = Binding {
            selection.contains(value)
        } set: { newValue in
            guard newValue != selection.contains(value) else {
                return
            }
            buttonAction(for: value)
        }

        Toggle(isOn: binding) {
            Text(value.localizedStringResource)
        }
    }

    private func buttonAction(for value: Value) {
        if selection.contains(value) {
            if selection != value || allowEmptySelection {
                selection.remove(value)
            }
        } else {
            selection.insert(value)
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
        Picker("Test", selection: $picker) { // for style comparison
            Text("Empty").tag("")
        }
        OptionSetPicker("Test", selection: $selection, style: .inline, allowEmptySelection: true)
    }
}
#endif
