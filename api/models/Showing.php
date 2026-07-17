<?php
class Showing {
    private $conn;
    private $table_name = "showings";

    public $id;
    public $date;
    public $locationID;
    public $movieID;
    public $weblink;
    public $special_info;

    public function __construct($db) {
        $this->conn = $db;
    }

    public function read() {
        $query = "SELECT s.id, s.date, s.locationID, s.weblink, s.movieID, s.special_info, 
                        l.name_de as location_name_de, l.name_fr as location_name_fr,
                        m.title as movie_title, m.id as movie_db_id
                 FROM " . $this->table_name . " s
                 LEFT JOIN movies m ON s.movieID = m.id
                 LEFT JOIN locations l ON s.locationID = l.id
                 ORDER BY s.date ASC";
        error_log('Executing query: ' . $query);
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        
        // Debug: Print first row
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        error_log('First row: ' . print_r($row, true));
        $stmt->execute(); // Reset for actual use
        
        return $stmt;
    }

    public function readForMovie($movieId) {
        $query = "SELECT s.id, s.date, s.locationID, s.weblink, s.movieID, s.special_info,
                        l.name_de as location_name_de, l.name_fr as location_name_fr,
                        m.title as movie_title
                 FROM " . $this->table_name . " s
                 INNER JOIN movies m ON s.movieID = m.id
                 LEFT JOIN locations l ON s.locationID = l.id
                 WHERE s.movieID = ?
                 ORDER BY s.date ASC";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $movieId);
        $stmt->execute();
        return $stmt;
    }

    public function readOne() {
        try {
            $query = "SELECT s.id, s.date, s.locationID, s.weblink, s.movieID, s.special_info,
                        l.name_de as location_name_de, l.name_fr as location_name_fr,
                        m.title as movie_title
                 FROM " . $this->table_name . " s
                 INNER JOIN movies m ON s.movieID = m.id
                 LEFT JOIN locations l ON s.locationID = l.id
                 WHERE s.id = ? LIMIT 0,1";
            error_log('Executing query: ' . $query . ' with id: ' . $this->id);
            
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(1, $this->id);
            $stmt->execute();
            
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            error_log('Row data: ' . print_r($row, true));
            
            if ($row) {
                $this->date = $row['date'];
                $this->locationID = $row['locationID'];
                $this->movieID = $row['movieID'];
                $this->weblink = $row['weblink'] ?? null;
                $this->special_info = $row['special_info'] ?? null;
            } else {
                error_log('No showing found with id: ' . $this->id);
                return false;
            }
            
            return $row;
        } catch (PDOException $e) {
            error_log('Error in Showing readOne: ' . $e->getMessage());
            throw $e;
        }
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
            // Check table structure
            $describeQuery = "DESCRIBE " . $this->table_name;
            $describeStmt = $this->conn->query($describeQuery);
            $columns = $describeStmt->fetchAll(PDO::FETCH_COLUMN);
            error_log('Table columns: ' . print_r($columns, true));
            $query = "INSERT INTO " . $this->table_name . "
                    (id, date, locationID, weblink, movieID, special_info)
                    VALUES (?, ?, ?, ?, ?, ?)";

            $stmt = $this->conn->prepare($query);

            // Generate UUID
            $this->id = $this->generateUUID();

            // Sanitize input
            $this->date = htmlspecialchars(strip_tags($this->date));
            $this->locationID = htmlspecialchars(strip_tags($this->locationID));
            $this->weblink = $this->weblink ? htmlspecialchars(strip_tags($this->weblink)) : null;
            $this->movieID = htmlspecialchars(strip_tags($this->movieID));

            // Bind values
            $stmt->bindParam(1, $this->id);
            $stmt->bindParam(2, $this->date);
            $stmt->bindParam(3, $this->locationID);
            $stmt->bindParam(4, $this->weblink);
            $stmt->bindParam(5, $this->movieID);
            $stmt->bindParam(6, $this->special_info);

            if($stmt->execute()) {
                return true;
            }
            return false;
        } catch(PDOException $e) {
            error_log('Error creating showing: ' . $e->getMessage());
            throw new Exception('Database error: ' . $e->getMessage());
        }
    }

    public function update() {
        try {
            $query = "UPDATE " . $this->table_name . "
                    SET date = ?, locationID = ?, movieID = ?,
                        weblink = ?, special_info = ?
                    WHERE id = ?";

            $stmt = $this->conn->prepare($query);

            // Sanitize input
            $this->date = htmlspecialchars(strip_tags($this->date));
            $this->locationID = htmlspecialchars(strip_tags($this->locationID));
            $this->movieID = htmlspecialchars(strip_tags($this->movieID));
            $this->weblink = $this->weblink ? htmlspecialchars(strip_tags($this->weblink)) : null;
            $this->special_info = $this->special_info ? htmlspecialchars(strip_tags($this->special_info)) : null;

            // Bind values
            $stmt->bindParam(1, $this->date);
            $stmt->bindParam(2, $this->locationID);
            $stmt->bindParam(3, $this->movieID);
            $stmt->bindParam(4, $this->weblink);
            $stmt->bindParam(5, $this->special_info);
            $stmt->bindParam(6, $this->id);

            return $stmt->execute();
        } catch(PDOException $e) {
            error_log('Error updating showing: ' . $e->getMessage());
            throw new Exception('Database error: ' . $e->getMessage());
        }
    }

    public function delete() {
        try {
            $query = "DELETE FROM " . $this->table_name . " WHERE id = ?";
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(1, $this->id);
            return $stmt->execute();
        } catch(PDOException $e) {
            error_log('Error deleting showing: ' . $e->getMessage());
            throw new Exception('Database error: ' . $e->getMessage());
        }
    }
}
