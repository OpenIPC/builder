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

WHERE IT IS READ. Text was the only output, and the issue it filed listed 43
findings nobody could attribute: which device does a moved S40network hurt?
--json writes the same findings as records -- every shadowed file with its
status and the devices builder.sh copies it into, every symbol finding with
all of its defconfigs -- and --push sends that to openipc.org, whose firmware
explorer shows it per device next to the device's size and Kconfig against
its firmware base.

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


def discover_shadows(repo_root, firmware):
    """Every devices/<dir>/<path> whose <path> also exists in firmware.

    builder.sh copies devices/<item>/* over the firmware clone, so any file
    sitting at a path firmware also has replaces it. That makes same-path
    shadows discoverable rather than something to remember, which matters: the
    hand-written list in the first version of this file covered 13 board configs
    and missed 93 shadows across 35 firmware paths -- among them load_goke,
    load_hisilicon, load_sigmastar and four vendor .mk files, exactly the shared
    files a fleet-wide fix lands in. A shadow found here with no entry in
    firmware-drift.json is itself a finding, so the list cannot silently rot.

    Shadows whose name differs from the file they replace -- gk7205v200.generic-fpv
    for gk7205v200.generic -- cannot be discovered this way and stay hand-authored.
    """
    found = {}
    devices = os.path.join(repo_root, "devices")
    for root, _dirs, files in os.walk(devices):
        for name in files:
            path = os.path.join(root, name)
            rel = os.path.relpath(path, devices).split(os.sep)
            if len(rel) < 2:
                continue
            in_firmware = os.path.join(*rel[1:])
            if os.path.isfile(os.path.join(firmware, in_firmware)):
                found[os.path.relpath(path, repo_root)] = in_firmware
    return found


def blob_sha(firmware, path):
    """firmware HEAD's blob SHA for `path`, or None if it is not there."""
    try:
        return subprocess.run(
            ["git", "-C", firmware, "rev-parse", f"HEAD:{path}"],
            capture_output=True, text=True, check=True).stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None


COMMIT_CAP = 200


def _git(firmware, *args):
    try:
        return subprocess.run(["git", "-C", firmware, *args],
                              capture_output=True, text=True, check=True).stdout
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None


def resolve_pin(firmware, path, blob, commit=None, reconciled=None):
    """(pinned_commit, commits since it, pin_unknown, truncated) for a pin.

    A pin records a *blob*, and a blob is not a commit: `git log <blob>..HEAD`
    excludes nothing, so the first version of this listed the path's entire
    history under "commits since" -- #998 from 2023 next to last week's #2408.
    The commit a pin means is the newest one that left `path` with that blob;
    the commits since are the ones that touched `path` after it.

    `commit`, when an entry records one, is used as it stands. A blob that
    never appears in the path's history (a hand-edited pin) cannot be placed,
    so the commits since `reconciled` stand in, flagged `pin_unknown`.
    """
    fmt = "--format=%H%x00%cI%x00%an%x00%s"

    def parse(out):
        rows = []
        for line in (out or "").splitlines():
            parts = line.split("\x00")
            if len(parts) == 4:
                rows.append({"sha": parts[0], "date": parts[1], "author": parts[2], "subject": parts[3]})
        return rows

    # A recorded commit is used only if git agrees it left `path` with this
    # blob; a mistyped or unrelated one would otherwise print an empty list
    # that reads as "nothing changed".
    if commit and (_git(firmware, "rev-parse", f"{commit}:{path}") or "").strip() == blob:
        rows = parse(_git(firmware, "log", fmt, f"{commit}..HEAD", "--", path))
        return commit, rows[:COMMIT_CAP], False, len(rows) > COMMIT_CAP

    history = parse(_git(firmware, "log", fmt, "HEAD", "--", path))
    for i, row in enumerate(history):
        if (_git(firmware, "rev-parse", f"{row['sha']}:{path}") or "").strip() == blob:
            since = history[:i]
            return row["sha"], since[:COMMIT_CAP], False, len(since) > COMMIT_CAP
    rows = parse(_git(firmware, "log", fmt, f"--since={reconciled}", "HEAD", "--", path)) if reconciled else history
    return None, rows[:COMMIT_CAP], True, len(rows) > COMMIT_CAP


def device_name(defconfig_path):
    """A defconfig's device: its file name without _defconfig, as builder.sh's BOARD."""
    base = os.path.basename(defconfig_path)
    return base[:-len("_defconfig")] if base.endswith("_defconfig") else base


