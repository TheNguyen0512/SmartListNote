# SmartList App

SmartList is a feature-rich task management application built with Flutter, designed to help users organize tasks efficiently with customizable preferences. This app provides a user-friendly interface to manage tasks, calendars, and notifications, with options to personalize settings such as calendar views, time formats, themes, and more.

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Screenshots](#screenshots)
- [Contributing](#contributing)
- [License](#license)

## Overview
SmartList is a cross-platform mobile app that allows users to:
- Manage tasks with priorities and due dates.
- View tasks in a customizable calendar (day, week, month views).
- Set reminders and notifications with sound and vibration options.
- Personalize the app with light, dark, or system themes.
- Switch between languages (English and Vietnamese).
- Sync settings with the cloud and export data.

The app includes a comprehensive settings screen where users can adjust preferences to suit their workflow.

## Features
- **Task Management**: Add, edit, and sort tasks by due date, priority, title, or creation date.
- **Calendar Preferences**: Switch between day, week, or month views; set the first day of the week; choose 12h or 24h time format.
- **Notifications**: Enable task due reminders, upcoming alerts, customize notification sounds, and toggle vibration.
- **Appearance**: Select from light, dark, or system themes; adjust text size with a slider.
- **Account Settings**: View profile information, change password, sync with cloud, export data, and switch languages.
- **About & Help**: Access help center, privacy policy, terms of service, and app version details.
- **Multi-Language Support**: Switch between English and Vietnamese seamlessly.

## Installation
### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio or Xcode (for Android/iOS emulation)
- Git (for cloning the repository)

### Steps
1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/smartlist.git
   cd smartlist
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Set Up Environment**
   - Ensure an emulator or physical device is connected.
   - Run the following to clear cache and build:
     ```bash
     flutter clean
     cd android && ./gradlew cleanBuildCache
     flutter pub get
     ```

4. **Run the App**
   ```bash
   flutter run
   ```

## Usage
1. **Launch the App**: Open the app on your emulator or device.
2. **Navigate to Settings**: Use the bottom navigation bar to access the "Settings" tab.
3. **Customize Preferences**:
   - Adjust calendar views, time formats, and first day of the week under "Calendar Preferences".
   - Set default task priorities, due date formats, and sorting options under "Task Management".
   - Enable/disable reminders, alerts, sounds, and vibration under "Notifications".
   - Change themes and text size under "Appearance".
   - Update language, sync settings, or export data under "Account Settings".
4. **Log Out**: Use the "Logout" button to sign out and return to the login screen.

## Screenshots
*(Add screenshots of the app's settings screen and other key features here. Example:)*
- Settings Screen: ![Settings Screen](![alt text](image.png))
- Task List: ![Task List](![alt text](image-1.png))

## Contributing
We welcome contributions to improve SmartList! Here's how you can help:
1. **Fork the Repository**
2. **Create a Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Commit Changes**
   ```bash
   git commit -m "Add your feature description"
   ```
4. **Push to the Branch**
   ```bash
   git push origin feature/your-feature-name
   ```
5. **Open a Pull Request**: Describe your changes and request a review.

Please ensure your code follows Flutter best practices and includes appropriate tests.
