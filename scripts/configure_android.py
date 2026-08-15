#!/usr/bin/env python3
"""Apply production Android identity after `flutter create`."""

from __future__ import annotations

import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[1]
ANDROID = ROOT / "mobile" / "android"
APP_ID = "ir.jahanfootball.app"
APP_LABEL = "جهان فوتبال"


def replace_in_file(path: pathlib.Path, pattern: str, repl: str) -> None:
    if not path.exists():
        return
    text = path.read_text(encoding="utf-8")
    updated = re.sub(pattern, repl, text)
    if updated != text:
        path.write_text(updated, encoding="utf-8")


def patch_manifest() -> None:
    manifest = ANDROID / "app" / "src" / "main" / "AndroidManifest.xml"
    if not manifest.exists():
        raise SystemExit(f"missing {manifest}")
    text = manifest.read_text(encoding="utf-8")
    if "android.permission.INTERNET" not in text:
        text = text.replace(
            "<manifest",
            '<manifest',
            1,
        )
        text = text.replace(
            ">",
            """>
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
""",
            1,
        )
    text = re.sub(r'android:label="[^"]*"', f'android:label="{APP_LABEL}"', text)
    if "android:usesCleartextTraffic" not in text:
        text = text.replace(
            "<application",
            '<application android:usesCleartextTraffic="false" android:supportsRtl="true"',
            1,
        )
    manifest.write_text(text, encoding="utf-8")


def patch_gradle() -> None:
    for name in ("build.gradle", "build.gradle.kts"):
        path = ANDROID / "app" / name
        if not path.exists():
            continue
        text = path.read_text(encoding="utf-8")
        text = re.sub(
            r'applicationId\s*=\s*"[^"]+"',
            f'applicationId = "{APP_ID}"',
            text,
        )
        text = re.sub(
            r'applicationId\s+"[^"]+"',
            f'applicationId "{APP_ID}"',
            text,
        )
        text = re.sub(r"minSdk\s*=\s*\w+", "minSdk = 23", text)
        text = re.sub(r"minSdkVersion\s+\w+", "minSdkVersion 23", text)
        text = re.sub(r"versionCode\s*=\s*\d+", "versionCode = 1", text)
        text = re.sub(r'versionName\s*=\s*"[^"]+"', 'versionName = "1.0.0"', text)
        path.write_text(text, encoding="utf-8")


def main() -> None:
    if not ANDROID.exists():
        raise SystemExit("android/ folder missing — run flutter create first")
    patch_manifest()
    patch_gradle()
    print("Android production identity applied:", APP_ID)


if __name__ == "__main__":
    main()
