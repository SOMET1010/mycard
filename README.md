# MyCard - Digital Business Card Creator

![Flutter](https://img.shields.io/badge/Flutter-3.19+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.9+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Tests](https://img.shields.io/badge/Tests-60%25+-brightgreen.svg)

A comprehensive Flutter application for creating and managing digital business cards with customizable templates, event themes, and multi-format export capabilities.

## ✨ Features

### 🎨 **Card Creation & Customization**
- **Multiple Templates**: Minimal, Corporate, Event Campaign, and Ansu't Style designs
- **Color Integration**: Full 8-color palette integration with consistent theming
- **Custom Fonts**: Support for custom typography and branding
- **Logo Upload**: Personalized company logo integration
- **QR Code Generation**: Automatic QR code generation for easy sharing

### 🚀 **Export & Sharing**
- **Multi-Format Export**: PNG, PDF, JPG, and vCard formats
- **Real-time Preview**: Live preview of card designs
- **Direct Sharing**: Share to contacts, social media, or save to device
- **Print-Ready**: High-resolution exports suitable for printing

### 📱 **Import & Management**
- **vCard Import**: Import contacts from .vcf files with advanced parsing
- **Batch Processing**: Import multiple contacts at once
- **Contact Validation**: Automatic validation and error handling
- **Smart Parsing**: Supports vCard 2.1 and 3.0 formats

### 💾 **Backup & Sync**
- **JSON Backup**: Complete data backup with version control
- **CSV Export**: Export data for spreadsheet applications
- **Cross-Platform**: Works on iOS, Android, Web, and Desktop
- **Offline-First**: Full functionality without internet connection

### ♿ **Accessibility**
- **WCAG Compliance**: Full accessibility support
- **High Contrast**: Optimized color contrast ratios
- **Screen Reader**: Full screen reader compatibility
- **Dynamic Text**: Support for dynamic text sizing

## 🏗️ **Architecture**

### **Core Architecture**
- **Feature-First**: Clean separation of concerns with feature-based structure
- **Riverpod**: Modern state management with reactive programming
- **GoRouter**: Declarative routing with deep linking support
- **Hive**: Efficient local storage with type adapters

### **Performance**
- **RepaintBoundary**: Optimized rendering with smart caching
- **Lazy Loading**: Efficient memory usage with on-demand loading
- **Background Processing**: Non-blocking operations for smooth UX
- **Code Splitting**: Optimized bundle size with modular imports

## 🚀 **Getting Started**

### **Prerequisites**
- Flutter 3.19 or higher
- Dart 3.9 or higher
- Android Studio / VS Code
- iOS development tools (for iOS builds)

### **Installation**
```bash
# Clone the repository
git clone https://github.com/your-username/mycard.git
cd mycard

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### **Development Setup**
```bash
# Install development dependencies
flutter pub dev

# Run tests
flutter test

# Run with coverage
flutter test --coverage

# Generate build files
flutter pub run build_runner build
```

## 🧪 **Testing**

### **Test Coverage**
- **Unit Tests**: 60%+ coverage with comprehensive test suites
- **Widget Tests**: Golden tests for UI consistency
- **Integration Tests**: Cross-platform integration testing
- **Performance Tests**: Automated performance benchmarking

### **Running Tests**
```bash
# All tests
flutter test

# Unit tests only
flutter test --test-name-regex="unit"

# Widget tests
flutter test --test-name-regex="widget|golden"

# Performance tests
flutter test --test-name-regex="performance"

# Accessibility tests
flutter test --test-name-regex="accessibility"
```

## 🎨 **Design System**

### **Color Palette**
- **Burnt Sienna** (#E28742): Primary accent color
- **Deep Sapphire** (#0E4274): Primary brand color
- **Half Baked** (#8DC5D2): Secondary accent
- **Eternity** (#21130D): Text and borders
- **Burnt Umber** (#873E23): Dark accent
- **Eastern Blue** (#1E81B0): Call-to-action
- **Tacao** (#EAB676): Highlight color
- **Green White** (#EEEEE4): Backgrounds

### **Typography**
- **Roboto**: Primary font for readability
- **Google Fonts**: Extensive font library support
- **Dynamic Text**: Scalable typography system

## 📱 **Platform Support**

| Platform | Status | Features |
|----------|--------|----------|
| Android | ✅ Full | All features supported |
| iOS | ✅ Full | All features supported |
| Web | ✅ Full | Responsive design |
| Windows | ✅ Full | Desktop optimization |
| macOS | ✅ Full | Native feel |
| Linux | ✅ Full | Full functionality |

## 🔄 **CI/CD Pipeline**

### **Automated Workflows**
- **Code Quality**: Automated linting and formatting checks
- **Testing**: Comprehensive test suite execution
- **Security**: Automated vulnerability scanning
- **Deployment**: Automatic deployment to staging and production

### **Quality Gates**
- **Test Coverage**: Minimum 60% coverage required
- **Build Performance**: Build time under 5 minutes
- **Security**: No critical vulnerabilities allowed
- **Performance**: Preview rendering under 100ms

## 🔧 **Configuration**

### **Environment Variables**
```bash
# Firebase Configuration
FIREBASE_APP_ID=your_app_id
FIREBASE_TOKEN=your_token

# Analytics (optional)
ANALYTICS_KEY=your_key
```

### **Build Configuration**
```yaml
# pubspec.yaml
flutter:
  uses-material-design: true
  assets:
    - assets/fonts/
    - assets/icons/
    - assets/logos/
    - assets/events/
    - assets/templates/
```

## 🤝 **Contributing**

### **Development Guidelines**
1. Follow the established code style (see `analysis_options.yaml`)
2. Write tests for new features
3. Update documentation
4. Run the full test suite before submitting PRs
5. Ensure accessibility compliance

### **Git Workflow**
```bash
# Create feature branch
git checkout -b feature/your-feature-name

# Make changes and commit
git commit -m "feat: add your feature"

# Push and create PR
git push origin feature/your-feature-name
```

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 **Acknowledgments**

- **Flutter Team**: For the amazing framework
- **Google Fonts**: For the extensive font library
- **Firebase**: For backend services
- **Community**: For inspiration and feedback

## 📞 **Support**

For support, please:
1. Check the [documentation](.github/CI-CD.md)
2. Search existing [issues](https://github.com/your-username/mycard/issues)
3. Create a new issue with detailed information

---

**Built with ❤️ using Flutter**
