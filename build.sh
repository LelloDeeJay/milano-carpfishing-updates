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
    
    # Rinomina l'APK con nome leggibile
    APK_ORIGINALE="build/app/outputs/flutter-apk/app-release.apk"
    APK_RINOMINATO="build/app/outputs/flutter-apk/La_Nuova_Milano_Carpfishing_V${VERSION_PART}.apk"
    cp "$APK_ORIGINALE" "$APK_RINOMINATO"
    
    echo "📱 APK rinominato: $APK_RINOMINATO"
    echo ""
    ls -lh "$APK_RINOMINATO"
    echo ""
    echo "💡 Per pubblicare su GitHub:"
    echo "   ./publish.sh"
else
    echo "❌ Build fallita"
    exit 1
fi
