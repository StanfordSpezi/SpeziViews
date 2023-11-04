//
//  SwiftUIView.swift
//  
//
//  Created by Andreas Bauer on 03.11.23.
//

import SwiftUI
/*
 struct ChildView: View {
 @State var text: String = ""
 @State var isInFocus: Bool = false
 @FocusState var focusState: String?

 var body: some View {
 TextField("Input A", text: text)
 }
 }

 struct FooView: View {
 var body: some View {
 ChildView()
 }
 }
 */
struct ChildView: View {
    private let identifier: String

    @State var text: String = ""
    @FocusState var isInFocus: Bool
    @FocusState.Binding var focusState: String?

    var body: some View {
        Text("Has Focus: \(isInFocus ? "Yes": "No")")
        if let focusState {
            Text("Focus State: \(focusState)")
        }
        TextField("Input A", text: $text)
            .focused($focusState, equals: identifier)
            .focused($isInFocus)
    }


    init(id: String, focus: FocusState<String?>.Binding) {
        self.identifier = id
        self._focusState = focus
    }
}


struct FocusStateTest: View {
    @FocusState private var state: String?

    var body: some View {
        List {
            Section {
                ChildView(id: "A", focus: $state)
            }

            Section {
                ChildView(id: "B", focus: $state)
            }

            Section("Set Focus") {
                Button("A") {
                    state = "A"
                }
                Button("B") {
                    state = "B"
                }
            }
        }
    }
}

#Preview {
    FocusStateTest()
}
