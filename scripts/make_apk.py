#!/usr/bin/env python3
"""Build a signed, installable Android APK without the Android SDK.

Produces a WebView shell around android-shell/www/index.html.
Package: ir.jahanfootball.app
"""

from __future__ import annotations

import hashlib
import io
import os
import struct
import subprocess
import sys
import zipfile
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WWW = ROOT / "android-shell" / "www" / "index.html"
OUT = ROOT / "artifacts" / "jahan-football-v1.0.0-release.apk"
ALT = ROOT / "artifacts" / "JahanFootball.apk"

ANDROID_NS = "http://schemas.android.com/apk/res/android"
RES_IDS = {
    "theme": 0x01010000,
    "label": 0x01010001,
    "icon": 0x01010002,
    "name": 0x01010003,
    "exported": 0x01010010,
    "minSdkVersion": 0x0101020C,
    "versionCode": 0x0101021B,
    "versionName": 0x0101021C,
    "targetSdkVersion": 0x01010270,
    "hardwareAccelerated": 0x010102D3,
    "usesCleartextTraffic": 0x010104EC,
}

TYPE_NULL = 0x00
TYPE_STRING = 0x03
TYPE_INT_DEC = 0x10
TYPE_INT_BOOLEAN = 0x12


def _u8(n: int) -> bytes:
    return struct.pack("<B", n)


def _u16(n: int) -> bytes:
    return struct.pack("<H", n & 0xFFFF)


def _u32(n: int) -> bytes:
    return struct.pack("<I", n & 0xFFFFFFFF)


def _s32(n: int) -> bytes:
    return struct.pack("<i", n)


def _align4(buf: bytearray) -> None:
    while len(buf) % 4:
        buf.append(0)


def mutf8(text: str) -> bytes:
    out = bytearray()
    for ch in text:
        code = ord(ch)
        if code == 0:
            out.extend(b"\xc0\x80")
        elif code <= 0x7F:
            out.append(code)
        elif code <= 0x7FF:
            out.append(0xC0 | (code >> 6))
            out.append(0x80 | (code & 0x3F))
        else:
            out.append(0xE0 | (code >> 12))
            out.append(0x80 | ((code >> 6) & 0x3F))
            out.append(0x80 | (code & 0x3F))
    return bytes(out)


def uleb128(value: int) -> bytes:
    out = bytearray()
    while True:
        byte = value & 0x7F
        value >>= 7
        if value:
            out.append(byte | 0x80)
        else:
            out.append(byte)
            break
    return bytes(out)


# ---------------------------------------------------------------------------
# Binary AndroidManifest
# ---------------------------------------------------------------------------


class StringPool:
    def __init__(self) -> None:
        self.items: list[str] = []
        self.index: dict[str, int] = {}

    def add(self, value: str) -> int:
        if value not in self.index:
            self.index[value] = len(self.items)
            self.items.append(value)
        return self.index[value]

    def encode(self) -> bytes:
        count = len(self.items)
        encoded = [value.encode("utf-16le") for value in self.items]
        offsets = []
        data = bytearray()
        for blob in encoded:
            offsets.append(len(data))
            utf16_len = len(blob) // 2
            data.extend(_u16(utf16_len))
            data.extend(blob)
            data.extend(_u16(0))
        _align4(data)
        header_size = 0x1C
        strings_start = header_size + 4 * count
        chunk = bytearray()
        chunk.extend(_u16(0x0001))
        chunk.extend(_u16(header_size))
        chunk.extend(_u32(0))  # placeholder size
        chunk.extend(_u32(count))
        chunk.extend(_u32(0))  # styles
        chunk.extend(_u32(0))  # flags UTF-16
        chunk.extend(_u32(strings_start))
        chunk.extend(_u32(0))
        for off in offsets:
            chunk.extend(_u32(off))
        chunk.extend(data)
        struct.pack_into("<I", chunk, 4, len(chunk))
        return bytes(chunk)


def typed_attr(ns: int, name: int, data_type: int, data: int, raw: int = -1) -> bytes:
    return _s32(ns) + _s32(name) + _s32(raw) + _u16(8) + _u8(0) + _u8(data_type) + _u32(data)


