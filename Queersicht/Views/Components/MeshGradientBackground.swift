import SwiftUI

struct MeshGradientBackground: View {
    private let colors: [Color] = [
        Color("wave1"),  // Light blue
        Color("wave2"),  // Deep blue
        Color("wave3")   // Ocean blue
    ]
    
    private var meshPoints: [[Float]] {
        [
            // Top row
            [0.0, 0.0],     // Top left
            [0.3, 0.0],     // Top left-center
            [0.7, 0.0],     // Top right-center
            [1.0, 0.0],     // Top right
            
            // Upper middle row
            [0.0, 0.3],     // Left edge
            [0.3, 0.2],     // Control point - gentle curve
            [0.7, 0.4],     // Control point - dramatic curve
            [1.0, 0.3],     // Right edge
            
            // Lower middle row
            [0.0, 0.7],     // Left edge
            [0.3, 0.8],     // Control point - dramatic curve
            [0.7, 0.6],     // Control point - gentle curve
            [1.0, 0.7],     // Right edge
            
            // Bottom row
            [0.0, 1.0],     // Bottom left
            [0.3, 1.0],     // Bottom left-center
            [0.7, 1.0],     // Bottom right-center
            [1.0, 1.0]      // Bottom right
        ]
    }
    
    private var meshColors: [Color] {
        [
            // Top row - All light blue
            colors[0], colors[0], colors[0], colors[0],
            // Upper middle - Transition to deep blue
            colors[0], colors[0], colors[1], colors[1],
            // Lower middle - Deep blue to ocean blue
            colors[1], colors[1], colors[2], colors[2],
            // Bottom row - All ocean blue
            colors[2], colors[2], colors[2], colors[2]
        ]
    }
    
    var body: some View {
        MeshGradient(
            width: 4,
            height: 4,
            points: meshPoints,
            colors: meshColors
        )
        .ignoresSafeArea()
    }
}
