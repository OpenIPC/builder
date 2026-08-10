#!/usr/bin/env python3
"""Build manifest.json and manifest.flat for OpenIPC/builder's nightly index.

Mirrors OpenIPC/firmware's enrich_manifest.py but accounts for builder's
**bimodal** asset filenames produced by .github/workflows/master.yml:

  - **Compound** form (one underscore per matrix-entry awk count == multi):
    `<soc>_<variant>_<vendor>-<model>-nor.tgz` — encodes the full device
    identifier. Platform key = the full `<soc>_<variant>_<vendor>-<model>`
    string. This is the common case (per-device builds).

  - **Simple** form (single-underscore matrix entry like `ssc338q_fpv`):
    `openipc.<soc>-<flash>-<variant>.tgz` — firmware-style. Platform key
    = `<soc>_<variant>`.

The flat schema is unchanged: `build_id platform flash size url`, plus
`@channel <name> <build_id>` records.

md5 is intentionally absent (same reasoning as firmware — every .tgz
ships a .md5sum sidecar that sysupgrade validates after download).

Retry hardening (HTTP 401 / 5xx / network) is the same as firmware's
post-#2129 enrich_manifest, with fast-fail on permanent 404.
"""
from __future__ import annotations

import datetime as dt
import json
import os
import re
import subprocess
import sys
import time
from pathlib import Path

REPO = os.environ.get("GITHUB_REPOSITORY", "OpenIPC/builder")
RETENTION = 90
TAG_RE = re.compile(r"^nightly-(\d{8})-([0-9a-f]{7})$")

# Bimodal asset names — see module docstring.
COMPOUND_RE = re.compile(r"^(?P<platform>[a-z0-9]+_[a-z0-9]+_[a-z0-9_.-]+)-(?P<flash>nor|nand)\.tgz$")
SIMPLE_RE   = re.compile(r"^openipc\.(?P<soc>[^.]+)-(?P<flash>nor|nand)-(?P<variant>\w+)\.tgz$")

# Retry budget for transient GitHub API failures (mirrors firmware/#2129).
GH_RETRY_DELAYS = (0, 5, 15, 40)


def gh(*args: str) -> str:
    cmd = ["gh", *args, "--repo", REPO]
    last_exc = None
    for delay in GH_RETRY_DELAYS:
        if delay > 0:
            time.sleep(delay)
        try:
            return subprocess.check_output(cmd, text=True, stderr=subprocess.PIPE)
        except subprocess.CalledProcessError as e:
            last_exc = e
            err = e.stderr or ""
            if "release not found" in err.lower() or "not found (HTTP 404)" in err:
                break
            sys.stderr.write(
                f"gh {' '.join(args[:3])}: attempt failed "
                f"(rc={e.returncode}): {err.strip()[:240]}\n"
            )
    sys.stderr.write(
        f"gh {' '.join(args[:3])}: giving up; "
        f"final stderr:\n{last_exc.stderr}\n"
    )
    raise last_exc


def list_dated_releases() -> list[dict]:
    raw = gh("release", "list", "--limit", "200",
             "--json", "tagName,createdAt,isPrerelease")
    rels = json.loads(raw)
    dated = [r for r in rels if TAG_RE.match(r["tagName"])]
    dated.sort(key=lambda r: r["createdAt"], reverse=True)
    return dated[:RETENTION]


def fetch_release(tag: str) -> dict:
    raw = gh("release", "view", tag,
             "--json", "tagName,createdAt,body,assets")
    return json.loads(raw)


def parse_body(body: str | None) -> tuple[str, str, str]:
    sha = short = built_at = ""
    for line in (body or "").splitlines():
        if line.startswith("sha="):
            sha = line[4:].strip()
        elif line.startswith("short="):
            short = line[6:].strip()
        elif line.startswith("built_at="):
            built_at = line[9:].strip()
    return sha, short, built_at


def parse_asset(name: str) -> tuple[str, str] | None:
    """Returns (platform_key, flash) or None if filename doesn't match."""
    m = COMPOUND_RE.match(name)
    if m:
        return m.group("platform"), m.group("flash")
    m = SIMPLE_RE.match(name)
    if m:
        return f"{m.group('soc')}_{m.group('variant')}", m.group("flash")
    return None


def main() -> None:
    out_dir = Path(sys.argv[1] if len(sys.argv) > 1 else ".")
    out_dir.mkdir(parents=True, exist_ok=True)

    now = dt.datetime.now(dt.timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")
    dated = list_dated_releases()

    if not dated:
        manifest = {"schema": 1, "generated_at": now,
                    "channels": {}, "builds": []}
        (out_dir / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
        (out_dir / "manifest.flat").write_text(
            f"# generated_at={now}\n"
            "# No nightly-YYYYMMDD-<short> releases yet — "
            "the first scheduled build will populate this index.\n"
        )
        print("manifest: 0 builds (empty index)")
        return

    builds = []
    for rel in dated:
        info = fetch_release(rel["tagName"])
        sha, short, built_at = parse_body(info.get("body") or "")
        platforms: dict[str, dict[str, dict]] = {}
        for a in info.get("assets") or []:
            parsed = parse_asset(a["name"])
            if not parsed:
                continue
            platform, flash = parsed
            platforms.setdefault(platform, {})[flash] = {
                "url": a["url"],
                "size": a["size"],
            }
        builds.append({
            "id": info["tagName"],
            "sha": sha,
            "short": short,
            "built_at": built_at or info["createdAt"],
            "release_url": f"https://github.com/{REPO}/releases/tag/{info['tagName']}",
            "platforms": platforms,
        })

    newest = builds[0]["id"]
    manifest = {
        "schema": 1,
        "generated_at": now,
        "channels": {"nightly": newest, "latest": newest},
        "builds": builds,
    }
    (out_dir / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")

    lines = [
        "# OpenIPC builder build index",
        f"# generated_at={now}",
        "# columns: build_id platform flash size url",
    ]
    for b in builds:
        for platform, flashes in sorted(b["platforms"].items()):
            for flash, info in sorted(flashes.items()):
                lines.append(f"{b['id']} {platform} {flash} {info['size']} {info['url']}")
    lines.append("# channels")
    for ch, target in manifest["channels"].items():
        lines.append(f"@channel {ch} {target}")
    (out_dir / "manifest.flat").write_text("\n".join(lines) + "\n")

    print(f"manifest: {len(builds)} builds, newest={newest}")


if __name__ == "__main__":
    main()
