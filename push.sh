#!/bin/bash
# === AUTOMATISCHES GIT DEPLOYMENT MIT REMOTE-INTEGRATION ===
# Für PointClickAdventureEditor (Eclipse Projekt)

PROJEKT_PFAD="C:\Users\pc\Documents\Phoenix Code\Grammar"
GITHUB_URL="https://github.com/einsundnull/HTML_Grammar.git"

echo "🚀 Starte automatisches Git Deployment..."

# === 1. Verzeichnis prüfen ===
cd "$PROJEKT_PFAD" || {
  echo "❌ Pfad existiert nicht: $PROJEKT_PFAD"
  read -p "Drücke Enter zum Schließen..."
  exit 1
}
echo "✅ Arbeitsverzeichnis: $(pwd)"

# === 2. Git Initialisierung ===
if [ ! -d ".git" ]; then
  echo "🔧 Initialisiere Git Repository..."
  git init
  git branch -M main
  git remote add origin "$GITHUB_URL"
fi

# === 3. Dateien hinzufügen & committen ===
git add -A
if git diff --cached --quiet; then
  echo "⚠️ Keine Änderungen zum Commit gefunden."
else
  COMMIT_MSG="Auto Deploy - $(date '+%Y-%m-%d %H:%M:%S')"
  git commit -m "$COMMIT_MSG" && echo "✅ Commit erstellt: $COMMIT_MSG"
fi

# === 4. Remote Pull (Rebase) ===
echo "📥 Remote Änderungen integrieren..."
if git pull --rebase origin main; then
  echo "✅ Remote Änderungen integriert."
else
  echo "⚠️ Fehler beim Integrieren. Fortfahren mit lokalem Stand..."
fi

# === 5. Push ===
echo "🚀 Push nach GitHub..."
if git push origin main; then
  STATUS="✅ Push erfolgreich!"
else
  echo "⚠️ Normaler Push fehlgeschlagen. Versuche mit --force-with-lease..."
  if git push --force-with-lease origin main; then
    STATUS="✅ Force Push erfolgreich!"
  else
    STATUS="❌ Push endgültig fehlgeschlagen."
  fi
fi

# === 6. Zusammenfassung ===
echo
echo "───────────────────────────────────────"
echo "📦  Git Deployment Status:"
echo "    $STATUS"
echo "📂  Projekt: $PROJEKT_PFAD"
echo "🔗  Repo: $GITHUB_URL"
echo "───────────────────────────────────────"
echo

read -p "Drücke Enter, um das Fenster zu schließen..."
exit 0
