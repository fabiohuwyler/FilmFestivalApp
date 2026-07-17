<?php
class ContentNote {
    private $conn;
    private $table_name = "content_notes";

    public $id;
    public $title;

    public function __construct($db) {
        $this->conn = $db;
    }

    public function read() {
        $query = "SELECT * FROM " . $this->table_name;
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        return $stmt;
    }

    public function readOne() {
        try {
            $query = "SELECT * FROM " . $this->table_name . " WHERE id = ? LIMIT 0,1";
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(1, $this->id);
            $stmt->execute();
            
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($row) {
                $this->title = $row['title'];
                return true;
            }
            return false;
        } catch(PDOException $e) {
            throw new Exception('Database error: ' . $e->getMessage());
        }
    }

    public function create() {
        try {
            $query = "INSERT INTO " . $this->table_name . "
                    (id, title)
                    VALUES (:id, :title)";

            $stmt = $this->conn->prepare($query);

            // Sanitize input
            $this->title = htmlspecialchars(strip_tags($this->title));

            // Bind values
            $stmt->bindParam(':id', $this->id);
            $stmt->bindParam(':title', $this->title);

            if($stmt->execute()) {
                return true;
            }
            return false;
        } catch(PDOException $e) {
            throw new Exception('Database error: ' . $e->getMessage());
        }
    }

    public function update() {
        try {
            $query = "UPDATE " . $this->table_name . "
                    SET
                        title = :title
                    WHERE
                        id = :id";

            $stmt = $this->conn->prepare($query);

            // Sanitize input
            $this->title = htmlspecialchars(strip_tags($this->title));

            // Bind values
            $stmt->bindParam(':title', $this->title);
            $stmt->bindParam(':id', $this->id);

            if($stmt->execute()) {
                return true;
            }
            return false;
        } catch(PDOException $e) {
            throw new Exception('Database error: ' . $e->getMessage());
        }
    }

    public function delete() {
        try {
            // First check if the content note is used in any movies
            $query = "SELECT COUNT(*) as count FROM movie_content_notes WHERE content_note_id = ?";
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(1, $this->id);
            $stmt->execute();
            $row = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($row['count'] > 0) {
                throw new Exception('Cannot delete content note because it is used by ' . $row['count'] . ' movie(s)');
            }

            // If not used, delete the content note
            $query = "DELETE FROM " . $this->table_name . " WHERE id = ?";
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(1, $this->id);
            
            if($stmt->execute()) {
                return true;
            }
            return false;
        } catch(PDOException $e) {
            throw new Exception('Database error: ' . $e->getMessage());
        }
    }
}
