//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if canImport(SnapshotTesting)
import SnapshotTesting
#endif
@testable import SpeziViews
import SwiftUI
import Testing

extension SnapshotTests {
    struct TestView: View {
        enum ButtonType: String, CaseIterable {
            case dismiss
            case info
            case async
            case primaryActionStyle = "primary-action-style"
            case primaryAndSecondaryActionStyle = "primary-and-secondary-action-style"
            case primaryActionProcessingStyle = "primary-action-processing-style"
            case actionStylesDisabledWhileProcessing = "action-styles-disabled-while-processing"
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
            case .primaryActionStyle:
                AsyncButton("Continue") {
                }
                .buttonStylePrimaryAction()
                .padding()
            case .primaryAndSecondaryActionStyle:
                VStack(spacing: 0) {
                    AsyncButton("Continue") {
                    }
                    .buttonStylePrimaryAction()
                    AsyncButton("Skip") {
                    }
                    .buttonStyleSecondaryAction()
                }
                .padding()
            case .primaryActionProcessingStyle:
                AsyncButton("Continue", state: .constant(.processing)) {
                }
                .buttonStylePrimaryAction()
                .padding()
            case .actionStylesDisabledWhileProcessing:
                VStack(spacing: 0) {
                    AsyncButton("Continue", state: .constant(.processing)) {
                    }
                    .buttonStylePrimaryAction()
                    AsyncButton("Skip") {
                    }
                    .buttonStyleSecondaryAction()
                    .disabled(true)
                }
                .padding()
            }
        }

        nonisolated init(type: ButtonType) {
            self.type = type
        }
    }


    @MainActor
    @Test("Buttons", arguments: TestView.ButtonType.allCases.map(TestView.init))
    func allButtons(_ button: TestView) async throws {
#if os(iOS)
        assertSnapshot(of: button, as: .image(layout: .device(config: .iPhone13Pro)), named: "button-" + button.type.rawValue)
#endif
    }
}
