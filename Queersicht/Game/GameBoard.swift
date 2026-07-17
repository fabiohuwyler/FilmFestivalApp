import SwiftUI

class GameBoard: ObservableObject {
    // Animation duration constants
    private let matchAnimationDuration: TimeInterval = 0.3
    private let fallAnimationDuration: TimeInterval = 0.5
    static let gridSize = 6
    static let gameDuration: TimeInterval = 60
    
    @Published var tiles: [[GameTile]] = []
    @Published var selectedTile: GameTile? = nil
    @Published var score = 0
    @Published var timeRemaining: TimeInterval = gameDuration
    @Published var isGameOver = false
    @Published var hasWon = false
    @Published var isGameStarted = false
    @Published var hasSubmittedScore = false
    
    private var timer: Timer?
    private var hasFirstMatch = false
    
    init() {
        initializeGrid()
    }
    
    private func shuffleBoard() -> [[GameTile]] {
        var newTiles: [[GameTile]] = []
        repeat {
            newTiles = []
            for row in 0..<Self.gridSize {
                var rowTiles: [GameTile] = []
                for col in 0..<Self.gridSize {
                    var newTile: GameTile
                    repeat {
                        newTile = GameTile.random(at: CGPoint(x: col, y: row))
                    } while (col >= 2 && rowTiles[col-1].type == newTile.type && rowTiles[col-2].type == newTile.type) ||
                            (row >= 2 && newTiles[row-1][col].type == newTile.type && newTiles[row-2][col].type == newTile.type)
                    rowTiles.append(newTile)
                }
                newTiles.append(rowTiles)
            }
        } while hasInitialMatches(in: newTiles)
        return newTiles
    }
    
    func initializeGrid() {
        // Reset game state
        score = 0
        timeRemaining = Self.gameDuration
        isGameOver = false
        hasWon = false
        selectedTile = nil
        isGameStarted = false
        hasSubmittedScore = false
        hasFirstMatch = false
        
        // Initialize tiles
        tiles = shuffleBoard()
        
        // Stop any existing timer
        timer?.invalidate()
        timer = nil
    }
    
