#!/usr/bin/env python3
"""Pick the build matrix for a CI run from the set of files a PR touches.

Until now this repo had no pull_request CI at all: a change landed unbuilt and
the nightly found out about it the next morning, or a user did. Building all 107
devices on every PR to fix that would cost ~50 runner-hours a go, which is why
it was never turned on. Almost every change here is one device -- 639 of the
file touches in the last 200 commits sit under a single devices/<dir>/ -- so
narrowing first is what makes PR CI affordable at all.

The rule is deliberately one-directional: a path has to be *recognised* as
belonging to particular devices before it can narrow anything. The shared
packages, builder.sh, and anything this script has never heard of all widen back
out to the full matrix. Getting the classification wrong therefore costs runner
time, never coverage.

The device -> files mapping is not written down here, it is read off the tree
the same way builder.sh reads it. builder.sh line 121 does

    ITEM=$(find devices -name ${DEVICE}_defconfig | cut -d/ -f1,2)
    cp -afv ${BUILDER_DIR}/${ITEM}/* ${FIRMWARE_DIR}

-- it locates the device by its defconfig and copies that WHOLE devices/<dir>/
tree over the firmware clone. So the devices a file affects are exactly the
devices whose defconfig lives in the same directory. That matters: devices/common/
holds 18 targets and devices/apfpv/ holds 2, and treating either as one device
would skip 17 real builds.

THE NIGHTLY IS NOT NARROWED, and must not be. builder.sh re-clones
OpenIPC/firmware at HEAD on every run, so what a nightly builds is mostly
decided outside this repo. master.yml already carries the scar: an earlier gate
skipped the nightly when this repo's HEAD matched the last published one, and
upstream firmware fixes stayed invisible to users until something here happened
to change. Every event except pull_request gets the whole matrix.

Usage:
    ci-matrix.py               # read GitHub Actions env; append to $GITHUB_OUTPUT
                               # when it is set, otherwise print the same lines
    ci-matrix.py --stdin       # read a file list on stdin, print the decision
    ci-matrix.py --self-test   # check this file still agrees with the tree
"""

import argparse
import glob
import json
import os
import re
import sys
import urllib.error
import urllib.request

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# The build matrix is every device in the tree, minus the opt-outs below. It is
# derived rather than listed because adding a camera IS the work here -- 8 of
# the 10 PRs open when this landed add a device, and 14% of recent commits do.
# A written-down list would mean every one of them also edits this file, and a
# change to this file cannot narrow (it is what does the narrowing), so
# registering a camera would cost a full 107-device build to prove one.
#
# This is the opposite call to OpenIPC/firmware's ci-matrix.py, deliberately.
# There the matrix is curated -- 29 defconfigs are intentionally never built and
# boards are not the product -- so the list is explicit and NOT_BUILT would be
# noise. Here devices are the product and the list is just "all of them".

# Devices that exist in the tree but are deliberately not built: the opt-out
# from the rule above. Every entry must still have a defconfig, so a rename
# leaves a name describing nothing and --self-test says so. Changes to these
# narrow to nothing, exactly as they do today.
NOT_BUILT = {
    "gk7102ca_lite_umea-qc01x", "gk7102ca_lite_vstarcam-g8896wip",
    "gk7205v200_rubyfpv_generic", "hi3518ev200_lite_lenovo-snowman-1080p",
    "hi3518ev200_ultimate_tplink-kasa-kc110", "t31_lite_tp-link-tapo-tc70-v3",
    "t31_lite_xiaomi-mjsxj05hl",
}

# Workflows and scripts that cannot change what a build produces. Matched on the
# whole filename, never as a prefix: one this list has never heard of is unknown,
# and unknown widens. package.sh and repack.sh are developer and end-user tools
# that no workflow invokes -- only builder.sh is on the CI path.
NO_BUILD_WORKFLOWS = {"build-one.yml", "cleanup.yml", "manifest.yml"}
NO_BUILD_SCRIPTS = {"enrich_manifest.py"}
NO_BUILD_FILES = {
    ".github/CODEOWNERS", ".gitignore", "LICENSE", "package.sh", "repack.sh",
}