def devices_for(repo_root, builder_path):
    """The devices a file under devices/ reaches, the way builder.sh copies it.

    builder.sh finds a device's defconfig and copies that defconfig's whole
    devices/<dir>/ over the firmware tree, so a file reaches every device whose
    defconfig sits in the same <dir> -- one device for a device directory, 18
    for devices/common. A file under br-ext-chip-<vendor>/ only matters to the
    targets that use that vendor tree (its configs/); anything else, general/
    included, reaches every target in <dir>.
    """
    rel = os.path.relpath(os.path.join(repo_root, builder_path), os.path.join(repo_root, "devices")).split(os.sep)
    if len(rel) < 2:
        return []
    top = os.path.join(repo_root, "devices", rel[0])
    if rel[1].startswith("br-ext-chip-"):
        top = os.path.join(top, rel[1], "configs")
    defconfigs = []
    for root, _dirs, files in os.walk(top):
        defconfigs += [os.path.join(root, f) for f in files if f.endswith("_defconfig")]
    # A kernel config under board/ is used only by the defconfigs that name it
    # (BR2_LINUX_KERNEL_CUSTOM_CONFIG_FILE=.../gk7205v200.generic-fpv.config);
    # the gk7205v300 targets beside them in devices/common use their own.
    if len(rel) > 2 and rel[2] == "board" and rel[-1].endswith(".config"):
        naming = []
        for path in defconfigs:
            with open(path, encoding="utf-8", errors="replace") as handle:
                if re.search(r"[/\"]" + re.escape(rel[-1]) + r"\"", handle.read()):
                    naming.append(path)
        if naming:
            defconfigs = naming
    return sorted({device_name(p) for p in defconfigs})


def load_config():
    with open(CONFIG, encoding="utf-8") as handle:
        return json.load(handle)


def analyse(firmware, buildroot, config, repo_root=REPO_ROOT):
    """Everything the check knows, as records: one per shadowed file (the
    reconciled ones too -- that is what lets a device page say "12 shadows,
    all reconciled"), one per symbol finding with every device it reaches, and
    the notices. check() renders these as text; --json writes them as they are.
    """
    shadows, symbols, notices = [], [], []
    devices = os.path.join(repo_root, "devices")

    # --- Check 1: shadowed files ---
    entries = {e["builder"]: e for e in config.get("shadows", [])}
    if firmware is not None:
        for builder_path, firmware_path in sorted(discover_shadows(repo_root, firmware).items()):
            if builder_path not in entries:
                shadows.append({"builder": builder_path, "firmware": firmware_path, "status": "unpinned",
                                "current_blob": blob_sha(firmware, firmware_path),
                                "devices": devices_for(repo_root, builder_path)})

    for entry in config.get("shadows", []):
        record = {"builder": entry["builder"], "firmware": entry["firmware"],
                  "pinned_blob": entry.get("blob"), "reconciled": entry.get("reconciled"),
                  "note": entry.get("note"), "devices": devices_for(repo_root, entry["builder"])}
        if not os.path.exists(os.path.join(repo_root, entry["builder"])):
            shadows.append(dict(record, status="missing_builder"))
            continue
        if firmware is None:
            continue
        current = blob_sha(firmware, entry["firmware"])
        if current is None:
            shadows.append(dict(record, status="firmware_gone"))
            continue
        record["current_blob"] = current
        if current == entry["blob"]:
            shadows.append(dict(record, status="ok", pinned_commit=entry.get("commit")))
            continue
        pinned_commit, commits, unknown, truncated = resolve_pin(
            firmware, entry["firmware"], entry["blob"], entry.get("commit"), entry.get("reconciled"))
        shadows.append(dict(record, status="moved", pinned_commit=pinned_commit, pin_unknown=unknown,
                            commits=commits, truncated=truncated))

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
        names = sorted({device_name(u) for u in users})

        if declared is not None and sym not in declared:
            if sym in dead:
                symbols.append({"symbol": sym, "kind": "known_dead", "users": users, "devices": names,
                                "reason": dead[sym]})
            else:
                symbols.append({"symbol": sym, "kind": "dead", "users": users, "devices": names})
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
                symbols.append({"symbol": sym, "kind": "stray", "users": strays,
                                "devices": sorted({device_name(u) for u in strays}),
                                "allowed": allowed, "reason": entry.get("reason")})

        if firmware is None:
            continue
        if sym not in firmware_selects and sym not in known and sym not in dead:
            symbols.append({"symbol": sym, "kind": "firmware_retired", "users": users, "devices": names})

    # Rot in the config file itself.
    for sym in sorted(set(known) | set(dead)):
        if sym not in builder_selects:
            symbols.append({"symbol": sym, "kind": "stale_entry", "users": [], "devices": []})

    return {"shadows": shadows, "symbols": symbols, "notices": notices}


