//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// Present hero information in a unified style.
///
/// The default style of the `HeroLayoutView` uses a combination of a ``HeroTitleView``, ``InformationListView``,
/// and a primary action button styled with ``PrimaryActionButtonStyle``.
///
/// - Tip: The ``SequentialStepsView`` provides an alternative for presenting
/// sequential information step by step.
///
/// ### Usage
///
/// The following example demonstrates the usage of the ``HeroLayoutView`` using its default configuration. The default configuration divides up
/// each screen into sections and allows you to add a title and subtitle for the overall view itself, as well as create separate information areas. Finally,
/// there is an option for an action that should be performed.
///
/// ```swift
/// HeroLayoutView(
///     title: "Title",
///     subtitle: "Subtitle",
///     items: [
///         InformationListView.Item(
///             iconSymbol: "pc",
///             title: "PC",
///             description: "This is a PC."
///         ),
///         InformationListView.Item(
///             iconSymbol: "desktopcomputer",
///             title: "Mac",
///             description: "This is an iMac."
///         )
///     ],
///     actionText: "Continue"
/// ) {
///     // Action that should be performed upon tapping the "Continue" button ...
/// }
/// ```
///
/// In implementation, you can treat the header, content, and footer as regular SwiftUI views.
/// However, to simplify things, you can also use the built-in ``HeroTitleView`` and a styled ``AsyncButton``, as demonstrated below.
/// ```swift
/// HeroLayoutView {
///     HeroTitleView(
///         title: "Title",
///         subtitle: "Subtitle"
///     )
/// } content: {
///     VStack {
///         Text("This is the hero content.")
///             .font(.headline)
///     }
/// } footer: {
///     AsyncButton("Continue") {
///         // navigate to next screen
///     }
///     .buttonStylePrimaryAction()
/// }
/// ```
public struct HeroLayoutView<Header: View, Content: View, Footer: View>: View {
    @Environment(\.verticalScrollIndicatorVisibility) private var scrollIndicatorVisibility
    @Environment(\.isInManagedNavigationStack) private var isInManagedNavigationStack
    @Environment(\.isFirstInManagedNavigationStack) private var isFirstInManagedNavigationStack
    @Environment(\.heroLayoutEdgesWithPaddingDisabled) private var edgesWithPaddingDisabled

    private let wrapInScrollView: Bool
    private let header: Header
    private let content: Content
    private let footer: Footer

    @_documentation(visibility: internal) // swiftlint:disable:next attributes
    public var body: some View {
        GeometryReader { geometry in
            if wrapInScrollView {
                ScrollView {
                    makeContents(geometry: geometry)
                }
                .scrollIndicators(effectiveScrollIndicatorVisibility, axes: .vertical)
            } else {
                makeContents(geometry: geometry)
            }
        }
    }

    /// The set of edges for which we want to apply implicit padding.
    ///
    /// - Note: This excludes the bottom edge, which is handled separately.
    private var edgesWithImplicitPadding: Edge.Set {
        // if the view is used as part of a `ManagedNavigationStack`, we don't want the extra padding at the top,
        // since that's where the navigation bar will be and we're already getting some padding via that.
        let edges: Edge.Set = isInManagedNavigationStack ? .horizontal : [.horizontal, .top]
        return edges.subtracting(edgesWithPaddingDisabled)
    }

    private var bottomPadding: CGFloat {
        // 34, because we have 10 points of default padding we want, plus the 24 points added to the view as a whole.
        edgesWithPaddingDisabled.contains(.bottom) ? 0 : 34
    }

    private var effectiveScrollIndicatorVisibility: ScrollIndicatorVisibility {
        let visibility = scrollIndicatorVisibility
        return visibility == .automatic ? .hidden : visibility
    }


    /// Creates a customized `HeroLayoutView` allowing complete customization of the layout.
    ///
    /// - Parameters:
    ///   - wrapInScrollView: Whether the `HeroLayoutView` should wrap its body in a `ScrollView`.
    ///       Defaults to `true`, but can be set to `false` to avoid nested `ScrollView`s.
    ///   - header: The header view displayed at the top.
    ///   - content: The content view.
    ///   - footer: The footer view displayed at the bottom.
    public init(
        wrapInScrollView: Bool = true,
        @ViewBuilder header: () -> Header = { EmptyView() },
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> Footer
    ) {
        self.wrapInScrollView = wrapInScrollView
        self.header = header()
        self.content = content()
        self.footer = footer()
    }


