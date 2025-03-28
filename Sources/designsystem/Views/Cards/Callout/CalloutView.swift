import SwiftUI

public struct CalloutView<Icon: View>: View {
    private let icon: Icon
    let title: String
    let text: String
    let backgroundColor: Color
    let dismiss: (() -> Void)?
    let actionButton: ActionButton<AnyView, AnyView>?
    
    public init(
        title: String = "",
        text: String = "",
        background: Color = Color.Status.informationSurface,
        @ViewBuilder icon: () -> Icon = { EmptyView() },
        dismiss: (() -> Void)? = nil,
        actionButton: ActionButton<AnyView, AnyView>? = nil
    ) {
        self.title = title
        self.text = text
        self.backgroundColor = background
        self.icon = icon()
        self.dismiss = dismiss
        self.actionButton = actionButton
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            
            HStack(alignment: .top, spacing: 16) {
                
                icon
                    .accessibilityHidden(true)
                    .frame(maxHeight: .infinity, alignment: .top)
                
                VStack(alignment: .leading, spacing: 4) {
                    if !title.isEmpty {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(Color.Neutral.text)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Text(text)
                        .font(.footnote)
                        .foregroundStyle(Color.Neutral.text)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityElement(children: .combine)
                .frame(maxWidth: .infinity, alignment: title.isEmpty ? .center : .top)
                
                if let dismiss {
                    Button {
                        dismiss()
                    } label: {
                        Circle()
                            .stroke(lineWidth: 2)
                            .frame(width: 30, height: 30)
                            .overlay {
                                Image(systemName: "xmark")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                            }
                            .foregroundStyle(Color.Primary.action)
                    }
                }
            }
            
            if let actionButton {
                actionButton
            }
        }
        .padding(16)
        .background(self.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .textCase(.none)
    }
}

public extension CalloutView where Icon == EmptyView {
    init(
        title: String = "",
        text: String = "",
        background: Color = Color.Status.informationSurface,
        dismiss: (() -> Void)? = nil,
        actionButton: ActionButton<AnyView, AnyView>? = nil
    ) {
        self.init(
            title: title,
            text: text,
            background: background,
            icon: { EmptyView() },
            dismiss: dismiss,
            actionButton: actionButton
        )
    }
}
#Preview ("CalloutView"){
    ScrollView {
        VStack(spacing: 16) {
            
            CalloutView(title: "Hello")
            
            CalloutView(title: "World",
                        text: "Domination")
            
            CalloutView(
                title: "Scheman",
                text: "Om du använder förebyggande läkemedel kan du nu skapa ett schema för dina intag.",
                icon: {
                    Image("illustration_helping", bundle: .module)
                        .resizable()
                        .frame(width: 100, height: 100)
                },
                dismiss: {
                    print("Dismiss schema")
                },
                actionButton: ActionButton(
                    style: .primary,
                    title: "Skapa nytt schema",
                    leadingIcon: { AnyView(Image(systemName: "heart")) },
                    trailingIcon: { AnyView(Image(systemName: "arrow.right")) },
                    action: {
                        print("tap")
                    }
                )
            )
            
            CalloutView(
                title: "Feedback",
                text: "Lämna feedback på din upplevelse - när som helst och hur många gånger som helst! Vi behöver din åsikt.",
                icon: {
                    Image("illustration_presenting_4", bundle: .module)
                        .resizable()
                        .frame(width: 100, height: 100)
                },
                actionButton: ActionButton(
                    style: .secondary,
                    title: "Lämna feedback",
                    action: {
                        print("tap")
                    }
                )
            )
            
            CalloutView(
                title: "Hejsan",
                text: "Detta är ett meddelande.",
                actionButton: ActionButton(
                    style: .primary,
                    title: "Hej",
                    leadingIcon: { AnyView(Image(systemName: "heart")) },
                    trailingIcon: { AnyView(Image(systemName: "heart")) },
                    action: {
                        print("tap")
                    }
                )
            )
        }
        .padding()
    }
}
