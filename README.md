# OpenIPC builder build manifest

This branch is maintained automatically by
[.github/workflows/manifest.yml](https://github.com/OpenIPC/builder/blob/master/.github/workflows/manifest.yml).

Generated files (do not edit by hand):

- `manifest.json` — full build index (JSON; for hosts, agents, CI tools).
- `manifest.flat` — whitespace-delimited index parseable by busybox shell
  (for on-device `sysupgrade --channel`/`--build`/`--list-builds`).

URLs:

- <https://openipc.github.io/builder/manifest.json>
- <https://openipc.github.io/builder/manifest.flat>

The mirror of OpenIPC/firmware's manifest scheme. Same schema, separate
namespace because OpenIPC/builder publishes a different ecosystem of
firmware variants (fpv, rubyfpv, apfpv, lte, venc, mini, plus device-
specific lite/ultimate models).
