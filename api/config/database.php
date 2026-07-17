<?php
ini_set('log_errors', 1);
ini_set('error_log', dirname(__FILE__) . '/../debug.log');

class Database {
    private $host = "example.com";
    private $db_name = "DBNAME";
    private $username = "DBUSER";
    private $password = "DBPASSWORD";
    public $conn;

    public function getConnection() {
        $this->conn = null;
        error_log("Attempting database connection at " . date('Y-m-d H:i:s'));

        try {
            $dsn = "mysql:host=" . $this->host . ";dbname=" . $this->db_name . ";port=3306;charset=utf8mb4";
            error_log("DSN: " . $dsn);
            
            $options = array(
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
                PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT => false,
                PDO::MYSQL_ATTR_SSL_CA => false
            );
            
            $this->conn = new PDO($dsn, $this->username, $this->password, $options);
            $this->conn->exec("set names utf8");
            return $this->conn;
        } catch(PDOException $exception) {
            error_log("Database connection error: " . $exception->getMessage());
            throw new Exception("Database connection failed: " . $exception->getMessage());
        }
    }
}
