//
//  ToastView.swift
//  Queersicht
//

import SwiftUI

struct ToastView: View {
    @Environment(\.colorScheme) var colorScheme
    var image: String?
    var title: String
    var subtitle: String?
    
    var body: some View {
        HStack(spacing: 16) {
            if image != nil {
                Image(systemName: image!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .lineLimit(1)
                    .font(.abcGramercyDisplayBold(size: 16))
                    .foregroundColor(.white)
                
                if subtitle != nil {
                    Text(subtitle!)
                        .lineLimit(1)
                        .font(.abcGramercyFineLight(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(image == nil ? .horizontal : .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.2))
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 4)
    }
}

struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.purple
            VStack(spacing: 24) {
                ToastView(image: "checkmark.circle.fill", title: "Data Loaded", subtitle: "Program updated successfully")
                ToastView(image: "arrow.clockwise.circle.fill", title: "Refreshing", subtitle: "Checking for updates...")
                ToastView(title: "Connected")
            }
        }
    }
}
