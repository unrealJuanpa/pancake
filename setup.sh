#!/bin/bash

# Setup script for Pancake Chat

echo "🚀 Setting up Pancake Chat..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    echo "   Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check if Dart is installed
if ! command -v dart &> /dev/null; then
    echo "❌ Dart is not installed. Please install Dart SDK."
    echo "   It's included with Flutter installation."
    exit 1
fi

# Check if Ollama is installed and running
if ! command -v ollama &> /dev/null; then
    echo "⚠️  Ollama is not installed. Please install Ollama for local LLM support."
    echo "   Visit: https://ollama.ai/"
    read -p "Continue setup without Ollama? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Setup aborted."
        exit 1
    fi
else
    # Check if Ollama server is running
    if ! curl -s http://localhost:11434/api/tags &> /dev/null; then
        echo "⚠️  Ollama is installed but not running. Starting Ollama..."
        ollama serve &
        sleep 2 # Give it a moment to start
    fi
    
    # Pull default model
    echo "📥 Pulling default LLM model (llama3)..."
    ollama pull llama3
fi

# Install Flutter dependencies
echo "🔧 Installing Flutter dependencies..."
flutter pub get

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "📝 Creating .env file from example..."
    cp .env.example .env
    echo "✅ .env file created. Please edit it to configure your settings."
else
    echo "ℹ️  .env file already exists. Skipping creation."
fi

echo ""
echo "🎉 Setup complete! You can now run the app with:"
echo ""
echo "  flutter run"
echo ""
echo "Happy coding! 🥞💬"

# Make the script executable
chmod +x setup.sh
