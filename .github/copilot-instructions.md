# Copilot Instructions for Forkcast

## Project Overview
This is a Flutter multi-platform project named "forkcast" configured for Android, iOS, web, Windows, macOS, and Linux. It uses the standard Flutter project structure with Material Design components and follows Flutter's recommended practices.

## Key Architecture Patterns

### Project Structure
- **Single-file approach**: Currently uses `lib/main.dart` as the sole source file with standard Flutter counter app template
- **Multi-platform setup**: Full platform support with native configurations in `android/`, `ios/`, `web/`, `windows/`, `macos/`, and `linux/` directories
- **Standard Flutter conventions**: Follows pub.dev guidelines with Material Design theming

### Dependencies & Configuration
- **Minimal dependencies**: Uses only core Flutter SDK and `cupertino_icons: ^1.0.8`
- **Flutter 3.9.0+**: Configured for modern Dart/Flutter versions
- **Linting**: Uses `flutter_lints: ^5.0.0` with standard rules in `analysis_options.yaml`
- **Private package**: `publish_to: 'none'` indicates this is not intended for pub.dev

## Development Workflows

### Build & Run Commands
```bash
# Standard Flutter commands work across all platforms
flutter run                    # Debug mode (hot reload enabled)
flutter run --release         # Release mode
flutter build apk            # Android APK
flutter build ios            # iOS build
flutter build web            # Web build
flutter test                  # Run widget tests
flutter analyze              # Static analysis
```

### Platform-Specific Notes
- **Android**: Uses Kotlin Gradle scripts (`.gradle.kts`) with `com.example.forkcast` package
- **Build output**: Centralized in `build/` directory at project root (configured in `android/build.gradle.kts`)
- **Java compatibility**: Android targets Java 11 (`JavaVersion.VERSION_11`)

### Testing
- **Widget testing**: Uses `flutter_test` framework
- **Test location**: Tests in `test/widget_test.dart` follow standard Flutter patterns
- **Import convention**: Uses `package:forkcast/main.dart` for app imports

## Code Style & Conventions

### Current Patterns
- **StatefulWidget pattern**: Uses traditional `StatefulWidget` with `setState()` for state management
- **Material Design**: Implements `MaterialApp` with `ColorScheme.fromSeed()` theming
- **Standard widgets**: Uses `Scaffold`, `AppBar`, `Column`, `FloatingActionButton` pattern
- **Constructor patterns**: Uses `const` constructors and `super.key` parameter

### File Organization
- **Monolithic structure**: Currently single-file architecture in `main.dart`
- **Future expansion**: When adding features, follow Flutter conventions:
  - `lib/screens/` for screen widgets
  - `lib/widgets/` for reusable components  
  - `lib/models/` for data models
  - `lib/services/` for business logic

## Important Configuration Details

### Build Configuration
- **Android namespace**: `com.example.forkcast` (should be updated for production)
- **Version management**: Uses `pubspec.yaml` version field (`1.0.0+1`)
- **Asset management**: Currently no custom assets configured (commented out in pubspec.yaml)
- **Flutter Gradle Plugin**: Uses modern `dev.flutter.flutter-gradle-plugin`

### Development Environment
- **IDE support**: Configured for standard Flutter IDEs (VS Code, Android Studio, IntelliJ)
- **Hot reload**: Enabled in debug mode for rapid development
- **Debug tools**: Supports Flutter's debug painting and inspector tools

## AI Assistant Guidelines
- When expanding the app, maintain the existing Material Design patterns
- Follow Flutter's widget composition approach rather than inheritance
- Use `const` constructors where possible for performance
- Implement proper `super.key` parameters for widget constructors
- When adding state management, consider the app's current simplicity before introducing complex solutions
- Update the Android package name from `com.example.forkcast` for production builds
- Add assets section to `pubspec.yaml` when introducing images or fonts