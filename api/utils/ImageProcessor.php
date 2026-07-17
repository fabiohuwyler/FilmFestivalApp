<?php
class ImageProcessor {
    private $uploadDir;
    private $maxWidth = 800;  // Max width for thumbnails
    private $maxHeight = 800; // Max height for thumbnails
    private $quality = 80;    // JPEG quality for thumbnails

    private $baseUrl;

    public function __construct() {
        // Store files directly in api/uploads directory
        $this->uploadDir = dirname(__DIR__) . '/uploads/';
        $this->baseUrl = 'https://example.com';
    }

    public function processUploadedImage($file, $type) {
        if (!in_array($type, ['movies', 'events', 'locations'])) {
            throw new Exception('Invalid image type');
        }

        // Validate file
        $this->validateImage($file);

        // Generate unique filename
        $filename = uniqid() . '_' . basename($file['name']);
        $originalDir = $this->uploadDir . $type . '/original/';
        $thumbDir = $this->uploadDir . $type . '/thumb/';

        // Ensure directories exist
        if (!file_exists($originalDir)) mkdir($originalDir, 0755, true);
        if (!file_exists($thumbDir)) mkdir($thumbDir, 0755, true);

        // Save original
        $originalPath = $originalDir . $filename;
        if (!move_uploaded_file($file['tmp_name'], $originalPath)) {
            throw new Exception('Failed to save original image');
        }

        // Create and save thumbnail
        $thumbPath = $thumbDir . $filename;
        $this->createThumbnail($originalPath, $thumbPath);

        return [
            'filename' => $filename,
            'original_url' => $this->baseUrl . '/uploads/' . $type . '/original/' . $filename,
            'thumb_url' => $this->baseUrl . '/uploads/' . $type . '/thumb/' . $filename
        ];
    }

    private function validateImage($file) {
        if (!isset($file['tmp_name']) || !is_uploaded_file($file['tmp_name'])) {
            throw new Exception('No file uploaded');
        }

        $allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
        if (!in_array($file['type'], $allowedTypes)) {
            throw new Exception('Invalid file type. Only JPG, PNG and GIF are allowed.');
        }

        $maxFileSize = 5 * 1024 * 1024; // 5MB
        if ($file['size'] > $maxFileSize) {
            throw new Exception('File too large. Maximum size is 5MB.');
        }
    }

    private function createThumbnail($sourcePath, $targetPath) {
        list($width, $height, $type) = getimagesize($sourcePath);
        
        // Calculate new dimensions
        $ratio = min($this->maxWidth / $width, $this->maxHeight / $height);
        $newWidth = round($width * $ratio);
        $newHeight = round($height * $ratio);

        // Create new image
        $thumb = imagecreatetruecolor($newWidth, $newHeight);
        
        // Handle transparency for PNG
        if ($type == IMAGETYPE_PNG) {
            imagealphablending($thumb, false);
            imagesavealpha($thumb, true);
        }

        // Load source image
        switch ($type) {
            case IMAGETYPE_JPEG:
                $source = imagecreatefromjpeg($sourcePath);
                break;
            case IMAGETYPE_PNG:
                $source = imagecreatefrompng($sourcePath);
                break;
            case IMAGETYPE_GIF:
                $source = imagecreatefromgif($sourcePath);
                break;
            default:
                throw new Exception('Unsupported image type');
        }

        // Resize
        imagecopyresampled($thumb, $source, 0, 0, 0, 0, $newWidth, $newHeight, $width, $height);

        // Save thumbnail
        switch ($type) {
            case IMAGETYPE_JPEG:
                imagejpeg($thumb, $targetPath, $this->quality);
                break;
            case IMAGETYPE_PNG:
                imagepng($thumb, $targetPath, 9); // PNG quality is 0-9
                break;
            case IMAGETYPE_GIF:
                imagegif($thumb, $targetPath);
                break;
        }

        // Clean up
        imagedestroy($source);
        imagedestroy($thumb);
    }
}
?>