    private func startTimer() {
        guard !hasFirstMatch else { return }
        hasFirstMatch = true
        isGameStarted = true
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func updateTimer() {
        guard !isGameOver else { return }
        
        timeRemaining -= 1
        if timeRemaining <= 0 {
            endGame(hasWon: false)  // No win condition, just show final score
        }
    }
    
    func selectTile(at position: CGPoint) {
        guard !isGameOver && isValidPosition(position) else { return }
        
        let tile = tiles[Int(position.y)][Int(position.x)]
        
        if let selectedTile = selectedTile {
            // If a tile is already selected
            let selectedPosition = findTilePosition(selectedTile)
            if let selectedPosition = selectedPosition,
               areAdjacent(position1: selectedPosition, position2: position) {
                swapTiles(from: selectedPosition, to: position)
            }
            self.selectedTile = nil
        } else {
            // Select the new tile
            selectedTile = tile
        }
    }
    
    func swapTiles(from position1: CGPoint, to position2: CGPoint) {
        guard isValidPosition(position1) && isValidPosition(position2) else { return }
        guard areAdjacent(position1: position1, position2: position2) else { return }
        
        // Swap tiles
        let temp = tiles[Int(position1.y)][Int(position1.x)]
        tiles[Int(position1.y)][Int(position1.x)] = tiles[Int(position2.y)][Int(position2.x)]
        tiles[Int(position2.y)][Int(position2.x)] = temp
        
        // Check for matches
        if !findMatches() {
            // If no matches, swap back
            let temp = tiles[Int(position1.y)][Int(position1.x)]
            tiles[Int(position1.y)][Int(position1.x)] = tiles[Int(position2.y)][Int(position2.x)]
            tiles[Int(position2.y)][Int(position2.x)] = temp
        }
        
        // No win condition check needed - game ends when timer runs out
    }
    
    private func hasPossibleMoves() -> Bool {
        // Check horizontal swaps
        for row in 0..<Self.gridSize {
            for col in 0..<(Self.gridSize - 1) {
                // Try swapping with right tile
                let temp = tiles[row][col]
                tiles[row][col] = tiles[row][col + 1]
                tiles[row][col + 1] = temp
                
                // Check if this creates a match
                if hasInitialMatches(in: tiles) {
                    // Swap back
                    tiles[row][col + 1] = tiles[row][col]
                    tiles[row][col] = temp
                    return true
                }
                
                // Swap back
                tiles[row][col + 1] = tiles[row][col]
                tiles[row][col] = temp
            }
        }
        
        // Check vertical swaps
        for row in 0..<(Self.gridSize - 1) {
            for col in 0..<Self.gridSize {
                // Try swapping with bottom tile
                let temp = tiles[row][col]
                tiles[row][col] = tiles[row + 1][col]
                tiles[row + 1][col] = temp
                
                // Check if this creates a match
                if hasInitialMatches(in: tiles) {
                    // Swap back
                    tiles[row + 1][col] = tiles[row][col]
                    tiles[row][col] = temp
                    return true
                }
                
                // Swap back
                tiles[row + 1][col] = tiles[row][col]
                tiles[row][col] = temp
            }
        }
        
        return false
    }
    
    private func findMatches() -> Bool {
        var hasMatches = false
        var matchedPositions = Set<CGPoint>()
        
        // First check if there are any possible moves left
        if !hasPossibleMoves() {
            // If no moves are possible, shuffle the board without resetting game state
            tiles = shuffleBoard()
            return false
        }
        
        // Check horizontal matches
        for row in 0..<Self.gridSize {
            for col in 0..<(Self.gridSize - 2) {
                let tile1 = tiles[row][col]
                let tile2 = tiles[row][col + 1]
                let tile3 = tiles[row][col + 2]
                
                if tile1.type == tile2.type && tile2.type == tile3.type {
                    matchedPositions.insert(CGPoint(x: col, y: row))
                    matchedPositions.insert(CGPoint(x: col + 1, y: row))
                    matchedPositions.insert(CGPoint(x: col + 2, y: row))
                    hasMatches = true
                }
            }
        }
        
        // Check vertical matches
        for col in 0..<Self.gridSize {
            for row in 0..<(Self.gridSize - 2) {
                let tile1 = tiles[row][col]
                let tile2 = tiles[row + 1][col]
                let tile3 = tiles[row + 2][col]
                
                if tile1.type == tile2.type && tile2.type == tile3.type {
                    matchedPositions.insert(CGPoint(x: col, y: row))
                    matchedPositions.insert(CGPoint(x: col, y: row + 1))
                    matchedPositions.insert(CGPoint(x: col, y: row + 2))
                    hasMatches = true
                }
            }
        }
        
        // Remove matched tiles and add score
        if hasMatches {
            // Start timer on first match
            startTimer()
            
            // Play match sound
            SoundManager.shared.playMatch()
            
            for position in matchedPositions {
                let tile = tiles[Int(position.y)][Int(position.x)]
                withAnimation(.easeOut(duration: matchAnimationDuration)) {
                    score += tile.type.points
                    tiles[Int(position.y)][Int(position.x)].isMatched = true
                }
            }
            
            // Apply gravity once after all matches are marked
            DispatchQueue.main.asyncAfter(deadline: .now() + matchAnimationDuration) {
                self.applyGravity()
                
                // Check for cascading matches after gravity settles
                DispatchQueue.main.asyncAfter(deadline: .now() + self.fallAnimationDuration) {
                    _ = self.findMatches()
                }
            }
        }
        
        return hasMatches
    }
    
    private func wouldCreateMatch(tile: GameTile, at position: CGPoint) -> Bool {
        let row = Int(position.y)
        let col = Int(position.x)
        
        // Check horizontal matches
        if col >= 2 {
            if tiles[row][col-1].type == tile.type && tiles[row][col-2].type == tile.type {
                return true
            }
        }
        if col <= Self.gridSize - 3 {
            if tiles[row][col+1].type == tile.type && tiles[row][col+2].type == tile.type {
                return true
            }
        }
        
        // Check vertical matches
        if row >= 2 {
            if tiles[row-1][col].type == tile.type && tiles[row-2][col].type == tile.type {
                return true
            }
        }
        if row <= Self.gridSize - 3 {
            if tiles[row+1][col].type == tile.type && tiles[row+2][col].type == tile.type {
                return true
            }
        }
        
        return false
    }
    
    private func endGame(hasWon: Bool) {
        timer?.invalidate()
        timer = nil
        isGameOver = true
        self.hasWon = hasWon
        
        // Score will be submitted by GameOverView
    }
    
    private func findTilePosition(_ tile: GameTile) -> CGPoint? {
        for row in 0..<Self.gridSize {
            for col in 0..<Self.gridSize {
                if tiles[row][col].id == tile.id {
                    return CGPoint(x: col, y: row)
                }
            }
        }
        return nil
    }
    
    private func isValidPosition(_ position: CGPoint) -> Bool {
        let row = Int(position.y)
        let col = Int(position.x)
        return row >= 0 && row < Self.gridSize && col >= 0 && col < Self.gridSize
    }
    
    private func areAdjacent(position1: CGPoint, position2: CGPoint) -> Bool {
        let rowDiff = abs(position1.y - position2.y)
        let colDiff = abs(position1.x - position2.x)
        return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1)
    }
    
