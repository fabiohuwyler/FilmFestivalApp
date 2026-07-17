<?php
class Movie {
    private $conn;
    private $table_name = "movies";

    public $id;
    public $title;
    public $description_de;
    public $description_fr;
    public $duration;
    public $imageURL;
    public $director;
    public $originlang;
    public $country;
    public $subtitles;
    public $trailerURL;
    public $content_notes;

    public function __construct($db) {
        $this->conn = $db;
    }

    public function read() {
        try {
            // First, check if the table exists
            $tableCheck = $this->conn->query("SHOW TABLES LIKE '" . $this->table_name . "'");
            if (!$tableCheck || $tableCheck->rowCount() === 0) {
                error_log('Table ' . $this->table_name . ' does not exist');
                throw new Exception('Table ' . $this->table_name . ' does not exist');
            }

            // Check table structure
            $columns = $this->conn->query("DESCRIBE " . $this->table_name);
            if (!$columns) {
                error_log('Failed to get table structure: ' . print_r($this->conn->errorInfo(), true));
                throw new Exception('Failed to get table structure');
            }

            // Check if tables exist and their structure
            $cnTableCheck = $this->conn->query("SHOW TABLES LIKE 'content_notes'");
            $hasContentNotes = ($cnTableCheck && $cnTableCheck->rowCount() > 0);
            
            $showingsTableCheck = $this->conn->query("SHOW TABLES LIKE 'showings'");
            $hasShowings = ($showingsTableCheck && $showingsTableCheck->rowCount() > 0);
            
            // Get showings table structure
            $showingColumns = array();
            if ($hasShowings) {
                error_log('Checking showings table structure');
                $columnsResult = $this->conn->query("DESCRIBE showings");
                if ($columnsResult) {
                    while ($column = $columnsResult->fetch(PDO::FETCH_ASSOC)) {
                        $showingColumns[] = $column['Field'];
                        error_log('Found column: ' . $column['Field']);
                    }
                } else {
                    error_log('Failed to get showings table structure');
                }
            }
            
            // Build the query
            if ($hasContentNotes && $hasShowings) {
                error_log('Content notes and showings tables exist');
                $showingFields = array('id', 'date');
                if (in_array('locationID', $showingColumns)) {
                    $showingFields[] = 'locationID';
                }
                if (in_array('weblink', $showingColumns)) {
                    $showingFields[] = 'weblink';
                }
                if (in_array('special_info', $showingColumns)) {
                    $showingFields[] = 'special_info';
                }
                
                error_log('Using showing fields: ' . implode(', ', $showingFields));
                
                $concatFields = array();
                foreach ($showingFields as $field) {
                    if ($field === 'date') {
                        $concatFields[] = "DATE_FORMAT(s.date, '%Y-%m-%dT%H:%i')"; 
                    } else {
                        if ($field === 'weblink') {
                            $concatFields[] = "COALESCE(s.$field, '')"; // Use COALESCE to preserve full URL
                        } else {
                            $concatFields[] = "IFNULL(s.$field,'')"; 
                        }; 
                    }
                }
                
                $query = "SELECT m.id, m.title, m.description_de, m.description_fr, m.duration, m.imageURL, m.director, m.originlang, m.country, m.subtitles, m.trailerURL, 
                         GROUP_CONCAT(DISTINCT cn.id) as contentNotes,
                         GROUP_CONCAT(DISTINCT CONCAT_WS('@@', " . implode(", ", $concatFields) . ")) as showingData
                         FROM " . $this->table_name . " m 
                         LEFT JOIN movie_content_notes mcn ON m.id = mcn.movie_id
                         LEFT JOIN content_notes cn ON mcn.content_note_id = cn.id
                         LEFT JOIN showings s ON s.movieID = m.id
                         GROUP BY m.id";
            error_log('Movie read query: ' . $query);
            } else if ($hasContentNotes) {
                error_log('Only content notes table exists');
                $query = "SELECT m.id, m.title, m.description_de, m.description_fr, m.duration, m.imageURL, m.director, m.originlang, m.country, m.subtitles, m.trailerURL, 
                         GROUP_CONCAT(cn.id) as content_note_ids 
                         FROM " . $this->table_name . " m 
                         LEFT JOIN movie_content_notes mcn ON m.id = mcn.movie_id
                         LEFT JOIN content_notes cn ON mcn.content_note_id = cn.id
                         GROUP BY m.id";
            } else if ($hasShowings) {
                error_log('Only showings table exists');
                $showingFields = array('id', 'date');
                if (in_array('locationID', $showingColumns)) {
                    $showingFields[] = 'locationID';
                }
                if (in_array('weblink', $showingColumns)) {
                    $showingFields[] = 'weblink';
                }
                
                $concatFields = array();
                foreach ($showingFields as $field) {
                    if ($field === 'date') {
                        $concatFields[] = "DATE_FORMAT(s.date, '%Y-%m-%dT%H:%i')"; 
                    } else {
                        if ($field === 'weblink') {
                            $concatFields[] = "COALESCE(s.$field, '')"; // Use COALESCE to preserve full URL
                        } else {
                            $concatFields[] = "IFNULL(s.$field,'')"; 
                        }; 
                    }
                }
                
                $query = "SELECT m.*, 
                         GROUP_CONCAT(CONCAT(" . implode(",':', ", $concatFields) . ")) as showing_data
                         FROM " . $this->table_name . " m 
                         LEFT JOIN showings s ON s.movieId = m.id
                         GROUP BY m.id";
            } else {
                error_log('No related tables exist');
                $query = "SELECT * FROM " . $this->table_name;
            }
            
            $stmt = $this->conn->prepare($query);
            if (!$stmt) {
                $error = $this->conn->errorInfo();
                error_log('Prepare failed: ' . print_r($error, true));
                throw new Exception('Failed to prepare statement: ' . $error[2]);
            }
            
            if (!$stmt->execute()) {
                $error = $stmt->errorInfo();
                error_log('Execute failed: ' . print_r($error, true));
                throw new Exception('Failed to execute statement: ' . $error[2]);
            }
            
            return $stmt;
        } catch (Exception $e) {
            error_log('Exception in Movie::read(): ' . $e->getMessage());
            throw $e;
        }
    }

