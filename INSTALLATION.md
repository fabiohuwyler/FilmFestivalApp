# Installation Guide

This guide will help you set up and run the Your Filmfestival Festival iOS app and its backend API.

## Prerequisites

- macOS 14.0 or later
- Xcode 15.0 or later
- PHP 8.0 or later (for backend API)
- MySQL/MariaDB database
- A web server (Apache/Nginx) for hosting the PHP backend

## Backend Setup

### 1. Database Configuration

1. Create a MySQL/MariaDB database for the application
2. Edit the database configuration file at `api/config/database.php`:

```php
private $host = "your_database_host";
private $db_name = "your_database_name";
private $username = "your_database_username";
private $password = "your_database_password";
```

3. Import the SQL schema and data:
   - Use `api/dummy_data.sql` for a fresh installation with sample data
   - Or use `api/BACKUP_proudout_qsapp.sql` for the complete database structure

```bash
mysql -u your_username -p your_database_name < api/dummy_data.sql
```

### 2. Web Interface Configuration

The admin web interface is available at a separate URL. To set it up:

1. Upload the `api/` folder to your web server
2. Ensure the following directories are writable by the web server:
   - `api/uploads/` (for image uploads)
   - `api/debug.log` (for error logging)
3. Configure your web server to point to the `api/` directory

The admin panel will be accessible at: `https://your-admin-url.com/admin/`

### 3. API Endpoints

The backend API provides the following endpoints:
- `GET /api/locations` - Get all locations
- `GET /api/movies` - Get all movies
- `GET /api/events` - Get all events
- `GET /api/showings` - Get all showings
- `POST /api/highscores/save_highscore.php` - Submit game high scores
- `GET /api/highscores/highscores.json` - Get high scores

## iOS App Setup

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/filmfestival-app.git
cd filmfestival-app
```

### 2. Open in Xcode

```bash
open YourFilmfestival.xcodeproj
```

### 3. Configure API URL

The app needs to know where your backend API is hosted. Update the API URLs in the following files:

**NetworkManager.swift** (Queersicht/NetworkManager.swift):
```swift
private init() {
    self._baseURL = "https://your-api-url.com/api"
}
```

**NetworkManager.swift** (Queersicht/Networking/NetworkManager.swift):
```swift
private init() {
    self.baseURL = "https://your-api-url.com"
}
```

**HighScoreManager.swift** (Queersicht/Game/HighScoreManager.swift):
```swift
let url = URL(string: "https://your-api-url.com/api/highscores/save_highscore.php")!
let url = URL(string: "https://your-api-url.com/api/highscores/highscores.json")!
```

**NewsViewModel.swift** (Queersicht/ViewModels/NewsViewModel.swift):
```swift
private let feedURL = URL(string: "https://your-news-url.com/feed/")!
```

### 4. Build and Run

1. Select your target device (iPhone Simulator or physical device)
2. Click the Run button (⌘R) or select Product > Run
3. The app will launch and attempt to fetch data from your configured API

## Configuration Options

### Language Support

The app supports German and French languages. The language can be changed in the onboarding screen or through app settings.

### Theme Customization

The app includes multiple color themes. Themes can be customized by modifying the theme IDs in:
- `FestivalInfoView.swift`
- `TheHomeScreen.swift`

### Image Assets

The app uses the following image asset catalogs:
- `Assets.xcassets` - Main app images
- App icons can be customized in the Asset Catalog

## Troubleshooting

### App Not Loading Data

1. Verify your API URL is correctly configured
2. Check that your backend server is running
3. Review the Xcode console for error messages
4. Ensure your device/simulator has internet connectivity

### Database Connection Errors

1. Verify database credentials in `api/config/database.php`
2. Check that your database server is running
3. Ensure the database user has proper permissions
4. Review `api/debug.log` for detailed error messages

### Image Upload Issues

1. Ensure the `api/uploads/` directory exists and is writable
2. Check PHP file upload permissions in `php.ini`
3. Verify maximum upload size settings

## Admin Panel Usage

The admin panel allows you to manage:
- Movies and their metadata
- Events and showings
- Locations and accessibility info
- Content notes and warnings

Access the admin panel at your configured web interface URL and log in with your admin credentials.

## Deployment

### Backend Deployment

1. Deploy the `api/` folder to your web server
2. Configure the database connection
3. Set up proper file permissions
4. Configure SSL/HTTPS for secure connections

### iOS App Deployment

1. Update the bundle identifier in Xcode project settings
2. Configure code signing and provisioning profiles
3. Update app icons and launch screens
4. Archive and upload to App Store Connect

## Support

For issues or questions:
- Check the debug logs in `api/debug.log`
- Review Xcode console output
- Ensure all prerequisites are met
- Verify API endpoints are accessible

## License

This project is open source and available under the MIT License.
