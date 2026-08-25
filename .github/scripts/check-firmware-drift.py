#!/usr/bin/env python3
"""Report where this repository has drifted from OpenIPC/firmware.

WHY THIS EXISTS. builder.sh copies devices/<item>/* over a fresh firmware clone
before building, so a device directory that ships its own copy of a firmware
file replaces it outright. A fleet-wide change in firmware therefore reaches
every device that only *references* a path, and none that ships its own copy --
silently, because nothing in either repository is looking.

That is not hypothetical. One forum comment on OpenIPC/firmware#2308 turned up
three separate instances of it in an afternoon:

  * 13 board kernel configs missed the CONFIG_VT/CONFIG_INPUT sweep that landed
    as firmware #2308 and #2309, so 21 device builds kept building the
    virtual-terminal layer (fixed in #126);
  * 97 defconfigs kept BR2_PACKAGE_JSONFILTER after firmware #2304 dropped it
    from every one of its own, which is what put three devices over their
    rootfs cap (fixed in #128);
  * the per-device excludes lists name files that no longer exist while missing
    files that do (reported at build time by firmware#2313).

THE TRIGGER IS THE WHOLE POINT. Every one of those was caused by a commit in
*firmware* while *builder* sat untouched. A pull_request check here would never
have fired -- nobody opens a builder PR when firmware changes. This has to run
on a schedule, and when it finds something the right response is an issue, not
a red nightly: drift someone else introduced is not a reason to break a build
that is otherwise fine.

WHAT IT CANNOT DO is fix anything. Auto-syncing firmware's version over a
builder copy would overwrite deliberate board-specific settings, which is the
one thing these copies exist for. It detects, a human decides, and the decision
is recorded by updating .github/firmware-drift.json. That file is the artifact:
a pinned blob means "someone looked at firmware's version of this and was
satisfied", and re-pinning it is the act of looking again.

CHECK 1, SHADOWED FILES. Content comparison is useless here -- a builder copy is
*supposed* to differ, that is why it exists. What matters is whether firmware's
version has moved since a human last reconciled the two, so each entry pins the
blob SHA it was reconciled against and this compares that to firmware HEAD. The
mapping is hand-authored because nothing can infer that gk7205v200.generic-fpv
derives from gk7205v200.generic.

CHECK 2, DEFCONFIG SYMBOLS. Nothing here is a copy of a firmware defconfig, so
pinning does not apply; the drift is a symbol firmware retired that builder kept
selecting. Every BR2_PACKAGE_*=y in a builder defconfig is resolved against all
three Kconfig sources and sorted into:

  * resolves nowhere -> a dead line, silently ignored by kconfig;
  * resolves, but no firmware defconfig selects it -> needs an allowlist entry.

Both halves matter and the second is the one that catches a JSONFILTER. The
allowlist is not bureaucracy: RUBYFPV, MSPOSD and the rtl88xx drivers are
legitimately builder-only, and writing that down is what makes a *new* entry
mean something. An entry may be a bare reason string, or an object with a
`devices` list of globs fencing it to the defconfigs that need it -- without
that, allowlisting JSONFILTER for devices/apfpv would also bless it creeping
back onto 95 unrelated defconfigs, which is the #128 bug verbatim.

RESOLVING AGAINST BUILDROOT IS NOT OPTIONAL, and getting this wrong is how the
check lies. Buildroot is not vendored in either repository, so a first pass that
consulted only OpenIPC packages reported HOSTAPD, IW, PHP, UHTTPD, LIBZIP and
BWM_NG as dead. All six are upstream Buildroot packages. Without --buildroot the
dead-symbol half is skipped and says so, rather than inventing findings.
"""

import argparse
import fnmatch
import json
import os
import re
import subprocess
import sys

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CONFIG = os.path.join(REPO_ROOT, ".github", "firmware-drift.json")

SELECT = re.compile(r"^(BR2_PACKAGE_[A-Z0-9_]+)=y\s*$", re.M)


