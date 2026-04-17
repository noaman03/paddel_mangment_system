# Contributing Guide

Thank you for your interest in contributing to the Padel System project! This guide will help you get started.

---

## 🚀 Getting Started

### 1. Setup Development Environment

```bash
# Clone repository
git clone <your-fork-url>
cd padelsystem

# Install Flutter (if not already installed)
flutter pub get

# Check your Flutter setup
flutter doctor

# Run the app
flutter run
```

### 2. Understand Project Structure

- **`lib/core/`** - Shared constants and utilities
- **`lib/Models/`** - Data models and entities
- **`lib/Features/`** - Feature-specific code (players, owner)
- **`lib/Screens/`** - Top-level screens and navigation

### 3. Familiarize with Architecture

Read these files in order:
1. `README.md` - Feature overview
2. `ARCHITECTURE.md` - Technical architecture
3. `FEATURES_IMPLEMENTATION.md` - Current implementation details

---

## 📋 Code Standards

### Naming Conventions

```dart
// Classes: PascalCase
class OwnerCourtManagement { }

// Functions/variables: camelCase
void showAddCourtDialog() { }
int courtCount = 0;

// Constants: camelCase with const
const double primaryPadding = 16.0;

// Private members: prefix with underscore
void _buildCourtCard() { }
List<Court> _courts = [];
```

### File Organization

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ... other imports

// Constants
const double _defaultPadding = 16.0;

// Main class/widget
class MyScreen extends ConsumerStatefulWidget {
  const MyScreen({super.key});

  @override
  ConsumerState<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends ConsumerState<MyScreen> {
  // State variables
  
  @override
  void initState() { }

  @override
  Widget build(BuildContext context) { }

  // Helper methods
  void _showDialog() { }
  Widget _buildCard() { }
}

// Supporting classes
class SupportingClass { }
```

### Documentation Comments

```dart
/// Displays a court management screen for owners.
///
/// This widget allows owners to add, edit, and delete courts.
/// It also provides image upload functionality.
class OwnerCourtManagement extends ConsumerStatefulWidget {
  const OwnerCourtManagement({super.key});

  /// Shows a dialog to add or edit a court.
  ///
  /// If [court] is null, creates a new court.
  /// Otherwise, edits the existing [court].
  void _showCourtDialog(OwnerCourt? court, int? index) { }
}
```

---

## 🔄 Development Workflow

### 1. Create a Feature Branch

```bash
# Always branch off main
git checkout main
git pull origin main
git checkout -b feature/your-feature-name

# Or for bug fixes
git checkout -b fix/bug-description
```

### 2. Make Your Changes

```bash
# Ensure code formatting
dart format lib/
dart format test/

# Check for lint issues
flutter analyze

# Run tests (if available)
flutter test
```

### 3. Commit with Clear Messages

```bash
git add .
git commit -m "feat: add court image gallery carousel

- Implemented PageView for image browsing
- Added delete button for each image
- Integrated with Firebase Storage (ready for integration)
- Added error handling for image loading"
```

**Commit format:** `type: short description`

Types:
- `feat:` - New feature
- `fix:` - Bug fix
- `refactor:` - Code refactoring
- `docs:` - Documentation
- `test:` - Test changes
- `chore:` - Build/dependency changes

### 4. Push and Create PR

```bash
git push origin feature/your-feature-name

# Then create Pull Request on GitHub
# Write clear PR description with:
# - What you changed
# - Why you changed it
# - How to test it
```

---

## 🧪 Testing Guidelines

### Before Submitting PR, Test:

1. **Compile Check**
   ```bash
   flutter analyze
   dart format --set-exit-if-changed lib/
   ```

2. **Manual Testing**
   - Test on Android emulator/device
   - Test on iOS simulator/device
   - Test landscape orientation
   - Test dark mode

3. **Feature Testing Checklist**
   - [ ] Feature works as intended
   - [ ] No UI glitches or layout issues
   - [ ] Error handling works (bad inputs, network errors)
   - [ ] Responsive on different screen sizes
   - [ ] No console warnings/errors
   - [ ] Back navigation works
   - [ ] Forms validate properly

---

## 📝 Types of Contributions

### Bug Fixes
1. Find a bug in existing code
2. Create a `fix/` branch
3. Write a test (if applicable)
4. Fix the bug
5. Verify fix doesn't break anything
6. Create PR with detailed description

### New Features
1. Discuss in issues first (get approval)
2. Create a `feature/` branch
3. Follow architecture patterns
4. Add comprehensive error handling
5. Test thoroughly
6. Update documentation
7. Create PR with feature description

### Documentation
1. Improve README, ARCHITECTURE, etc.
2. Add code comments to complex logic
3. Update example code
4. Fix typos or clarify confusing sections

### Refactoring
1. Improve code quality without changing behavior
2. Extract reusable components
3. Improve performance
4. Reduce code duplication
5. Ensure all tests still pass

---

## 🎯 Common Tasks

### Adding a New Screen

```dart
// 1. Create feature folder
lib/Features/players/my_feature/

// 2. Create screen file
lib/Features/players/my_feature/my_screen.dart

// 3. Follow this structure
class MyScreen extends ConsumerStatefulWidget {
  const MyScreen({
    super.key,
    required this.parameter,
  });

