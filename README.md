Aurelia Echoes 📚🎧
Aurelia Echoes is a personal audiobook library manager built with Flutter. It allows users to import their library data from CSV files (Audible/Goodreads), automatically fetch metadata and cover art, organize books into series, and track reading progress in a sleek, dark-mode interface.

🚀 Key Features
📖 Library Management
Import Anywhere: seamless CSV import support (smart detection for Title, Author, and Date Added columns).
Reading Tracker: Toggle books as "Read" or "Unread" with a simple checkbox.
Sorting & Filtering:
  Sort by: Date Added (Newest/Oldest), Author (A-Z), Title (A-Z).
  Filter by: Show All, Unread Only, or Read Only.

🧠 Smart Metadata Engine
Dual-Source Scraping: Combines data from Google Books API and Open Library to find the best covers and author details.
Auto-Correction: Fills in missing data for imported books automatically.

✨ Series Automation
Regex Pattern Matching: Automatically detects series info from titles (e.g., "Harry Potter (Book 1)" or "Dune: The Dune Chronicles #1").
Auto-Grouping: Groups books into series folders and sorts them by volume number.

🛡️ Data Safety
Offline First: All data is stored locally using a high-performance SQLite database (Drift).
Backup & Restore: Export your entire cleaned library to a JSON file and save it to Google Drive (or any other location) via the system share sheet.

🛠️ Tech Stack
Framework: Flutter (Dart)
Database: Drift (SQLite abstraction)
State Management: Provider
Networking: http (Google Books & Open Library APIs)
Utilities:
  csv (Parsing import files)
  share_plus (Exporting backups)
  file_picker (Selecting files)
  intl (Date formatting)

📸 Screenshots
Library View,          Series Grouping,     Import & Backup
(Add Screenshot Here),(Add Screenshot Here),(Add Screenshot Here)

📥 Installation
To build and run this project locally:

Clone the repository:
Bash: git clone https://github.com/YourUsername/aurelia_echoes_final.git
cd aurelia_echoes_final

Install dependencies:
Bash: flutter pub get

Run the App:
Bash: flutter run

Build Release APK:
Bash: flutter build apk --release

Output location: build/app/outputs/flutter-apk/app-release.apk

📖 Usage Guide
  1. Importing Books
      Export your library from Audible or Goodreads as a .csv file.
      Open the app and navigate to the Manage tab.
      Tap Import CSV and select your file.
      The app will automatically detect columns for Title, Author, and Date Added.

2. Organizing Series
    Go to the Series tab.
    Tap the Sparkle Icon (✨).
    The app will scan your library using Regex patterns and online APIs to group books into series folders automatically.

3. Backing Up
    Go to the Manage tab.
    Tap Backup Library (Save JSON).
    Select Google Drive (or your preferred storage) from the share menu.

📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

Developed with ❤️ by Jacqueline Carnahan
   