def kconfig_symbols(*trees):
    """Every `config <SYM>` / `menuconfig <SYM>` declared under the given trees."""
    found = set()
    pattern = re.compile(r"^\s*(?:menu)?config\s+([A-Za-z0-9_]+)\s*$", re.M)
    for tree in trees:
        if not tree or not os.path.isdir(tree):
            continue
        for root, _dirs, files in os.walk(tree):
            for name in files:
                # Config.in is not the only name kconfig sources. buildroot's
                # php declares every extension in package/php/Config.ext, and
                # matching only "Config.in" reported BR2_PACKAGE_PHP_EXT_ZIP as
                # resolving nowhere -- a finding invented by the checker rather
                # than found in the tree. Config.ext, Config.in.host and
                # Config.in.options all exist upstream; take anything Config*.
                if not name.startswith("Config"):
                    continue
                path = os.path.join(root, name)
                try:
                    with open(path, encoding="utf-8", errors="replace") as handle:
                        found.update(pattern.findall(handle.read()))
                except OSError:
                    continue
    return found


def selected_in(directory, pattern="*_defconfig"):
    """symbol -> sorted list of defconfigs selecting it, under `directory`."""
    out = {}
    for root, _dirs, files in os.walk(directory):
        for name in files:
            if not fnmatch.fnmatch(name, pattern):
                continue
            path = os.path.join(root, name)
            try:
                with open(path, encoding="utf-8", errors="replace") as handle:
                    body = handle.read()
            except OSError:
                continue
            for sym in SELECT.findall(body):
                out.setdefault(sym, []).append(os.path.relpath(path, directory))
    return {k: sorted(v) for k, v in out.items()}


def blob_sha(firmware, path):
    """firmware HEAD's blob SHA for `path`, or None if it is not there."""
    try:
        return subprocess.run(
            ["git", "-C", firmware, "rev-parse", f"HEAD:{path}"],
            capture_output=True, text=True, check=True).stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None


def firmware_log(firmware, path, since):
    try:
        return subprocess.run(
            ["git", "-C", firmware, "log", "--oneline", f"{since}..HEAD", "--", path],
            capture_output=True, text=True, check=True).stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return ""


def load_config():
    with open(CONFIG, encoding="utf-8") as handle:
        return json.load(handle)


