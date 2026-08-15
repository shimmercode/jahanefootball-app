#!/usr/bin/env python3
"""Package aapt2 resources + smali DEX and sign the APK (v1)."""

from __future__ import annotations

import importlib.util
import shutil
import subprocess
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load_make_apk():
    spec = importlib.util.spec_from_file_location("make_apk", ROOT / "scripts" / "make_apk.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def package(base_apk: Path, dex: Path, dest: Path) -> None:
    work = dest.parent / ".pack"
    if work.exists():
        shutil.rmtree(work)
    work.mkdir(parents=True)
    with zipfile.ZipFile(base_apk) as zf:
        zf.extractall(work)
    shutil.copy2(dex, work / "classes.dex")

    files: dict[str, bytes] = {}
    for path in work.rglob("*"):
        if path.is_file() and "META-INF" not in path.parts:
            files[str(path.relative_to(work)).replace("\\", "/")] = path.read_bytes()

    mod = load_make_apk()
    signwork = dest.parent / ".signwork"
    signwork.mkdir(exist_ok=True)
    mf = mod.build_manifest_mf(files)
    sf = mod.build_cert_sf(mf)
    rsa = mod.sign_sf(sf.encode("utf-8"), signwork)
    files["META-INF/MANIFEST.MF"] = mf.encode("utf-8")
    files["META-INF/CERT.SF"] = sf.encode("utf-8")
    files["META-INF/CERT.RSA"] = rsa

    order = ["AndroidManifest.xml", "classes.dex", "resources.arsc"]
    rest = sorted(name for name in files if name not in order)
    dest.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(dest, "w") as zf:
        for name in order + rest:
            info = zipfile.ZipInfo(name)
            info.external_attr = 0o644 << 16
            info.compress_type = zipfile.ZIP_STORED if name.endswith((".png", ".arsc")) else zipfile.ZIP_DEFLATED
            zf.writestr(info, files[name])


def main() -> None:
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("--base", required=True)
    parser.add_argument("--dex", required=True)
    parser.add_argument("--out", required=True)
    args = parser.parse_args()
    package(Path(args.base), Path(args.dex), Path(args.out))
    print(args.out)


if __name__ == "__main__":
    main()
