//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct GeometryReaderTestView: View {
    @State var name = PersonNameComponents()
    
    var body: some View {
        VStack {
            HorizontalGeometryReader { width in
                ZStack {
                    Rectangle()
                        .foregroundColor(.gray)
                        .border(.red)
                    Text("\(width)")
                }
            }
                .frame(width: 200)
                .border(.blue)
            HorizontalGeometryReader { width in
                ZStack {
                    Rectangle()
                        .foregroundColor(.gray)
                        .border(.red)
                    Text("\(width)")
                }
            }
                .frame(width: 300)
                .border(.blue)
        }
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
    }
}


#if DEBUG
struct GeometryReaderTestView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReaderTestView()
    }
}
#endif
