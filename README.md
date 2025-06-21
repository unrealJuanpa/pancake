# Pancake Chat

A beautiful and feature-rich chat application built with Flutter that connects to Ollama's local LLM API. Chat with AI models locally with a clean and intuitive interface.

## Features

- 🗨️ Chat with local LLM models using Ollama
- 💾 SQLite database for chat history persistence
- 🎨 Clean, modern UI with dark/light theme support
- ⚡ Real-time streaming responses
- ⚙️ Customizable model settings per chat
- 📝 System prompt support
- 🔄 Context length configuration
- 🌐 Configurable server URL

## Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (included with Flutter)
- [Ollama](https://ollama.ai/) installed and running locally

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/pancake-chat.git
   cd pancake-chat
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Usage

1. **Start Ollama**
   Make sure Ollama is running on your machine. By default, the app connects to `http://localhost:11434`.

2. **Create a New Chat**
   - Click the "+" button in the chat list
   - Select your preferred model from the dropdown
   - Configure the system prompt and other settings
   - Click "Save"

3. **Start Chatting**
   - Type your message in the input field
   - Press Enter or click the send button
   - The AI response will appear in the chat

4. **Settings**
   - Click the gear icon in the top-right corner to open settings
   - Adjust model parameters, system prompt, and other settings
   - Changes are automatically saved

## Configuration

### Environment Variables

Create a `.env` file in the root directory with the following variables:

```env
DEFAULT_OLLAMA_URL=http://localhost:11434
DEFAULT_MODEL=llama3
```

## Dependencies

- `provider`: State management
- `sqflite`: Local SQLite database
- `http`: HTTP client for API calls
- `web_socket_channel`: For streaming responses
- `flutter_markdown`: For rendering formatted text
- `shared_preferences`: For storing app preferences
- `intl`: Internationalization support
- `uuid`: For generating unique IDs

## Project Structure

```
lib/
  ├── main.dart          # App entry point
  ├── models/            # Data models
  │   ├── chat.dart
  │   └── message.dart
  ├── providers/         # State management
  │   └── chat_provider.dart
  ├── services/          # Business logic
  │   ├── database_service.dart
  │   └── ollama_service.dart
  ├── utils/             # Utilities and constants
  │   └── constants.dart
  └── widgets/           # Reusable UI components
      ├── chat_list.dart
      ├── chat_view.dart
      └── settings_panel.dart
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Ollama](https://ollama.ai/) for the amazing local LLM API
- [Flutter](https://flutter.dev/) for the awesome UI toolkit
- All the amazing package developers who made this app possible
