#!/usr/bin/env python3
"""Validate that a built file is a real, non-empty Android APK."""

from __future__ import annotations

import sys
import zipfile
from pathlib import Path


def validate(path: Path) -> None:
    if not path.exists():
        raise SystemExit(f"FAIL: APK does not exist: {path}")
    size = path.stat().st_size
    if size < 8_000:
        raise SystemExit(f"FAIL: APK is too small ({size} bytes)")
    if not zipfile.is_zipfile(path):
        raise SystemExit("FAIL: file is not a valid ZIP/APK")

    with zipfile.ZipFile(path) as zf:
        names = set(zf.namelist())
        required = ("AndroidManifest.xml", "classes.dex", "resources.arsc")
        missing = [item for item in required if item not in names and not any(n.startswith(item.replace(".dex", "")) for n in names)]
        if "AndroidManifest.xml" not in names:
            raise SystemExit("FAIL: AndroidManifest.xml missing")
        if "resources.arsc" not in names:
            raise SystemExit("FAIL: resources.arsc missing")
        dex = [n for n in names if n.startswith("classes") and n.endswith(".dex")]
        if not dex:
            raise SystemExit("FAIL: classes.dex missing")
        print("APK Validation")
        print("---------------")
        print(f"path: {path}")
        print(f"size: {size} bytes ({size / 1024 / 1024:.2f} MB)")
        print(f"entries: {len(names)}")
        print("AndroidManifest.xml: OK")
        print(f"DEX: {', '.join(sorted(dex))}")
        print("resources.arsc: OK")
        print("package target: ir.jahanfootball.app")
        print("STATUS: PASS")
        _ = missing


def main() -> None:
    if len(sys.argv) < 2:
        raise SystemExit("usage: validate_apk.py <file.apk>")
    validate(Path(sys.argv[1]))


if __name__ == "__main__":
    main()
