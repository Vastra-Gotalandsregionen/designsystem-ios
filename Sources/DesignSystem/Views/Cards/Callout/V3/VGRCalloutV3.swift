import SwiftUI

public struct VGRCalloutV3<Content: View, Icon: View, Header: View>: View {

    private let content: Content
    private let icon: Icon
    private let header: Header
    private let title: String
    private let text: String
    private let backgroundColor: Color
    private let onDismiss: (() -> Void)?

    /// Creates a container that stacks its children vertically in a `ScrollView`.
    /// - Parameter content: A view builder that produces the stacked children,
    ///   typically ``VGRSection`` views.
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
        VStack(alignment: .leading, spacing: .Margins.medium) {

            HStack(alignment: .top, spacing: .Margins.medium) {

                icon

                VStack(spacing: .Margins.medium) {
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
    public init(title: String = "",
                text: String = "",
                backgroundColor: Color = Color.Status.informationSurface,
                onDismiss: (() -> Void)? = nil,
                @ViewBuilder content: () -> Content) {
        self.init(title: title, text: text, backgroundColor: backgroundColor, onDismiss: onDismiss, icon: { EmptyView() }, header: { EmptyView() }, content: content)
    }
}

extension VGRCalloutV3 where Content == EmptyView, Header == EmptyView {
    public init(title: String = "",
                text: String = "",
                backgroundColor: Color = Color.Status.informationSurface,
                onDismiss: (() -> Void)? = nil,
                @ViewBuilder icon: () -> Icon) {
        self.init(title: title, text: text, backgroundColor: backgroundColor, onDismiss: onDismiss, icon: icon, header: { EmptyView() }, content: { EmptyView() })
    }
}

extension VGRCalloutV3 where Content == EmptyView, Icon == EmptyView, Header == EmptyView {
    public init(title: String = "",
                text: String = "",
                backgroundColor: Color = Color.Status.informationSurface,
                onDismiss: (() -> Void)? = nil) {
        self.init(title: title, text: text, backgroundColor: backgroundColor, onDismiss: onDismiss, icon: { EmptyView() }, header: { EmptyView() }, content: { EmptyView() })
    }
}

extension VGRCalloutV3 where Icon == EmptyView, Content == EmptyView {
    public init(title: String = "",
                text: String = "",
                backgroundColor: Color = Color.Status.informationSurface,
                onDismiss: (() -> Void)? = nil,
                @ViewBuilder header: () -> Header) {
        self.init(title: title, text: text, backgroundColor: backgroundColor, onDismiss: onDismiss, icon: { EmptyView() }, header: header, content: { EmptyView() })
    }
}

extension VGRCalloutV3 where Icon == EmptyView {
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
    public init(title: String = "",
                text: String = "",
                backgroundColor: Color = Color.Status.informationSurface,
                onDismiss: (() -> Void)? = nil,
                @ViewBuilder icon: () -> Icon,
                @ViewBuilder header: () -> Header) {
        self.init(title: title, text: text, backgroundColor: backgroundColor, onDismiss: onDismiss, icon: icon, header: header, content: { EmptyView() })
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
                }) {
                    /// Should be in content
                    Text("Header content")

                }

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