def xml_node(node_type: int, body: bytes, line: int = 1) -> bytes:
    header_size = 0x10
    chunk = bytearray()
    chunk.extend(_u16(node_type))
    chunk.extend(_u16(header_size))
    chunk.extend(_u32(header_size + 8 + len(body)))
    chunk.extend(_u32(line))
    chunk.extend(_s32(-1))
    chunk.extend(body)
    return bytes(chunk)


def build_manifest() -> bytes:
    pool = StringPool()
    # Resource-map IDs apply to the FIRST N strings. Put android attrs first.
    attr_name = pool.add("name")
    attr_label = pool.add("label")
    attr_exported = pool.add("exported")
    attr_min = pool.add("minSdkVersion")
    attr_vcode = pool.add("versionCode")
    attr_vname = pool.add("versionName")
    attr_target = pool.add("targetSdkVersion")
    attr_hw = pool.add("hardwareAccelerated")
    attr_clear = pool.add("usesCleartextTraffic")
    res_ids_in_order = [
        RES_IDS["name"],
        RES_IDS["label"],
        RES_IDS["exported"],
        RES_IDS["minSdkVersion"],
        RES_IDS["versionCode"],
        RES_IDS["versionName"],
        RES_IDS["targetSdkVersion"],
        RES_IDS["hardwareAccelerated"],
        RES_IDS["usesCleartextTraffic"],
    ]

    android = pool.add(ANDROID_NS)
    prefix = pool.add("android")
    manifest = pool.add("manifest")
    uses_sdk = pool.add("uses-sdk")
    uses_permission = pool.add("uses-permission")
    application = pool.add("application")
    activity = pool.add("activity")
    intent_filter = pool.add("intent-filter")
    action = pool.add("action")
    category = pool.add("category")
    attr_package = pool.add("package")
    pkg = pool.add("ir.jahanfootball.app")
    app_label = pool.add("جهان فوتبال")
    vname = pool.add("1.0.0")
    internet = pool.add("android.permission.INTERNET")
    netstate = pool.add("android.permission.ACCESS_NETWORK_STATE")
    activity_name = pool.add("ir.jahanfootball.app.MainActivity")
    main_action = pool.add("android.intent.action.MAIN")
    launcher = pool.add("android.intent.category.LAUNCHER")

    def start(name_idx: int, attrs: list[bytes]) -> bytes:
        body = bytearray()
        body.extend(_s32(-1))
        body.extend(_s32(name_idx))
        body.extend(_u16(0x14))
        body.extend(_u16(0x14))
        body.extend(_u16(len(attrs)))
        body.extend(_u16(0))
        body.extend(_u16(0))
        body.extend(_u16(0))
        for attr in attrs:
            body.extend(attr)
        return xml_node(0x0102, bytes(body))

    def end(name_idx: int) -> bytes:
        return xml_node(0x0103, _s32(-1) + _s32(name_idx))

    def perm(value_idx: int) -> bytes:
        return start(
            uses_permission,
            [typed_attr(android, attr_name, TYPE_STRING, value_idx, value_idx)],
        ) + end(uses_permission)

    nodes = bytearray()
    nodes.extend(xml_node(0x0100, _s32(prefix) + _s32(android)))
    nodes.extend(
        start(
            manifest,
            [
                typed_attr(-1, attr_package, TYPE_STRING, pkg, pkg),
                typed_attr(android, attr_vcode, TYPE_INT_DEC, 1),
                typed_attr(android, attr_vname, TYPE_STRING, vname, vname),
            ],
        )
    )
    nodes.extend(
        start(
            uses_sdk,
            [
                typed_attr(android, attr_min, TYPE_INT_DEC, 23),
                typed_attr(android, attr_target, TYPE_INT_DEC, 28),
            ],
        )
    )
    nodes.extend(end(uses_sdk))
    nodes.extend(perm(internet))
    nodes.extend(perm(netstate))
    nodes.extend(
        start(
            application,
            [
                typed_attr(android, attr_label, TYPE_STRING, app_label, app_label),
                typed_attr(android, attr_hw, TYPE_INT_BOOLEAN, 0xFFFFFFFF),
                typed_attr(android, attr_clear, TYPE_INT_BOOLEAN, 0),
            ],
        )
    )
    nodes.extend(
        start(
            activity,
            [
                typed_attr(android, attr_name, TYPE_STRING, activity_name, activity_name),
                typed_attr(android, attr_exported, TYPE_INT_BOOLEAN, 0xFFFFFFFF),
                typed_attr(android, attr_label, TYPE_STRING, app_label, app_label),
            ],
        )
    )
    nodes.extend(start(intent_filter, []))
    nodes.extend(
        start(action, [typed_attr(android, attr_name, TYPE_STRING, main_action, main_action)])
    )
    nodes.extend(end(action))
    nodes.extend(
        start(category, [typed_attr(android, attr_name, TYPE_STRING, launcher, launcher)])
    )
    nodes.extend(end(category))
    nodes.extend(end(intent_filter))
    nodes.extend(end(activity))
    nodes.extend(end(application))
    nodes.extend(end(manifest))
    nodes.extend(xml_node(0x0101, _s32(prefix) + _s32(android)))

    pool_blob = pool.encode()
    resmap = bytearray()
    resmap.extend(_u16(0x0180))
    resmap.extend(_u16(8))
    resmap.extend(_u32(8 + 4 * len(res_ids_in_order)))
    for rid in res_ids_in_order:
        resmap.extend(_u32(rid))

    file_body = pool_blob + bytes(resmap) + bytes(nodes)
    header = _u16(0x0003) + _u16(8) + _u32(8 + len(file_body))
    return header + file_body