# CI plumbing: decides how the build runs, cannot change a byte of what it
# produces. Gets SMOKE_TARGETS. ci-matrix.py is deliberately absent: it is what
# decides the matrix, so it cannot be trusted to decide a smaller one for
# itself. Adding a device does not touch it -- that is the point of deriving
# the list -- so this costs a full matrix only when the rules themselves move.
SMOKE_WORKFLOWS = {"master.yml"}

# One target per way a build can differ: every SoC vendor, every architecture,
# every toolchain tuple, every variant, and both of the shared device
# directories. --self-test enforces that cover rather than the list, so these can
# be re-picked freely while it holds.
SMOKE_TARGETS = [
    "gk7205v200_lite_tiandy-tc-c321n",   # Goke lite
    "hi3518ev200_lite_switcam-hs303",    # HiSilicon lite
    "hi3516ev300_ultimate_rvi-1ncmw2028",  # HiSilicon ultimate
    "ssc325_lite_imou-c22cp",            # SigmaStar lite, the musleabihf toolchain
    "ssc338q_fpv_caddx-fly",             # SigmaStar fpv
    "t31_lite_wyze-v3b",                 # Ingenic, the only mips
    "t20_ultimate_azarton-c1",           # Ingenic ultimate
    "hi3536dv100_fpv",                   # the only gnueabi toolchain in the tree
    "gk7205v200_fpv",                    # devices/common, and the fpv flavour
    "hi3516cv300_mini",                  # devices/common, mini
    "gk7205v200_lte",                    # devices/common, lte
    "gk7205v200_venc",                   # devices/common, venc
    "ssc30kq_rubyfpv_generic",           # devices/common, rubyfpv
    "gk7205v200_otg_generic",            # otg
    "ssc338q_apfpv",                     # devices/apfpv
]

# LICENSE and README anchored to whole filenames; unanchored they would also
# swallow LICENSES/vendor.txt and READMEgenerator.c and skip CI for real files.
DOCS = re.compile(r"^(?:docs/|archive/|(?:LICENSE|README)(?:\.[^/]*)?$)")
MARKDOWN = re.compile(r"^(?!devices/|package/).*\.md$")
WORKFLOW = re.compile(r"^\.github/workflows/([^/]+)$")
GITHUB_SCRIPT = re.compile(r"^\.github/scripts/([^/]+)$")
DEVICE_PATH = re.compile(r"^devices/([^/]+)/(.*)$")
DEVICE_DEFCONFIG = re.compile(r"^devices/[^/]+/.*/configs/(.+)_defconfig$")
PACKAGE_PATH = re.compile(r"^package/([^/]+)/")

FULL_LABEL = "ci:full"


class Tree:
    """Which devices a file reaches, read off the checkout.

    builder.sh copies a whole devices/<dir>/ tree over the firmware clone, so
    the unit is the directory, not the device name.
    """

    def __init__(self, root=REPO_ROOT):
        self.root = root
        self.directory_of = {}    # target -> devices/<dir>
        self.traits_of = {}
        for path in sorted(glob.glob(f"{root}/devices/*/**/configs/*_defconfig",
                                     recursive=True)):
            relative = path[len(root) + 1:]
            target = os.path.basename(path)[: -len("_defconfig")]
            self.directory_of[target] = "/".join(relative.split("/")[:2])
            self.traits_of[target] = self._traits(path)
        self.built = sorted(t for t in self.directory_of if t not in NOT_BUILT)
        self.smoke = [t for t in self.built if t in set(SMOKE_TARGETS)]

    def _traits(self, path):
        with open(path) as handle:
            body = handle.read()

        def string(option):
            found = re.search(rf'^{option}="([^"]*)"', body, re.M)
            return found.group(1) if found else "?"

        if re.search(r"^BR2_aarch64=y", body, re.M):
            architecture = "aarch64"
        elif re.search(r"^BR2_mips", body, re.M):
            architecture = "mips"
        else:
            architecture = "arm"
        return {
            "vendor:" + string("BR2_OPENIPC_SOC_VENDOR"),
            "arch:" + architecture,
            "toolchain:" + string("BR2_TOOLCHAIN_EXTERNAL_CUSTOM_PREFIX"),
            "variant:" + string("BR2_OPENIPC_VARIANT"),
        }

    def targets_in(self, directory):
        """Every built target whose defconfig lives in devices/<dir>/."""
        return [t for t in self.built if self.directory_of[t] == directory]


