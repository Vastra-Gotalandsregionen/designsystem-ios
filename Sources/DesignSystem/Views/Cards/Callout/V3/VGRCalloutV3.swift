import SwiftUI

/// A rounded card used to surface contextual information, warnings, or
/// confirmations inline with surrounding content.
///
/// The callout is composed of a fixed text block (``title`` and ``text``) plus
/// three optional view slots:
///
/// - `icon`: a leading glyph rendered next to the text block. Hidden from
///   accessibility by default.
/// - `header`: additional content rendered directly under the text block,
///   inside the same horizontal row as the icon.
/// - `content`: arbitrary content rendered below the row, full-width.
///
/// Pass `onDismiss` to show a trailing close button. The callout's background
/// defaults to `Color.Status.informationSurface`; pass another `Color.Status.*`
/// surface (for example `errorSurface`) to convey severity.
///
/// Convenience initializers are provided for every combination of omitted
/// slots, so callers only specify the slots they need.
///
/// ```swift
/// VGRCalloutV3(title: "Heads up",
///              text: "Your session expires soon.",
///              onDismiss: { dismissed = true },
///              icon: { Image(systemName: "clock") })
/// ```
public struct VGRCalloutV3<Content: View, Icon: View, Header: View>: View {

    private let content: Content
    private let icon: Icon
    private let header: Header
    private let title: String
    private let text: String
    private let backgroundColor: Color
    private let onDismiss: (() -> Void)?

    /// Creates a callout with all three view slots populated.
    ///
    /// Prefer one of the convenience initializers when you don't need every
    /// slot — they let you omit unused builders entirely.
    ///
    /// - Parameters:
    ///   - title: Headline text. Hidden when empty.
    ///   - text: Body text rendered below the title. Hidden when empty.
    ///   - backgroundColor: Surface color for the card. Defaults to
    ///     `Color.Status.informationSurface`.
    ///   - onDismiss: When non-nil, a trailing close button is shown and this
    ///     closure is invoked on tap.
    ///   - icon: Leading glyph, rendered next to the text block.
    ///   - header: Supplementary content placed directly under the text block.
    ///   - content: Full-width content placed below the icon/text row.
    public init(title: String = "",
                text: String = "",
                backgroundColor: Color = Color.Status.informationSurface,
                onDismiss: (() -> Void)? = nil,
                @ViewBuilder icon: () -> Icon,
                @ViewBuilder header: () -> Header,
                @ViewBuilder content: () -> Content) {
        self.title = title
        self.text = text
        self.backgroundColor = backgroundColor
        self.onDismiss = onDismiss
        self.content = content()
        self.icon = icon()
        self.header = header()
    }

    public var body: some View {
        VStack(alignment: .leading,
               spacing: .Margins.medium) {

            HStack(alignment: .top,
                   spacing: .Margins.medium) {

                icon
                    .accessibilityHidden(true)

                VStack(spacing: .Margins.medium) {
                    VStack(spacing: .Margins.xtraSmall / 2.0) {
                        if !title.isEmpty {
                            Text(title)
                                .font(.headline)
                                .maxLeading()
                                .multilineTextAlignment(.leading)
                        }

                        if !text.isEmpty {
                            Text(text)
                                .font(.footnoteRegular)
                                .maxLeading()
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .foregroundStyle(Color.Neutral.text)
                    .maxLeading()

                    header
                        .maxLeading()
                }

                if let onDismiss {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle")

                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    .font(.body).fontWeight(.light)
                    .foregroundStyle(Color.Primary.action)
                    .buttonStyle(.plain)
                }
            }

            content
        }
        .padding(.Margins.medium)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: .Radius.mainRadius))
    }
}

extension VGRCalloutV3 where Icon == EmptyView, Header == EmptyView {
    /// Creates a callout with only the `content` slot populated.
    public init(title: String = "",
                text: String = "",
                backgroundColor: Color = Color.Status.informationSurface,
                onDismiss: (() -> Void)? = nil,
                @ViewBuilder content: () -> Content) {
        self.init(title: title, text: text, backgroundColor: backgroundColor, onDismiss: onDismiss, icon: { EmptyView() }, header: { EmptyView() }, content: content)
    }
}

extension VGRCalloutV3 where Content == EmptyView, Header == EmptyView {
    /// Creates a callout with only the `icon` slot populated.
    public init(title: String = "",
                text: String = "",
                backgroundColor: Color = Color.Status.informationSurface,
                onDismiss: (() -> Void)? = nil,
                @ViewBuilder icon: () -> Icon) {
        self.init(title: title, text: text, backgroundColor: backgroundColor, onDismiss: onDismiss, icon: icon, header: { EmptyView() }, content: { EmptyView() })
    }
}

