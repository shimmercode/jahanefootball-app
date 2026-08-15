#!/usr/bin/env bash
# Build an installable APK:
#   aapt2 (manifest/resources) + smali (real DEX) + v1 signature
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
AAPT="${AAPT:-/home/user/vendor-src/npm-tools/package/bin/x64/linux/aapt2}"
ANDROID_JAR="${ANDROID_JAR:-/home/user/vendor-src/android-platforms/android-23/android.jar}"
JAVA="${JAVA:-/tmp/package/jre/bin/java}"
SMALI="${SMALI:-/tmp/yongjhih-rc/bin/smali-2.1.0.jar}"
WORKDIR="${TMPDIR:-/tmp}/jahan-football-apk"
ICON="$ROOT/android-shell/res-src/ic_launcher.png"
if [[ ! -f "$ICON" ]]; then
  ICON="$ROOT/mobile/assets/branding/app_icon_1024.png"
fi

for req in "$AAPT" "$ANDROID_JAR" "$JAVA" "$SMALI" "$ICON"; do
  if [[ ! -e "$req" ]]; then
    echo "missing required tool/file: $req" >&2
    exit 1
  fi
done

rm -rf "$WORKDIR"
mkdir -p "$WORKDIR/res/values" "$WORKDIR/res/mipmap-hdpi" \
  "$WORKDIR/res/mipmap-xhdpi" "$WORKDIR/res/mipmap-xxhdpi" \
  "$WORKDIR/assets" "$WORKDIR/compiled"

cp "$ROOT/android-shell/AndroidManifest.xml" "$WORKDIR/AndroidManifest.xml"
cp -a "$ROOT/android-shell/www/." "$WORKDIR/assets/"
cat > "$WORKDIR/res/values/strings.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">جهان فوتبال</string>
</resources>
EOF
for d in mipmap-hdpi mipmap-xhdpi mipmap-xxhdpi; do
  cp "$ICON" "$WORKDIR/res/$d/ic_launcher.png"
done

"$AAPT" compile --dir "$WORKDIR/res" -o "$WORKDIR/compiled"
"$AAPT" link -o "$WORKDIR/base.apk" \
  -I "$ANDROID_JAR" \
  --manifest "$WORKDIR/AndroidManifest.xml" \
  -R "$WORKDIR/compiled"/*.flat \
  --min-sdk-version 21 \
  --target-sdk-version 29 \
  --version-code 2 \
  --version-name 1.0.1 \
  --auto-add-overlay \
  -A "$WORKDIR/assets"

"$JAVA" -jar "$SMALI" -a 29 -o "$WORKDIR/classes.dex" "$ROOT/android-shell/smali"
python3 "$ROOT/scripts/package_signed_apk.py" \
  --base "$WORKDIR/base.apk" \
  --dex "$WORKDIR/classes.dex" \
  --out "$ROOT/artifacts/jahan-football-v1.0.0-release.apk"
cp -f "$ROOT/artifacts/jahan-football-v1.0.0-release.apk" \
  "$ROOT/artifacts/JahanFootball.apk"
python3 "$ROOT/scripts/validate_apk.py" "$ROOT/artifacts/jahan-football-v1.0.0-release.apk"
echo "APK ready"
