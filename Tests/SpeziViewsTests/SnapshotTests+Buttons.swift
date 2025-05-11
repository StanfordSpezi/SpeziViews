//
//  SnapshotTests+Texts.swift
//  SpeziViews
//
//  Created by Max Rosenblattl on 12.05.25.
//

//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SnapshotTesting
@testable import SpeziViews
import SwiftUI
import Testing

extension SnapshotTests {
    struct TestView: View {
        enum ButtonType: String {
            case dismiss, info, async
        }
        let type: ButtonType

        var body: some View {
            switch type {
            case .dismiss:
                DismissButton()
            case .info:
                InfoButton("Clean Code", action: {})
            case .async:
                AsyncButton("Clean Code") {
                    try? await Task.sleep(nanoseconds: 1_000)
                }
            }
        }

        nonisolated init(type: ButtonType) {
            self.type = type
        }
    }


    @MainActor
    @Test("Buttons", arguments: [
        TestView(type: .dismiss),
        TestView(type: .info),
        TestView(type: .async)
    ])
    func allButtons(_ button: TestView) async throws {
#if os(iOS)
        assertSnapshot(of: button, as: .image(layout: .device(config: .iPhone13Pro)), named: "button-" + button.type.rawValue)
#endif
    }
}
