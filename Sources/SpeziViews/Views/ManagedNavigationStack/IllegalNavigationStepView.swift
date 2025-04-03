//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// The `IllegalNavigationStepView` is shown when the application attempts to navigate to an illegal step in a ``ManagedNavigationStack``.
///
/// This behavior shouldn't occur at all as there are lots of checks performed within the ``ManagedNavigationStack/Path`` that prevent such illegal steps.
struct IllegalNavigationStepView: View {
    var body: some View {
        Text("ILLEGAL_NAVIGATION_STEP", bundle: .module)
    }
}


#if DEBUG
#Preview {
    IllegalNavigationStepView()
}
#endif
