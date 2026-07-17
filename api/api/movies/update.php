<?php
// Required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Include database and object files
include_once '../../config/database.php';
include_once '../../models/Movie.php';

// Get database connection
$database = new Database();
$db = $database->getConnection();

// Initialize movie object
$movie = new Movie($db);

// Get posted data
$data = json_decode(file_get_contents("php://input"));

// Make sure all required fields are present
if (
    empty($data->id) ||
    empty($data->title) ||
    empty($data->duration)
) {
    http_response_code(400);
    echo json_encode(array("message" => "Unable to update movie. Required data is incomplete."));
    exit();
}

// Set movie property values
$movie->id = $data->id;
$movie->title = $data->title;
$movie->description_de = $data->description_de ?? null;
$movie->description_fr = $data->description_fr ?? null;
$movie->duration = $data->duration;
$movie->imageURL = $data->imageURL ?? null;
$movie->director = $data->director ?? null;
$movie->originlang = $data->originlang ?? null;
$movie->country = $data->country ?? null;
$movie->subtitles = $data->subtitles ?? null;
$movie->trailerURL = $data->trailerURL ?? null;
$movie->content_notes = $data->content_notes ?? null;

// Update the movie
try {
    if($movie->update()) {
        http_response_code(200);
        echo json_encode(array("message" => "Movie was updated."));
    } else {
        http_response_code(503);
        echo json_encode(array("message" => "Unable to update movie."));
    }
} catch(Exception $e) {
    http_response_code(503);
    echo json_encode(array(
        "message" => "Unable to update movie.",
        "error" => $e->getMessage()
    ));
}
?>
