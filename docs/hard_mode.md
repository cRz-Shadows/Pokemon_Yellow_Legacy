# Hard mode

Hard mode is chosen once, in the new-game menu, and can't be changed afterwards. It is stored as bit 0 of the difficulty byte (`wDifficulty`); the code checks it with the `test_hard_rules` macro (`macros/code.asm`). Pick Starter mode (bit 1) is independent and has its own rules, see [pick_starter_mode.md](pick_starter_mode.md).

## What changes

| | Normal | Hard |
|---|---|---|
| Level cap | none | by badge count (table below) until you enter the Hall of Fame |
| Obedience | only traded Pokémon can disobey, by badge | your own Pokémon above the level cap may loaf, nap, hurt themselves or use a random move; traded ones keep the badge thresholds below |
| Items in battle | allowed | the bag is locked in **trainer** battles (*Items can't be used here*); wild battles still allow items and Poké Balls |
| Switching after a faint | "Switch Pokémon?" is offered when a trainer sends out the next one (Options: SHIFT) | never offered, as if Options were SET; you can still switch on your own turn |
| Options: battle style | SHIFT or SET | always SET (the menu shows SET and ignores the buttons) |
| Rare Candy | up to Lv100 | refused at the cap (*Can't go beyond the level cap for your BADGES.*) |
| Exp | up to Lv100 | stops at the cap; a Pokémon already above the cap gains nothing and keeps its level |
| Day-care | grows to Lv100 | stops growing at the cap |
| 1/256 misses and failed crits | fixed: 100% accurate moves never miss, and a maxed crit rate is a guaranteed crit | kept, as in the original game |
| Link battles | | use the Normal rules (crit and accuracy), so both consoles draw the same random numbers whatever mode each player is in |
| Hall of Fame screen | "YELLOW LEGACY" | "LEGACY HARD" |

Nothing else depends on the difficulty byte: trainer AI and parties are the same in both modes.

## Level caps

| Badges | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|---|
| Cap | 12 | 21 | 24 | 35 | 43 | 50 | 53 | 55 | 65 |

Beating the Elite Four (entering the Hall of Fame) lifts the cap to Lv100 and nothing disobeys any more. The table is `HardLevelCaps` in `engine/battle/experience.asm`; `GetHardLevelCap` is the one routine that returns the cap (experience, Rare Candy, the Day-care and obedience all call it).

Traded Pokémon (original trainer isn't you) keep the original badge thresholds for obedience in every mode, Hard included: Lv10 with 0 badges, Lv30 with the Cascade Badge, Lv50 with the Rainbow Badge, Lv70 with the Marsh Badge, and no limit with the Earth Badge. In Hard mode the level cap above only applies to the Pokémon you caught or were given yourself.

## For contributors

- Test for the mode with `test_hard_rules` (nz = Hard). For crit and accuracy rolls use `test_hard_battle_rules`, which reports "not Hard" in a link battle.
- Don't hard-code the caps: call `GetHardLevelCap` (it returns the cap in `e`, and `farcall` clobbers `a`, `b`, `c` and `hl`).
- If you add a rule that changes how many random numbers a battle draws, make it skip link battles the same way, or the two consoles will desync.
