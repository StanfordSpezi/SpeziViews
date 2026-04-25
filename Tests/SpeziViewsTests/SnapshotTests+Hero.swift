//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SnapshotTesting
@testable import SpeziViews
import SwiftUI
import Testing

extension SnapshotTests {
    enum HeroVariant: String, CaseIterable {
        case heroTitleOnly = "hero-title-only"
        case heroTitleSubtitle = "hero-title-subtitle"
        case informationListSingleArea = "information-list-single-area"
        case informationListMultipleAreas = "information-list-multiple-areas"
        case informationListCustomIcon = "information-list-custom-icon"
        case heroLayoutDefault = "hero-layout-default"
        case heroLayoutCustom = "hero-layout-custom"
        case heroLayoutNoFooter = "hero-layout-no-footer"
        case heroLayoutConditionalFooter = "hero-layout-conditional-footer"
        case heroLayoutManagedNavigation = "hero-layout-managed-navigation"
        case heroLayoutManagedNavigationNoTopPadding = "hero-layout-managed-navigation-no-top-padding"
        case sequentialStepsInitial = "sequential-steps-initial"
        case sequentialStepsRevealed = "sequential-steps-revealed"
        case sequentialStepsFinal = "sequential-steps-final"
    }

    struct HeroTestView: View {
        let variant: HeroVariant

        var body: some View {
            switch variant {
            case .heroTitleOnly:
                HeroTitleView(title: "Welcome")
                    .padding()
            case .heroTitleSubtitle:
                HeroTitleView(title: "Welcome", subtitle: "Review the setup before you continue.")
                    .padding()
            case .informationListSingleArea:
                InformationListView {
                    InformationListView.Item(
                        iconSymbol: "heart.text.square.fill",
                        title: "Stay informed",
                        description: "Review updates and reminders in a consistent layout."
                    )
                }
                .padding()
            case .informationListMultipleAreas:
                InformationListView(items: Self.sampleItems)
                    .padding()
            case .informationListCustomIcon:
                InformationListView {
                    InformationListView.Item {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.teal.gradient)
                            .frame(width: 40, height: 40)
                    } title: {
                        Text("Custom icon")
                    } description: {
                        Text("Any SwiftUI view can be used as the leading icon.")
                    }
                }
                .padding()
            case .heroLayoutDefault:
                HeroLayoutView(
                    title: "Secure setup",
                    subtitle: "A consistent hero layout for Spezi apps.",
                    items: Self.sampleItems,
                    actionText: "Continue"
                ) {
                }
            case .heroLayoutCustom:
                HeroLayoutView(wrapInScrollView: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        Image(systemName: "sparkles.rectangle.stack.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.accentColor)
                        Text("Custom header")
                            .font(.largeTitle.bold())
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical)
                } content: {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("This content uses the generalized hero layout without the predefined title or list primitives.")
                        Text("The footer uses AsyncButton with the new primary and secondary action styles.")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } footer: {
                    VStack(spacing: 0) {
                        AsyncButton("Save") {
                        }
                        .buttonStylePrimaryAction()
                        AsyncButton("Cancel") {
                        }
                        .buttonStyleSecondaryAction()
                    }
                }
            case .heroLayoutNoFooter:
                HeroLayoutView(wrapInScrollView: false) {
                    HeroTitleView(title: "No footer", subtitle: "Bottom padding moves into the content area when no footer is provided.")
                } content: {
                    InformationListView {
                        InformationListView.Item(
                            iconSymbol: "checkmark.shield.fill",
                            title: "Single flow",
                            description: "The layout still balances spacing correctly."
                        )
                    }
                } footer: {
                    EmptyView()
                }
            case .heroLayoutConditionalFooter:
                HeroLayoutView(wrapInScrollView: false) {
                    HeroTitleView(title: "Conditional Footer", subtitle: "Uses @ViewBuilder to conditionally show footer.")
                } content: {
                    InformationListView {
                        InformationListView.Item(
                            iconSymbol: "checkmark.shield.fill",
                            title: "Conditional rendering",
                            description: "This tests @ViewBuilder that may produce EmptyView at runtime."
                        )
                    }
                } footer: {
                    EmptyView()
                }
            case .heroLayoutManagedNavigation:
                ManagedNavigationStack {
                    HeroLayoutView(
                        title: "Managed navigation",
                        subtitle: "The first step receives the extra top padding compensation.",
                        items: Self.sampleItems,
                        actionText: "Continue"
                    ) {
                    }
                    Text("Second Step")
                }
            case .heroLayoutManagedNavigationNoTopPadding:
                ManagedNavigationStack {
                    HeroLayoutView(
                        title: "No Top Padding",
                        subtitle: "Uses disablePadding(.top) to opt out of the compensation.",
                        items: Self.sampleItems,
                        actionText: "Continue"
                    ) {
                    }
                    .disablePadding(.top)
                    Text("Second Step")
                }
            case .sequentialStepsInitial:
                SequentialStepsView(
                    title: "Before you start",
                    subtitle: "Read the most important details first.",
                    steps: Self.sampleSteps,
                    actionText: "Finish"
                ) {
                }
            case .sequentialStepsRevealed:
                SequentialStepsView(
                    header: HeroTitleView(title: "Before you start", subtitle: "Read the most important details first."),
                    steps: Self.sampleSteps,
                    actionText: Text(verbatim: "Finish"),
                    action: {},
                    currentStepIndex: 1
                )
            case .sequentialStepsFinal:
                SequentialStepsView(
                    header: HeroTitleView(title: "Before you start", subtitle: "Read the most important details first."),
                    steps: Self.sampleSteps,
                    actionText: Text(verbatim: "Finish"),
                    action: {},
                    currentStepIndex: Self.sampleSteps.count - 1
                )
            }
        }

        nonisolated init(variant: HeroVariant) {
            self.variant = variant
        }

        private static let sampleItems: [InformationListView.Item] = [
            InformationListView.Item(
                iconSymbol: "heart.text.square.fill",
                title: "Share health context",
                description: "Present structured details with concise titles and descriptions."
            ),
            InformationListView.Item(
                iconSymbol: "bell.badge.fill",
                title: "Manage notifications",
                description: "Reuse the same visuals outside onboarding-specific flows."
            ),
            InformationListView.Item(
                iconSymbol: "lock.doc.fill",
                title: "Review consent",
                description: "Action buttons remain visually aligned with the rest of the Spezi ecosystem."
            )
        ]

        private static let sampleSteps: [SequentialStepsView<HeroTitleView>.Step] = [
            .init(title: "Understand the flow", description: "Each tap reveals one more step, making dense information easier to scan."),
            .init(title: "Reuse the layout", description: "The same step view can be used outside onboarding packages."),
            .init(title: "Finish setup", description: "The final button switches from the localized next label to the provided action text.")
        ]
    }


    @MainActor
    @Test("Hero", arguments: HeroVariant.allCases)
    func heroViews(_ variant: HeroVariant) async throws {
#if os(iOS)
        let view = HeroTestView(variant: variant)
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13Pro)), named: variant.rawValue)
#endif
    }
}
