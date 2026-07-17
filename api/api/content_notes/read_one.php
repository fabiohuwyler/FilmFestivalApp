<?php
// Required headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: access");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Credentials: true");
header("Content-Type: application/json");

// Include database and object files
include_once '../../config/database.php';
include_once '../../models/ContentNote.php';

// Get database connection
$database = new Database();
$db = $database->getConnection();

// Initialize content note object
$contentNote = new ContentNote($db);

// Set ID property of content note to be read
$contentNote->id = isset($_GET['id']) ? $_GET['id'] : die();

// Read the details of content note
try {
    if ($contentNote->readOne()) {
        // Create array
        $content_note_arr = array(
            "id" => $contentNote->id,
            "title" => $contentNote->title
        );

        http_response_code(200);
        echo json_encode($content_note_arr);
    } else {
        http_response_code(404);
        echo json_encode(array("message" => "Content note not found."));
    }
} catch (Exception $e) {
    http_response_code(503);
    echo json_encode(array("message" => $e->getMessage()));
}