def classify(tree, changed, labels=(), event="pull_request", draft=False):
    """Map a list of changed paths to {rows, needs_build, reason}."""
    full = list(tree.built)

    # Everything except a PR builds everything. The nightly especially: what it
    # produces is decided by firmware HEAD, not by this repo's diff.
    if event != "pull_request":
        return _decision(full, True, reason=f"{event} builds everything")
    if FULL_LABEL in labels:
        return _decision(full, True, reason=f"{FULL_LABEL} label set")
    if draft:
        return _decision([], False, reason="draft pull request")
    if not changed:
        return _decision(full, True, reason="no file list available")

    targets, smoked = set(), False
    for path in changed:
        if DOCS.match(path) or MARKDOWN.match(path) or path in NO_BUILD_FILES:
            continue
        workflow = WORKFLOW.match(path)
        if workflow:
            if workflow.group(1) in NO_BUILD_WORKFLOWS:
                continue
            if workflow.group(1) in SMOKE_WORKFLOWS:
                targets.update(tree.smoke)
                smoked = True
                continue
            return _decision(full, True, reason=f"{path} affects every device")
        script = GITHUB_SCRIPT.match(path)
        if script:
            if script.group(1) in NO_BUILD_SCRIPTS:
                continue
            return _decision(full, True, reason=f"{path} affects every device")

        device = DEVICE_PATH.match(path)
        if device:
            # A defconfig names exactly one target. Anything else in the tree
            # -- overlay, excludes list, kernel config -- is copied wholesale by
            # builder.sh, so it reaches every target sharing the directory.
            defconfig = DEVICE_DEFCONFIG.match(path)
            if defconfig:
                if defconfig.group(1) in tree.built:
                    targets.add(defconfig.group(1))
                continue
            hits = tree.targets_in(f"devices/{device.group(1)}")
            if hits:
                targets.update(hits)
                continue
            return _decision(full, True,
                             reason=f"{path} is in no directory CI builds")

        if PACKAGE_PATH.match(path):
            # builder.sh copy_extra_packages() copies package/* into the
            # firmware tree and appends every one to its Config.in, for every
            # build. Nothing here is per-device.
            return _decision(full, True, reason=f"{path} is built into every device")

        # builder.sh itself, a new top-level file, or something this script has
        # never seen. Widen.
        return _decision(full, True, reason=f"{path} affects every device")

    if not targets:
        return _decision([], False, reason="nothing that reaches a build")
    if not smoked:
        return _decision(sorted(targets), True, reason="narrowed to the affected devices")
    if targets == set(tree.smoke):
        return _decision(sorted(targets), True,
                         reason="CI plumbing only: smoke set, not every device")
    return _decision(sorted(targets), True,
                     reason="affected devices plus the CI-plumbing smoke set")


def _decision(rows, needs_build, reason):
    return {
        # Actions rejects an empty include list outright, so an empty matrix is
        # expressed by skipping the whole job via needs_build instead.
        "matrix": {"include": [{"platform": t} for t in rows] or [{"platform": "none"}]},
        "needs_build": needs_build,
        "rows": rows,
        "reason": reason,
    }


