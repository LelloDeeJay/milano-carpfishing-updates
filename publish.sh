#!/bin/bash
set -e

echo "🚀 Pubblicazione aggiornamento su GitHub..."

# Incrementa versione e compila
./build.sh

# Leggi la nuova versione
NEW_VERSION=$(grep "^version:" pubspec.yaml | awk '{print $2}')
VERSION_PART="${NEW_VERSION%+*}"
TAG="v$VERSION_PART"

echo ""
echo "🏷️  Creo tag $TAG..."

# Commit e push
git add .
git commit -m "🎣 $NEW_VERSION - aggiornamento"
git push
git tag $TAG
git push origin $TAG

# Chiedi note release
read -p "📝 Note per questa release (o Invio per default): " RELEASE_NOTES
if [ -z "$RELEASE_NOTES" ]; then
    RELEASE_NOTES="Aggiornamento alla versione $NEW_VERSION"
fi

# Crea release su GitHub
gh release create "$TAG" --title "Versione $VERSION_PART" --notes "$RELEASE_NOTES" build/app/outputs/flutter-apk/app-release.apk

echo ""
echo "🎉 PUBBLICAZIONE COMPLETATA!"
echo "📦 Versione: $NEW_VERSION"
echo "🏷️  Tag GitHub: $TAG"
echo "🔗 URL: https://github.com/LelloDeeJay/milano-carpfishing-updates/releases/tag/$TAG"
echo ""
echo "Il presidente può ora aggiornare l'app dal telefono."
