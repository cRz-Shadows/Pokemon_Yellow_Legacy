# Repository review findings (2026-10-14)

> **Historical.** This is a snapshot of `main` at `0491ed8`. Its findings have since been fixed or filed as GitHub issues, and its file and line references have moved. Current work is tracked in the GitHub issues, not here.

Six review agents examined the repository at `main` (`0491ed8`): architecture, documentation, efficiency, engineering, security and user experience. They focused on this fork's work on top of upstream: Pick Starter mode, bug fixes, label renames, CI, release tooling and docs. Each finding is tagged with its severity and the reviewer that raised it. Findings raised by more than one reviewer are merged.

Each agent verified its findings by reading the code, and some also ran builds, PyBoy or Python checks. Two notes from the maintainer session that compiled this report:

- **Finding 1 was reproduced independently** in PyBoy: reading a beach-house poster in Pick Starter mode prints "3 error" instead of the poster text, while Normal mode shows "30 years of waves…".
- **Two reviewer details were corrected after checking:**
  - `vc/pokemon_yellow_legacy.constants.asm` is still used: `includes.asm` includes it for `_YELLOW_VC` builds. Only the `%.constants.sym` Makefile rule is dead (finding 12).
  - The `actions/cache` restores already fail on a miss (`fail-on-cache-miss: true`), so architecture item 9 is resolved.

## Priorities

| # | Severity | Finding | Area |
|---|---|---|---|
| 1 | **High** | Beach-house posters print garbage in Pick Starter mode; the bug is in **released V1.1.0** | Engineering |
| 2 | **High** | The published patching instructions show `{BASE_SHA1}`/`{PATCHED_SHA1}` placeholders | Docs, UX |
| 3 | **Medium** | The save-layout CI check misses variables that shift inside a saved range | Engineering |
| 4 | **Medium** | `INSTALL.md` clones upstream, not this fork | Docs, UX |
| 5 | **Medium** | The "has a starter Pikachu" test is copied by hand, and the copies differ | Architecture |
| 6 | **Medium** | Pick Starter isn't explained in-game (controls, weak starters, no follower) or in the release zip | UX |
| 7 | **Medium** | Any label change reruns all 11 CI jobs | Efficiency |
| 8 | **Medium** | CI scripts regex-parse assembly source for IDs | Architecture |

Suggested order: fix 1 as a **1.1.1 hotfix** (along with 3, so the test that should catch this kind of problem works). Then do the doc fixes (2, 4 and the low documentation items), which are quick. Then the rest.

---

## Engineering

1. **High: `SummerBeachHouseCheckPickStarterSurfer` overwrites HL, so the posters print garbage.**
   - **Where:** `scripts/SummerBeachHouse.asm:94-101`, `:115-122`, `:136-143` (the three posters); the helper is at `:233-269`.
   - **Defect:** each poster does `ld hl, .PosterNText2`, then calls the helper, then `jr z, .next` → `PrintText`. When no party member knows Surf, the helper returns Z with HL pointing into party RAM.
   - **Failure:** Pick Starter, a non-Pikachu starter, no Surf user (the normal case). Reading any poster shows "3 error". The Surfin' Dude's first-time text has the same flaw, but it can only be reached in the Virtual Console build.
   - **Fix:** `push hl`/`push de`/`push bc` in the helper, with matching pops on both exits. Add poster reads (both modes) to `scenario_tests.py`.
2. **Medium: the save-layout check misses shifted variables.**
   - **Where:** `.github/scripts/compare_builds.py:51-65`, `:115-131`.
   - **Defect:** the check only requires that every base address still has *some* symbol on it. Insert a variable and shrink a later `ds` pad by the same amount, and every variable in between moves to its neighbour's address. No address goes empty and the range end doesn't move, so the check passes.
   - **Fix:** compare by name. Each saved symbol must keep its address. A missing name is acceptable only if a new name now sits at its old address (a rename).
3. **Low: the confirm prompt can show the previous Pokémon's picture.**
   - **Where:** `engine/menus/pick_starter.asm:47-49`.
   - **Defect:** pressing A within 24 frames of moving shows "So, you want CHARMANDER?" over the old sprite and palette.
   - **Fix:** in `.confirm`, call `PickStarter_DrawPic` first if `wPickStarterPicDelay` is non-zero.
