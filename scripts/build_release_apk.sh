#!/usr/bin/env bash
# Build an installable APK with official aapt2 + android.jar, then sign it.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
AAPT="${AAPT:-/home/user/vendor-src/npm-tools/package/bin/x64/linux/aapt2}"
ANDROID_JAR="${ANDROID_JAR:-/home/user/vendor-src/android-platforms/android-23/android.jar}"
WORKDIR="${TMPDIR:-/tmp}/jahan-football-apk"
ICON="$ROOT/mobile/assets/branding/app_icon_1024.png"

if [[ ! -x "$AAPT" ]]; then
  echo "aapt2 not found at $AAPT" >&2
  exit 1
fi
if [[ ! -f "$ANDROID_JAR" ]]; then
  echo "android.jar not found at $ANDROID_JAR" >&2
  exit 1
fi

rm -rf "$WORKDIR"
mkdir -p "$WORKDIR/res/values" "$WORKDIR/res/mipmap-hdpi" \
  "$WORKDIR/res/mipmap-xhdpi" "$WORKDIR/res/mipmap-xxhdpi" \
  "$WORKDIR/assets" "$WORKDIR/compiled"

cp "$ROOT/android-shell/AndroidManifest.xml" "$WORKDIR/AndroidManifest.xml"
cp "$ROOT/android-shell/www/index.html" "$WORKDIR/assets/index.html"
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
  --target-sdk-version 28 \
  --version-code 1 \
  --version-name 1.0.0 \
  --auto-add-overlay \
  -A "$WORKDIR/assets"

python3 - <<PY
import importlib.util, shutil, zipfile
from pathlib import Path
root = Path("$ROOT")
spec = importlib.util.spec_from_file_location("make_apk", root / "scripts" / "make_apk.py")
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)
work = Path("$WORKDIR/pack")
if work.exists():
    shutil.rmtree(work)
work.mkdir()
with zipfile.ZipFile("$WORKDIR/base.apk") as zf:
    zf.extractall(work)
(work / "classes.dex").write_bytes(mod.build_dex())
files = {}
for p in work.rglob("*"):
    if p.is_file() and "META-INF" not in p.parts:
        files[str(p.relative_to(work)).replace("\\\\", "/")] = p.read_bytes()
signwork = Path("$WORKDIR/signwork")
signwork.mkdir(exist_ok=True)
mf = mod.build_manifest_mf(files)
sf = mod.build_cert_sf(mf)
rsa = mod.sign_sf(sf.encode("utf-8"), signwork)
files["META-INF/MANIFEST.MF"] = mf.encode("utf-8")
files["META-INF/CERT.SF"] = sf.encode("utf-8")
files["META-INF/CERT.RSA"] = rsa
out = root / "artifacts" / "jahan-football-v1.0.0-release.apk"
order = ["AndroidManifest.xml", "classes.dex", "resources.arsc"]
rest = sorted(k for k in files if k not in order)
with zipfile.ZipFile(out, "w") as zf:
    for name in order + rest:
        info = zipfile.ZipInfo(name)
        info.external_attr = 0o644 << 16
        info.compress_type = zipfile.ZIP_STORED if name.endswith((".png", ".arsc")) else zipfile.ZIP_DEFLATED
        zf.writestr(info, files[name])
(root / "artifacts" / "JahanFootball.apk").write_bytes(out.read_bytes())
print(out, out.stat().st_size)
PY

python3 "$ROOT/scripts/validate_apk.py" "$ROOT/artifacts/jahan-football-v1.0.0-release.apk"
echo "APK ready"
