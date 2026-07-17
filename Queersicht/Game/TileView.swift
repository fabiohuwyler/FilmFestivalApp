import SwiftUI

enum SwipeDirection {
    case up, down, left, right
}

struct TileView: View {
    let tile: GameTile
    let isSelected: Bool
    let onSwipe: (SwipeDirection) -> Void
    
    @GestureState private var dragAmount = CGSize.zero
    
    var body: some View {
        GeometryReader { geometry in
            Image(tile.type.imageName)
                .resizable()
                .scaledToFit()
                .padding(2)
                .frame(width: 42, height: 42)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(tile.type.color.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? tile.type.color : Color.clear, lineWidth: 2)
                )
                .gesture(
                    DragGesture()
                        .updating($dragAmount) { value, state, _ in
                            state = value.translation
                        }
                        .onEnded { value in
                            let threshold: CGFloat = 10
                            if abs(value.translation.width) > abs(value.translation.height) {
                                if value.translation.width > threshold {
                                    onSwipe(.right)
                                } else if value.translation.width < -threshold {
                                    onSwipe(.left)
                                }
                            } else {
                                if value.translation.height > threshold {
                                    onSwipe(.down)
                                } else if value.translation.height < -threshold {
                                    onSwipe(.up)
                                }
                            }
                        }
                )
                .animation(.easeInOut(duration: 0.2), value: isSelected)
                .transition(.scale.combined(with: .opacity))
        }
    }
}

#Preview {
    HStack {
        TileView(tile: GameTile(type: .rainbow, position: .zero), isSelected: false) { _ in }
        TileView(tile: GameTile(type: .trans, position: .zero), isSelected: true) { _ in }
    }
    .padding()
    .frame(width: 200, height: 100)
}
