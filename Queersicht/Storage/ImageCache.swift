import SwiftUI
import UIKit

@MainActor
class ImageCache {
    static let shared = ImageCache()
    
    private let fileManager = FileManager.default
    private let cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        return cache
    }()
    
    private var cacheDirectory: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imageCache = docs.appendingPathComponent("ImageCache", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: imageCache, withIntermediateDirectories: true)
            print("[ImageCache] Cache directory created/exists at: \(imageCache.path)")
            // List contents to verify
            let contents = try FileManager.default.contentsOfDirectory(at: imageCache, includingPropertiesForKeys: nil)
            print("[ImageCache] Cache contains \(contents.count) files")
            contents.forEach { print("[ImageCache] - \($0.lastPathComponent)") }
        } catch {
            print("[ImageCache] Error creating cache directory: \(error)")
        }
        return imageCache
    }()
    
    private init() {}
    
    /// Clear all cached images from both memory and disk
    func clearCache() async throws {
        // Clear memory cache
        cache.removeAllObjects()
        
        // Clear disk cache
        let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        for file in contents {
            try fileManager.removeItem(at: file)
        }
        print("[ImageCache] Cache cleared successfully")
    }
    
    // Different sizes for different use cases
    enum ImageSize {
        case thumbnail    // For grid/list views (160x90)
        case preview     // For cards (320x180)
        case full       // For detail views (640x360)
        
        var dimensions: (width: Int, height: Int) {
            switch self {
            case .thumbnail: return (160, 90)
            case .preview: return (320, 180)
            case .full: return (640, 360)
            }
        }
        
        var suffix: String {
            switch self {
            case .thumbnail: return "_thumb"
            case .preview: return "_preview"
            case .full: return "_full"
            }
        }
    }
    
    /// Check if an image exists in memory cache
    internal func checkMemoryCache(for url: URL, size: ImageSize) -> UIImage? {
        let key = cacheKey(for: url, size: size)
        return cache.object(forKey: key as NSString)
    }
    
    /// Load an image from cache or download and resize it
    internal func image(for url: URL, size: ImageSize) async throws -> UIImage {
        let cacheKey = cacheKey(for: url, size: size)
        print("[ImageCache] Loading image for key: \(cacheKey)")
        
        // Check memory cache first
        if let cachedImage = checkMemoryCache(for: url, size: size) {
            print("[ImageCache] Found in memory cache")
            return cachedImage
        }
        
        // Try disk cache
        if let diskImage = try? await loadFromDisk(key: cacheKey) {
            print("[ImageCache] Found in disk cache")
            return diskImage
        }
        
        // Try to download
        do {
            print("[ImageCache] Downloading from network")
            let image = try await downloadAndResize(url: url, size: size)
            
            // Save to both caches
            cache.setObject(image, forKey: cacheKey as NSString)
            try await saveToDisk(image: image, key: cacheKey)
            
            print("[ImageCache] Successfully downloaded and cached")
            return image
        } catch let error as NSError {
            print("[ImageCache] Download failed: \(error.localizedDescription)")
            
            // If offline, try disk cache one more time
            if error.code == NSURLErrorNotConnectedToInternet {
                if let diskImage = try? await loadFromDisk(key: cacheKey) {
                    print("[ImageCache] Recovered from disk cache after offline error")
                    return diskImage
                }
            }
            throw error
        }
    }
    
    /// Clear all cached images
    func clearCache() {
        cache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
    }
    
    // MARK: - Private Methods
    
    func cacheKey(for url: URL, size: ImageSize) -> String {
        // Create a unique filename from the URL path
        let urlPath = url.absoluteString
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "%20", with: "_")
        
        let key = "\(urlPath)_\(size.suffix).jpg"
        print("[ImageCache] Generated cache key: \(key)")
        return key
    }
    
    func loadFromDisk(key: String) async throws -> UIImage? {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        print("[ImageCache] Checking disk cache at: \(fileURL.path)")
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            print("[ImageCache] File does not exist at path")
            return nil
        }
        
        do {
            let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
            let fileSize = attributes[.size] as? Int64 ?? 0
            print("[ImageCache] Found file of size: \(fileSize) bytes")
            
            let data = try Data(contentsOf: fileURL)
            print("[ImageCache] Successfully read \(data.count) bytes")
            
            if let image = UIImage(data: data) {
                print("[ImageCache] Successfully created image from data")
                cache.setObject(image, forKey: key as NSString)
                return image
            }
            
            print("[ImageCache] Failed to create image from data, removing corrupted file")
            try? fileManager.removeItem(at: fileURL)
        } catch {
            print("[ImageCache] Error loading from disk: \(error)")
        }
        return nil
    }
    
    private func saveToDisk(image: UIImage, key: String) async throws {
        // Ensure directory exists
        try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        let fileURL = cacheDirectory.appendingPathComponent(key)
        
        print("[ImageCache] Saving image to: \(fileURL.path)")
        
        // Convert to data
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            print("[ImageCache] Failed to compress image")
            throw ImageCacheError.compressionFailed
        }
        
        // Write atomically
        do {
            try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
            print("[ImageCache] Successfully saved image (\(data.count) bytes)")
            
            // Verify file exists
            if fileManager.fileExists(atPath: fileURL.path) {
                print("[ImageCache] Verified file exists at: \(fileURL.path)")
            } else {
                print("[ImageCache] WARNING: File not found after save!")
            }
        } catch {
            print("[ImageCache] Error saving file: \(error)")
            throw error
        }
    }
    
    private func downloadAndResize(url: URL, size: ImageSize) async throws -> UIImage {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
        let (data, _) = try await URLSession.shared.data(for: request)
        guard let originalImage = UIImage(data: data) else {
            throw ImageCacheError.invalidImageData
        }
        
        let (targetWidth, targetHeight) = size.dimensions
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1  // Use points instead of pixels
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: targetWidth, height: targetHeight), format: format)
        return renderer.image { context in
            originalImage.draw(in: CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight))
        }
    }
}

// MARK: - Errors

extension ImageCache {
    enum ImageCacheError: LocalizedError {
        case invalidImageData
        case compressionFailed
        
        var errorDescription: String? {
            switch self {
            case .invalidImageData:
                return "Invalid image data received"
            case .compressionFailed:
                return "Failed to compress image"
            }
        }
    }
}