def build_resources_arsc() -> bytes:
    # Empty resource table — valid ResTable with zero packages.
    return _u16(0x0002) + _u16(0x000C) + _u32(12) + _u32(0)


# ---------------------------------------------------------------------------
# DEX: WebView Activity
# ---------------------------------------------------------------------------


class DexBuilder:
    def __init__(self) -> None:
        self.strings: list[str] = []
        self.string_index: dict[str, int] = {}
        self.types: list[str] = []
        self.protos: list[tuple[str, str, tuple[str, ...]]] = []
        self.methods: list[tuple[str, tuple[str, str, tuple[str, ...]], str]] = []

    def s(self, value: str) -> int:
        if value not in self.string_index:
            self.string_index[value] = len(self.strings)
            self.strings.append(value)
        return self.string_index[value]

    def add_type(self, descriptor: str) -> None:
        self.s(descriptor)
        if descriptor not in self.types:
            self.types.append(descriptor)

    def add_proto(self, shorty: str, ret: str, params: tuple[str, ...]) -> None:
        self.s(shorty)
        self.add_type(ret)
        for p in params:
            self.add_type(p)
        item = (shorty, ret, params)
        if item not in self.protos:
            self.protos.append(item)

    def add_method(self, owner: str, proto: tuple[str, str, tuple[str, ...]], name: str) -> None:
        self.add_type(owner)
        self.add_proto(*proto)
        self.s(name)
        item = (owner, proto, name)
        if item not in self.methods:
            self.methods.append(item)

    def type_idx(self, descriptor: str) -> int:
        return self.types.index(descriptor)

    def proto_idx(self, proto: tuple[str, str, tuple[str, ...]]) -> int:
        return self.protos.index(proto)

    def method_idx(self, owner: str, proto: tuple[str, str, tuple[str, ...]], name: str) -> int:
        return self.methods.index((owner, proto, name))


def insn_35c(op: int, arg_count: int, method_idx: int, regs: list[int]) -> bytes:
    regs = list(regs) + [0] * 5
    c, d, e, f, g = regs[:5]
    word0 = op | (g << 8) | (arg_count << 12)
    word2 = c | (d << 4) | (e << 8) | (f << 12)
    return _u16(word0) + _u16(method_idx) + _u16(word2)


