<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Enable error logging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Set up logging
function logMessage($message) {
    error_log(date('Y-m-d H:i:s') . " - " . $message . "\n", 3, __DIR__ . '/debug.log');
}

logMessage('Script started');

// Get the JSON data from the request
$json = file_get_contents('php://input');
logMessage('Received data: ' . $json);

$data = json_decode($json, true);

if ($data && isset($data['highscores'])) {
    $file_path = __DIR__ . '/highscores.json';
    logMessage('Writing to file: ' . $file_path);
    
    // Make sure the directory is writable
    if (!is_writable(__DIR__)) {
        logMessage('Directory is not writable: ' . __DIR__);
        http_response_code(500);
        echo json_encode([
            'error' => 'Directory not writable',
            'path' => __DIR__
        ]);
        exit;
    }
    
    // If file doesn't exist, create it with proper permissions
    if (!file_exists($file_path)) {
        logMessage('File does not exist, creating it');
        touch($file_path);
        chmod($file_path, 0666);
    }
    
    // Write to the JSON file
    $result = file_put_contents($file_path, $json);
    logMessage('Write result: ' . ($result === false ? 'FAILED' : 'SUCCESS'));
    
    if ($result === false) {
        http_response_code(500);
        $error_info = [
            'error' => 'Failed to write file',
            'file_path' => $file_path,
            'permissions' => [
                'file' => file_exists($file_path) ? substr(sprintf('%o', fileperms($file_path)), -4) : 'file_not_found',
                'dir' => substr(sprintf('%o', fileperms(__DIR__)), -4),
                'php_user' => get_current_user(),
                'is_writable_dir' => is_writable(__DIR__) ? 'yes' : 'no',
                'is_writable_file' => file_exists($file_path) && is_writable($file_path) ? 'yes' : 'no'
            ]
        ];
        logMessage('Error info: ' . json_encode($error_info));
        echo json_encode($error_info);
    } else {
        // Verify the file was written
        $written_content = file_get_contents($file_path);
        logMessage('Verification read: ' . $written_content);
        
        if ($written_content === $json) {
            logMessage('Verification successful');
            echo $json;
        } else {
            logMessage('Verification failed - content mismatch');
            http_response_code(500);
            echo json_encode([
                'error' => 'Verification failed',
                'written' => $written_content,
                'expected' => $json
            ]);
        }
    }
} else {
    logMessage('Invalid JSON data received');
    http_response_code(400);
    echo json_encode([
        'error' => 'Invalid JSON data',
        'received' => $json
    ]);
}
?>