4. **Low: test gaps.**
   - Picker paging, the wrap to #151 and the bottom page (MEW) are never tested.
   - The beach posters and printer are never read, which is how finding 1 got through.
   - The VC ROM is never tested.
   - **Fix:** add an "Up from the start → MEW" picker case, poster reads, and one VC beach scenario.

*Verified correct:* `CheckLinkBattleCupRules` flag handling; the Safari clamp (including a leftover step-count value); picker paging and push/pop balance; every `wDifficulty` reader uses `cp DIFFICULTY_HARD`; `NUM_TRAINERS + 1` equals the old 48; the BPS encoder/decoder (205 random round-trips); `pipefail` on every `tee` step.

## Documentation

1. **Medium: `INSTALL.md:144` clones `cRz-Shadows/Pokemon_Yellow_Legacy`,** the upstream repo, which has no Pick Starter mode or CI. Use this fork's URL, or explain the difference. *(UX raised this too.)*
2. **Medium: `docs/patching_instructions.md:20,27` shows raw `{BASE_SHA1}`/`{PATCHED_SHA1}` placeholders on GitHub,** and says "from this zip". `README.md:14` links players there. Write the base SHA-1 (`cc7d0326…5f4a38e1`) into the doc, and point to the release notes or zip for the patched SHA-1. *(UX: high.)*
3. **Medium: `docs/pick_starter_mode.md:99` says "Normal and Hard modes … are unchanged".** The cup-rules and Safari fixes do change Normal and Hard behaviour. Add a Fixes list, and say "rules and saves are unchanged".
4. **Medium: `docs/ci.md:11` is wrong about Melanie's cases.** The unhappy and happy Pikachu cases run in **Normal** mode, not Pick Starter.
5. **Low-medium: `docs/ci.md:44-48` (Upstream watch) is incomplete.**
   - Mention that the `upstream-sync` label must exist.
   - Mention that the job only runs in this repo.
   - "Isn't reopened" really means a **new** issue is opened instead.
6. **Low: stale or ambiguous comments.**
   - `scripts/CeruleanMelaniesHouse.asm:76`: "only if happiness >= 147" no longer covers the no-starter-Pikachu case.
   - `engine/battle/effects.asm:79`: the comment sits on the branch where cup rules do *not* apply.
   - `ram/wram.asm`: "never read" now also covers `wPickStarterPicDelay`, which is read.
7. **Low: `docs/bugs_and_glitches.md` has stale line anchors and an old address.**
   - `pikachu_follow.asm#1165` (missing the `L`, and outdated).
   - `core.asm#L4960` (now points at Super Fang; `HandleCounterMove` is at 4885).
   - "past d437" (the buffer is now at `$d485`).
   
   Use symbol names. All four listed bugs still exist.
8. **Low: small gaps in `docs/ci.md`.**
   - Scenario tests also upload screenshots.
   - "Each ROM" covers only the normal and debug ROMs, not VC.
9. **Low: `smoke_test.py` doesn't say it must run from the repo root.** `scenario_tests.py` does.
10. **Low: README has no release-tool command or contributor links.**
    - `README.md:15` gives no command for the release tool, and the script has no usage message.
    - The Pick Starter section sits under the external features list.
    - Nothing links `docs/ci.md`.

*Verified accurate:* the Pick Starter rules, controls and save notes; the weak-starter table (recomputed); the `ci.md` check table, labels and local commands; the patching steps; the comments in the picker, Safari, cup-rule and intro code.

## User experience

