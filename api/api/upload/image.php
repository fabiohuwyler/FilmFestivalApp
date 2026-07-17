<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Include required files
$basePath = dirname(dirname(dirname(__FILE__)));
include_once $basePath . '/utils/ImageProcessor.php';

try {
    // Log request details
    error_log('Upload request received');
    error_log('POST data: ' . print_r($_POST, true));
    error_log('FILES data: ' . print_r($_FILES, true));

    // Validate request
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new Exception('Invalid request method: ' . $_SERVER['REQUEST_METHOD']);
    }

    if (!isset($_POST['type']) || !isset($_FILES['image'])) {
        error_log('Missing parameters. POST: ' . print_r($_POST, true) . ' FILES: ' . print_r($_FILES, true));
        throw new Exception('Missing required parameters');
    }

    $type = $_POST['type'];
    $file = $_FILES['image'];

    error_log('Processing image of type: ' . $type);
    error_log('File details: ' . print_r($file, true));

    // Process image
    if (!is_dir($basePath . '/uploads')) {
        mkdir($basePath . '/uploads', 0755, true);
        error_log('Created uploads directory');
    }

    $processor = new ImageProcessor();
    $result = $processor->processUploadedImage($file, $type);
    error_log('Upload directory: ' . $basePath . '/uploads');
    
    error_log('Image processed successfully. Result: ' . print_r($result, true));

    // Return success response
    http_response_code(201);
    echo json_encode([
        'status' => 'success',
        'data' => $result
    ]);

} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ]);
}
?>
