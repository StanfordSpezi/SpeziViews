//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: Copyright (c) 2020 Guillermo Gonzalez
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


// type and implementation copied from https://github.com/gonzalezreal/swift-markdown-ui/blob/a9c7615fb50323069c2979c69263973aa1b24a8f/Sources/MarkdownUI/Utility/ResizeToFit.swift
struct ResizeToFit: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard let view = subviews.first else {
            return .zero
        }
        var size = view.sizeThatFits(.unspecified)
        if let width = proposal.width, size.width > width {
            let aspectRatio = size.width / size.height
            size.width = width
            size.height = width / aspectRatio
        }
        return size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard let view = subviews.first else {
            return
        }
        view.place(at: bounds.origin, proposal: .init(bounds.size))
    }
}
