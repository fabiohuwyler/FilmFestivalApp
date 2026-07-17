//
//  TextStrokeModifier.swift
//  Queersicht
//

import SwiftUI

// MARK: - Text Stroke Modifier
struct StrokeModifier: ViewModifier {
    var strokeSize: CGFloat
    var strokeColor: Color
    
    func body(content: Content) -> some View {
        content
            .padding(strokeSize)
            .background(
                Rectangle()
                    .foregroundStyle(strokeColor)
                    .mask(outline(context: content))
            )
    }
    
    private func outline(context: Content) -> some View {
        Canvas { context, size in
            context.addFilter(.alphaThreshold(min: 0.01))
            context.drawLayer { layer in
                if let text = context.resolveSymbol(id: 0) {
                    layer.draw(text, at: CGPoint(x: size.width / 2, y: size.height / 2))
                }
            }
        } symbols: {
            context.tag(0).blur(radius: strokeSize)
        }
    }
}

extension View {
    func textStroke(color: Color, width: CGFloat) -> some View {
        modifier(StrokeModifier(strokeSize: width, strokeColor: color))
    }
}