    private func applyGravity() {
        // For each column
        for col in 0..<Self.gridSize {
            // Start from the bottom row
            var emptyRow = Self.gridSize - 1
            
            // Find and fill empty spaces
            for row in (0..<Self.gridSize).reversed() {
                if tiles[row][col].isMatched {
                    // Skip matched tiles
                    continue
                }
                
                if row != emptyRow {
                    // Move tile down with animation
                    withAnimation(.easeIn(duration: fallAnimationDuration)) {
                        tiles[emptyRow][col] = tiles[row][col]
                        tiles[emptyRow][col].position = CGPoint(x: col, y: emptyRow)
                        tiles[row][col].isMatched = true  // Mark old position as empty
                    }
                }
                
                emptyRow -= 1
            }
            
            // Fill empty spaces at the top with new tiles
            if emptyRow >= 0 {
                for row in 0...emptyRow {
                    withAnimation(.easeIn(duration: fallAnimationDuration).delay(0.2)) {
                        tiles[row][col] = GameTile.random(at: CGPoint(x: col, y: row))
                    }
                }
            }
        }
        
        // After gravity, check if any moves are possible
        if !hasPossibleMoves() {
            // If no moves are possible, shuffle the board without resetting game state
            tiles = shuffleBoard()
        }
    }
    
    private func hasInitialMatches(in grid: [[GameTile]]) -> Bool {
        // Check horizontal matches
        for row in 0..<Self.gridSize {
            for col in 0..<(Self.gridSize - 2) {
                let tile1 = grid[row][col]
                let tile2 = grid[row][col + 1]
                let tile3 = grid[row][col + 2]
                
                if tile1.type == tile2.type && tile2.type == tile3.type {
                    return true
                }
            }
        }
        
        // Check vertical matches
        for col in 0..<Self.gridSize {
            for row in 0..<(Self.gridSize - 2) {
                let tile1 = grid[row][col]
                let tile2 = grid[row + 1][col]
                let tile3 = grid[row + 2][col]
                
                if tile1.type == tile2.type && tile2.type == tile3.type {
                    return true
                }
            }
        }
        
        return false
    }
}
