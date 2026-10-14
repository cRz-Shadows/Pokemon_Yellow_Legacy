# CI checks

Every pull request and every push to `main` runs `.github/workflows/ci.yml`. Each job is a separate check on the PR, so a failure says which check failed.

| Check | What it does | Can fail? |
|---|---|---|
| **Build** | Builds `pokemon_yellow_legacy.gbc`, the debug ROM and the Virtual Console patch (and its `_vc` ROM) with RGBDS 1.0.4. | yes |
| **Warnings** | Fails on any build warning except the known title truncation (`.github/scripts/check_warnings.py`). | yes |
| **Tracked files** | Fails if the build modified any tracked file. | yes |
| **Smoke test** | Plays the opening in PyBoy: new game in Normal, Hard and Pick Starter (Charmander, Squirtle, Pikachu, the list wrap to Mew, paging), starter, the rival's comment on the pick and his Pokémon (Squirtle against Charmander, Bulbasaur against Squirtle), first rival battle, Oak's lab scenes; the weak-starter warning for Magikarp; the picker's SELECT pages (types, base stats, moves); the debug ROM must reach its menu (`.github/scripts/smoke_test.py`). | yes |
| **Scenario tests** | Warps to specific events and checks them: the rival's comment on a picked Eevee and Magikarp, the rival's ace in the Cerulean City battle (Wartortle against a Charmander pick, Eevee in Normal mode), Melanie's Bulbasaur (Pick Starter with Charmander; Normal with an unhappy and a happy Pikachu), the Safari Zone gate with no money (6th refusal, 4th refusal is free), Pikachu's Beach (the Surfin' Dude, posters and printer) in Pick Starter and Normal mode, saving (Pikachu's happiness lands at its own offset and the checksum is valid), and the beach on the VC ROM (`.github/scripts/scenario_tests.py`). | yes |
| **Build base** | Builds the base commit (the PR's base, or the previous `main` commit) for the comparison checks. | no |
| **ROM changes** | Reports whether the normal and debug ROMs are identical to the base build. | only with the `expect-identical-rom` label |
| **Save layout** | Fails if any saved WRAM or SRAM variable (compared by name) or saved range moved, which would break old saves. Renames are listed but allowed. | yes, unless the `save-layout-change` label is set |
| **Bank space** | Free ROM space (including empty banks), the tightest bank the PR changed, and a table of changed banks. | no |
| **Lint workflows** | actionlint (plus shellcheck) on the workflow files. | yes |
| **Lint Python** | ruff on the CI and release scripts (rules in `.github/ruff.toml`), and their unit tests (`.github/scripts/test_ci_scripts.py`, plus `test_data_tables.py`, which checks the type chart and the learnset order). | yes |

The comparison checks are skipped, with a note, if there is no base commit or it doesn't build. When the Smoke test or Scenario tests fail, screenshots are uploaded as the `smoke-test-failures` or `scenario-test-failures` artifact.

The emulator tests read every map, script, species and move ID they need from the `.sym` file: `constants/ci_exports.asm` (and the `EXPORT` lines in `scripts/OaksLab.asm`) export them, so the tests never parse assembly source. To use a new ID in a test, export it there.

## Labels

- **`expect-identical-rom`**: for refactors and renames. The ROM changes check fails if either ROM differs from the base build.
- **`save-layout-change`**: when a PR is meant to change the save layout. The Save layout check then passes and says so.

The comparison jobs read the PR's labels when they run. After adding or removing a label, use **Re-run jobs** on the PR (label changes don't start a run).

## Running the checks locally

```sh
pip install -r .github/requirements.txt
make test    # builds, then unit tests, smoke test, scenario tests and ruff
```

The comparison checks need a build of the base commit:

```sh
git worktree add ../base main
make -C ../base yellow yellow_debug
mkdir -p base-out && cp ../base/pokemon_yellow_legacy*.{gbc,sym,map} base-out/
python3 .github/scripts/compare_builds.py roms base-out .    # also: save, banks
git worktree remove ../base
```

To check for new warnings: `make yellow yellow_debug yellow_vc 2>&1 | tee build.log` then `python3 .github/scripts/check_warnings.py build.log`.

## Dependencies

- Actions are pinned by commit SHA (with the version in a comment), and checkouts don't keep the token (`persist-credentials: false`).
- The CI's Python packages are hash-locked in `.github/requirements.txt`, generated from `.github/requirements.in` with `pip-compile --generate-hashes --strip-extras .github/requirements.in`.
- Dependabot (`.github/dependabot.yml`) opens weekly PRs for both.

## Safeguards

- The ROMs are passed between jobs through the Actions cache instead of being uploaded as artifacts. A PR runs its own copy of the workflow, so a malicious PR could still try to publish a ROM. The real controls are:
  - Workflows from outside contributors' PRs only run after a maintainer approves them (repository setting: *Require approval for all external contributors*).
  - Review changes to `.github/`, `tools/` and the `Makefile` before approving a run or merging: a PR can change what the checks do.
- A PR could fill the Actions cache quota and evict another run's build. That can only make checks fail (`fail-on-cache-miss`), never pass falsely.

## Upstream watch

`.github/workflows/upstream-watch.yml` runs every Monday (and on demand from the Actions tab, with an optional dry run). It compares this fork's `main` with [cRz-Shadows/Pokemon_Yellow_Legacy](https://github.com/cRz-Shadows/Pokemon_Yellow_Legacy) and keeps one **`upstream-sync`** issue listing the upstream commits the fork doesn't have (`.github/scripts/upstream_watch.py`).

- It only runs in `technicks89/Pokemon_Yellow_Legacy`, and the `upstream-sync` label must exist there.
- New upstream commits: the open issue is updated (with a comment), or a new issue is opened if the last one was closed.
- Closing the issue means "seen, not merging these": no new issue is opened until upstream has new commits.
- Once the fork contains everything, the open issue is closed automatically.
- Upstream commit messages and authors are shown as code, so they can't add mentions, links or images.
- To bring an upstream commit in, translate it to this fork's label names first: `git format-patch -1 <sha> --stdout | tools/upstream_rename.py | git am -3` (the map is `docs/rename_map.tsv`).
