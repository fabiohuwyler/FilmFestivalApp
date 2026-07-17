import SwiftUI

struct QueerCrushView: View {
    @StateObject private var gameBoard = GameBoard()
    @Environment(\.dismiss) private var dismiss
    @State private var showingInstructions = false
    @State private var showHighScores = false
    @EnvironmentObject var languageManager: LanguageManager
    
    private let tileSize: CGFloat = 42
    private let spacing: CGFloat = 12
    
    var body: some View {
        ZStack {
            // Background
            DemoMeshGradientBackground()
            
            VStack(spacing: 12) {

                
                // Title
                Text("Queer Crush")
                    .font(.abcGramercyDisplayBold(size: 32))
                    .foregroundColor(.white)
                    .padding(.top, 8)
                
                // Header
                HStack {
                    // Timer and Score
                    HStack(spacing: 24) {
                        Text("time".localized(languageManager.selectedLanguage) + ": \(Int(gameBoard.timeRemaining))")
                            .font(.abcGramercyDisplayBold(size: 24))
                            .foregroundColor(.white)
                        
                        Text("score".localized(languageManager.selectedLanguage) + ": \(gameBoard.score)")
                            .font(.abcGramercyDisplayBold(size: 24))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Help Button
                    Button {
                        showingInstructions = true
                    } label: {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                    .frame(height: 20)
                
                // Game Grid
                GameGridView(gameBoard: gameBoard, tileSize: tileSize, spacing: spacing)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
                
                Spacer()
                
                // Bottom Buttons
                HStack(spacing: 16) {
                    // High Scores Button
                    Button {
                        showHighScores = true
                    } label: {
                        Text("view_high_scores".localized(languageManager.selectedLanguage))
                            .font(.abcGramercyDisplayBold(size: 17))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 32)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.3))
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, y: 2)
                            )
                    }
                    
                    // Restart Button
                    Button {
                        gameBoard.initializeGrid()
                    } label: {
                        Text("restart_game".localized(languageManager.selectedLanguage))
                            .font(.abcGramercyDisplayBold(size: 17))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 32)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.3))
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, y: 2)
                            )
                    }
                }
                .padding(.bottom, 16)
            }
            .sheet(isPresented: $showingInstructions) {
                InstructionsView()
            }
            .sheet(isPresented: $showHighScores) {
                HighScoreListView()
            }
            
            // Game Over Overlay
            if gameBoard.isGameOver {
                GameOverView(
                    hasWon: gameBoard.hasWon,
                    score: gameBoard.score,
                    onRestart: { gameBoard.initializeGrid() },
                    gameBoard: gameBoard
                )
                .onAppear {
                    if gameBoard.hasWon {
                        SoundManager.shared.playWin()
                    } else {
                        SoundManager.shared.playWin()
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
    
}

struct GameGridView: View {
    @ObservedObject var gameBoard: GameBoard
    let tileSize: CGFloat
    let spacing: CGFloat
    
    var body: some View {
        VStack(spacing: spacing) {
            ForEach(0..<GameBoard.gridSize) { row in
                HStack(spacing: spacing) {
                    ForEach(0..<GameBoard.gridSize) { col in
                        TileView(tile: gameBoard.tiles[row][col],
                                isSelected: gameBoard.selectedTile?.id == gameBoard.tiles[row][col].id) { direction in
                            handleSwipe(row: row, col: col, direction: direction)
                        }
                        .frame(width: tileSize, height: tileSize)
                        .onTapGesture {
                            gameBoard.selectTile(at: CGPoint(x: col, y: row))
                        }
                    }
                }
            }
            .padding(4)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.7))
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 24)
    }
    
    private func handleSwipe(row: Int, col: Int, direction: SwipeDirection) {
        var targetPosition = CGPoint(x: col, y: row)
        switch direction {
        case .up:
            targetPosition.y -= 1
        case .down:
            targetPosition.y += 1
        case .left:
            targetPosition.x -= 1
        case .right:
            targetPosition.x += 1
        }
        
        gameBoard.swapTiles(from: CGPoint(x: col, y: row), to: targetPosition)
    }
}

struct GameInstructions: View {
    let language: Language
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(language == .german ? "Spielanleitung" : "Comment jouer")
                .font(.abcGramercyDisplayBold(size: 24))
                .foregroundColor(Color("theDark"))
            
            Text(language == .german ?
                 "• Tausche benachbarte Symbole, um mindestens 3 gleiche in einer Reihe zu verbinden\n• Sammle in 60 Sekunden so viele Punkte wie möglich\n• Tippe auf ein Symbol und dann auf ein benachbartes, oder wische, um zu tauschen\n• Der Timer startet automatisch bei deinem ersten Match!" :
                 "• Échangez des symboles adjacents pour aligner au moins 3 identiques\n• Marquez le plus de points possible en 60 secondes\n• Tapez sur un symbole puis sur un adjacent, ou glissez pour échanger\n• Le chronomètre démarre automatiquement à votre premier match!")
                .font(.abcGramercyFineLight(size: 17))
                .foregroundColor(.secondary)
        }
    }
}

struct InstructionsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    GameInstructions(language: .german)
                        .padding(.bottom, 8)
                    GameInstructions(language: .french)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

struct FestivalMeterView: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.1))
                    .scaleEffect(1.2)
                
                // Progress Bar
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.pink, .purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, min(geometry.size.width * progress, geometry.size.width)))
                    .animation(.easeInOut(duration: 0.3), value: progress)
                
                // Festival Text
                Text("Festival")
                    .font(.abcGramercyDisplayBold(size: 17))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
            }
        }
    }
}
