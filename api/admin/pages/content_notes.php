<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

try {
    $basePath = dirname(dirname(__DIR__)); // This will give us the api root directory
    require_once $basePath . '/config/database.php';
    require_once $basePath . '/models/ContentNote.php';

    $database = new Database();
    $db = $database->getConnection();
    if (!$db) {
        throw new Exception('Database connection failed');
    }
    
    $contentNote = new ContentNote($db);
} catch (Exception $e) {
    die('Error: ' . $e->getMessage());
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Content Notes - Your Filmfestival Festival Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        .modal:not(.show) {
            display: none;
        }
    </style>
</head>
<body>

<div class="container py-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2>Content Notes</h2>
        <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#formModal" onclick="loadContentNoteForm()">
            <i class="bi bi-plus-circle"></i> Add Content Note
        </button>
    </div>

    <div class="table-responsive">
        <table class="table table-striped">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Title</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <?php
                try {
                    $stmt = $contentNote->read();
                    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                        echo "<tr>";
                        echo "<td>" . htmlspecialchars($row['id']) . "</td>";
                        echo "<td>" . htmlspecialchars($row['title']) . "</td>";

                        echo "<td class='action-buttons'>";
                        $editBtn = sprintf('<button class="btn btn-sm btn-outline-primary me-2" onclick="loadContentNoteForm(\'%s\')" data-bs-toggle="modal" data-bs-target="#formModal"><i class="bi bi-pencil"></i></button>', $row['id']);
                        $deleteBtn = sprintf('<button class="btn btn-sm btn-outline-danger" onclick="deleteContentNote(\'%s\')"><i class="bi bi-trash"></i></button>', $row['id']);
                        echo $editBtn . $deleteBtn;
                        echo "</td>";
                        echo "</tr>";
                    }
                } catch (Exception $e) {
                    echo "<tr><td colspan='4' class='text-danger'>Error loading content notes: " . htmlspecialchars($e->getMessage()) . "</td></tr>";
                }
                ?>
            </tbody>
        </table>
    </div>
</div>

<!-- Modal -->
<div class="modal" id="formModal" tabindex="-1" role="dialog" aria-labelledby="formModalLabel">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="formModalLabel">Add/Edit Content Note</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <!-- Form will be loaded here -->
            </div>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
function loadContentNoteForm(id = null) {
    const title = id ? 'Edit Content Note' : 'Add Content Note';
    $('.modal-title').text(title);
    
    let formHtml = `
        <form id="contentNoteForm" onsubmit="saveContentNote(event)">
            <div class="mb-3">
                <label class="form-label">ID *</label>
                <input type="text" class="form-control" name="id" required ${id ? 'readonly' : ''}>
                <div class="form-text">A unique identifier for this content note (e.g., "violence", "nudity")</div>
            </div>
            <div class="mb-3">
                <label class="form-label">Title *</label>
                <input type="text" class="form-control" name="title" required>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="submit" class="btn btn-primary">Save</button>
            </div>
        </form>
    `;
    
    $('.modal-body').html(formHtml);
    
    if (id) {
        // Load content note data for editing
        fetch(`https://example.com/api/content_notes/read_one.php?id=${id}`)
            .then(response => response.json())
            .then(data => {
                const form = document.getElementById('contentNoteForm');
                form.id.value = data.id || '';
                form.title.value = data.title || '';

            });
    }
}

async function saveContentNote(event) {
    event.preventDefault();
    const form = event.target;
    const formData = new FormData(form);
    const noteData = {};
    
    formData.forEach((value, key) => {
        noteData[key] = value;
    });
    
    try {
        const isEdit = form.id.readOnly;
        const url = isEdit ? 'https://example.com/api/content_notes/update.php' : 'https://example.com/api/content_notes/create.php';
        
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(noteData)
        });

        const result = await response.json();
        
        if (!response.ok) {
            throw new Error(result.message || 'Error saving content note');
        }

        // Close modal and reload page
        $('#formModal').modal('hide');
        location.reload();
    } catch (error) {
        alert('Error: ' + error.message);
    }
}

async function deleteContentNote(id) {
    if (!confirm('Are you sure you want to delete this content note?')) {
        return;
    }
    
    try {
        const response = await fetch('https://example.com/api/content_notes/delete.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ id: id })
        });

        const result = await response.json();
        
        if (!response.ok) {
            throw new Error(result.message || 'Error deleting content note');
        }

        location.reload();
    } catch (error) {
        alert('Error: ' + error.message);
    }
}
</script>

</body>
</html>
