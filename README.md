# Your Filmfestival Festival App

Your Filmfestival Festival is a beautifully designed iOS app created for the **Queersicht LGBTIAQ*-Filmfestival 2025**. It serves as a central hub for showcasing movies, events, and locations, allowing users to explore the festival's program, manage favorites, and access detailed information about screenings and venues.

This app is not only tailored for Queersicht Festival but also serves as a **starter template** for developers looking to build apps for other festivals, events, or community-driven projects.

---

## Features

- **Program List**  

  Displays the festival's program organized by dates, including movies and events.

- **Favorites Management**  

  Users can favorite movies and access them later from the home view.

- **Detailed Views**  

  Detailed information about movies, events, and locations:

  - **Movies**: Title, origin language, director, duration, content notes, trailer, and showtimes.

  - **Events**: Title, date, location details, and descriptions.

  - **Locations**: Name, address, accessibility info, and an interactive map with navigation options.

- **Interactive Map Integration**  

  Locations feature a map with a button to open the address in a navigation app.

- **Multi-Screen Layout**  

  The app supports different layouts for iPhone and iPad.

- **Custom Themes**  

  Uses a vibrant, festival-inspired color scheme and custom fonts (*DMSerifDisplay-Regular* and *Lora-Regular*).

- **Easy Customization**  

  The codebase is modular and well-documented, making it simple to adapt for other festivals or events.

---

## Getting Started

### Prerequisites

- **Xcode**: Ensure you have the latest version installed.

- **Firebase**: The app uses Firebase for backend services. Set up your Firebase project and download the `GoogleService-Info.plist` file.

### Setup

1\. Clone this repository:

   ```bash

   git clone https://github.com/yourusername/filmfestival-app.git

   cd filmfestival-app

   ```

2\. Open the project in Xcode:

   ```bash

   open YourFilmfestival.xcodeproj

   ```

3\. Add your `GoogleService-Info.plist` file to the project.

4\. Install the custom fonts (*DMSerifDisplay-Regular.ttf* and *Lora-Regular.ttf*):

   - Drag and drop the font files into your Xcode project.

   - Ensure they are included in your target's "Copy Bundle Resources."

5\. Update the Firebase database structure:

   - Create collections for `movies`, `events`, `locations`, and `contentnotes`.

   - Refer to the codebase for the required structure of these collections.

---

## Usage

The app is designed to work seamlessly out of the box for a film festival but can be customized for:

- **Music Festivals**  

  Display artist lineups, set times, and venue details.

- **Community Events**  

  Showcase workshops, meetups, and local gatherings.

- **Conferences**  

  Provide a detailed schedule, speaker bios, and location info.

- **Cultural Festivals**  

  Highlight exhibits, performances, and cultural events.

### Customization Tips

- **Branding**: Update the color scheme and fonts in `Assets.xcassets` and `Font+Custom.swift`.

- **Data Models**: Modify the `Models.swift` file to match your Firebase database schema.

- **Views**: Customize the `ListView` and `DetailView` files for your specific use case.

---

## Screenshots

### Program View

![Program View](path/to/screenshot1.png)

### Movie Detail

![Movie Detail](path/to/screenshot2.png)

### Location Detail

![Location Detail](path/to/screenshot3.png)

---

## Contributing

Contributions are welcome! Feel free to fork this repository and submit a pull request with your improvements or new features.

---

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

---

## Acknowledgments

Special thanks to the **Your Filmfestival Festival** for inspiring this app.  

Built with love by **Fabio Huwyler**.