    /// Creates the default style of the `HeroLayoutView` using a combination of ``HeroTitleView``, ``InformationListView``,
    /// and a primary action button styled with ``PrimaryActionButtonStyle``.
    ///
    /// - Parameters:
    ///   - title: The hero view's localized title.
    ///   - subtitle: The hero view's optional localized subtitle.
    ///   - items: The hero view's information items, defining the view's main content.
    ///   - actionText: The localized text that should appear on the `HeroLayoutView`'s primary button.
    ///   - action: The closure that is called when the primary button is pressed.
    public init(
        title: LocalizedStringResource,
        subtitle: LocalizedStringResource? = nil, // swiftlint:disable:this function_default_parameter_at_end
        items: [InformationListView.Item],
        actionText: LocalizedStringResource,
        action: @escaping @MainActor () async throws -> Void
    ) where Header == HeroTitleView, Content == InformationListView, Footer == _HeroPrimaryActionFooter {
        self.init {
            HeroTitleView(title: title, subtitle: subtitle)
        } content: {
            InformationListView(items: items)
        } footer: {
            _HeroPrimaryActionFooter(title: Text(actionText), action: action)
        }
    }

    /// Creates the default style of the `HeroLayoutView` using a combination of ``HeroTitleView``, ``InformationListView``,
    /// and a primary action button styled with ``PrimaryActionButtonStyle``.
    ///
    /// - Parameters:
    ///   - title: The title without localization.
    ///   - subtitle: The subtitle without localization.
    ///   - items: The hero view's information items, defining the view's main content.
    ///   - actionText: The text that should appear on the `HeroLayoutView`'s primary button without localization.
    ///   - action: The closure that is called when the primary button is pressed.
    @_disfavoredOverload
    public init(
        title: some StringProtocol,
        subtitle: (some StringProtocol)? = String?.none, // swiftlint:disable:this function_default_parameter_at_end
        items: [InformationListView.Item],
        actionText: some StringProtocol,
        action: @escaping @MainActor () async throws -> Void
    ) where Header == HeroTitleView, Content == InformationListView, Footer == _HeroPrimaryActionFooter {
        self.init {
            HeroTitleView(title: title, subtitle: subtitle)
        } content: {
            InformationListView(items: items)
        } footer: {
            _HeroPrimaryActionFooter(title: Text(actionText), action: action)
        }
    }


    @ViewBuilder
    private func makeContents(geometry: GeometryProxy) -> some View {
        VStack(alignment: .center) {
            VStack {
                header
                content
                    // if we don't have a footer, we apply the bottom padding here
                    .padding(.bottom, footer is EmptyView ? bottomPadding : 0)
            }
            if !(footer is EmptyView) {
                Spacer(minLength: 40)
                footer
                    // if we do have a footer, we apply it here
                    .padding(.bottom, bottomPadding)
            }
        }
        .padding(edgesWithImplicitPadding)
        // if this is the first view in a stack, we need to add an implicit extra top padding,
        // in order to compensate for the fact that the other steps in the stack will get some de-facto
        // top padding via the navigation bar (which won't be present in the first step).
        .padding(.top, isFirstInManagedNavigationStack ? 24 : 0)
        .frame(minHeight: geometry.size.height)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}


extension EnvironmentValues {
    @Entry fileprivate var heroLayoutEdgesWithPaddingDisabled: Edge.Set = []
}


extension View {
    /// Disables the ``HeroLayoutView``'s implicit padding for the specified edges.
    ///
    /// If this modifier is applied multiple times, the outermost call will take precedence.
    ///
    /// - Note: If the ``HeroLayoutView`` is contained in a `ManagedNavigationStack`, its top edge will already be disabled implicitly.
    public func disablePadding(_ edges: Edge.Set) -> some View {
        self.environment(\.heroLayoutEdgesWithPaddingDisabled, edges)
    }
}


#if DEBUG
#Preview {
    let mock: [InformationListView.Item] = [
        InformationListView.Item(
            iconSymbol: "pc",
            title: String("PC"),
            description: String("This is a PC. And we can write a lot about PCs in a section like this. A very long text!")
        ),
        InformationListView.Item(
            iconSymbol: "desktopcomputer",
            title: String("Mac"),
            description: String("This is an iMac")
        ),
        InformationListView.Item(
            iconSymbol: "laptopcomputer",
            title: String("MacBook"),
            description: String("This is a MacBook")
        )
    ]

    HeroLayoutView(
        title: String("Title"),
        subtitle: String("Subtitle"),
        items: mock,
        actionText: String("Primary Button")
    ) {
        print("Primary!")
    }
}
#endif


@_documentation(visibility: internal)
public struct _HeroPrimaryActionFooter: View {
    let title: Text
    let action: @MainActor () async throws -> Void

    @State private var viewState: ViewState = .idle

    @_documentation(visibility: internal)
    public var body: some View {
        AsyncButton(state: $viewState, action: { try await action() }) {
            title
        }
        .buttonStylePrimaryAction()
        .viewStateAlert(state: $viewState)
    }
}
