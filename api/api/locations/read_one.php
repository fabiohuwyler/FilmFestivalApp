<?php
// Required headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: access");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Credentials: true");
header("Content-Type: application/json");

// Include database and object files
include_once '../../config/database.php';
include_once '../../models/Location.php';

// Get database connection
$database = new Database();
$db = $database->getConnection();

// Initialize location object
$location = new Location($db);

// Set ID property of location to read
$location->id = isset($_GET['id']) ? $_GET['id'] : die();

// Read the details of location to be edited
try {
    $row = $location->readOne();

    if ($row) {
        // Create array
        $location_arr = array(
            "id" => $location->id,
            "name_de" => $location->name_de,
            "name_fr" => $location->name_fr,
            "address_de" => $location->address_de,
            "address_fr" => $location->address_fr,
            "latitude" => $location->latitude,
            "longitude" => $location->longitude,
            "accessibilityInfo_de" => $location->accessibilityInfo_de,
            "accessibilityInfo_fr" => $location->accessibilityInfo_fr,
            "imageURL" => $location->imageURL,
            "description_de" => $location->description_de,
            "description_fr" => $location->description_fr,
            "weblink" => $location->weblink
        );

        // Set response code - 200 OK
        http_response_code(200);

        // Make it json format
        echo json_encode($location_arr);
    } else {
        // Set response code - 404 Not found
        http_response_code(404);

        // Tell the user location does not exist
        echo json_encode(array("message" => "Location does not exist."));
    }
} catch(Exception $e) {
    // Set response code - 503 Service unavailable
    http_response_code(503);

    // Tell the user
    echo json_encode(array(
        "message" => "Unable to read location.",
        "error" => $e->getMessage()
    ));
}
?>
