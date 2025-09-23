import SwiftUI

//TODO: - This component is going to be deprecated - need to refactor CalloutView first though.

@available(*, deprecated, message: "Use VGRButton instead.")
public struct ActionButton<LeadingIcon: View, TrailingIcon: View>: View {
    
    public enum ButtonStyle {
        case original
        case primary
        case secondary
    }
    
    private let style: ButtonStyle
    private let title: String
    private let leadingIcon: LeadingIcon?
    private let trailingIcon: TrailingIcon?
    var action: (() -> Void)
    
    public init(
        style: ButtonStyle,
        title: String,
        @ViewBuilder leadingIcon: () -> LeadingIcon = { EmptyView() },
        @ViewBuilder trailingIcon: () -> TrailingIcon = { EmptyView() },
        action: @escaping (() -> Void)
    ) {
        self.style = style
        self.title = title
        self.leadingIcon = leadingIcon()
        self.trailingIcon = trailingIcon()
        self.action = action
    }
    
    private var backgroundColor: Color {
        switch style {
        case .original: return Color.Elevation.elevation1
        case .primary: return Color.Primary.action
        case .secondary: return .clear
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .original: return Color.Primary.action
        case .primary: return Color.Neutral.textInverted
        case .secondary: return Color.Primary.action
        }
    }
    
    private var font: Font {
        switch style {
        case .original: .body
        case .primary: .headline
        case .secondary: .headline
        }
    }
    
    private var cornerRadius: CGFloat {
        switch style {
        case .original: 8
        case .primary: 16
        case .secondary: 16
        }
    }
    
    public var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 12) {
                if let leadingIcon {
                    leadingIcon
                        .accessibilityHidden(true)
                }
                
                Text(title)
                    .font(font)
                
                if let trailingIcon {
                    trailingIcon
                        .accessibilityHidden(true)
                }
            }
            .padding([.top, .bottom], 12)
            .frame(maxWidth: .infinity, alignment: .center)
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.Primary.action,
                            lineWidth: style == .secondary ? 2 : 0)
            )
        }
    }
}

public extension ActionButton where LeadingIcon == AnyView, TrailingIcon == AnyView {
    init(style: ButtonStyle,
         title: String,
         action: @escaping (() -> Void)) {
        self.init(
            style: style,
            title: title,
            leadingIcon: { AnyView(EmptyView()) },
            trailingIcon: { AnyView(EmptyView()) },
            action: action
        )
    }
}

public extension ActionButton where LeadingIcon == AnyView {
    init(style: ButtonStyle,
         title: String,
         @ViewBuilder trailingIcon: () -> TrailingIcon,
         action: @escaping (() -> Void)) {
        self.init(
            style: style,
            title: title,
            leadingIcon: { AnyView(EmptyView()) },
            trailingIcon: trailingIcon,
            action: action
        )
    }
}

public extension ActionButton where TrailingIcon == AnyView {
    init(style: ButtonStyle,
         title: String,
         @ViewBuilder leadingIcon: () -> LeadingIcon,
         action: @escaping (() -> Void)) {
        self.init(
            style: style,
            title: title,
            leadingIcon: leadingIcon,
            trailingIcon: { AnyView(EmptyView()) },
            action: action
        )
    }
}

#Preview {
    ScrollView {
        VGRShape {
            VStack {
                Text("Original")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ActionButton(
                    style: .original,
                    title: "No icons",
                    action: { print("tap") }
                )
                
                ActionButton(
                    style: .original,
                    title: "Leading",
                    leadingIcon: { Image(systemName: "heart") },
                    action: { print("tap") }
                )
                
                ActionButton(
                    style: .original,
                    title: "Trailing",
                    trailingIcon: { Image(systemName: "arrow.right") },
                    action: { print("tap") }
                )
                
                ActionButton(
                    style: .original,
                    title: "Both Icons",
                    leadingIcon: { Image(systemName: "star.fill") },
                    trailingIcon: { Image(systemName: "heart.fill") },
                    action: { print("tap") }
                )
            }
            .padding(16)
            
            VStack(spacing: 16) {
                Text("Primary")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ActionButton(
                    style: .primary,
                    title: "No Icons",
                    action: { print("tap") }
                )
                
                ActionButton(
                    style: .primary,
                    title: "Leading Icon",
                    leadingIcon: { Image(systemName: "heart.fill") },
                    action: { print("tap") }
                )
                
                ActionButton(
                    style: .primary,
                    title: "Trailing Icon",
                    trailingIcon: { Image(systemName: "arrow.right") },
                    action: { print("tap") }
                )
                
                ActionButton(
                    style: .primary,
                    title: "Both Icons",
                    leadingIcon: { Image(systemName: "star.fill") },
                    trailingIcon: { Image(systemName: "heart.fill") },
                    action: { print("tap") }
                )
                
                
            }
            .padding(16)
            
            VStack {
                Text("Secondary")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ActionButton(
                    style: .secondary,
                    title: "Secondary",
                    leadingIcon: { Image(systemName: "heart") },
                    trailingIcon: { Image(systemName: "heart") },
                    action: { print("tap") }
                )
            }
            .padding(16)
        }
    }
}