extension VGRCalloutV3 where Content == EmptyView, Icon == EmptyView, Header == EmptyView {
    /// Creates a text-only callout with no view slots.
    public init(title: String = "",
                text: String = "",
                backgroundColor: Color = Color.Status.informationSurface,
                onDismiss: (() -> Void)? = nil) {
        self.init(title: title, text: text, backgroundColor: backgroundColor, onDismiss: onDismiss, icon: { EmptyView() }, header: { EmptyView() }, content: { EmptyView() })
    }
}

extension VGRCalloutV3 where Icon == EmptyView, Content == EmptyView {
    /// Creates a callout with only the `header` slot populated.
    public init(title: String = "",
                text: String = "",
                backgroundColor: Color = Color.Status.informationSurface,
                onDismiss: (() -> Void)? = nil,
                @ViewBuilder header: () -> Header) {
        self.init(title: title, text: text, backgroundColor: backgroundColor, onDismiss: onDismiss, icon: { EmptyView() }, header: header, content: { EmptyView() })
    }
}

extension VGRCalloutV3 where Icon == EmptyView {
    /// Creates a callout with `header` and `content` slots, but no icon.
    public init(title: String = "",
                text: String = "",
                backgroundColor: Color = Color.Status.informationSurface,
                onDismiss: (() -> Void)? = nil,
                @ViewBuilder header: () -> Header,
                @ViewBuilder content: () -> Content) {
        self.init(title: title, text: text, backgroundColor: backgroundColor, onDismiss: onDismiss, icon: { EmptyView() }, header: header, content: content)
    }
}

extension VGRCalloutV3 where Content == EmptyView {
    /// Creates a callout with `icon` and `header` slots, but no body content.
    public init(title: String = "",
                text: String = "",
                backgroundColor: Color = Color.Status.informationSurface,
                onDismiss: (() -> Void)? = nil,
                @ViewBuilder icon: () -> Icon,
                @ViewBuilder header: () -> Header) {
        self.init(title: title, text: text, backgroundColor: backgroundColor, onDismiss: onDismiss, icon: icon, header: header, content: { EmptyView() })
    }
}

extension VGRCalloutV3 where Header == EmptyView {
    /// Creates a callout with `icon` and `content` slots, but no header.
    public init(title: String = "",
                text: String = "",
                backgroundColor: Color = Color.Status.informationSurface,
                onDismiss: (() -> Void)? = nil,
                @ViewBuilder icon: () -> Icon,
                @ViewBuilder content: () -> Content) {
        self.init(title: title, text: text, backgroundColor: backgroundColor, onDismiss: onDismiss,
                  icon: icon,
                  header: { EmptyView() },
                  content: content)
    }
}

#Preview {
    let title: String = "Heading"
    let text: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec posuere felis a tortor elementum, non bibendum elit malesuada. Ut eleifend, ex eget convallis suscipit, ipsum urna tincidunt mauris, vitae ultrices eros ipsum quis elit."

    NavigationStack {
        VGRContainer {
            VGRSection {
                VGRCalloutV3(title: title,
                             text: text,
                             icon: {
                    /// Should be in icon
                    Image(systemName: "gearshape")
                        .resizable()
                        .frame(width: 25, height: 25)
                })

                VGRCalloutV3(text: text,
                             icon: {
                    /// Should be in icon
                    Image(systemName: "gearshape")
                        .resizable()
                        .frame(width: 25, height: 25)
                })

                VGRCalloutV3(title: title, text: text)

                VGRCalloutV3(title: title, text: text,
                             content: {
                    /// Should be in content
                    VGRButton(label: "Content button") {
                        print("Button pressed")
                    }
                })

                VGRCalloutV3(title: title, text: text,
                             icon: {
                    Image(systemName: "gearshape")
                        .resizable()
                        .frame(width: 25, height: 25)
                }, content: {
                    /// Should be in content
                    Text("Header content")
                })

                VGRCalloutV3(title: title,
                             text: text,
                             onDismiss: { print("Hello world") },
                             content: {
                    /// Should be in content
                    VGRButton(label: "Content button") {
                        print("Button pressed")
                    }
                })

                VGRCalloutV3(title: title,
                             text: text,
                             onDismiss: { print("Hello world") },
                             icon: {
                    Image(systemName: "gearshape")
                        .resizable()
                        .frame(width: 25, height: 25)
                },
                             content: {
                    /// Should be in content
                    VGRButton(label: "Content button") {
                        print("Button pressed")
                    }
                })

                VGRCalloutV3(title: title,
                             text: text,
                             backgroundColor: Color.Status.errorSurface,
                             icon: {
                    Image(systemName: "gearshape")
                        .resizable()
                        .frame(width: 25, height: 25)
                }, header: {
                    /// Should be in header
                    Text("Header content")
                        .font(.footnoteRegular)
                        .italic()
                        .maxLeading()
                }) {
                    /// Should be in content
                    VGRButton(label: "Content button") {
                        print("Button pressed")
                    }
                }
            }
        }
        .navigationTitle("VGRCalloutV3")
        .navigationBarTitleDisplayMode(.inline)
    }
}
