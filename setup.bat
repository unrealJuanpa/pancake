@echo off
REM Setup script for Pancake Chat (Windows)

echo 🚀 Setting up Pancake Chat...

REM Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Flutter is not installed. Please install Flutter first.
    echo    Visit: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

REM Check if Dart is installed
where dart >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Dart is not installed. Please install Dart SDK.
    echo    It's included with Flutter installation.
    pause
    exit /b 1
)

echo 🔍 Checking for Ollama...
where ollama >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ⚠️  Ollama is not installed. Please install Ollama for local LLM support.
    echo    Visit: https://ollama.ai/
    set /p CONTINUE=Continue setup without Ollama? (y/n) 
    if /i not "%CONTINUE%"=="y" (
        if /i not "%CONTINUE%"=="Y" (
            echo ❌ Setup aborted.
            pause
            exit /b 1
        )
    )
) else (
    echo 🔄 Checking if Ollama server is running...
    curl http://localhost:11434/api/tags >nul 2>nul
    if %ERRORLEVEL% NEQ 0 (
        echo ⚠️  Ollama is installed but not running. Please start Ollama manually.
        echo    Run 'ollama serve' in a new terminal and then run this script again.
        pause
        exit /b 1
    )
    
    echo 📥 Pulling default LLM model (llama3)...
    ollama pull llama3
)

echo 🔧 Installing Flutter dependencies...
flutter pub get

REM Create .env file if it doesn't exist
if not exist ".env" (
    echo 📝 Creating .env file from example...
    copy /y .env.example .env >nul
    echo ✅ .env file created. Please edit it to configure your settings.
) else (
    echo ℹ️  .env file already exists. Skipping creation.
)

echo.
echo 🎉 Setup complete! You can now run the app with:
echo.
echo   flutter run
echo.
echo Happy coding! 🥞💬
pause
