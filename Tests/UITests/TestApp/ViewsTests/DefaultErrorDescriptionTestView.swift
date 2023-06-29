//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct DefaultErrorDescriptionTestView: View {
    var body: some View {
        ViewStateTestView()
            .environment(\.defaultErrorDescription, "This is a default error description!")
    }
}

struct DefaultErrorDescriptionTestView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultErrorDescriptionTestView()
    }
}
