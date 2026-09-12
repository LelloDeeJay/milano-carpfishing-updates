#!/bin/bash
set -e

echo "🚀 Pubblicazione aggiornamento su GitHub..."

APK="build/app/outputs/flutter-apk/app-release.apk"

if [ ! -f "$APK" ]; then
    echo "❌ APK non trovato. Compila prima con: ./build.sh"
    exit 1
fi

NEW_VERSION=$(grep "^version:" pubspec.yaml | awk '{print $2}')
VERSION_PART="${NEW_VERSION%+*}"
TAG="v$VERSION_PART"

APK_NOME="La_Nuova_Milano_Carpfishing_V${VERSION_PART}.apk"
cp "$APK" "$APK_NOME"

echo "📦 Versione: $NEW_VERSION"
echo "🏷️  Tag: $TAG"
echo "📱 APK: $APK_NOME"
echo ""

# NON committiamo codice sorgente, solo README
git add README.md .gitignore publish.sh 2>/dev/null || true
git commit -m "🎣 Release $VERSION_PART" 2>/dev/null || echo "Nessuna modifica al README"
git push 2>/dev/null || echo "Push fallito (nessun problema, la release va comunque)"

git tag "$TAG" 2>/dev/null || echo "Tag già esistente"
git push origin "$TAG" 2>/dev/null || echo "Tag già pubblicato"

read -p "📝 Note per questa release (o Invio per default): " RELEASE_NOTES
if [ -z "$RELEASE_NOTES" ]; then
    RELEASE_NOTES="Aggiornamento alla versione $NEW_VERSION"
fi

# Crea release con SOLO l'APK (niente codice)
gh release create "$TAG" --title "Versione $VERSION_PART" --notes "$RELEASE_NOTES" "$APK_NOME"

# Pulisci APK temporaneo
rm -f "$APK_NOME"

echo ""
echo "🎉 PUBBLICAZIONE COMPLETATA!"
echo "📦 Versione: $NEW_VERSION"
echo "🏷️  Tag GitHub: $TAG"
echo "🔗 URL: https://github.com/LelloDeeJay/milano-carpfishing-updates/releases/tag/$TAG"
echo ""
echo "✅ Solo APK pubblicato, codice sorgente protetto sul tuo PC"
