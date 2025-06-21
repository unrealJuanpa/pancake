# 🥞 Pancake Chat

<div align="center">
  <img src="assets/icons/app_icon.png" alt="Pancake Chat Logo" width="120">
  
  [![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
  [![Ollama](https://img.shields.io/badge/Ollama-FF6D00?style=for-the-badge&logo=ollama&logoColor=white)](https://ollama.ai/)
  
  A beautiful, feature-rich chat application built with Flutter that connects to Ollama's local LLM API. Chat with AI models locally with a clean and intuitive interface.
  
  *🚧 This project is currently in active development. Features and APIs might change.*
</div>

## ✨ Features

### Core Features
- 🗨️ **Local LLM Integration**: Connect to any Ollama-supported model
- 💾 **Persistent Chat History**: SQLite database stores all your conversations
- ⚡ **Real-time Streaming**: Get responses as they're generated

### User Experience
- 🎨 **Modern UI**: Clean, responsive design with dark/light theme support
- 📱 **Cross-Platform**: Runs on Windows, macOS, Linux, and Web (mobile support coming soon)
- 🔄 **Context-Aware**: Maintains conversation history for better responses

### Customization
- ⚙️ **Per-Chat Settings**: Customize model parameters for each conversation
- 📝 **System Prompts**: Set custom instructions for the AI
- 🔄 **Context Length**: Configure how much conversation history to include

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version)
- [Ollama](https://ollama.ai/) installed and running locally
- For development: [Git](https://git-scm.com/), [VS Code](https://code.visualstudio.com/) (recommended) or Android Studio

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/pancake-chat.git
   cd pancake-chat
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For Windows
   flutter run -d windows
   
   # For macOS
   flutter run -d macos
   
   # For Linux
   flutter run -d linux
   
   # For web
   flutter run -d chrome
   ```

## 🎮 Usage Guide

### Starting a New Chat
1. Click the "+" button in the sidebar
2. Enter a name for your chat (optional)
3. Select your preferred model from the dropdown
4. Customize settings as needed
5. Click "Create" to start chatting

### Chat Interface
- **Input Field**: Type your message and press Enter or click the send button
- **Streaming Responses**: Watch as the AI generates responses in real-time
- **Message Actions**: Hover over messages for options (copy, delete, etc.)

### Settings Panel
Access settings by clicking the gear icon (⚙️) in the top-right corner:
- **Model Settings**: Change the active model and parameters
- **System Prompt**: Set custom instructions for the AI
- **Context Length**: Adjust how much conversation history to include
- **Server URL**: Configure the Ollama server address

## ⚙️ Configuration

### Environment Variables
Create a `.env` file in the root directory to override default settings:

```env
# Ollama server URL (default: http://localhost:11434)
DEFAULT_OLLAMA_URL=http://localhost:11434

# Default model to use (default: llama3)
DEFAULT_MODEL=llama3

# Enable debug mode (default: false)
DEBUG=true
```

## 🏗️ Project Structure

```
lib/
  ├── main.dart                 # Application entry point
  │
  ├── models/                  # Data models
  │   ├── chat.dart             # Chat model and related logic
  │   └── message.dart          # Message model and related logic
  │
  ├── providers/               # State management
  │   └── chat_provider.dart    # Main business logic and state
  │
  ├── services/                # Business logic and external services
  │   ├── database_service.dart # Local database operations
  │   └── ollama_service.dart   # Ollama API integration
  │
  ├── utils/                   # Utilities and helpers
  │   ├── constants.dart        # App-wide constants
  │   └── extensions/           # Dart extensions
  │
  └── widgets/                 # Reusable UI components
      ├── chat_list.dart       # Chat history sidebar
      ├── chat_view.dart       # Main chat interface
      ├── message_bubble.dart  # Individual message UI
      └── settings_panel.dart  # Settings and configuration UI
```

## 🛠️ Development

### Running in Development Mode

```bash
# Start with debug flags
flutter run -d windows --debug

# Enable hot reload
flutter run -d windows --hot
```

### Building for Production

```bash
# Build for Windows
flutter build windows

# Build for macOS
flutter build macos

# Build for Linux
flutter build linux

# Build for Web
flutter build web
```

## 📦 Dependencies

### Core Dependencies
- `provider`: State management
- `sqflite`: Local SQLite database
- `http`: HTTP client for API calls
- `web_socket_channel`: For streaming responses

### UI Components
- `flutter_markdown`: For rendering formatted text
- `font_awesome_flutter`: For beautiful icons

### Utilities
- `uuid`: For generating unique IDs
- `intl`: Internationalization and formatting
- `shared_preferences`: For storing user preferences

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/) for the amazing cross-platform framework
- [Ollama](https://ollama.ai/) for providing local LLM capabilities
- All the amazing open-source packages that made this project possible

---

<div align="center">
  Made with ❤️ and ☕ by the Pancake Team
</div>

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Ollama](https://ollama.ai/) for the amazing local LLM API
- [Flutter](https://flutter.dev/) for the awesome UI toolkit
- All the amazing package developers who made this app possible
