# CI checks

Every pull request and every push to `main` runs `.github/workflows/ci.yml`. Each job is a separate check on the PR, so a failure says which check failed.

| Check | What it does | Can fail? |
|---|---|---|
| **Build** | Builds `pokemon_yellow_legacy.gbc`, the debug ROM and the Virtual Console patch with RGBDS 1.0.4. | yes |
| **Warnings** | Fails on any build warning except the known title truncation (`.github/scripts/check_warnings.py`). | yes |
| **Tracked files** | Fails if the build modified any tracked file. | yes |
| **Smoke test** | Plays the opening in PyBoy: new game in Normal, Hard and Pick Starter (Charmander and Pikachu), starter, first rival battle, Oak's lab scenes; the debug ROM must reach its menu (`.github/scripts/smoke_test.py`). On failure, screenshots are uploaded as an artifact. | yes |
| **Scenario tests** | Warps to specific events and checks them: Melanie's Bulbasaur (Pick Starter, unhappy and happy Pikachu), the Safari Zone gate with no money (6th refusal, 4th refusal is free), Pikachu's Beach in Pick Starter and Normal mode (`.github/scripts/scenario_tests.py`). | yes |
| **Build base** | Builds the base commit (the PR's base, or the previous `main` commit) for the comparison checks. | no |
| **ROM changes** | Reports whether each ROM is identical to the base build. | only with the `expect-identical-rom` label |
| **Save layout** | Fails if a saved WRAM range or SRAM symbol moved, which would break old saves. | yes, unless the `save-layout-change` label is set |
| **Bank space** | Free space per ROM bank and how it changed. | no |
| **Lint workflows** | actionlint (plus shellcheck) on the workflow files. | yes |
| **Lint Python** | ruff on the CI and release scripts (rules in `.github/ruff.toml`). | yes |

The comparison checks are skipped, with a note, if there is no base commit or it doesn't build.

## Labels

- **`expect-identical-rom`**: for refactors and renames. The ROM changes check fails if either ROM differs from the base build.
- **`save-layout-change`**: when a PR is meant to change the save layout. The Save layout check then passes and says so.

Adding or removing a label reruns the checks.

## Running the checks locally

```sh
make yellow yellow_debug yellow_vc 2>&1 | tee build.log
python3 .github/scripts/check_warnings.py build.log
pip install -r .github/requirements.txt
python3 .github/scripts/smoke_test.py pokemon_yellow_legacy pokemon_yellow_legacy_debug
python3 .github/scripts/scenario_tests.py pokemon_yellow_legacy
# with a build of the base commit in base-out/:
python3 .github/scripts/compare_builds.py roms base-out .    # also: save, banks
ruff check --config .github/ruff.toml .github/scripts tools/make_release_patches.py
```

The ROMs are passed between jobs through the Actions cache, which only workflows can read; they are never uploaded as artifacts. Dependabot (`.github/dependabot.yml`) opens weekly PRs to update the actions and the Python packages in `.github/requirements.txt`.

## Upstream watch

`.github/workflows/upstream-watch.yml` runs every Monday (and on demand from the Actions tab, with an optional dry run). It compares this fork's `main` with [cRz-Shadows/Pokemon_Yellow_Legacy](https://github.com/cRz-Shadows/Pokemon_Yellow_Legacy) and keeps one **`upstream-sync`** issue listing the upstream commits the fork doesn't have (`.github/scripts/upstream_watch.py`).

- New upstream commits: the open issue is updated (with a comment), or a new one is opened.
- Closing the issue means "seen, not merging these"; it isn't reopened until upstream has new commits.
- Once the fork contains everything, the open issue is closed automatically.

