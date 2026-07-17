<?php
// Required headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: access");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Credentials: true");
header("Content-Type: application/json");

// Include database and object files
include_once '../../config/database.php';
include_once '../../models/Movie.php';

// Get database connection
$database = new Database();
$db = $database->getConnection();

// Initialize movie object
$movie = new Movie($db);

// Set ID property of movie to be read
$movie->id = isset($_GET['id']) ? $_GET['id'] : die();

// Read the details of movie to be edited
$movie->readOne();

// Create array
$movie_arr = array(
    "id" =>  $movie->id,
    "title" => $movie->title,
    "description_de" => $movie->description_de,
    "description_fr" => $movie->description_fr,
    "duration" => $movie->duration,
    "imageURL" => $movie->imageURL,
    "director" => $movie->director,
    "originlang" => $movie->originlang,
    "country" => $movie->country,
    "subtitles" => $movie->subtitles,
    "trailerURL" => $movie->trailerURL,
    "content_notes" => $movie->content_notes
);

// Make it json format
print_r(json_encode($movie_arr));
?>