def changed_files_from_api():
    """Ask the API which files the PR touches."""
    repo = os.environ.get("GITHUB_REPOSITORY")
    token = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")
    number = _event().get("pull_request", {}).get("number")
    if not (repo and token and number):
        return None

    files, page = [], 1
    while True:
        url = (f"https://api.github.com/repos/{repo}/pulls/{number}/files"
               f"?per_page=100&page={page}")
        request = urllib.request.Request(url, headers={
            "Authorization": f"Bearer {token}",
            "Accept": "application/vnd.github+json",
        })
        with urllib.request.urlopen(request, timeout=30) as response:
            batch = json.load(response)
        files += [entry["filename"] for entry in batch]
        # A rename drops the old path from the list; it may be the only thing
        # tying the change to a device, so count it too.
        files += [entry["previous_filename"] for entry in batch
                  if entry.get("previous_filename")]
        if len(batch) < 100:
            return files
        page += 1
        # The endpoint stops at 3000 files. A partial list can only narrow too
        # far, so say we do not know, which reads as "build everything".
        if page > 30:
            print("ci-matrix: PR exceeds the 3000-file listing limit", file=sys.stderr)
            return None


def _event():
    path = os.environ.get("GITHUB_EVENT_PATH")
    if not (path and os.path.exists(path)):
        return {}
    with open(path) as handle:
        return json.load(handle)


