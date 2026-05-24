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
├── mods/
│   ├── CS2 Kernel Pro/
│   │   └── cs2_kernel_pro.exe
│   └── CS2 Kernel ESP/
│       └── cs2_kernel_esp.exe
├── auto_commit.bat               ← Manual release helper script
└── .github/workflows/
    └── release-on-main.yml       ← Automatic GitHub Release on push to main
```

---

## Release Process

### Step 0: Refresh local artifacts (MANDATORY before any release)

**Run `refresh_builds.bat` after every rebuild of `cs2/loader`, `cs2/kernel-pro`, or `cs2/kernel-esp`.** The exes in this folder are not the build outputs — they're copies. If you skip the refresh, the release will contain stale exes regardless of what you changed in source.

`refresh_builds.bat` copies:
- `cs2/loader/build/release/SpitewareLoader.exe` → `SpitewareLoader.exe`
- `cs2/loader/build/debug/SpitewareLoader.exe` → `SpitewareLoader_Debug.exe`
- `cs2/kernel-pro/build/Spiteware/cs2_kernel_pro.exe` → `cs2_kernel_pro.exe`
- `cs2/kernel-esp/build/Spiteware/cs2_kernel_esp.exe` → `cs2_kernel_esp.exe`

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
| `cs2_kernel_pro_url` | GitHub Release asset download URL |
| `cs2_kernel_esp_url` | GitHub Release asset download URL |

The Loader compares the version variable against its local copy and downloads a fresh binary from the release asset URL if an update is available.

---

## Related Projects

- `cs2/cs2_kernel_pro` — source for `cs2_kernel_pro.exe`
- `cs2/cs2_kernel_esp` — source for `cs2_kernel_esp.exe`
- `website/spiteware` — manages KeyAuth app variables pointing to these releases
