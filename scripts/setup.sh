#!/bin/bash
# Setup script for AI Chatbot development environment

echo "Setting up AI Chatbot development environment..."

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "Flutter is not installed. Please install Flutter first."
    echo "Visit: https://docs.flutter.dev/get-started/install"
    exit 1
fi

# Check Flutter version
echo "Flutter version:"
flutter --version

# Get dependencies
echo "\nInstalling dependencies..."
flutter pub get

# Run code generation (if needed in future)
# echo "\nRunning code generation..."
# flutter pub run build_runner build --delete-conflicting-outputs

# Setup git hooks (optional)
echo "\nSetting up git hooks..."
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Pre-commit hook for AI Chatbot

# Run flutter analyze
echo "Running flutter analyze..."
flutter analyze
if [ $? -ne 0 ]; then
    echo "Flutter analyze failed. Please fix the issues before committing."
    exit 1
fi

# Check formatting
echo "Checking code formatting..."
flutter format --dry-run --set-exit-if-changed .
if [ $? -ne 0 ]; then
    echo "Code formatting issues found. Run 'flutter format .' to fix."
    exit 1
fi

echo "Pre-commit checks passed!"
EOF

chmod +x .git/hooks/pre-commit

# Create necessary directories
echo "\nCreating directories..."
mkdir -p assets/images
mkdir -p assets/icons
mkdir -p assets/fonts

# Check for Android SDK
if [ -z "$ANDROID_HOME" ]; then
    echo "\nWarning: ANDROID_HOME is not set. Make sure Android SDK is properly configured."
fi

# Success message
echo "\n✅ Setup complete!"
echo "\nNext steps:"
echo "1. Run 'flutter doctor' to check your environment"
echo "2. Open the project in your IDE"
echo "3. Run 'flutter run' to start the app"
echo "\nHappy coding! 🚀"