def check(firmware, buildroot, config, repo_root=REPO_ROOT):
    """Return (findings, notices). A finding is drift; a notice is FYI."""
    findings, notices = [], []
    devices = os.path.join(repo_root, "devices")

    # --- Check 1: shadowed files ---
    for entry in config.get("shadows", []):
        builder_path = os.path.join(repo_root, entry["builder"])
        if not os.path.exists(builder_path):
            findings.append(
                f"shadow entry names {entry['builder']}, which is not in this tree; "
                f"drop the entry or fix the path")
            continue
        if firmware is None:
            continue
        current = blob_sha(firmware, entry["firmware"])
        if current is None:
            findings.append(
                f"{entry['builder']} shadows {entry['firmware']}, which no longer "
                f"exists in firmware; re-point or drop the entry")
            continue
        if current != entry["blob"]:
            moved = firmware_log(firmware, entry["firmware"], entry["blob"])
            detail = f"\n      firmware commits since:\n        " + \
                     "\n        ".join(moved.splitlines()) if moved else ""
            findings.append(
                f"{entry['firmware']} moved in firmware since this copy was "
                f"reconciled ({entry.get('reconciled', 'unknown date')}).\n"
                f"      builder copy: {entry['builder']}\n"
                f"      pinned {entry['blob'][:12]}, firmware now {current[:12]}"
                f"{detail}")

    # --- Check 2: defconfig symbols ---
    builder_selects = selected_in(devices)
    firmware_selects = set()
    if firmware is not None:
        firmware_selects = set(selected_in(firmware).keys())

    known = config.get("builder_only_symbols", {})
    dead = config.get("known_dead_symbols", {})

    declared = None
    if buildroot:
        declared = kconfig_symbols(
            os.path.join(buildroot, "package"),
            os.path.join(firmware, "general", "package") if firmware else None,
            os.path.join(repo_root, "package"))
    else:
        notices.append(
            "no --buildroot given, so the dead-symbol half is skipped: upstream "
            "Buildroot packages cannot be told apart from symbols that resolve "
            "nowhere, and guessing produces false findings either way")

    for sym in sorted(builder_selects):
        users = builder_selects[sym]
        where = f"{users[0]}" + (f" (+{len(users) - 1} more)" if len(users) > 1 else "")

        if declared is not None and sym not in declared:
            if sym in dead:
                notices.append(f"{sym} still resolves to no Kconfig anywhere -- {dead[sym]}")
            else:
                findings.append(
                    f"{sym} resolves to no Kconfig in buildroot, firmware or here, "
                    f"so kconfig ignores the line.\n      first seen in {where}")
            continue

        # An allowlist entry may also fence the symbol to the devices that
        # actually need it. Without that, allowlisting is all-or-nothing: once
        # JSONFILTER was written down as builder-only for devices/apfpv, the
        # same symbol creeping back onto 95 unrelated defconfigs -- exactly the
        # #128 bug -- would have passed silently.
        entry = known.get(sym)
        if isinstance(entry, dict) and entry.get("devices"):
            allowed = entry["devices"]
            strays = [u for u in users
                      if not any(fnmatch.fnmatch(u, glob) for glob in allowed)]
            if strays:
                findings.append(
                    f"{sym} is allowlisted only for {', '.join(allowed)}, but "
                    f"{len(strays)} other defconfig(s) select it.\n"
                    f"      first stray: {strays[0]}\n"
                    f"      Either they need it too -- widen the devices list -- or "
                    f"this is the OpenIPC/firmware#2304 case again.")

        if firmware is None:
            continue
        if sym not in firmware_selects and sym not in known and sym not in dead:
            findings.append(
                f"{sym} is selected here but by no firmware defconfig.\n"
                f"      first seen in {where}\n"
                f"      Either firmware retired it (the OpenIPC/firmware#2304 case) or it "
                f"is deliberately builder-only -- say which in builder_only_symbols.")

    # Rot in the config file itself.
    for sym in sorted(set(known) | set(dead)):
        if sym not in builder_selects:
            findings.append(
                f"{sym} is listed in firmware-drift.json but no defconfig selects it; "
                f"drop the entry")

    return findings, notices


