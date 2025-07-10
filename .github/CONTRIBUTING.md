# Contributing to AI Chatbot

Thank you for your interest in contributing to AI Chatbot! This document provides guidelines and instructions for contributing.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/AI-Chatbot.git`
3. Create a new branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Submit a pull request

## Development Setup

### Prerequisites
- Flutter SDK (latest stable)
- Android Studio or VS Code with Flutter extensions
- Git

### Setup Steps

```bash
# Clone the repository
git clone https://github.com/Arthurkhan/AI-Chatbot.git
cd AI-Chatbot

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Code Style

### Dart/Flutter Guidelines

1. Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
2. Use `flutter analyze` before committing
3. Format code with `flutter format .`
4. Maintain 80-character line length where possible

### File Organization

```
lib/
├── models/       # Data models
├── screens/      # UI screens
├── widgets/      # Reusable widgets
├── services/     # Business logic
├── utils/        # Utilities
└── config/       # Configuration
```

### Naming Conventions

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/Functions: `camelCase`
- Constants: `SCREAMING_SNAKE_CASE`
- Private members: `_leadingUnderscore`

## Commit Convention

We use conventional commits for clear history:

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting)
- `refactor:` Code refactoring
- `test:` Test additions or changes
- `chore:` Maintenance tasks

### Examples

```
feat(chat): add voice input support
fix(personality): resolve avatar color issue
docs(readme): update installation instructions
```

## Pull Request Process

### Before Submitting

1. Update documentation if needed
2. Add/update tests for your changes
3. Ensure all tests pass: `flutter test`
4. Check code quality: `flutter analyze`
5. Format code: `flutter format .`

### PR Guidelines

1. **Title**: Use conventional commit format
2. **Description**: Clearly explain:
   - What changes were made
   - Why they were necessary
   - Any breaking changes
3. **Screenshots**: Include for UI changes
4. **Testing**: Describe testing performed
5. **Issues**: Reference related issues

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Manual testing completed
- [ ] No regressions identified

## Screenshots (if applicable)
[Add screenshots here]

## Related Issues
Closes #[issue number]
```

## Testing

### Unit Tests

```dart
test('should create personality with valid data', () {
  final personality = Personality(
    name: 'Test',
    systemPrompt: 'You are a test assistant',
  );
  
  expect(personality.name, 'Test');
  expect(personality.systemPrompt, isNotEmpty);
});
```

### Widget Tests

```dart
testWidgets('ChatScreen displays messages', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: ChatScreen(),
  ));
  
  expect(find.byType(MessageList), findsOneWidget);
});
```

## Code of Conduct

### Our Pledge

We pledge to make participation in our project a harassment-free experience for everyone.

### Expected Behavior

- Be respectful and inclusive
- Accept constructive criticism
- Focus on what's best for the community
- Show empathy towards others

### Unacceptable Behavior

- Harassment or discrimination
- Trolling or insulting comments
- Public or private harassment
- Publishing private information

## Getting Help

- Create an issue for bugs or features
- Join discussions in issues/PRs
- Check existing documentation
- Ask questions in issues with 'question' label

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project documentation

Thank you for contributing to AI Chatbot!