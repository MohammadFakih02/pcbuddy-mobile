***

# 📱 PCBuddy - Frontend

**PCBuddy** is a modern, AI-powered mobile application built with **Flutter**. It helps users design their dream computers, check compatibility, assess laptop performance, and estimate gaming FPS using **Google Gemini AI**.

The app follows an **Offline-First** architecture, syncing the hardware database from the backend to a local SQLite database, ensuring a snappy experience even with poor internet connectivity.

---

## 🚀 Features

### 🤖 AI Capabilities
*   **AI Build Assistant:** Describe your needs (e.g., "White gaming PC under $1500 for Fortnite") and get a complete parts list instantly.
*   **Laptop Assessor:** Enter a laptop model name to get detailed specs, thermal ratings, and estimated FPS for popular games.
*   **Performance Estimator:** Predict gaming performance (Low/Med/High/Ultra settings) for your custom builds.
*   **Compatibility Check:** Validates your manual builds for potential issues (e.g., PSU wattage, Socket mismatch).

### 🛠️ PC Builder
*   **Interactive Part Picker:** Select components (CPU, GPU, RAM, etc.) from a synced database.
*   **Real-time Pricing:** See the estimated total cost as you add parts.
*   **Smart Filtering:** Search and filter thousands of parts locally.
*   **Visual Preview:** See images and details of every component.

### 🔄 Offline-First Sync
*   **Delta Sync:** Downloads only new or modified hardware parts from the .NET Backend to the local device.
*   **SQLite Database:** Stores 80,000+ parts locally for instant searching and filtering.
*   **Visual Feedback:** Custom Lottie animations and progress bars during synchronization.

### 👤 User Profile
*   **Authentication:** Secure Login and Registration with JWT.
*   **Remember Me:** Persists login credentials for quick access.
*   **Profile Management:** Update display name, bio, and upload profile pictures.
*   **Saved Builds:** Save your custom PC configuration to the cloud and view it on your profile.

---

## 🛠️ Tech Stack

*   **Framework:** [Flutter](https://flutter.dev/) (Dart)
*   **State Management:** [Provider](https://pub.dev/packages/provider)
*   **Local Database:** [sqflite](https://pub.dev/packages/sqflite) (SQLite)
*   **Networking:** [http](https://pub.dev/packages/http)
*   **Animations:** [lottie](https://pub.dev/packages/lottie)
*   **Storage:** [shared_preferences](https://pub.dev/packages/shared_preferences)
*   **Media:** [image_picker](https://pub.dev/packages/image_picker)

---

## ⚙️ Setup & Installation

### 1. Prerequisites
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
*   An IDE (VS Code or Android Studio).
*   **PCBuddy Backend** running locally (or hosted).

### 2. Clone the Repository
```bash
git clone https://github.com/yourusername/pcbuddy-frontend.git
cd pcbuddy-frontend
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Configure Backend URL
Open `lib/config/api_constants.dart` and update the `baseUrl` to point to your running .NET API.

```dart
class ApiConstants {
  // For Android Emulator
  static const String baseUrl = 'http://10.0.2.2:7105'; 
  
  // For Physical Device (Use your computer's LAN IP)
  // static const String baseUrl = 'http://192.168.1.5:7105'; 
  
  // ... endpoints
}
```
*Note: Ensure your Backend is running (`dotnet run`) before starting the app.*

### 5. Run the App
```bash
flutter run
```

---

## 📂 Project Structure

```text
lib/
├── config/            # API Constants & HTTP Overrides
├── models/            # Data models (AuthUser, HardwareItem, AI Models)
├── pages/             # UI Screens (Home, Builder, Profile, Login)
├── providers/         # State Management (AuthProvider)
├── services/          # Logic (Auth, Computer, AI, Database, Sync)
├── theme/             # App Theme & Colors
├── utils/             # Helper functions
├── widgets/           # Reusable widgets (Buttons, TextFields, Tiles)
└── main.dart          # Entry point
```

## 🧩 Dependencies

This project relies on the following key packages:

*   `provider`: State management.
*   `http`: Making API calls to the .NET backend.
*   `sqflite` & `path`: Local database storage.
*   `lottie`: Sync animations.
*   `image_picker`: Uploading profile pictures.
*   `shared_preferences`: Storing "Remember Me" credentials and Sync timestamps.

---
