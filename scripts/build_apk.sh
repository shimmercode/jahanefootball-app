#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/mobile"

ENV_NAME="${ENV:-production}"
API_BASE_URL="${API_BASE_URL:-https://raw.githubusercontent.com/shimmercode/jahanefootball-app/v1.0.0/backend/public/v1}"
FOOTBALL_API_BASE_URL="${FOOTBALL_API_BASE_URL:-https://www.thesportsdb.com/api/v1/json/3}"
WORDPRESS_BASE_URL="${WORDPRESS_BASE_URL:-}"

flutter pub get
flutter analyze
flutter test
flutter create --platforms=android --org ir.jahanfootball --project-name jahan_football .
python3 "$ROOT/scripts/configure_android.py"
dart run flutter_launcher_icons
dart run flutter_native_splash:create || true

flutter build apk --release \
  --dart-define=ENV="$ENV_NAME" \
  --dart-define=API_BASE_URL="$API_BASE_URL" \
  --dart-define=FOOTBALL_API_BASE_URL="$FOOTBALL_API_BASE_URL" \
  --dart-define=WORDPRESS_BASE_URL="$WORDPRESS_BASE_URL"

SRC="build/app/outputs/flutter-apk/app-release.apk"
DEST="$ROOT/artifacts/jahan-football-v1.0.0-release.apk"
mkdir -p "$ROOT/artifacts"
cp "$SRC" "$DEST"
python3 "$ROOT/scripts/validate_apk.py" "$DEST"
echo "APK ready: $DEST"
