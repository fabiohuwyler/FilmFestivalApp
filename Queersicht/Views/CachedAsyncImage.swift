import SwiftUI

struct CachedAsyncImage: View {
    let url: URL?
    let size: ImageCache.ImageSize
    @State private var image: UIImage?
    @State private var isLoading = false
    
    init(url: URL?, size: ImageCache.ImageSize = .preview) {
        self.url = url
        self.size = size
    }
    
    var body: some View {
        Group {
            if let displayImage = image {
                Image(uiImage: displayImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color.gray.opacity(0.2)
                    .overlay {
                        if isLoading {
                            ProgressView()
                        } else {
                            Image(systemName: "photo")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                        }
                    }
            }
        }
        .onAppear {
            Task {
                await loadImage()
            }
        }
    }
    
    private func loadImage() async {
        guard let url = url else { return }
        guard image == nil else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        let cacheKey = ImageCache.shared.cacheKey(for: url, size: size)
        
        // First try memory cache
        if let memoryImage = ImageCache.shared.checkMemoryCache(for: url, size: size) {
            print("[CachedAsyncImage] Found in memory cache")
            image = memoryImage
            return
        }
        
        // Then try disk cache with retries
        for attempt in 1...3 {
            print("[CachedAsyncImage] Trying disk cache (attempt \(attempt))")
            if let diskImage = try? await ImageCache.shared.loadFromDisk(key: cacheKey) {
                print("[CachedAsyncImage] Loaded from disk cache")
                image = diskImage
                return
            }
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s between attempts
        }
        
        // Finally try network
        do {
            print("[CachedAsyncImage] Trying network load")
            let downloadedImage = try await ImageCache.shared.image(for: url, size: size)
            image = downloadedImage
            print("[CachedAsyncImage] Successfully downloaded")
        } catch {
            print("[CachedAsyncImage] Network error: \(error.localizedDescription)")
            // One last try from disk after network failure
            if let lastChanceImage = try? await ImageCache.shared.loadFromDisk(key: cacheKey) {
                print("[CachedAsyncImage] Recovered from disk after network failure")
                image = lastChanceImage
            }
        }
    }
}
