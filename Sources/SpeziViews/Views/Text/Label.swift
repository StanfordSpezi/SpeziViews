//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


private struct _Label: UIViewRepresentable {
    let text: String
    let textStyle: UIFont.TextStyle
    let textAlignment: NSTextAlignment
    let textColor: UIColor
    let numberOfLines: Int
    let preferredMaxLayoutWidth: CGFloat
    
    
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.textColor = textColor
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont.preferredFont(forTextStyle: textStyle)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = textAlignment
        label.numberOfLines = numberOfLines
        
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        updateUIView(label, context: context)
        
        return label
    }
    
    func updateUIView(_ label: UILabel, context: Context) {
        label.text = text
        label.preferredMaxLayoutWidth = preferredMaxLayoutWidth
    }
}


/// A ``Label`` is a SwiftUI-based wrapper around a `UILabel` that allows the usage of an `NSTextAlignment` to e.g. justify the text.
public struct Label: View {
    private let text: LocalizedStringResource
    private let textStyle: UIFont.TextStyle
    private let textAlignment: NSTextAlignment
    private let textColor: UIColor
    private let numberOfLines: Int

    @Environment(\.locale) private var locale
    
    
    public var body: some View {
        HorizontalGeometryReader { width in
            _Label(
                text: text.localizedString(for: locale),
                textStyle: textStyle,
                textAlignment: textAlignment,
                textColor: textColor,
                numberOfLines: numberOfLines,
                preferredMaxLayoutWidth: width
            )
        }
            .accessibilityRepresentation {
                Text(text)
            }
    }
    
    
    /// Creates a new localized instance of the SwiftUI-based wrapper around a `UILabel`.
    /// - Parameters:
    ///   - text: The localized text that should be displayed.
    ///   - textStyle: The `UIFont.TextStyle` of the `UILabel`. Defaults to `.body`.
    ///   - textAlignment: The `NSTextAlignment` of the `UILabel`. Defaults to `.justified`.
    ///   - textColor: The `UIColor` of the `UILabel`. Defaults to `.label`.
    ///   - numberOfLines: The number of lines allowed of the `UILabel`. Defaults to 0 indicating no limit.
    public init(
        _ text: LocalizedStringResource,
        textStyle: UIFont.TextStyle = .body,
        textAlignment: NSTextAlignment = .justified,
        textColor: UIColor = .label,
        numberOfLines: Int = 0
    ) {
        self.text = text
        self.textStyle = textStyle
        self.textAlignment = textAlignment
        self.textColor = textColor
        self.numberOfLines = numberOfLines
    }
    
    /// Creates a new instance of the SwiftUI-based wrapper around a `UILabel` without localization.
    /// - Parameters:
    ///   - text: The text that should be displayed without localization.
    ///   - textStyle: The `UIFont.TextStyle` of the `UILabel`. Defaults to `.body`.
    ///   - textAlignment: The `NSTextAlignment` of the `UILabel`. Defaults to `.justified`.
    ///   - textColor: The `UIColor` of the `UILabel`. Defaults to `.label`.
    ///   - numberOfLines: The number of lines allowed of the `UILabel`. Defaults to 0 indicating no limit.
    @_disfavoredOverload
    public init<Text: StringProtocol>(
        _ text: Text,
        textStyle: UIFont.TextStyle = .body,
        textAlignment: NSTextAlignment = .justified,
        textColor: UIColor = .label,
        numberOfLines: Int = 0
    ) {
        self.text = LocalizedStringResource("\(String(text))")
        self.textStyle = textStyle
        self.textAlignment = textAlignment
        self.textColor = textColor
        self.numberOfLines = numberOfLines
    }
}


#if DEBUG
struct Label_Previews: PreviewProvider {
    static var previews: some View {
        Label("This is very long text that wraps around multiple lines and adjusts the spacing between words accordingly.")
    }
}
#endif