    public function readOne() {
        try {
            $query = "SELECT m.*, GROUP_CONCAT(cn.id) as content_notes 
                     FROM " . $this->table_name . " m 
                     LEFT JOIN movie_content_notes mcn ON m.id = mcn.movie_id 
                     LEFT JOIN content_notes cn ON mcn.content_note_id = cn.id 
                     WHERE m.id = ? 
                     GROUP BY m.id 
                     LIMIT 0,1";
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(1, $this->id);
            $stmt->execute();
            
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($row) {
                $this->title = $row['title'];
                $this->description_de = $row['description_de'] ?? null;
                $this->description_fr = $row['description_fr'] ?? null;
                $this->duration = $row['duration'];
                $this->imageURL = $row['imageURL'] ?? null;
                $this->director = $row['director'] ?? null;
                $this->originlang = $row['originlang'] ?? null;
                $this->country = $row['country'] ?? null;
                $this->subtitles = $row['subtitles'] ?? null;
                $this->trailerURL = $row['trailerURL'] ?? null;
                $this->content_notes = $row['content_notes'] ?? null;
                return true;
            }
            return false;
        } catch(PDOException $e) {
            error_log('Error reading movie: ' . $e->getMessage());
            throw new Exception('Database error: ' . $e->getMessage());
        }
    }

