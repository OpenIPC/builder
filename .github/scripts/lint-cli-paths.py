#!/usr/bin/env python3
"""Check the setting paths every shipped script hands to `cli`.

WHY THIS EXISTS. `cli -s` writes a value into /etc/majestic.yaml and cannot
fail: yaml-cli stores whatever dotted path it is given, creating the
intermediate mappings as it goes, and exits 0. Nothing downstream complains
either, because majestic simply never reads a key it does not recognise. A typo
in a setting path is therefore completely silent from the moment it is written
to the end of the device's life.

devices/t40_lite_movols-mo-805p/general/overlay/usr/share/openipc/customizer.sh
is what this file is made of. Six of its lines carry a trailing colon:

    cli -s .video0.bitrate: 4000
    cli -s .video0.rcMode: avbr

so the path is `.video0.bitrate:`, which is not `.video0.bitrate`. Those six
settings -- bitrate, rate-control mode, profile, GOP size, GOP mode and OSD
size -- have never applied on that camera, and no build, no review and no boot
ever said so. The device has shipped that way.

SCOPE is the shape of the path, deliberately, and nothing else. Whether
`.video0.bitrate` is a key this majestic build actually declares is a question
only the running binary can answer (`curl localhost/api/v1/config.json` lists
what a given build has), and it varies by vendor and by flavour. Shape is what
can be decided from the tree alone, it is free, and it is the whole of the
class that shipped.

A path built at runtime is skipped rather than guessed at --
devices/gk7205v200_otg_generic/.../uvc-gadget-setup reads `cli -g ".$1"` out of
a helper, which is fine and unknowable here.

Usage:
    lint-cli-paths.py               # check the tree
    lint-cli-paths.py --self-test   # check this checker still catches things
"""

import re
import sys
from pathlib import Path

# `cli`, `sensor_cli` and the `yaml-cli` binary underneath them all take the
# same grammar: a mode flag, then the dotted path. `wifibroadcast cli` is the
# same applet against /etc/wfb.yaml and is caught by the same rule.
INVOCATION = re.compile(
    r"\b(?:yaml-cli|sensor_cli|cli)\s+"
    r"(?:-[a-zA-Z]+\s+\S+\s+)*"          # any -i/-o pair that came first
    r"(-s|--set|-g|--get|-d|--del)\s+"
    r"(\"[^\"]*\"|'[^']*'|\S+)"
)

# A leading dot is convention rather than syntax (yaml-cli splits on "." and
# drops empty components), so it is optional here. What is not optional is that
# every component is a plausible YAML key.
WELL_FORMED = re.compile(r"^\.?[A-Za-z0-9_][A-Za-z0-9_.-]*$")

# Interpolation of any kind means the path is not decidable from the tree.
DYNAMIC = re.compile(r"[$`]")


def path_is_malformed(path):
    """True when this is a path yaml-cli will store and majestic never read."""
    if DYNAMIC.search(path):
        return False
    if not WELL_FORMED.match(path):
        return True
    # Empty components and a trailing separator address nothing. yaml-cli drops
    # them silently rather than refusing, which is what makes them worth
    # catching here.
    return ".." in path or path.endswith(".")


def findings_in(text):
    """(line number, offending path, source line) for each bad path in `text`."""
    out = []
    for lineno, line in enumerate(text.splitlines(), 1):
        if line.lstrip().startswith("#"):
            continue
        for match in INVOCATION.finditer(line):
            path = match.group(2).strip("\"'")
            if path_is_malformed(path):
                out.append((lineno, path, line.strip()))
    return out


def is_shell(p):
    """Shipped shell, by extension or by shebang. Markdown is not scanned: the
    documentation spells paths as `.<path>` on purpose."""
    if p.suffix == ".sh":
        return True
    try:
        with p.open("rb") as f:
            return f.read(2) == b"#!" and b"sh" in f.readline()
    except OSError:
        return False


def check_tree(root):
    scanned = 0
    bad = []
    for p in sorted(Path(root).rglob("*")):
        if not p.is_file() or ".git/" in str(p) or not is_shell(p):
            continue
        try:
            text = p.read_text(errors="ignore")
        except OSError:
            continue
        if not INVOCATION.search(text):
            continue
        scanned += 1
        for lineno, path, line in findings_in(text):
            bad.append((p, lineno, path, line))

    # A scan that finds nothing to check looks exactly like a clean run, which
    # is the failure mode every silent-typo bug in this file is made of.
    if scanned == 0:
        print("FAIL: no script in the tree invokes cli -- is the matcher broken?")
        return 1

    for p, lineno, path, line in bad:
        print(f"{p}:{lineno}: malformed setting path {path!r}")
        print(f"    {line}")
    if bad:
        print(f"\nFAIL: {len(bad)} malformed cli setting path(s) in {scanned} script(s)")
        print("A path yaml-cli stores but majestic never reads applies nothing,")
        print("and says nothing. Fix the path, or use a variable if it is dynamic.")
        return 1
    print(f"ok   cli setting paths well formed in {scanned} script(s)")
    return 0


def self_test():
    cases = [
        ("cli -s .video0.bitrate 4096", False, "plain set"),
        ("cli -s .video0.bitrate: 4000", True, "the movols trailing colon"),
        ("cli -s .osd.size: 0.8", True, "trailing colon, float value"),
        ("cli -g .video0.size", False, "get"),
        ("cli -d .outgoing.server", False, "delete"),
        ("cli -s .isp.sensorConfig /etc/sensors/imx335.ini", False, "path-like value"),
        ('cli -g ".$1"', False, "runtime path is not decidable"),
        ("cli -s .nightMode.irCutPin1 11", False, "digits in a component"),
        ("cli -s .outgoing.0 rtmp://a/b", False, "sequence index"),
        ("cli -s .video0..fps 20", True, "empty component"),
        ("cli -s .video0. 20", True, "trailing separator"),
        ("cli -s .video0.fps=20 x", True, "= is not a separator"),
        ("yaml-cli -i /etc/wfb.yaml -s .wireless.txpower 20", False, "explicit -i first"),
        ("# cli -s .video0.bitrate: 4000", False, "commented out"),
        ("sensor_cli -s .sensor.width 1920", False, "sensor_cli applet"),
    ]
    rc = 0
    for line, want_bad, name in cases:
        got_bad = bool(findings_in(line))
        if got_bad != want_bad:
            verb = "flag" if want_bad else "accept"
            print(f"FAIL self-test: expected to {verb} {name}: {line!r}")
            rc = 1
        else:
            print(f"ok   self-test: {name}")
    return rc


def main():
    if "--self-test" in sys.argv[1:]:
        return self_test()
    root = sys.argv[1] if len(sys.argv) > 1 else "."
    return check_tree(root)


if __name__ == "__main__":
    sys.exit(main())
