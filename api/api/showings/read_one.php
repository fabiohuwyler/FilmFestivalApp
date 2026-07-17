<?php
// Required headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: access");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Credentials: true");
header("Content-Type: application/json");

// Include database and object files
include_once '../../config/database.php';
include_once '../../models/Showing.php';

// Get database connection
$database = new Database();
$db = $database->getConnection();

// Initialize showing object
$showing = new Showing($db);

// Set ID property of showing to read
$showing->id = isset($_GET['id']) ? $_GET['id'] : die();

// Read the details of showing to be edited
try {
    $row = $showing->readOne();
    error_log('Read One Result: ' . print_r($row, true));

    if ($row) {
        // Create array
        $showing_arr = array(
            "id" => $row['id'],
            "date" => $row['date'],
            "locationID" => $row['locationID'],
            "movieID" => $row['movieID'],
            "movie_title" => $row['movie_title'],
            "weblink" => $row['weblink'] ?? null,
            "special_info" => $row['special_info'] ?? null,
            "location_name_de" => $row['location_name_de'] ?? null,
            "location_name_fr" => $row['location_name_fr'] ?? null
        );

        error_log('Sending response: ' . print_r($showing_arr, true));

        // Set response code - 200 OK
        http_response_code(200);

        // Make it json format
        echo json_encode($showing_arr);
    } else {
        // Set response code - 404 Not found
        http_response_code(404);

        // Tell the user showing does not exist
        echo json_encode(array("message" => "Showing does not exist."));
    }
} catch(Exception $e) {
    // Set response code - 503 Service unavailable
    http_response_code(503);

    // Tell the user
    echo json_encode(array(
        "message" => "Unable to read showing.",
        "error" => $e->getMessage()
    ));
}
?>
