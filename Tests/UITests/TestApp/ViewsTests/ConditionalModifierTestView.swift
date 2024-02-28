//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct ConditionalModifierTestView: View {
    @State var condition = false
    @State var closureCondition = false
    
    
    var body: some View {
        VStack {
            Text("Condition present")
                .if(condition) { view in
                    view
                        .hidden()
                }
            
            Button("Toggle Condition") {
                condition.toggle()
            }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 20)
            
            Divider()
            
            Text("Closure Condition present")
                .if(condition: {
                    closureCondition
                }, transform: { view in
                    view
                        .hidden()
                })
                .padding(.top, 20)
            
            Button("Toggle Closure Condition") {
                closureCondition.toggle()
            }
                .buttonStyle(.borderedProminent)
        }
    }
}


#Preview {
    ConditionalModifierTestView()
}
