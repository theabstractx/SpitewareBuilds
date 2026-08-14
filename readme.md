# SpitewareBuilds

This repository is a release artifact store — it contains compiled binaries, not source code. When a new build is ready, executables are committed here and a GitHub Release is created automatically. The Spiteware Loader downloads files from these releases at startup.

**Status:** Working

---

## Contents

```
SpitewareBuilds/
├── SpitewareLoader.exe           ← Loader binary (production)
├── SpitewareLoader_Debug.exe     ← Loader binary (debug build)
├── cs2_kernel_pro.exe            ← CS2 Kernel Pro cheat (flat copy)
├── cs2_kernel_esp.exe            ← CS2 Kernel ESP cheat (flat copy)
├── cs2_kernel_obsidian.exe       ← CS2 Kernel Obsidian (Thesis Build)
├── mods/
│   ├── cs2_kernel_pro.exe        ← Flat exe copy (same bytes as the top-level exe)
│   ├── cs2_kernel_esp.exe        ← Flat exe copy
│   ├── cs2_kernel_obsidian.exe   ← Flat exe copy
│   ├── CS2 Kernel Pro/
│   │   ├── cs2_kernel_pro.exe    ← Duplicate exe (shipped alongside the default config)
│   │   ├── default.cfg           ← Default per-mod config
│   │   └── Data/
│   │       ├── buttons.json      ← Default keybind snapshot
│   │       ├── client_dll.json   ← client.dll offset snapshot
│   │       ├── gamedata.json     ← Gamedata offset snapshot
│   │       └── offsets.json      ← Engine/global offset snapshot
│   ├── CS2 Kernel ESP/
│   │   ├── cs2_kernel_esp.exe
│   │   ├── default.cfg
│   │   └── Data/{buttons,client_dll,gamedata,offsets}.json
│   └── CS2 Kernel Obsidian/
│       ├── cs2_kernel_obsidian.exe
│       ├── default.cfg
│       └── Data/{buttons,client_dll,gamedata,offsets}.json
├── refresh_builds.bat            ← Copies exes from sibling build dirs into this repo
├── auto_commit.bat               ← Manual release helper script
└── .github/workflows/
    └── release-on-main.yml       ← Automatic GitHub Release on push to main
```

Every `mods/CS2 Kernel <Name>/` directory ships a full first-run bundle: the mod exe, a `default.cfg`, and a `Data/` folder holding the offset JSON snapshots the mod loads at startup (buttons / client_dll / gamedata / offsets). These are the defaults new users get; the loader-managed install replaces them with the latest values fetched from the offset server.

---

## Release Process

### Step 0: Refresh local artifacts (MANDATORY before any release)

**Run `refresh_builds.bat` after every rebuild of `cs2/loader`, `cs2/kernel-pro`, `cs2/kernel-esp`, or `cs2/kernel-obsidian`.** The exes in this folder are not the build outputs — they're copies. If you skip the refresh, the release will contain stale exes regardless of what you changed in source.

`refresh_builds.bat` copies:
- `cs2/loader/build/release/SpitewareLoader.exe` → `SpitewareLoader.exe`
- `cs2/loader/build/debug/SpitewareLoader.exe` → `SpitewareLoader_Debug.exe`
- `cs2/kernel-pro/build/Spiteware/cs2_kernel_pro.exe` → `cs2_kernel_pro.exe`
- `cs2/kernel-esp/build/Spiteware/cs2_kernel_esp.exe` → `cs2_kernel_esp.exe`
- `cs2/kernel-obsidian/build/Spiteware/cs2_kernel_obsidian.exe` → `cs2_kernel_obsidian.exe`

Each missing source is a hard failure — the script aborts and reports which file wasn't found. After a successful refresh, proceed to the automatic or manual release path below.

### Automatic (GitHub Actions)

Every push to `main` triggers `.github/workflows/release-on-main.yml`:

1. Checks out the repository
2. Finds all `.exe` files in the repo (excluding `dist/`)
3. Creates a GitHub Release tagged `build-<run_number>` (e.g. `build-42`) with all `.exe` files attached as release assets

The workflow requires no manual steps — committing new binaries and pushing to `main` is sufficient.

### Manual (auto_commit.bat)

For releasing from a local machine:

```bat
auto_commit.bat
```

This script:
1. Generates a timestamp (`YYYY-MM-DD_HH-MM-SS`)
2. Runs `git add .`, `git commit -m "Auto commit <timestamp>"`, and `git push`
3. The push to `main` triggers the GitHub Actions release workflow above

---

## Tag Naming Convention

| Format | Example | Source |
|--------|---------|--------|
| `build-<N>` | `build-42` | GitHub Actions run number (auto-increments) |

Tags are created by the GitHub Actions workflow via `softprops/action-gh-release@v2`. The run number is the version identifier.

---

## How the Loader Uses This Repository

The Spiteware Loader retrieves download URLs from KeyAuth app variables at startup. These variables are configured in the KeyAuth dashboard and point to specific GitHub Release asset URLs from this repository.

Example KeyAuth app variables:

| Variable | Value |
|----------|-------|
| `cs2_kernel_pro_version` | Version string (e.g. `"1.4"`) |
| `cs2_kernel_esp_version` | Version string |
| `cs2_kernel_obsidian_version` | Version string |
| `cs2_kernel_pro_url` | GitHub Release asset download URL |
| `cs2_kernel_esp_url` | GitHub Release asset download URL |
| `cs2_kernel_obsidian_url` | GitHub Release asset download URL |

The Loader compares the version variable against its local copy and downloads a fresh binary from the release asset URL if an update is available.

---

## Related Projects

- `cs2/kernel-pro` — source for `cs2_kernel_pro.exe`
- `cs2/kernel-esp` — source for `cs2_kernel_esp.exe`
- `cs2/kernel-obsidian` — source for `cs2_kernel_obsidian.exe`
- `cs2/loader` — source for `SpitewareLoader.exe` / `SpitewareLoader_Debug.exe`
- `platform/spiteware` — manages KeyAuth app variables pointing to these releases

---

## Known Issues

Documented defects in this repo's tooling. None affect the shipped binaries themselves — they only affect the release-plumbing scripts around them.

- **`auto_commit.bat:13` — DD.MM.YYYY locale breaks the commit timestamp.** The date-parsing branch mis-orders the components on European Windows locales (e.g. German `26.06.2026`), producing commit messages like `Auto commit 2026-26-06_00-17-27` — month and day swapped. Cosmetic only: it shows up in `git log`, but no release logic depends on the commit message text (the release tag comes from `github.run_number`, not this stamp).
- **`.github/workflows/release-on-main.yml:22` — `SpitewareLoader_Debug.exe` is published as a public release asset.** The `find . -name *.exe` glob scoops up every `.exe` in the repo, including the debug loader. If you don't want the debug loader downloadable from the GitHub Releases page, either delete it before pushing or narrow the `find` invocation.
- **`.github/workflows/release-on-main.yml:22` — flat vs. `mods/` copy ordering is undefined.** The same glob also picks up both the flat top-level exes and the `mods/CS2 Kernel <Name>/` duplicates, which share basenames. `cp` overwrites into `dist/` in whichever order `find` emits — safe today only because `refresh_builds.bat` keeps the two copies byte-identical. If the flat copy and the `mods/` copy ever drift, the release will ship whichever one landed in `dist/` last.
