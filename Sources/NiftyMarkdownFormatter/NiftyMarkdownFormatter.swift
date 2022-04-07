
import SwiftUI

// MARK: Public

/**
 SwiftUI view with formatted markdown. The formatted markdown is wrapped in a `VStack` with no extra view modifiers.
 
 - Parameter markdown: The text needed to be formatted, as a `String`
 - Parameter alignment: The horizontal alignment of the `VStack` in the view. Default is `.center`, like in default `VStack`.
 - Parameter spacing: The distance between adjacent subviews, or `nil` if you want the stack to choose a default distance for each pair of subviews.
 */
public struct FormattedMarkdown: View {
    let markdown: String
    let alignment: HorizontalAlignment
    let spacing: CGFloat?

    public init(markdown: String, alignment: HorizontalAlignment? = nil, spacing: CGFloat? = nil) {
        self.markdown = markdown
        self.alignment = alignment ?? .center
        self.spacing = spacing
    }
    
    public var body: some View {
        let formattedStrings = formattedMarkdownArray(markdown: markdown)
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(0..<formattedStrings.count, id: \.self) { textView in
                formattedStrings[textView]
            }
        }
    }
}

/**
 Formats the markdown.

 - Parameter markdown: the markdown to be formatted as a `String`.
 
 - Returns: array of `Text` views.
 */
public func formattedMarkdownArray(markdown: String) -> [AnyView] {
    var formattedViews: [AnyView] = []
    let splitStrings: [String] = markdown.components(separatedBy: "\n")
    for string in splitStrings {
        if string.starts(with: "#") {
            let heading = formatHeading(convertMarkdownHeading(string))
            formattedViews.append(AnyView(heading))
        } else if string.starts(with: "* ") {
            formattedViews.append(
                AnyView(
                    HStack {
                        VStack(alignment: .leading) {
                            Circle().frame(width: 5, height: 5).padding(.top, 9)
                            Spacer()
                        }
                        Text(formatUnorderedListItem(string))
                            .multilineTextAlignment(.leading)
                    }
                )
            )
        } else if string.range(of: "^[0-9].") != nil {
            // formattedViews.append(AnyView(Text(formatOrderedListItem(string))))
            formattedViews.append(
                formatOrderedListItem(string)
            )
        } else if string.count == 0 {
            // Ignore empty lines
        } else if string.starts(with: "![") {
            if #available(macOS 12.0, *) {
                formattedViews.append(AnyView(formatImage(string)))
            } else {
                // Fallback on earlier versions
            }
        } else {
            if #available(iOS 15, macOS 12, *) {
                if let attributedString = try? AttributedString(markdown: string) {
                    formattedViews.append(AnyView(Text(attributedString)))
                } else {
                    formattedViews.append(AnyView(Text(string)))
                }
            } else {
                formattedViews.append(AnyView(Text(string)))
            }
        }
    }
    
    return formattedViews
}