    public function getShowings() {
        $query = "SELECT * FROM showings WHERE movieID = ?";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $this->id);
        $stmt->execute();
        return $stmt;
    }

    private function generateUUID() {
        return sprintf('%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
            mt_rand(0, 0xffff), mt_rand(0, 0xffff),
            mt_rand(0, 0xffff),
            mt_rand(0, 0x0fff) | 0x4000,
            mt_rand(0, 0x3fff) | 0x8000,
            mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
        );
    }

    public function create() {
        try {
            $this->conn->beginTransaction();

            $query = "INSERT INTO " . $this->table_name . "
                    (id, title, description_de, description_fr, duration, imageURL, director, originlang, country, subtitles, trailerURL)
                    VALUES (:id, :title, :description_de, :description_fr, :duration, :imageURL, :director, :originlang, :country, :subtitles, :trailerURL)";

            $stmt = $this->conn->prepare($query);

            // Generate UUID if not provided
            if (!$this->id) {
                $this->id = $this->generateUUID();
            }

            // Sanitize input
            $this->title = htmlspecialchars(strip_tags($this->title));
            $this->description_de = $this->description_de ? htmlspecialchars(strip_tags($this->description_de)) : null;
            $this->description_fr = $this->description_fr ? htmlspecialchars(strip_tags($this->description_fr)) : null;
            $this->duration = $this->duration ? filter_var($this->duration, FILTER_SANITIZE_NUMBER_INT) : null;
            $this->imageURL = $this->imageURL ? htmlspecialchars(strip_tags($this->imageURL)) : null;
            $this->director = $this->director ? htmlspecialchars(strip_tags($this->director)) : null;
            $this->originlang = $this->originlang ? htmlspecialchars(strip_tags($this->originlang)) : null;
            $this->country = $this->country ? htmlspecialchars(strip_tags($this->country)) : null;
            $this->subtitles = $this->subtitles ? htmlspecialchars(strip_tags($this->subtitles)) : null;
            $this->trailerURL = $this->trailerURL ? htmlspecialchars(strip_tags($this->trailerURL)) : null;

            // Bind values
            $stmt->bindParam(':id', $this->id);
            $stmt->bindParam(':title', $this->title);
            $stmt->bindParam(':description_de', $this->description_de);
            $stmt->bindParam(':description_fr', $this->description_fr);
            $stmt->bindParam(':duration', $this->duration);
            $stmt->bindParam(':imageURL', $this->imageURL);
            $stmt->bindParam(':director', $this->director);
            $stmt->bindParam(':originlang', $this->originlang);
            $stmt->bindParam(':country', $this->country);
            $stmt->bindParam(':subtitles', $this->subtitles);
            $stmt->bindParam(':trailerURL', $this->trailerURL);

            if($stmt->execute()) {
                // Handle content notes if provided
                if ($this->content_notes) {
                    $notes = explode(',', $this->content_notes);
                    foreach ($notes as $noteId) {
                        if (!empty($noteId)) {
                            $query = "INSERT INTO movie_content_notes (movie_id, content_note_id) VALUES (:movie_id, :note_id)";
                            $stmt = $this->conn->prepare($query);
                            $stmt->bindParam(':movie_id', $this->id);
                            $stmt->bindParam(':note_id', $noteId);
                            $stmt->execute();
                        }
                    }
                }
                $this->conn->commit();
                return true;
            }
            $this->conn->rollBack();
            return false;
        } catch (Exception $e) {
            $this->conn->rollBack();
            throw $e;
        }
    }

    public function update() {
        try {
            $this->conn->beginTransaction();

            // Update movie details
            $query = "UPDATE " . $this->table_name . "
                    SET
                        title = :title,
                        description_de = :description_de,
                        description_fr = :description_fr,
                        duration = :duration,
                        imageURL = :imageURL,
                        director = :director,
                        originlang = :originlang,
                        country = :country,
                        subtitles = :subtitles,
                        trailerURL = :trailerURL
                    WHERE
                        id = :id";

            $stmt = $this->conn->prepare($query);

            // Bind values
            $stmt->bindParam(':title', $this->title);
            $stmt->bindParam(':description_de', $this->description_de);
            $stmt->bindParam(':description_fr', $this->description_fr);
            $stmt->bindParam(':duration', $this->duration);
            $stmt->bindParam(':imageURL', $this->imageURL);
            $stmt->bindParam(':director', $this->director);
            $stmt->bindParam(':originlang', $this->originlang);
            $stmt->bindParam(':country', $this->country);
            $stmt->bindParam(':subtitles', $this->subtitles);
            $stmt->bindParam(':trailerURL', $this->trailerURL);
            $stmt->bindParam(':id', $this->id);

            if($stmt->execute()) {
                // Update content notes
                // First, remove all existing notes for this movie
                $query = "DELETE FROM movie_content_notes WHERE movie_id = :movie_id";
                $stmt = $this->conn->prepare($query);
                $stmt->bindParam(':movie_id', $this->id);
                $stmt->execute();

                // Then add the new notes
                if ($this->content_notes) {
                    $notes = explode(',', $this->content_notes);
                    foreach ($notes as $noteId) {
                        if (!empty($noteId)) {
                            $query = "INSERT INTO movie_content_notes (movie_id, content_note_id) VALUES (:movie_id, :note_id)";
                            $stmt = $this->conn->prepare($query);
                            $stmt->bindParam(':movie_id', $this->id);
                            $stmt->bindParam(':note_id', $noteId);
                            $stmt->execute();
                        }
                    }
                }
                $this->conn->commit();
                return true;
            }
            $this->conn->rollBack();
            return false;
        } catch (Exception $e) {
            $this->conn->rollBack();
            throw $e;
        }
    }

    public function delete() {
        try {
            // Delete related records first
            $this->conn->beginTransaction();

            // Delete from movie_content_notes
            $query = "DELETE FROM movie_content_notes WHERE movie_id = ?";
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(1, $this->id);
            $stmt->execute();

            // Delete from showings
            $query = "DELETE FROM showings WHERE movieID = ?";
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(1, $this->id);
            $stmt->execute();

            // Delete the movie
            $query = "DELETE FROM " . $this->table_name . " WHERE id = ?";
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(1, $this->id);
            
            $result = $stmt->execute();
            $this->conn->commit();
            return $result;
        } catch(PDOException $e) {
            $this->conn->rollBack();
            error_log('Error deleting movie: ' . $e->getMessage());
            throw new Exception('Database error: ' . $e->getMessage());
        }
    }
}