  final String parameter;

  @override
  ConsumerState<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends ConsumerState<MyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Screen')),
      body: Center(
        child: Text(widget.parameter),
      ),
    );
  }
}

// 4. Import and use in navigation
```

### Adding a New Model

```dart
// lib/Models/my_model.dart

class MyModel {
  final String id;
  final String name;
  final DateTime timestamp;

  MyModel({
    required this.id,
    required this.name,
    required this.timestamp,
  });

  // Convert to Firestore map
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'timestamp': timestamp,
  };

  // Create from Firestore map
  factory MyModel.fromMap(Map<String, dynamic> map) => MyModel(
    id: map['id'] as String,
    name: map['name'] as String,
    timestamp: (map['timestamp'] as Timestamp).toDate(),
  );
}
```

### Adding Firebase Integration

```dart
// 1. Create a service class
class MyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<MyModel>> getItems() async {
    final snapshot = await _firestore.collection('items').get();
    return snapshot.docs
        .map((doc) => MyModel.fromMap(doc.data()))
        .toList();
  }

  Future<void> addItem(MyModel item) async {
    await _firestore.collection('items').doc(item.id).set(item.toMap());
  }
}

// 2. Use with Riverpod
final myServiceProvider = Provider((ref) => MyService());

final itemsProvider = FutureProvider((ref) {
  final service = ref.watch(myServiceProvider);
  return service.getItems();
});
```

---

## 🐛 Bug Report Template

When reporting bugs, include:

```markdown
### Description
Clear description of the bug

### Steps to Reproduce
1. Navigate to X
2. Click Y
3. Observe Z

### Expected Behavior
What should happen

### Actual Behavior
What actually happens

### Screenshots/Video
If applicable

### Environment
- Device: (e.g., Pixel 6, iPhone 14)
- OS: (e.g., Android 13, iOS 16)
- Flutter version: (flutter --version)
- Branch: (which branch you're on)
```

---

## 💡 Feature Request Template

When requesting features, include:

```markdown
### Description
What feature would you like?

### Use Case
Why do you need this?

### Proposed Solution
How could it be implemented?

### Alternatives
Any other approaches?

### Additional Context
Any other info
```

---

## 📚 Learning Resources

### Flutter & Dart
- [Flutter Official Docs](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Best Practices](https://flutter.dev/docs/testing/best-practices)

### State Management (Riverpod)
- [Riverpod Documentation](https://riverpod.dev)
- [Riverpod Examples](https://github.com/rrousselGit/riverpod/tree/master/packages/riverpod/example)

### Firebase
- [Firebase for Flutter](https://firebase.google.com/docs/flutter/setup)
- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)

### Architecture
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

## 🎓 Code Review Checklist

When reviewing others' code, check:

- [ ] Code follows project style guide
- [ ] No unnecessary imports
- [ ] Variables named descriptively
- [ ] Functions are not too long (max ~30 lines)
- [ ] Comments explain why, not what
- [ ] Error handling is comprehensive
- [ ] No hardcoded values (use constants)
- [ ] Widget tree is not too deeply nested
- [ ] No memory leaks (dispose called properly)
- [ ] Performance considerations addressed
- [ ] Tests pass and cover new code
- [ ] Documentation updated

---

## 🚀 Release Process

When preparing for release:

```bash
# 1. Update version in pubspec.yaml
version: 1.1.0+2

# 2. Update CHANGELOG.md
# Add new features, fixes, improvements

# 3. Create release branch
git checkout -b release/v1.1.0

# 4. Bump version
flutter pub get

# 5. Tag release
git tag -a v1.1.0 -m "Release version 1.1.0"
git push origin v1.1.0

# 6. Build for stores
flutter build apk --release
flutter build ios --release
```

---

## 📞 Getting Help

- **Questions?** Open a Discussion
- **Found a bug?** Open an Issue
- **Have a feature idea?** Discuss in Issues first
- **Code questions?** Ask in comments on related PR/Issue

---

## 🎉 Thanks for Contributing!

Your contributions help make Padel System better for everyone. We appreciate:
- Bug reports
- Feature suggestions
- Code improvements
- Documentation updates
- Tutorial content
- Translations
- Testing on different devices

---

**Happy coding! 🚀**