def self_test():
    """Fail loudly when this file drifts from the tree it describes."""
    tree = Tree()
    problems = []

    # 1. Every target must be locatable exactly the way builder.sh locates it,
    #    and must resolve to one directory.
    for target in tree.built:
        matches = glob.glob(f"{REPO_ROOT}/devices/*/**/configs/{target}_defconfig",
                            recursive=True)
        if len(matches) > 1:
            # builder.sh does `find ... | cut -d/ -f1,2` and copies the result
            # unquoted, so two matches make it copy two trees over each other.
            problems.append(
                f"{target} has {len(matches)} defconfigs; builder.sh would "
                f"resolve it to more than one directory")

    # 2. Every opt-out must still name something. A renamed device leaves its
    #    old name here describing nothing, and the new one silently builds.
    for target in sorted(NOT_BUILT):
        if target not in tree.directory_of:
            problems.append(
                f"{target} is in NOT_BUILT but has no defconfig; drop it, or "
                f"fix the name if the device was renamed")

    # 3. The smoke set has to be real, smaller, and cover every way a build can
    #    differ -- including both shared device directories, since a plumbing
    #    change that only breaks devices/common/ would otherwise go unproven.
    for target in SMOKE_TARGETS:
        if target not in tree.built:
            problems.append(f"{target} is in SMOKE_TARGETS but is not built")
    if len(tree.smoke) >= len(tree.built):
        problems.append("SMOKE_TARGETS is not smaller than the full matrix")
    covered = set().union(*(tree.traits_of[t] for t in tree.smoke)) if tree.smoke else set()
    for trait in sorted(set().union(*(tree.traits_of[t] for t in tree.built))):
        if trait not in covered:
            problems.append(
                f"no target in SMOKE_TARGETS has {trait}; a CI-plumbing change "
                f"would go unproven for it")
    shared = {tree.directory_of[t] for t in tree.built
              if len(tree.targets_in(tree.directory_of[t])) > 1}
    for directory in sorted(shared):
        if not any(tree.directory_of[t] == directory for t in tree.smoke):
            problems.append(
                f"no target in SMOKE_TARGETS lives in {directory}/, which backs "
                f"{len(tree.targets_in(directory))} devices")

    # 4. A name in both a no-build and a smoke list is dead config, and a
    #    classified file that no longer exists is a name describing nothing.
    for name in sorted(NO_BUILD_WORKFLOWS & SMOKE_WORKFLOWS):
        problems.append(
            f"{name} is both a no-build and a smoke workflow; the no-build list "
            f"wins and the smoke entry never fires")
    for names, directory in [(NO_BUILD_WORKFLOWS | SMOKE_WORKFLOWS, "workflows"),
                             (NO_BUILD_SCRIPTS, "scripts")]:
        for name in sorted(names):
            if not os.path.exists(os.path.join(REPO_ROOT, ".github", directory, name)):
                problems.append(
                    f".github/{directory}/{name} is classified but does not exist")
    for name in sorted(NO_BUILD_FILES):
        if not os.path.exists(os.path.join(REPO_ROOT, name)):
            problems.append(f"{name} is classified but does not exist")

    # 5. The narrowing must be sound.
    full = len(tree.built)
    smoke = len(tree.smoke)
    common = len(tree.targets_in("devices/common"))
    apfpv = len(tree.targets_in("devices/apfpv"))
    cases = [
        # One device.
        (["devices/t31_lite_wyze-v3b/general/overlay/usr/share/openipc/customizer.sh"],
         1, "a device overlay is that device"),
        (["devices/t31_lite_wyze-v3b/br-ext-chip-ingenic/configs/"
          "t31_lite_wyze-v3b_defconfig"], 1, "a device defconfig"),
        # Shared directories. This is the case a per-directory-is-a-device rule
        # would get wrong, and it is 18 builds wide.
        (["devices/common/general/overlay/etc/inittab"],
         common, "a file in devices/common reaches every target sharing it"),
        (["devices/apfpv/general/overlay/etc/udhcpd.conf"],
         apfpv, "same for devices/apfpv"),
        # ...but a defconfig inside a shared directory still names one target.
        (["devices/common/br-ext-chip-goke/configs/gk7205v200_fpv_defconfig"],
         1, "a defconfig in a shared directory is still one device"),
        # A defconfig CI does not build contributes nothing.
        (["devices/t31_lite_tp-link-tapo-tc70-v3/br-ext-chip-ingenic/configs/"
          "t31_lite_tp-link-tapo-tc70-v3_defconfig"], 0, "an unbuilt device"),
        # Everything shared or unknown widens.
        (["builder.sh"], full, "the build script"),
        (["package/kc110-board-support/Config.in"],
         full, "package/ is copied into every build"),
        (["package/demo-openipc/src/demo-openipc.c"], full, "same for its sources"),
        ([".github/scripts/ci-matrix.py"], full, "this file"),
        ([".github/workflows/some-new-thing.yml"], full, "an unknown workflow widens"),
        ([".github/scripts/some-new-thing.sh"], full, "an unknown script widens"),
        (["some-new-top-level-file"], full, "an unknown path widens"),
        (["devices/t31_lite_wyze-v3b/x", "builder.sh"],
         full, "one shared path widens the whole set"),
        # CI plumbing smoke-tests.
        ([".github/workflows/master.yml"], smoke, "the build workflow smoke-tests"),
        ([".github/workflows/master.yml", ".github/workflows/cleanup.yml"],
         smoke, "smoke plus something that never builds"),
        ([".github/workflows/master.yml", "builder.sh"],
         full, "smoke loses to anything that changes a build"),
        # Nothing that reaches a build.
        (["README.md"], 0, "readme"),
        (["NOTES.md"], 0, "notes"),
        (["CLAUDE.md"], 0, "agent instructions are markdown"),
        (["LICENSE"], 0, "licence"),
        ([".github/CODEOWNERS"], 0, "codeowners"),
        ([".github/workflows/manifest.yml"], 0, "manifest never builds"),
        ([".github/scripts/enrich_manifest.py"], 0, "manifest script"),
        (["repack.sh"], 0, "end-user tool, no workflow runs it"),
        (["package.sh"], 0, "developer tool, no workflow runs it"),
        (["archive/gk7205v200_fpv/202607231714/openipc.tgz"], 0, "build output"),
        # Anchoring: the same names elsewhere are not them.
        (["devices/t31_lite_wyze-v3b/README.md"],
         1, "markdown inside a device is that device"),
        (["package/demo-openipc/README.md"], full, "markdown inside a package widens"),
        (["READMEgenerator.c"], full, "README prefix is not a readme"),
        (["scripts/repack.sh"], full, "same name in a subdirectory is not the tool"),
    ]
    for paths, expected, what in cases:
        got = len(classify(tree, paths)["rows"])
        if got != expected:
            problems.append(f"{what}: expected {expected} rows, got {got}")

    # 6. Zero rows and "go build something" must never be emitted together.
    for paths, _, what in cases:
        decision = classify(tree, paths)
        if decision["needs_build"] and not decision["rows"]:
            problems.append(f"{what}: needs_build with an empty matrix")
        if decision["rows"] and not decision["needs_build"]:
            problems.append(f"{what}: rows with needs_build false")

    # 7. The nightly must never be narrowed, whatever the diff looks like.
    for event in ("schedule", "workflow_dispatch", "push"):
        decision = classify(tree, ["README.md"], event=event)
        if len(decision["rows"]) != full:
            problems.append(f"{event} must build every device, got {len(decision['rows'])}")
    if len(classify(tree, ["README.md"], labels=[FULL_LABEL])["rows"]) != full:
        problems.append(f"{FULL_LABEL} must build every device")
    if classify(tree, ["builder.sh"], draft=True)["needs_build"]:
        problems.append("a draft pull request must not build")

    # 8. No workflow may declare a top-level key twice. Legal YAML -- the last
    #    one wins -- but Actions refuses the file and the run produces no jobs.
    workflows = os.path.join(REPO_ROOT, ".github", "workflows")
    for name in sorted(os.listdir(workflows)):
        if not name.endswith((".yml", ".yaml")):
            continue
        seen = set()
        with open(os.path.join(workflows, name)) as handle:
            for line in handle:
                key = re.match(r"([A-Za-z_][\w-]*):", line)   # column 0 only
                if not key:
                    continue
                if key.group(1) in seen:
                    problems.append(
                        f".github/workflows/{name} declares '{key.group(1)}' more "
                        f"than once; Actions will refuse the file")
                seen.add(key.group(1))

    for problem in problems:
        print(f"ci-matrix: {problem}", file=sys.stderr)
    if problems:
        return 1
    print(f"ci-matrix: self-test ok ({len(tree.built)} devices, "
          f"{len(tree.smoke)} smoke, {len(cases)} cases)")
    return 0


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--stdin", action="store_true",
                        help="read changed paths from stdin instead of the API")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()

    if args.self_test:
        return self_test()

    tree = Tree()
    if args.stdin:
        changed = [line.strip() for line in sys.stdin if line.strip()]
        event, labels, draft = "pull_request", [], False
    else:
        event = os.environ.get("GITHUB_EVENT_NAME", "pull_request")
        pull_request = _event().get("pull_request", {})
        labels = [label["name"] for label in pull_request.get("labels", [])]
        draft = bool(pull_request.get("draft"))
        changed = None
        if event == "pull_request":
            try:
                changed = changed_files_from_api()
            except (urllib.error.URLError, OSError, ValueError) as exc:
                # Never fail the run over this; an empty list means full matrix.
                print(f"ci-matrix: cannot list PR files ({exc})", file=sys.stderr)

    decision = classify(tree, changed or [], labels, event, draft)

    print(f"ci-matrix: {len(decision['rows'])}/{len(tree.built)} devices "
          f"(needs_build={decision['needs_build']}) --- {decision['reason']}",
          file=sys.stderr)
    for target in decision["rows"]:
        print(f"  {target}", file=sys.stderr)

    lines = [
        f"matrix={json.dumps(decision['matrix'], separators=(',', ':'))}",
        f"needs-build={str(decision['needs_build']).lower()}",
        f"reason={decision['reason']}",
    ]
    # Write $GITHUB_OUTPUT here rather than having the workflow redirect stdout
    # into it. Under a redirect every print() in this file is one keystroke away
    # from corrupting the step outputs, and a crash between the first line and
    # the last leaves a half-written file that Actions still reads. Diagnostics
    # go to stderr precisely so that cannot happen -- which is a rule that has
    # to hold forever to stay safe, instead of a property of the code.
    # Falls back to stdout so a local run still shows what it decided.
    destination = None if args.stdin else os.environ.get("GITHUB_OUTPUT")
    if destination:
        with open(destination, "a") as handle:
            handle.write("\n".join(lines) + "\n")
    else:
        print("\n".join(lines))
    return 0


if __name__ == "__main__":
    sys.exit(main())
