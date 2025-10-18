# CI/CD Pipeline Documentation

## Overview

This project implements a comprehensive CI/CD pipeline using GitHub Actions to ensure code quality, security, and reliable deployment.

## Workflows

### 1. Main CI/CD Pipeline (`.github/workflows/ci-cd.yml`)

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main`
- Releases (published)

**Jobs:**

#### Code Quality
- Code formatting check (`dart format`)
- Static analysis (`flutter analyze`)
- Linting (`flutter lint`)

#### Testing
- **Unit Tests**: Runs all unit tests with coverage reporting
- **Widget Tests**: Runs widget and golden tests
- **Performance Tests**: Validates performance requirements

#### Build & Security
- **Android Build**: Builds APK and App Bundle
- **iOS Build**: Builds iOS app (macOS only)
- **Security Scan**: Uses Trivy for vulnerability scanning

#### Deployment
- **Staging**: Auto-deploys to Firebase App Distribution on `develop` branch
- **Production**: Creates GitHub Release on release publication

### 2. Quality Gate (`.github/workflows/quality-gate.yml`)

**Quality Metrics:**
- **Test Coverage**: Minimum 60% coverage required
- **Build Performance**: Build time must be under 5 minutes
- **Security**: Dependency and code security checks

### 3. Integration Tests (`.github/workflows/integration-tests.yml`)

**Platforms Tested:**
- Android (emulator)
- iOS (simulator)
- Web (Chrome)
- Desktop (Linux, Windows, macOS)
- Accessibility compliance

## Required Secrets

For deployment and services, configure these repository secrets:

- `FIREBASE_APP_ID`: Firebase App ID for App Distribution
- `FIREBASE_TOKEN`: Firebase authentication token

## Quality Standards

### Code Quality
- **Formatting**: All code must follow Dart formatting standards
- **Analysis**: No static analysis warnings or errors
- **Linting**: All lint rules must pass

### Testing
- **Coverage**: Minimum 60% test coverage
- **Unit Tests**: All unit tests must pass
- **Widget Tests**: All widget and golden tests must pass
- **Integration Tests**: All integration tests across platforms must pass

### Performance
- **Build Time**: APK build must complete in under 5 minutes
- **Preview**: Card preview must render in under 100ms
- **Memory**: No memory leaks in performance tests

### Security
- **Dependencies**: No known security vulnerabilities
- **Code**: No security anti-patterns
- **Data**: Proper validation and sanitization

## Running Tests Locally

### Unit Tests
```bash
flutter test
flutter test --coverage
```

### Widget Tests
```bash
flutter test --test-name-regex="widget|golden"
```

### Integration Tests
```bash
flutter test integration_test/
```

### Performance Tests
```bash
flutter test --test-name-regex="performance"
```

## Deployment Process

### Staging (Firebase App Distribution)
1. Triggers on push to `develop` branch
2. Builds Android App Bundle
3. Deploys to Firebase App Distribution
4. Notifies staging testers group

### Production (GitHub Releases)
1. Triggers on release publication
2. Builds APK and App Bundle
3. Creates GitHub Release with artifacts
4. Generates release notes automatically

## Monitoring

### Coverage Reports
- Coverage reports are uploaded as artifacts
- Integrated with Codecov for coverage tracking
- Minimum 60% coverage enforced

### Security Scanning
- Trivy scans for vulnerabilities
- Results uploaded to GitHub Security tab
- Fail build on critical vulnerabilities

### Performance Monitoring
- Build times monitored and enforced
- Performance metrics tracked in tests
- Alerts on performance degradation

## Troubleshooting

### Common Issues

1. **Build Failures**
   - Check Flutter version compatibility
   - Verify all dependencies are up to date
   - Review error logs for specific issues

2. **Test Failures**
   - Run tests locally to reproduce issues
   - Check golden test image comparisons
   - Verify test data and fixtures

3. **Deployment Issues**
   - Verify Firebase configuration
   - Check authentication tokens
   - Review deployment logs

### Debug Mode

To enable debug logging, set the following in your workflow:

```yaml
env:
  FLUTTER_VERBOSE: true
```

## Contributing

1. All code changes must pass CI/CD checks
2. Update tests when adding new features
3. Maintain or improve test coverage
4. Follow the established code style and patterns
5. Test accessibility features when relevant

## Support

For CI/CD related issues:
- Check workflow logs
- Review this documentation
- Create an issue with relevant logs and error messages