# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MyCard is a comprehensive Flutter application for creating and managing digital business cards with customizable templates, event themes, and multi-format export capabilities. The project follows a feature-first architecture with clean separation of concerns using modern Flutter patterns.

## Architecture Overview

### Core Architecture Patterns
- **Feature-First Structure**: Code is organized by features (auth, editor, gallery, etc.) rather than layers
- **Riverpod State Management**: Modern reactive state management with providers
- **GoRouter**: Declarative routing with nested navigation and authentication guards
- **Hive Local Storage**: Type-safe local database with generated adapters
- **Clean Architecture**: Separation of data, domain, and presentation layers

### Key Directories Structure

```
lib/
├── app/                    # Application-level configuration
│   ├── router.dart         # GoRouter configuration with auth guards
│   ├── theme.dart          # Light/dark theme definitions
│   └── di.dart             # Dependency injection providers
├── core/                   # Shared utilities and services
│   ├── services/           # Business logic services
│   └── utils/              # Utility functions
├── data/                   # Data layer
│   ├── models/             # Data models with Hive serialization
│   ├── repo/               # Repository pattern implementations
│   └── local/              # Local storage configuration
├── features/               # Feature modules
│   ├── auth/              # Authentication flows
│   ├── editor/            # Card editor interface
│   ├── gallery/           # Card management
│   ├── templates/         # Template selection
│   ├── events/            # Event overlays
│   ├── export/            # Export functionality
│   ├── ai/                # AI-powered features
│   ├── community/         # Community themes
│   └── comparison/        # Theme comparison
├── widgets/               # Reusable UI components
│   ├── atoms/             # Basic UI elements
│   ├── molecules/         # Component combinations
│   ├── card_renderers/    # Card template renderers
│   └── accessibility/     # Accessibility components
└── l10n/                  # Internationalization
```

### Data Models

#### BusinessCard (lib/data/models/business_card.dart)
Core entity representing a digital business card with:
- Personal information (name, title, contact details)
- Template and event overlay associations
- Custom color schemes
- Logo integration
- Hive persistence with generated adapters

#### EventOverlay (lib/data/models/event_overlay.dart)
Event-based theming system with:
- Predefined events (Octobre Rose, Movember, etc.)
- Date-based activation logic
- Color and icon customization
- JSON serialization support

### Card Rendering System

The application uses a modular card rendering system located in `lib/widgets/card_renderers/`:
- **card_renderer.dart**: Abstract base class for all renderers
- **renderer_minimal.dart**: Clean, minimalist design
- **renderer_corporate.dart**: Professional business layout
- **renderer_ansut_style.dart**: Custom branded style
- **renderer_event_campaign.dart**: Event-specific layouts
- **renderer_photo_badge.dart**: Photo integration layouts
- **renderer_modern_gradient.dart**: Contemporary gradient designs

### State Management Pattern

Using Riverpod with the following provider types:
- `Provider`: For immutable dependencies
- `StateProvider`: For simple mutable state
- `StreamProvider`: For Firebase auth state and real-time data
- `FutureProvider`: For asynchronous initialization
- `ConsumerWidget/ConsumerStatefulWidget`: For widgets that consume state

Key providers defined in `lib/app/di.dart`:
- `authRepositoryProvider`: Firebase authentication
- `cardsRepositoryProvider`: Local card storage
- `templatesRepositoryProvider`: Template management
- `eventsRepositoryProvider`: Event overlay management

### Authentication Flow

Firebase-based authentication with route guards:
- Unauthenticated users: Redirected to `/login`
- Authenticated users: Access to main features
- Routes are protected using GoRouter's redirect logic
- Auth state changes trigger navigation updates

### Color System

