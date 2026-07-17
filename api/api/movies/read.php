<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

ini_set('display_errors', 0);
ini_set('display_startup_errors', 0);
error_reporting(0);

// Custom error log
ini_set('log_errors', 1);
ini_set('error_log', dirname(__FILE__) . '/../../debug.log');
error_log("Starting movies/read.php at " . date('Y-m-d H:i:s'));

try {
    include_once '../../config/database.php';
    include_once '../../models/Movie.php';

    $database = new Database();
    $db = $database->getConnection();
    if (!$db) {
        throw new Exception("Database connection failed");
    }

    $movie = new Movie($db);
    $stmt = $movie->read();
    if ($stmt === false) {
        throw new Exception("Failed to read movies");
    }

    $movies_arr = array();
    error_log('Processing movies result set');
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        error_log('Movie row data: ' . print_r($row, true));
        if ($row === false) {
            throw new Exception("Error fetching row: " . print_r($stmt->errorInfo(), true));
        }
        
        // Get content notes if available
        $contentNotes = array();
        if (isset($row['contentNotes']) && !empty($row['contentNotes'])) {
            $noteIds = explode(',', $row['contentNotes']);
            foreach ($noteIds as $noteId) {
                $note_query = "SELECT * FROM content_notes WHERE id = ?";
                $note_stmt = $database->getConnection()->prepare($note_query);
                $note_stmt->bindParam(1, $noteId);
                $note_stmt->execute();
                
                if ($note = $note_stmt->fetch(PDO::FETCH_ASSOC)) {
                    $contentNotes[] = array(
                        "id" => $note['id'],
                        "title" => $note['title']
                    );
                }
            }
        }

        // Parse showing data if available
        $showings = array();
        if (isset($row['showingData']) && !empty($row['showingData'])) {
            $showingList = explode(',', $row['showingData']);
            foreach ($showingList as $showingItem) {
                $parts = explode('@@', $showingItem);
                if (count($parts) < 5) continue; // Need id, date, locationID, weblink, special_info
                
                $showing = array(
                    "id" => $parts[0],
                    "date" => $parts[1] . ':00Z', // Add seconds to ISO8601
                    "locationID" => $parts[2],
                    "weblink" => $parts[3],
                    "special_info" => $parts[4]
                );
                
                $showings[] = $showing;
            }
        }

        $movieItem = array(
            "id" => $row['id'] ?? null,
            "title" => $row['title'] ?? '',
            "description_de" => $row['description_de'] ?? null,
            "description_fr" => $row['description_fr'] ?? null,
            "duration" => isset($row['duration']) ? intval($row['duration']) : null,
            "imageURL" => $row['imageURL'] ?? null,
            "director" => $row['director'] ?? null,
            "originlang" => $row['originlang'] ?? null,
            "country" => $row['country'] ?? null,
            "subtitles" => $row['subtitles'] ?? null,
            "trailerURL" => $row['trailerURL'] ?? null,
            "contentNotes" => $contentNotes,
            "showings" => $showings
        );
        error_log('Processed movie item: ' . print_r($movieItem, true));

        array_push($movies_arr, $movieItem);
    }

    if (empty($movies_arr)) {
        http_response_code(404);
        echo json_encode(array("message" => "No movies found."));
    } else {
        error_log("JSON Response: " . json_encode($movies_arr, JSON_PRETTY_PRINT));
        http_response_code(200);
        echo json_encode($movies_arr);
    }

} catch (Exception $e) {
    error_log("Error in movies/read.php: " . $e->getMessage());
    http_response_code(500);
    $error = array(
        "message" => "Internal server error",
        "error" => $e->getMessage(),
        "trace" => $e->getTraceAsString()
    );
    error_log(print_r($error, true));
    echo json_encode($error);
}