def render(report):
    """The records as the text findings this check has always printed."""
    findings = []
    for r in report["shadows"]:
        if r["status"] == "unpinned":
            findings.append(
                f"{r['builder']} sits at a path firmware also has "
                f"({r['firmware']}), so builder.sh replaces firmware's copy, but "
                f"nothing has reconciled the two.\n"
                f"      Add it to firmware-drift.json with the blob it was checked against.")
        elif r["status"] == "missing_builder":
            findings.append(
                f"shadow entry names {r['builder']}, which is not in this tree; "
                f"drop the entry or fix the path")
        elif r["status"] == "firmware_gone":
            findings.append(
                f"{r['builder']} shadows {r['firmware']}, which no longer "
                f"exists in firmware; re-point or drop the entry")
        elif r["status"] == "moved":
            lines = [f"{c['sha'][:8]} {c['subject']}" for c in r["commits"]]
            if r.get("truncated"):
                lines.append(f"... (first {COMMIT_CAP} shown)")
            since = "firmware commits since" + (" the reconciled date (pin not found in history)" if r.get("pin_unknown") else "")
            detail = f"\n      {since}:\n        " + "\n        ".join(lines) if lines else ""
            findings.append(
                f"{r['firmware']} moved in firmware since this copy was "
                f"reconciled ({r.get('reconciled') or 'unknown date'}).\n"
                f"      builder copy: {r['builder']}\n"
                f"      pinned {r['pinned_blob'][:12]}, firmware now {r['current_blob'][:12]}"
                f"{detail}")
    notices = list(report["notices"])
    for r in report["symbols"]:
        users = r["users"]
        where = f"{users[0]}" + (f" (+{len(users) - 1} more)" if len(users) > 1 else "") if users else ""
        if r["kind"] == "known_dead":
            notices.append(f"{r['symbol']} still resolves to no Kconfig anywhere -- {r['reason']}")
        elif r["kind"] == "dead":
            findings.append(
                f"{r['symbol']} resolves to no Kconfig in buildroot, firmware or here, "
                f"so kconfig ignores the line.\n      first seen in {where}")
        elif r["kind"] == "stray":
            findings.append(
                f"{r['symbol']} is allowlisted only for {', '.join(r['allowed'])}, but "
                f"{len(users)} other defconfig(s) select it.\n"
                f"      first stray: {users[0]}\n"
                f"      Either they need it too -- widen the devices list -- or "
                f"this is the OpenIPC/firmware#2304 case again.")
        elif r["kind"] == "firmware_retired":
            findings.append(
                f"{r['symbol']} is selected here but by no firmware defconfig.\n"
                f"      first seen in {where}\n"
                f"      Either firmware retired it (the OpenIPC/firmware#2304 case) or it "
                f"is deliberately builder-only -- say which in builder_only_symbols.")
        elif r["kind"] == "stale_entry":
            findings.append(
                f"{r['symbol']} is listed in firmware-drift.json but no defconfig selects it; "
                f"drop the entry")
    return findings, notices


def all_devices(repo_root=REPO_ROOT):
    """Every device a defconfig under devices/ builds, with the directory it lives in."""
    out = []
    for root, _dirs, files in os.walk(os.path.join(repo_root, "devices")):
        for name in files:
            if name.endswith("_defconfig"):
                rel = os.path.relpath(os.path.join(root, name), os.path.join(repo_root, "devices"))
                out.append({"device": device_name(name), "dir": rel.split(os.sep)[0]})
    return sorted(out, key=lambda d: d["device"])


def document(report, firmware, buildroot_version, repo_root=REPO_ROOT):
    """The report as openipc.org's drift push takes it (schema 1)."""
    import datetime
    run = os.environ.get("GITHUB_RUN_ID")
    return {
        "schema": 1,
        "checked_at": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "builder_commit": (_git(repo_root, "rev-parse", "HEAD") or "").strip(),
        "firmware_commit": (_git(firmware, "rev-parse", "HEAD") or "").strip() if firmware else "",
        "buildroot_version": buildroot_version or "",
        "run_url": (f"{os.environ.get('GITHUB_SERVER_URL', 'https://github.com')}/"
                    f"{os.environ.get('GITHUB_REPOSITORY', '')}/actions/runs/{run}") if run else "",
        "devices": all_devices(repo_root),
        **report,
    }


