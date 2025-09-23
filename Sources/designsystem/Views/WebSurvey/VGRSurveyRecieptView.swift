import SwiftUI
import Lottie

public struct SurveyRecieptView: View {
    
    let onComplete: (() -> Void)
    
    /// Since this opens in an Overlay, A11y acts weird so we force the focus to the title in onAppear.
    @AccessibilityFocusState var initialFocus: Bool
    
    public init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }
    
    public var body: some View {
        
        VStack (spacing: 32) {
            LottieView(animation: .named("feedback-animation", bundle: .module))
                .playing(loopMode: .playOnce)
                .frame(width: 200, height: 200)
                .padding(.top, 16)
            
            VStack (spacing: 16) {
                Text("survey.reciept.title", bundle: .module)
                    .font(.title)
                    .fontWeight(.semibold)
                    .accessibilityFocused($initialFocus)
                    .accessibilitySortPriority(1)
                
                Text("survey.reciept.text", bundle: .module)
                    .font(.body)
            }
            .foregroundStyle(Color.Neutral.text)
            
            ActionButton("general.button.done",
                         style: .primary) {
                onComplete()
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        .padding(.top, 32)
        .edgesIgnoringSafeArea(.all)
        .background(Color.Elevation.background)
        .onAppear {
            initialFocus = true
        }
    }
}

#Preview ("Reciept") {
    
    @Previewable @State var recieptActive: Bool = true
    
    NavigationStack {
        VStack {
            Button {
                recieptActive.toggle()
            } label: {
                Text("öoepen reciept")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.Elevation.background)
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled()
        .accessibilityAddTraits(.isModal)
        .navigationTitle("sörvey")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    recieptActive.toggle()
                } label: {
                    Text("Avbryt")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    recieptActive.toggle()
                } label: {
                    Text("Klar")
                }
            }
        }
        .overlay {
            if recieptActive {
                SurveyRecieptView {
                    recieptActive.toggle()
                }
                .transition(.opacity)
            }
        }
        .padding(32)
        .background(Color.Elevation.background)
    }
}