def self_test():
    """Exercise the classifier on synthetic trees; no network, no clones."""
    import tempfile
    import textwrap
    problems = []

    with tempfile.TemporaryDirectory() as tmp:
        repo = os.path.join(tmp, "builder")
        d = os.path.join(repo, "devices", "thing", "br-ext-chip-x", "configs")
        os.makedirs(d)
        os.makedirs(os.path.join(repo, "package"))
        with open(os.path.join(d, "thing_defconfig"), "w") as handle:
            handle.write("BR2_PACKAGE_KNOWN=y\nBR2_PACKAGE_RETIRED=y\n"
                         "BR2_PACKAGE_NOWHERE=y\nBR2_PACKAGE_SHARED=y\n")

        br = os.path.join(tmp, "buildroot", "package", "known")
        os.makedirs(br)
        with open(os.path.join(br, "Config.in"), "w") as handle:
            handle.write("config BR2_PACKAGE_KNOWN\n\tbool \"known\"\n")
        for sym in ("RETIRED", "SHARED"):
            sub = os.path.join(tmp, "buildroot", "package", sym.lower())
            os.makedirs(sub)
            with open(os.path.join(sub, "Config.in"), "w") as handle:
                handle.write(f"config BR2_PACKAGE_{sym}\n\tbool \"{sym}\"\n")

        fw = os.path.join(tmp, "firmware", "br-ext-chip-y", "configs")
        os.makedirs(fw)
        with open(os.path.join(fw, "board_defconfig"), "w") as handle:
            handle.write("BR2_PACKAGE_SHARED=y\n")

        cfg = {"shadows": [],
               "builder_only_symbols": {"BR2_PACKAGE_KNOWN": "builder-only on purpose"},
               "known_dead_symbols": {}}
        findings, notices = check(os.path.join(tmp, "firmware"),
                                  os.path.join(tmp, "buildroot"), cfg, repo_root=repo)
        blob = "\n".join(findings)

        def want(cond, what):
            if not cond:
                problems.append(what)

        want(any("BR2_PACKAGE_NOWHERE" in f and "no Kconfig" in f for f in findings),
             "a symbol declared nowhere must be reported as a dead line")
        want(any("BR2_PACKAGE_RETIRED" in f and "no firmware defconfig" in f for f in findings),
             "a symbol firmware no longer selects must be reported")
        want("BR2_PACKAGE_KNOWN" not in blob,
             "an allowlisted builder-only symbol must not be reported")
        want("BR2_PACKAGE_SHARED" not in blob,
             "a symbol firmware also selects must not be reported")

        # Without buildroot the dead-symbol half must go quiet rather than guess.
        findings2, notices2 = check(os.path.join(tmp, "firmware"), None, cfg, repo_root=repo)
        want(not any("no Kconfig" in f for f in findings2),
             "without --buildroot the dead-symbol half must be skipped, not guessed")
        want(any("--buildroot" in n for n in notices2),
             "skipping the dead-symbol half must be said out loud")

        # Rot: an allowlist entry nothing selects any more.
        cfg2 = dict(cfg, builder_only_symbols={"BR2_PACKAGE_KNOWN": "x",
                                               "BR2_PACKAGE_VANISHED": "y"})
        findings3, _ = check(os.path.join(tmp, "firmware"),
                             os.path.join(tmp, "buildroot"), cfg2, repo_root=repo)
        want(any("BR2_PACKAGE_VANISHED" in f and "drop the entry" in f for f in findings3),
             "an allowlist entry no defconfig selects must be reported as rot")

    # The shipped config must describe this tree, the same way ci-matrix.py's
    # NOT_BUILT must. An entry for a device that was renamed is a name
    # describing nothing.
    config = load_config()
    for entry in config.get("shadows", []):
        if not os.path.exists(os.path.join(REPO_ROOT, entry["builder"])):
            problems.append(f"shadows: {entry['builder']} is not in this tree")
        for key in ("firmware", "blob", "reconciled"):
            if not entry.get(key):
                problems.append(f"shadows: {entry['builder']} has no {key}")

    if problems:
        for problem in problems:
            print(f"  - {problem}")
        print(f"\ncheck-firmware-drift: self-test FAILED ({len(problems)} problem(s))")
        return 1
    counts = (len(config.get("shadows", [])),
              len(config.get("builder_only_symbols", {})),
              len(config.get("known_dead_symbols", {})))
    print("check-firmware-drift: self-test ok "
          f"({counts[0]} shadowed files, {counts[1]} builder-only symbols, "
          f"{counts[2]} known-dead symbols)")
    return 0


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--firmware", help="path to an OpenIPC/firmware checkout")
    parser.add_argument("--buildroot", help="path to an extracted buildroot tree")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()

    if args.self_test:
        return self_test()

    if not args.firmware:
        parser.error("--firmware is required (or use --self-test)")

    findings, notices = check(args.firmware, args.buildroot, load_config())

    for notice in notices:
        print(f"note: {notice}")
    if notices:
        print()

    if not findings:
        print("check-firmware-drift: no drift from firmware.")
        return 0

    print(f"check-firmware-drift: {len(findings)} finding(s)\n")
    for finding in findings:
        print(f"  - {finding}")
    print("\nEach of these is a decision, not a build failure. Reconcile the copy or\n"
          "the defconfig, then record the decision in .github/firmware-drift.json.")
    return 1


if __name__ == "__main__":
    sys.exit(main())