def push_report(report, base_url, opener=None, sleep=None):
    """POST the report to openipc.org's drift endpoint.

    Authenticated the way build pushes are: the job's GitHub Actions OIDC token,
    which the service accepts only from this workflow on master. Retries
    network errors and 5xx; a 4xx is final. The token and retry policy are
    push_build.py's, imported rather than copied.
    """
    import gzip
    import time
    import urllib.error
    import urllib.request
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    from push_build import ATTEMPTS, FIRST_DELAY, oidc_token
    opener = opener or urllib.request.urlopen
    sleep = sleep or time.sleep
    body = gzip.compress(json.dumps(report, separators=(",", ":")).encode())
    url = base_url.rstrip("/") + "/api/v1/drift"
    delay = FIRST_DELAY
    for attempt in range(1, ATTEMPTS + 1):
        try:
            req = urllib.request.Request(url, data=body, method="POST", headers={
                "Authorization": f"Bearer {oidc_token(opener=opener)}",
                "Content-Type": "application/json",
                "Content-Encoding": "gzip",
                "User-Agent": "OpenIPC drift push",
            })
            with opener(req, timeout=120) as resp:
                print(f"pushed drift report: HTTP {resp.status} {resp.read().decode(errors='replace')}")
                return 0
        except urllib.error.HTTPError as e:
            text = e.read().decode(errors="replace")
            if 400 <= e.code < 500:
                print(f"::error::openipc.org refused the drift report: HTTP {e.code} {text}")
                return 1
            reason = f"HTTP {e.code} {text}"
        except (urllib.error.URLError, TimeoutError, ConnectionError) as e:
            reason = str(e)
        if attempt == ATTEMPTS:
            print(f"::error::drift push failed after {ATTEMPTS} attempts: {reason}")
            return 1
        print(f"::warning::drift push attempt {attempt} failed ({reason}); retrying in {delay}s")
        sleep(delay)
        delay *= 2
    return 1


