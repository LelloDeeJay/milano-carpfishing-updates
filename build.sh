#!/bin/bash

echo "🔨 Compilazione con incremento automatico versione..."

# Leggi la versione attuale
VERSION_LINE=$(grep "^version:" pubspec.yaml)
OLD_VERSION=$(echo $VERSION_LINE | awk '{print $2}')

# Separa versione e build number
VERSION_PART="${OLD_VERSION%+*}"
BUILD_PART="${OLD_VERSION#*+}"

# Separa major.minor.patch
IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION_PART"

# Incrementa patch e build number
NEW_PATCH=$((PATCH + 1))
NEW_BUILD=$((BUILD_PART + 1))
NEW_VERSION="$MAJOR.$MINOR.$NEW_PATCH+$NEW_BUILD"

# Aggiorna il pubspec
sed -i "s/^version: $OLD_VERSION/version: $NEW_VERSION/" pubspec.yaml

echo "✅ Versione aggiornata: $OLD_VERSION → $NEW_VERSION"
echo ""

# Compila
flutter build apk --release

# Verifica successo
if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 Build completata con successo!"
    echo "📦 Versione: $NEW_VERSION"
    echo "📱 APK: build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    ls -lh build/app/outputs/flutter-apk/app-release.apk
else
    echo "❌ Build fallita"
    exit 1
fi
