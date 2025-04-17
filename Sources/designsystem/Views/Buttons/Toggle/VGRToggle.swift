import SwiftUI

public struct VGRToggle: View {
    
    @Binding var isOn: Bool
    let text: String
    let description: String
    
    public init(isOn: Binding<Bool>, text: String, description: String = "") {
        self._isOn = isOn
        self.text = text
        self.description = description
    }
    
    public var body: some View {
        HStack {
            VStack (alignment: .leading, spacing: 0) {
                Text(text)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.Neutral.text)
                
                if !description.isEmpty {
                    Text(description)
                        .foregroundStyle(Color.Neutral.text)
                        .font(.footnote)
                }
            }
            
            Spacer()
            
            Rectangle()
                .foregroundColor(isOn ? Color.Primary.action : Color.Neutral.textVariant)
                .frame(width: 51, height: 31)
                .overlay(
                    Circle()
                        .foregroundColor(.white)
                        .padding(2)
                        .offset(x: isOn ? 10 : -10)
                        .animation(.easeOut(duration: 0.1), value: isOn)
                )
                .cornerRadius(20)
                .onTapGesture {
                    isOn.toggle()
                }
        }
        .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
        .background(Color.Elevation.elevation1)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    @Previewable @State var isOn: Bool = false
    
    VGRToggle(isOn: $isOn, text: "Hej hopp")
}