def check(firmware, buildroot, config, repo_root=REPO_ROOT):
    """Return (findings, notices). A finding is drift; a notice is FYI."""
    return render(analyse(firmware, buildroot, config, repo_root))


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

        # Discovery: a file sitting at a path firmware also has, with no entry,
        # is the omission that let 88 shadows go unlisted in the first version.
        shadowed = os.path.join(repo, "devices", "thing", "general", "overlay", "etc", "rc.local")
        os.makedirs(os.path.dirname(shadowed))
        with open(shadowed, "w") as handle:
            handle.write("# device copy\n")
        fwcopy = os.path.join(tmp, "firmware", "general", "overlay", "etc", "rc.local")
        os.makedirs(os.path.dirname(fwcopy))
        with open(fwcopy, "w") as handle:
            handle.write("# firmware copy\n")
        findings4, _ = check(os.path.join(tmp, "firmware"),
                             os.path.join(tmp, "buildroot"), cfg, repo_root=repo)
        want(any("rc.local" in f and "nothing has reconciled" in f for f in findings4),
             "a same-path shadow with no entry must be reported")

        cfg5 = dict(cfg, shadows=[{"builder": "devices/thing/general/overlay/etc/rc.local",
                                   "firmware": "general/overlay/etc/rc.local",
                                   "blob": "deadbeef", "reconciled": "2026-01-01"}])
        findings5, _ = check(os.path.join(tmp, "firmware"),
                             os.path.join(tmp, "buildroot"), cfg5, repo_root=repo)
        want(not any("nothing has reconciled" in f for f in findings5),
             "an entry must silence the discovery finding for that path")

        # Rot: an allowlist entry nothing selects any more.
        cfg2 = dict(cfg, builder_only_symbols={"BR2_PACKAGE_KNOWN": "x",
                                               "BR2_PACKAGE_VANISHED": "y"})
        findings3, _ = check(os.path.join(tmp, "firmware"),
                             os.path.join(tmp, "buildroot"), cfg2, repo_root=repo)
        want(any("BR2_PACKAGE_VANISHED" in f and "drop the entry" in f for f in findings3),
             "an allowlist entry no defconfig selects must be reported as rot")

    # A pin names a blob; the commits "since" it are the ones after the commit
    # that left the path with that blob -- not the path's whole history, which
    # is what `git log <blob>..HEAD` printed.
    with tempfile.TemporaryDirectory() as tmp:
        fw = os.path.join(tmp, "fw")
        os.makedirs(os.path.join(fw, "general"))
        run = lambda *a: subprocess.run(["git", "-C", fw, *a], capture_output=True, text=True, check=True).stdout.strip()
        run("init", "-q")
        run("config", "user.email", "t@t")
        run("config", "user.name", "t")
        blobs = []
        for n in (1, 2, 3):
            with open(os.path.join(fw, "general", "S40network"), "w") as handle:
                handle.write(f"version {n}\n")
            run("add", "-A")
            run("commit", "-q", "-m", f"change {n}")
            blobs.append(run("rev-parse", "HEAD:general/S40network"))
        pinned, since, unknown, _ = resolve_pin(fw, "general/S40network", blobs[1])
        want([c["subject"] for c in since] == ["change 3"] and not unknown,
             "a pin at commit 2's blob must list only commit 3 as since")
        want(pinned == run("rev-parse", "HEAD~1"), "a pin must resolve to the commit that left that blob")
        _, since, unknown, _ = resolve_pin(fw, "general/S40network", "0" * 40, reconciled="2000-01-01")
        want(unknown and len(since) == 3, "a blob the history never had must be flagged, not placed")
        pinned, since, _, _ = resolve_pin(fw, "general/S40network", blobs[1], commit=run("rev-parse", "HEAD~2"))
        want(pinned == run("rev-parse", "HEAD~1") and [c["subject"] for c in since] == ["change 3"],
             "a recorded commit that does not hold the pinned blob must be ignored, not trusted")
        pinned, since, _, _ = resolve_pin(fw, "general/S40network", blobs[1], commit="f" * 40)
        want(pinned == run("rev-parse", "HEAD~1") and len(since) == 1,
             "a recorded commit git does not know must be ignored, not trusted")

    # Attribution follows builder.sh: a vendor tree reaches its own configs/,
    # anything else in the directory reaches every device there.
    with tempfile.TemporaryDirectory() as tmp:
        for vendor, dev in (("br-ext-chip-goke", "gk_fpv"), ("br-ext-chip-goke", "gk_lte"), ("br-ext-chip-sigmastar", "ssc_fpv")):
            d = os.path.join(tmp, "devices", "common", vendor, "configs")
            os.makedirs(d, exist_ok=True)
            open(os.path.join(d, f"{dev}_defconfig"), "w").close()
        want(devices_for(tmp, "devices/common/br-ext-chip-goke/board/x.config") == ["gk_fpv", "gk_lte"],
             "a vendor-tree file must reach only that vendor's devices")
        want(devices_for(tmp, "devices/common/general/overlay/etc/x") == ["gk_fpv", "gk_lte", "ssc_fpv"],
             "a general/ file must reach every device in the directory")

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
    parser.add_argument("--json", metavar="PATH",
                        help="also write the report as JSON, the document openipc.org's drift push takes")
    parser.add_argument("--buildroot-version", help="recorded in the JSON; the workflow reads it from firmware's Makefile")
    parser.add_argument("--push", metavar="PATH",
                        help="push a report --json wrote to openipc.org instead of checking (needs the job's OIDC token)")
    parser.add_argument("--url", default="https://openipc.org", help="service --push sends to (default https://openipc.org)")
    args = parser.parse_args()

    if args.push:
        with open(args.push, encoding="utf-8") as handle:
            report = json.load(handle)
        attention = sum(1 for r in report.get("shadows", []) if r.get("status") != "ok")
        print(f"drift report: {len(report.get('devices', []))} device(s), {len(report.get('shadows', []))} "
              f"shadowed file(s) ({attention} needing attention), {len(report.get('symbols', []))} symbol record(s)")
        return push_report(report, args.url)

    if args.self_test:
        return self_test()

    if not args.firmware:
        parser.error("--firmware is required (or use --self-test)")

    report = analyse(args.firmware, args.buildroot, load_config())
    findings, notices = render(report)
    if args.json:
        with open(args.json, "w", encoding="utf-8") as handle:
            json.dump(document(report, args.firmware, args.buildroot_version), handle, indent=1)

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