8-color palette system defined in `palette.md`:
- Burnt Sienna (#E28742): Primary accent
- Deep Sapphire (#0E4274): Primary brand
- Half Baked (#8DC5D2): Secondary accent
- Eternity (#21130D): Text and borders
- Burnt Umber (#873E23): Dark accent
- Eastern Blue (#1E81B0): Call-to-action
- Tacao (#EAB676): Highlight color
- Green White (#EEEEE4): Backgrounds

## Key Features Implementation

### Card Editor (lib/features/editor/)
Real-time card editing with:
- Live preview updates
- Form validation
- Template switching
- Color customization
- Logo upload
- QR code generation

### Export System (lib/features/export/)
Multi-format export capabilities:
- PNG high-resolution (300 DPI)
- PDF with print-ready layouts
- vCard format for contact applications
- Direct sharing via system share sheet

### Template System (lib/features/templates/)
Template management with:
- JSON-based template definitions
- Dynamic template loading
- Preview generation
- Custom color schemes

### Event Overlay System (lib/features/events/)
Seasonal theming with:
- Date-based activation
- Icon and color customization
- Period-based filtering
- JSON configuration

## Testing Strategy

### Test Organization
- `test/unit/`: Business logic tests
- `test/widget/`: UI component tests
- `test/golden/`: Visual regression tests

### Coverage Requirements
- Minimum 60% test coverage required
- Critical business logic: 90%+ coverage
- UI components: Widget tests for interactions
- Visual consistency: Golden tests for renderers

### Running Specific Tests
```bash
# Business card model tests
flutter test test/unit/business_card_test.dart

# Card renderer widget tests
flutter test test/widget/card_renderers/

# Golden tests for visual consistency
flutter test test/golden/ --update-goldens
```

## Development Guidelines

### Code Style
- Follow `analysis_options.yaml` configuration
- Use `dart format .` before commits
- Prefer const constructors where possible
- Use single quotes for strings
- Limit lines to 80 characters

### File Organization
- One public class per file
- Use `library` directive at file start
- Group imports: dart, flutter, packages, local
- Keep widget files under 300 lines when possible

### Performance Considerations
- Use `RepaintBoundary` for complex widgets
- Implement lazy loading for large lists
- Optimize image loading with caching
- Use `const` widgets where possible

### Accessibility
- Maintain WCAG AA compliance
- Use semantic labels for screen readers
- Support dynamic text sizing
- Ensure proper color contrast ratios

## Build and Deployment

### Environment Configuration
- Firebase options in `firebase_options.dart` (needs configuration)
- Environment variables for sensitive data
- Platform-specific build configurations

### Build Commands
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### CI/CD Pipeline
- Automated testing on PR
- Code quality checks
- Build verification
- Security scanning

## Common Development Commands

### Environment Setup
```bash
# Install dependencies
flutter pub get

# Generate code (Hive adapters, JSON serialization)
flutter pub run build_runner build

# Clean and regenerate code
flutter pub run build_runner clean && flutter pub run build_runner build

# Run with development dependencies
flutter pub dev
```

### Running and Building
```bash
# Run in debug mode
flutter run

# Run on specific device
flutter run -d chrome     # Web
flutter run -d android    # Android
flutter run -d ios        # iOS

# Build for production
flutter build apk --release
flutter build appbundle --release
flutter build web --release
flutter build ios --release
```

### Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test files
flutter test test/unit/business_card_test.dart
flutter test test/widget/card_renderers/
flutter test test/golden/ --update-goldens

# Run tests by pattern
flutter test --test-name-regex="unit"
flutter test --test-name-regex="widget|golden"
flutter test --test-name-regex="performance"
flutter test --test-name-regex="accessibility"
```

### Code Quality
```bash
# Format code
dart format .

# Analyze code
dart analyze

# Fix issues automatically
dart fix --apply
```

## Common Issues and Solutions

### Hive Initialization
Ensure Hive is initialized before running:
```dart
await Hive.initFlutter();
await registerHiveAdapters();
await HiveBoxes.initializeAllBoxes();
```

### Firebase Configuration
Update `firebase_options.dart` with actual project credentials before production deployment.

### Build Runner
Run `flutter pub run build_runner clean` if generated files become corrupted, then regenerate.

### Asset Loading
Verify all assets are properly declared in `pubspec.yaml` under the assets section.

## Platform-Specific Considerations

### Android
- Minimum SDK: 23
- Permissions: Storage, Camera (for logo upload)
- Adaptive icons support

### iOS
- Minimum iOS: 13.0
- Info.plist configurations for camera/storage
- Dynamic type support

### Web
- Responsive design implementation
- File upload limitations
- Local storage considerations