1. **High (player): the release zip doesn't include the Pick Starter guide.** It holds only the `.bps` and instructions, so players never see the mode notes or the weak-starter list. Add a short "Things to know" section to the zip. *(This is separate from the placeholder issue under Documentation.)*
2. **Medium (player): the picker never shows its controls** (`engine/menus/pick_starter.asm`, `text/OaksLab.asm:258-264`). Left/Right paging can't be discovered, and B does nothing. Add a controls line to Oak's lead-in, or an `A:PICK` hint in the empty preview row.
3. **Medium (player): no in-game warning for the 12 starters with no damaging move.** Add "It can't attack yet. Sure?" to the confirm prompt for those species. *(This is related to #47, stats/moves in the picker.)*
4. **Medium (player): the mode description doesn't say "Only PIKACHU will follow you"** (`data/text/text_3.asm:455-461`). That is the biggest change in the mode, and the description is the last chance to see it before committing.
5. **Medium (player): the rename step can lose saves** (`docs/patching_instructions.md:31-39`).
   - Renaming the ROM breaks the link to the existing `.sav`; tell players to rename it to match.
   - Explain how to see the patched ROM's SHA-1 (load the patched file back into ROM Patcher JS).
6. **Medium (contributor): no contributing guide.** Nothing links `docs/ci.md`, and the branch and PR flow, labels and `pip install -r .github/requirements.txt` aren't described anywhere. Add a README "Contributing" section.
7. **Low (contributor): `docs/ci.md` doesn't say how to make the base build in `base-out/`.**
8. **Low (contributor): the debug ROM skips the mode menu,** so Pick Starter can't be tested quickly there. Document it, or add a debug option.
9. **Low (player): the picker feels sluggish.** The sprite appears after a 24-frame idle delay plus the decompress, and input is lost during the decompress. Consider about 12 frames.
10. **Low (player): the beach wording draws attention to the Pikachu visuals.** "Your POKéMON knows how to SURF!" is followed by a Pikachu minigame. Name the actual Surf user (`text_ram`), or have the Dude joke about his Pikachu board.
11. **Low (player): Oak says "I keep every kind of POKéMON here!"** right after his "was going to give you one" line, and the Pikachu he caught is never mentioned again. Consider rewording.
12. **Low (player): "PICK STARTER" isn't a difficulty, but sits under "Select Difficulty".** Consider "Select a mode".

*Works well:* CI failure messages say what to do; in-game text respects the 18-character limit and the game's caps style; the main Pick Starter path can't get the player stuck.

## Architecture

1. **Medium: one byte holds two settings** (`constants/misc_constants.asm:23-27`). `wDifficulty` mixes the rule set (Normal/Hard) with how the starter is chosen. "Hard + Pick" can't be expressed without a fourth value and rewriting 9 `cp DIFFICULTY_HARD` checks. Treat it as flags (bit 0 = Hard, bit 1 = pick), which keeps the saved values 0, 1 and 2 compatible, and use one shared Hard check.
2. **Medium: the "has a starter Pikachu" test is copied by hand.**
   - `SummerBeachHouse.asm:240-245` checks the mode *and* `wPlayerStarter`.
   - `CeruleanMelaniesHouse.asm:22-24` and `OaksLab.asm` (×3) check only `wPlayerStarter`.
   
   They agree today only by convention. Add one `HasStarterPikachu` helper.
3. **Medium: CI scripts regex-parse assembly for IDs.**
   - `smoke_test.py:35-39` counts `dw_const` lines.
   - `scenario_tests.py:30-47,280-283` counts `const` order.
   
   A `const_skip` or reformatted line would silently give wrong IDs. Export the needed constants through an assembled file instead. *(Reviewer note: the Makefile's `%.constants.sym` rule it suggested reusing is dead; see finding 12.)*
4. **Medium: hard-coded and duplicated test inputs.**
   - `smoke_test.py:130-135` has hard-coded map IDs.
   - `wStatusFlags3 |= 1 << 3` is a magic bit.
   - Melanie's threshold of 147 appears in both the test and the script.
   - The charmap is re-implemented in Python.
   
   Fold these into the same export, and add a `MELANIE_HAPPINESS_THRESHOLD` constant.
5. **Medium: upstream merges are expensive.** The ~430 renames turn most upstream patches into conflicts, and the upstream watch only reports. Commit the old→new rename map so patches can be rewritten mechanically, and keep future mode hooks as small helper calls.
6. **Low: `wPickStarterPicDelay` overlays `wUnusedNamePointer` without a `UNION`** (`ram/wram.asm:1288-1291`). The latter is still written by `engine/battle/misc.asm:95` and `engine/link/cable_club.asm:259`, which is safe only because those never run during the picker. Use `UNION`/`NEXTU` with a comment.
7. **Low: the Safari clamp `4` is a bare number** (`scripts/SafariZoneGate_2.asm:188-190`). Derive it from the table length.
8. **Low: no `make test`.** The test scripts live in `.github/scripts` and the release tool in `tools/`. Add a `make test` target that CI also calls.

*Fits well:* the picker's own floating `SECTION` reached with `callfar`; one cup-rule helper with three callers; `compare_builds` reading only `.sym` addresses; the `cp DIFFICULTY_HARD` refactor.

## Efficiency

1. **Medium: any label reruns everything** (`.github/workflows/ci.yml:9,17`). Adding *any* label reruns all 11 jobs, and `cancel-in-progress` kills the current run. Skip the rerun unless the label is `save-layout-change` or `expect-identical-rom`.
2. **Low-medium: PyBoy renders every frame** (`smoke_test.py:65-67`). Nothing reads the screen except failure screenshots. Switching to `pb.tick(frames, False)` measured smoke 14.0 s → 6.2 s and scenario 8.2 s → 4.2 s, with all tests still passing. Render one frame before saving a failure screenshot.
3. **Low: the scenario tests replay the intros the smoke test already plays.** Merging the two jobs and reusing saved states would save a runner and 20-40 s, at the cost of one fewer PR check.
4. **Low: five sub-second checks each start a runner** (Warnings, Tracked files, ROM changes, Save layout, Bank space), costing about 1.5-2 runner-minutes per run. They could be steps in one job, at the cost of separate PR checks. These were split on purpose.
5. **Low: "Total free" ROM space is understated by about 1 MB** (`compare_builds.py:146-149`). Banks 65-127 are empty but not listed in the map. "Tightest bank" always reports an already-full bank. Add the unlisted banks to the total, and report the tightest *changed* bank.
6. **Low: dead Makefile rule.** `Makefile:119-121` (`%.constants.sym`, which also runs `scan_includes` on a literal `%` on every make) and the `vc/%.constants.sym` entry in `tidy` (`Makefile:70`) are leftovers from the old VC pipeline. Delete them. Keep `vc/pokemon_yellow_legacy.constants.asm`, which is used.

*ROM space:* the fork's code is cheap, and nothing it added runs often. Bank 1 dropped from 738 to 206 bytes free (the Pick Starter section, which floats and will move if needed); banks 40 and 42 have about 230 bytes free. With 63 empty banks, nothing is at risk.

## Security

No exploitable issue was found:
- Workflows use `pull_request` (not `_target`) with a read-only token and no secrets.
- No PR-controlled text reaches a shell.
- Downloads are checksum-verified.
- Caches are keyed per run and scoped per ref.
- No ROM is tracked or uploaded.

The real gaps are about governance, all low:

1. **Low: a PR could publish a ROM as an artifact.** A PR's own `ci.yml` runs, so a malicious PR could add an upload. `docs/ci.md:41` and the `ci.yml` header overstate this by calling the cache "readable only by workflows". Require approval for outside contributors' workflow runs, and reword the docs.
2. **Low: a PR can rewrite the required checks.** For example, `run: exit 0` in Save layout turns it green. Add `.github/CODEOWNERS` for `/.github/` and `/tools/` and require code-owner review, or use a ruleset with required workflows.
3. **Low: upstream commit text goes unescaped into issues** (`upstream_watch.py:80-84`).
   - Messages and author names could carry `@mentions`, links or images into the bot's issue.
   - A commit message containing the marker comment would be matched first.
   
   Put the text in code spans or escape it, and match only the marker on the last line.

Hardening suggestions:
- Pin actions by commit SHA; Dependabot can keep SHA pins updated.
- Lock transitive Python dependencies with hashes.
- Set `persist-credentials: false` on checkout, especially in `upstream-watch.yml`.
- Pass inputs to the composite action through `env:`.
- Cache-quota exhaustion by a PR could only make checks fail, never pass falsely.
