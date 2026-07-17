<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
session_start();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Your Filmfestival Festival Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        .sidebar {
            min-height: 100vh;
            background: #2c3e50;
        }
        .sidebar .nav-link {
            color: white;
            margin-bottom: 0.5rem;
        }
        .sidebar .nav-link:hover {
            background: #34495e;
        }
        .sidebar .nav-link.active {
            background: #3498db;
        }
        .content {
            padding: 20px;
        }
        .action-buttons {
            white-space: nowrap;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-2 sidebar p-3">
                <h4 class="text-white mb-4">Your Filmfestival Festival Admin</h4>
                <nav class="nav flex-column">
                    <a class="nav-link active" href="?page=movies">
                        <i class="bi bi-film"></i> Movies
                    </a>
                    <a class="nav-link" href="?page=events">
                        <i class="bi bi-calendar-event"></i> Events
                    </a>
                    <a class="nav-link" href="?page=locations">
                        <i class="bi bi-geo-alt"></i> Locations
                    </a>
                    <a class="nav-link" href="?page=content_notes">
                        <i class="bi bi-tags"></i> Content Notes
                    </a>
                    <a class="nav-link" href="?page=showings">
                        <i class="bi bi-clock"></i> Showings
                    </a>
                </nav>
            </div>

            <!-- Main Content -->
            <div class="col-md-10 content">
                <?php
                $page = $_GET['page'] ?? 'movies';
                $validPages = ['movies', 'events', 'locations', 'content_notes', 'showings'];
                
                if (in_array($page, $validPages)) {
                    switch ($page) {
                        case 'locations':
                            include 'pages/locations.php';
                            break;
                        case 'content_notes':
                            include 'pages/content_notes.php';
                            break;
                        default:
                            include "pages/{$page}.php";
                            break;
                    }
                } else {
                    echo "<div class='alert alert-danger'>Invalid page requested.</div>";
                }
                ?>
            </div>
        </div>
    </div>

    <!-- Modal for forms -->
    <div class="modal fade" id="formModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        // Handle active nav links
        document.querySelectorAll('.nav-link').forEach(link => {
            if (link.getAttribute('href').includes(new URLSearchParams(window.location.search).get('page'))) {
                link.classList.add('active');
            } else {
                link.classList.remove('active');
            }
        });
    </script>
</body>
</html>
