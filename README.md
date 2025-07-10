# AI Chatbot

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## Overview

A powerful Flutter-based AI chatbot mobile application that runs Large Language Models (LLMs) locally on device. Features customizable AI personalities, complete device permissions integration, and a beautiful modern UI with dark/light mode support.

## Features

### Core Features
- 🤖 **Local AI Execution** - Run AI models directly on device (no internet required)
- 🎭 **Multiple Personalities** - Create and customize AI personalities with unique behaviors
- 💬 **Conversation Management** - Multiple conversations per personality
- 🌓 **Dark/Light Mode** - Beautiful theme support
- 🔒 **Privacy First** - All data stored locally on device
- 📱 **Device Integration** - Access to calendar, contacts, camera, location, and more

### Device Permissions
- 📅 Calendar (read/write events)
- 👥 Contacts (read/edit)
- 📱 Phone (make calls)
- 💬 SMS (read/send)
- 📍 Location (current location)
- 📷 Camera/Photos (access gallery)
- 🎤 Microphone (voice input)
- 📁 Files (document access)
- 🔔 Notifications (send notifications)
- ✉️ Email (read/compose)

## Quick Start

### Prerequisites
- Flutter SDK (latest stable)
- Android Studio / Xcode
- Android device with API 21+ (Android 5.0+)
- ~2GB free storage for AI model

### Installation

```bash
# Clone the repository
git clone https://github.com/Arthurkhan/AI-Chatbot.git

# Navigate to project directory
cd AI-Chatbot

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## AI Model Setup

The app uses Gemma 2B model by default. On first launch:
1. The app will download the model (~500MB)
2. Model will be cached locally
3. Subsequent launches will use cached model

## Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **AI Model**: Gemma 2B (via flutter_gemma)
- **Database**: SQLite (sqflite)
- **State Management**: Provider
- **Permissions**: permission_handler
- **UI Components**: Material Design 3

## Project Structure

```
lib/
├── main.dart
├── config/
│   ├── themes.dart
│   └── constants.dart
├── models/
│   ├── personality.dart
│   ├── conversation.dart
│   └── message.dart
├── screens/
│   ├── chat/
│   ├── personalities/
│   └── settings/
├── services/
│   ├── ai_service.dart
│   ├── database_service.dart
│   └── permission_service.dart
├── widgets/
│   ├── chat_bubble.dart
│   ├── personality_card.dart
│   └── common/
└── utils/
    ├── helpers.dart
    └── extensions.dart
```

## Documentation

Detailed documentation available in `/docs`:
- [Architecture Overview](docs/architecture/overview.md)
- [UI/UX Design Guide](docs/ui-ux/design-system.md)
- [Development Workflow](docs/workflows/development-workflow.md)
- [API Documentation](docs/architecture/api-design.md)

## Contributing

Please read [CONTRIBUTING.md](.github/CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Google Gemma team for the excellent local AI model
- Flutter team for the amazing framework
- Contributors and testers