import SwiftUI

struct LoadingOverlay: View {
    let message: String
    var isError: Bool = false
    var onRetry: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                if !isError {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                } else {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 36))
                        .foregroundColor(.white)
                }
                
                Text(message)
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                if isError, let retry = onRetry {
                    Button(action: retry) {
                        Text("Try Again")
                            .font(.custom("Inter-Bold", size: 16))
                            .foregroundColor(.black)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.top, 8)
                }
            }
            .padding(32)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}
