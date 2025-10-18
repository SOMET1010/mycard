#!/bin/bash

# Script pour build les versions release avec numérotation
# Usage: ./scripts/build_release.sh [android|ios|web]

PLATFORM=${1:-android}
BUILD_NUMBER=$(git rev-list --count HEAD)
VERSION_CODE=$((BUILD_NUMBER + 1000))

echo "=== Build Release pour $PLATFORM ==="
echo "Build Number: $BUILD_NUMBER"
echo "Version Code: $VERSION_CODE"

case $PLATFORM in
    "android")
        echo "Build Android APK..."
        flutter build apk --release --build-number=$BUILD_NUMBER
        echo "Build Android AAB..."
        flutter build appbundle --release --build-number=$BUILD_NUMBER
        ;;
    "ios")
        echo "Build iOS..."
        flutter build ios --release --build-number=$BUILD_NUMBER
        ;;
    "web")
        echo "Build Web..."
        flutter build web --release
        ;;
    *)
        echo "Platform non supportée: $PLATFORM"
        echo "Utilisation: android, ios, web"
        exit 1
        ;;
esac

echo "=== Build terminé ==="