def build_dex() -> bytes:
    d = DexBuilder()
    p_void = ("V", "V", ())
    p_bundle = ("VL", "V", ("Landroid/os/Bundle;",))
    p_ctx = ("VL", "V", ("Landroid/content/Context;",))
    p_settings = ("L", "Landroid/webkit/WebSettings;", ())
    p_bool = ("VZ", "V", ("Z",))
    p_str = ("VL", "V", ("Ljava/lang/String;",))
    p_view = ("VL", "V", ("Landroid/view/View;",))

    cls = "Lir/jahanfootball/app/MainActivity;"
    for t in (
        "V",
        "Z",
        "Ljava/lang/Object;",
        "Ljava/lang/String;",
        "Landroid/app/Activity;",
        "Landroid/os/Bundle;",
        "Landroid/webkit/WebView;",
        "Landroid/webkit/WebSettings;",
        "Landroid/content/Context;",
        "Landroid/view/View;",
        cls,
    ):
        d.add_type(t)

    d.s("file:///android_asset/index.html")
    d.s("MainActivity.java")
    d.s("<init>")
    d.s("onCreate")
    d.s("getSettings")
    d.s("setJavaScriptEnabled")
    d.s("loadUrl")
    d.s("setContentView")

    d.add_method("Landroid/app/Activity;", p_void, "<init>")
    d.add_method("Landroid/app/Activity;", p_bundle, "onCreate")
    d.add_method("Landroid/app/Activity;", p_view, "setContentView")
    d.add_method("Landroid/webkit/WebView;", p_ctx, "<init>")
    d.add_method("Landroid/webkit/WebView;", p_settings, "getSettings")
    d.add_method("Landroid/webkit/WebSettings;", p_bool, "setJavaScriptEnabled")
    d.add_method("Landroid/webkit/WebView;", p_str, "loadUrl")
    d.add_method(cls, p_void, "<init>")
    d.add_method(cls, p_bundle, "onCreate")

    # ---- data blobs we can compute after laying out ids ----
    # We assemble in two passes: first emit data with placeholder offsets via a layout buffer.

    string_data = bytearray()
    string_data_offs: list[int] = []
    for item in d.strings:
        string_data_offs.append(len(string_data))
        encoded = mutf8(item)
        string_data.extend(uleb128(len(item)))
        string_data.extend(encoded)
        string_data.append(0)
    _align4(string_data)

    # type lists for protos that have params
    type_lists: dict[tuple[str, ...], bytearray] = {}
    for _shorty, _ret, params in d.protos:
        if params and params not in type_lists:
            blob = bytearray()
            blob.extend(_u32(len(params)))
            for p in params:
                blob.extend(_u16(d.type_idx(p)))
            _align4(blob)
            type_lists[params] = blob

    init_code = bytearray()
    init_code.extend(insn_35c(0x70, 1, d.method_idx("Landroid/app/Activity;", p_void, "<init>"), [0]))
    init_code.extend(_u16(0x000E))  # return-void

    url_idx = d.s("file:///android_asset/index.html")
    oncreate = bytearray()
    oncreate.extend(insn_35c(0x6F, 2, d.method_idx("Landroid/app/Activity;", p_bundle, "onCreate"), [3, 4]))
    oncreate.extend(_u8(0x22) + _u8(0x00) + _u16(d.type_idx("Landroid/webkit/WebView;")))
    oncreate.extend(insn_35c(0x70, 2, d.method_idx("Landroid/webkit/WebView;", p_ctx, "<init>"), [0, 3]))
    oncreate.extend(insn_35c(0x6E, 1, d.method_idx("Landroid/webkit/WebView;", p_settings, "getSettings"), [0]))
    oncreate.extend(_u8(0x0C) + _u8(0x01))
    oncreate.extend(_u8(0x12) + _u8(0x12))
    oncreate.extend(insn_35c(0x6E, 2, d.method_idx("Landroid/webkit/WebSettings;", p_bool, "setJavaScriptEnabled"), [1, 2]))
    oncreate.extend(_u8(0x1A) + _u8(0x02) + _u16(url_idx))
    oncreate.extend(insn_35c(0x6E, 2, d.method_idx("Landroid/webkit/WebView;", p_str, "loadUrl"), [0, 2]))
    oncreate.extend(insn_35c(0x6E, 2, d.method_idx("Landroid/app/Activity;", p_view, "setContentView"), [3, 0]))
    oncreate.extend(_u16(0x000E))
    if (len(oncreate) // 2) % 2 == 1:
        oncreate.extend(_u16(0))

    def code_item(registers: int, ins: int, outs: int, insns: bytes) -> bytes:
        insns_size = len(insns) // 2
        item = bytearray()
        item.extend(_u16(registers))
        item.extend(_u16(ins))
        item.extend(_u16(outs))
        item.extend(_u16(0))
        item.extend(_u32(0))
        item.extend(_u32(insns_size))
        item.extend(insns)
        _align4(item)
        return bytes(item)

    init_item = code_item(1, 1, 1, bytes(init_code))
    oncreate_item = code_item(5, 2, 2, bytes(oncreate))

    # Layout
    header_size = 0x70
    string_ids_off = header_size
    string_ids_size = len(d.strings)
    type_ids_off = string_ids_off + 4 * string_ids_size
    type_ids_size = len(d.types)
    proto_ids_off = type_ids_off + 4 * type_ids_size
    proto_ids_size = len(d.protos)
    field_ids_off = proto_ids_off + 12 * proto_ids_size
    field_ids_size = 0
    method_ids_off = field_ids_off
    method_ids_size = len(d.methods)
    class_defs_off = method_ids_off + 8 * method_ids_size
    class_defs_size = 1
    data_off = class_defs_off + 32 * class_defs_size

    # data section order: string_data, type_lists, code items, class_data, map_list
    data = bytearray()

    def place(blob: bytes) -> int:
        nonlocal data
        _align4(data)
        off = data_off + len(data)
        data.extend(blob)
        return off

    string_data_file_off = place(bytes(string_data))
    type_list_file_off: dict[tuple[str, ...], int] = {}
    for params, blob in type_lists.items():
        type_list_file_off[params] = place(bytes(blob))
    init_off = place(init_item)
    oncreate_off = place(oncreate_item)

    class_data = bytearray()
    class_data.extend(uleb128(0))
    class_data.extend(uleb128(0))
    class_data.extend(uleb128(1))  # direct
    class_data.extend(uleb128(1))  # virtual
    class_data.extend(uleb128(d.method_idx(cls, p_void, "<init>")))
    class_data.extend(uleb128(0x10001))  # public constructor
    class_data.extend(uleb128(init_off))
    # virtual list restarts idx-diff from 0
    class_data.extend(uleb128(d.method_idx(cls, p_bundle, "onCreate")))
    class_data.extend(uleb128(0x1))  # public
    class_data.extend(uleb128(oncreate_off))
    class_data_off = place(bytes(class_data))

    # map list last
    map_entries = [
        (0x0000, 1, 0),  # header
        (0x0001, string_ids_size, string_ids_off),
        (0x0002, type_ids_size, type_ids_off),
        (0x0003, proto_ids_size, proto_ids_off),
        (0x0005, method_ids_size, method_ids_off),
        (0x0006, class_defs_size, class_defs_off),
        (0x2002, string_ids_size, string_data_file_off),
    ]
    if type_lists:
        first_tl = min(type_list_file_off.values())
        map_entries.append((0x1001, len(type_lists), first_tl))
    map_entries.append((0x2001, 2, init_off))
    map_entries.append((0x2000, 1, class_data_off))
    # map_list itself
    map_off_placeholder = data_off + len(data)
    map_blob = bytearray()
    # +1 for the map_list type itself
    map_blob.extend(_u32(len(map_entries) + 1))
    for typ, size, off in map_entries:
        map_blob.extend(_u16(typ))
        map_blob.extend(_u16(0))
        map_blob.extend(_u32(size))
        map_blob.extend(_u32(off))
    map_blob.extend(_u16(0x1000))
    map_blob.extend(_u16(0))
    map_blob.extend(_u32(1))
    map_blob.extend(_u32(map_off_placeholder))
    map_off = place(bytes(map_blob))
    # fix last entry offset if alignment moved it
    if map_off != map_off_placeholder:
        # rewrite map list with corrected self offset
        data[map_off - data_off :] = b""
        map_blob = bytearray()
        map_blob.extend(_u32(len(map_entries) + 1))
        for typ, size, off in map_entries:
            map_blob.extend(_u16(typ))
            map_blob.extend(_u16(0))
            map_blob.extend(_u32(size))
            map_blob.extend(_u32(off))
        map_blob.extend(_u16(0x1000))
        map_blob.extend(_u16(0))
        map_blob.extend(_u32(1))
        map_blob.extend(_u32(map_off))
        map_off = place(bytes(map_blob))

    _align4(data)
    data_size = len(data)
    file_size = data_off + data_size

    # ids
    string_ids = b"".join(_u32(string_data_file_off + off) for off in string_data_offs)
    type_ids = b"".join(_u32(d.s(t)) for t in d.types)
    proto_ids = bytearray()
    for shorty, ret, params in d.protos:
        proto_ids.extend(_u32(d.s(shorty)))
        proto_ids.extend(_u32(d.type_idx(ret)))
        proto_ids.extend(_u32(type_list_file_off.get(params, 0)))
    method_ids = bytearray()
    for owner, proto, name in d.methods:
        method_ids.extend(_u16(d.type_idx(owner)))
        method_ids.extend(_u16(d.proto_idx(proto)))
        method_ids.extend(_u32(d.s(name)))
    class_defs = bytearray()
    class_defs.extend(_u32(d.type_idx(cls)))
    class_defs.extend(_u32(0x1))  # public
    class_defs.extend(_u32(d.type_idx("Landroid/app/Activity;")))
    class_defs.extend(_u32(0))  # interfaces
    class_defs.extend(_u32(d.s("MainActivity.java")))
    class_defs.extend(_u32(0))  # annotations
    class_defs.extend(_u32(class_data_off))
    class_defs.extend(_u32(0))  # static values

    header = bytearray(0x70)
    header[0:8] = b"dex\n035\x00"
    struct.pack_into("<I", header, 32, file_size)
    struct.pack_into("<I", header, 36, 0x70)
    struct.pack_into("<I", header, 40, 0x12345678)
    struct.pack_into("<I", header, 48, 0)
    struct.pack_into("<I", header, 52, map_off)
    struct.pack_into("<I", header, 56, string_ids_size)
    struct.pack_into("<I", header, 60, string_ids_off)
    struct.pack_into("<I", header, 64, type_ids_size)
    struct.pack_into("<I", header, 68, type_ids_off)
    struct.pack_into("<I", header, 72, proto_ids_size)
    struct.pack_into("<I", header, 76, proto_ids_off)
    struct.pack_into("<I", header, 80, field_ids_size)
    struct.pack_into("<I", header, 84, field_ids_off)
    struct.pack_into("<I", header, 88, method_ids_size)
    struct.pack_into("<I", header, 92, method_ids_off)
    struct.pack_into("<I", header, 96, class_defs_size)
    struct.pack_into("<I", header, 100, class_defs_off)
    struct.pack_into("<I", header, 104, data_size)
    struct.pack_into("<I", header, 108, data_off)

    body = bytes(header) + string_ids + type_ids + bytes(proto_ids) + bytes(method_ids) + bytes(class_defs) + bytes(data)
    assert len(body) == file_size

    sha = hashlib.sha1(body[32:]).digest()
    checksum = zlib.adler32(sha + body[32:]) & 0xFFFFFFFF
    out = bytearray(body)
    struct.pack_into("<I", out, 8, checksum)
    out[12:32] = sha
    return bytes(out)


# ---------------------------------------------------------------------------
# APK + JAR v1 signature
# ---------------------------------------------------------------------------


def wrap70(line: str) -> list[str]:
    if len(line) <= 70:
        return [line]
    lines = [line[:70]]
    rest = line[70:]
    while rest:
        lines.append(" " + rest[:69])
        rest = rest[69:]
    return lines


def sha256_b64(data: bytes) -> str:
    import base64

    return base64.b64encode(hashlib.sha256(data).digest()).decode("ascii")


def build_manifest_mf(entries: dict[str, bytes]) -> str:
    lines = ["Manifest-Version: 1.0", "Created-By: JahanFootball-1.0.0", ""]
    for name in sorted(entries):
        digest = sha256_b64(entries[name])
        lines.extend(wrap70(f"Name: {name}"))
        lines.extend(wrap70(f"SHA-256-Digest: {digest}"))
        lines.append("")
    return "\r\n".join(lines) + "\r\n"


def build_cert_sf(mf: str) -> str:
    mf_bytes = mf.encode("utf-8")
    lines = [
        "Signature-Version: 1.0",
        "Created-By: JahanFootball-1.0.0",
        f"SHA-256-Digest-Manifest: {sha256_b64(mf_bytes)}",
        "",
    ]
    # per-section digest
    parts = mf.split("\r\n\r\n")
    for part in parts:
        if part.startswith("Name: "):
            section = part + "\r\n\r\n"
            name_line = part.split("\r\n", 1)[0]
            lines.append(name_line)
            lines.extend(wrap70(f"SHA-256-Digest: {sha256_b64(section.encode('utf-8'))}"))
            lines.append("")
    return "\r\n".join(lines) + "\r\n"


def sign_sf(sf_bytes: bytes, work: Path) -> bytes:
    key = work / "key.pem"
    cert = work / "cert.pem"
    sf_path = work / "CERT.SF"
    rsa_path = work / "CERT.RSA"
    sf_path.write_bytes(sf_bytes)
    if not key.exists():
        subprocess.check_call(
            [
                "openssl",
                "req",
                "-x509",
                "-newkey",
                "rsa:2048",
                "-keyout",
                str(key),
                "-out",
                str(cert),
                "-days",
                "10000",
                "-nodes",
                "-subj",
                "/CN=Jahan Football/O=JahanFootball/C=IR",
            ],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    subprocess.check_call(
        [
            "openssl",
            "smime",
            "-sign",
            "-md",
            "sha256",
            "-binary",
            "-noattr",
            "-in",
            str(sf_path),
            "-outform",
            "der",
            "-out",
            str(rsa_path),
            "-signer",
            str(cert),
            "-inkey",
            str(key),
        ]
    )
    return rsa_path.read_bytes()


def write_apk(path: Path, files: dict[str, bytes]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(path, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        # STORED for native libs would go here; we have none.
        for name, data in files.items():
            info = zipfile.ZipInfo(name)
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o644 << 16
            zf.writestr(info, data)


def main() -> None:
    if not WWW.exists():
        raise SystemExit(f"missing {WWW}")
    html = WWW.read_bytes()
    manifest = build_manifest()
    dex = build_dex()
    arsc = build_resources_arsc()
    if not dex.startswith(b"dex\n035"):
        raise SystemExit("DEX magic invalid")

    payload = {
        "AndroidManifest.xml": manifest,
        "classes.dex": dex,
        "resources.arsc": arsc,
        "assets/index.html": html,
    }
    work = ROOT / "artifacts" / ".signwork"
    work.mkdir(parents=True, exist_ok=True)
    mf = build_manifest_mf(payload)
    sf = build_cert_sf(mf)
    rsa = sign_sf(sf.encode("utf-8"), work)
    files = {
        **payload,
        "META-INF/MANIFEST.MF": mf.encode("utf-8"),
        "META-INF/CERT.SF": sf.encode("utf-8"),
        "META-INF/CERT.RSA": rsa,
    }
    write_apk(OUT, files)
    ALT.write_bytes(OUT.read_bytes())
    print(f"APK written: {OUT} ({OUT.stat().st_size} bytes)")
    print(f"copy: {ALT}")
    print(f"DEX {len(dex)}  MANIFEST {len(manifest)}  HTML {len(html)}")


if __name__ == "__main__":
    main()
