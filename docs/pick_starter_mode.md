# Pick Starter Mode

Pick Starter is a third play mode alongside **Normal** and **Hard**. It plays like Normal mode, except that Professor Oak lets you choose **any of the 151 Pokémon** as your starter.


## Starting a game

1. Choose **NEW GAME**.
2. At **Select game mode**, choose **PICK STARTER** and confirm. The description says that only a Pikachu starter follows you.
3. When Oak gives you your first Pokémon in his lab, he explains the controls and a list of all 151 Pokémon opens instead.
   - **Up / Down** move one entry. Holding them scrolls, and the list wraps around at both ends.
   - **Left / Right** move a page.
   - The highlighted Pokémon's number, name, types and front sprite are shown. The sprite appears once you stop scrolling (after about 12 frames).
   - **Select** switches the info next to the sprite between its **types**, its **base stats** (HP, Attack, Defense, Speed, Special) and the **moves it will know** at level 5. The choice stays while you scroll. The moves come from the same code that gives you the Pokémon, so they're exactly what you get.
   - **A** asks "So, you want …?". For a Pokémon with no damaging move at level 5, it adds "It can't attack yet. Are you sure?". **YES** takes it and **NO** returns to the list. You can't leave without choosing.
   - The debug build's quick start skips the mode menu, so test Pick Starter with a regular new game.


## Rules

- Everything except the starter follows **Normal** rules: Shift mode is allowed, items can be used in battle, and there are no gym level caps.
- The starter is a regular **level 5** of its species, with its usual Legacy stats and level-5 moves. It levels up and evolves normally.
- **If you pick Pikachu**, you get the usual starter Pikachu. It follows you, has happiness, and keeps every Pikachu scene, exactly as in Normal mode.
- **If you pick anything else:**
  - Nothing follows you.
  - The Pikachu-only scenes are skipped. They check for the starter Pikachu, as they do in Normal mode when Pikachu is in the PC.
  - In Oak's lab, your rival comments on your pick before your first battle: an Eevee like his ("Copycat!"), a legendary or Mew, a Pokémon that can't attack yet, or otherwise its (first) type.
  - **If you pick a Bulbasaur, Charmander or Squirtle-line Pokémon**, your rival counters it, as in Red/Blue. He swaps his Eevee for the starter that beats yours: Charmander against the Bulbasaur line, Squirtle against the Charmander line, Bulbasaur against the Squirtle line. He keeps that starter's line in every rival battle, evolving it by level. His other Pokémon come from his usual Legacy teams: the Jolteon team's with Bulbasaur, the Flareon team's with Charmander, the Vaporeon team's with Squirtle. His Champion rematch team is unchanged, and no Eeveelution stands in the Champion's room after the Hall of Fame.
  - In Oak's lab, the "Pikachu escapes its Poké Ball" scene is skipped. Oak then gives his usual battle advice instead of "talk to it and see how it feels".
  - **Melanie** (Cerulean City) gives you **Bulbasaur** without needing a happy Pikachu.
  - **Charmander** (Route 24) and **Squirtle** (Officer Jenny, Vermilion City) are available as usual, so all three classic starters can be obtained.
  - **Pikachu's Beach** (the surfing minigame in the Summer Beach House, Route 19) can be played with **any Pokémon in your party that knows Surf**, not just a Pikachu. The Surfin' Dude names it ("Your CHARMANDER knows how to SURF!") and admits his board is built for a Pikachu: the minigame itself still shows Pikachu. The beach-house posters and printer unlock too.


## Things to know

- **Starters that can't attack at first.** These species know no damaging move at level 5:

  | Pokémon | Level-5 moves |
  |---|---|
  | Abra | Teleport |
  | Kadabra, Alakazam | Teleport, Kinesis |
  | Magikarp | Splash |
  | Ditto | Transform |
  | Ekans, Arbok | Leer |
  | Cubone, Marowak | Growl, Leer |
  | Clefable | Sing, Metronome, Growl |
  | Mr. Mime | Barrier |
  | Snorlax | Amnesia |

  The game is still completable with them, but treat them as a challenge pick. You'll likely lose the first rival battle (the story continues anyway). You can run from wild battles until you can buy Poké Balls in Viridian City and catch a second Pokémon. Ditto copies its opponent's moves, so it can fight from the start.
- **Legendaries and Mew** can be picked too. They start at level 5 like everything else.
- At the start of the game, Oak still catches a wild Pikachu on Route 1. In the lab he mentions it before letting you pick; that Pikachu stays with him.


## Save compatibility

- The mode is stored in the existing difficulty byte: 0 = Normal, 1 = Hard, 2 = Pick Starter. The byte is a set of flags (bit 0 = Hard rules, bit 1 = pick the starter), so these values keep their meaning; the code checks it with the `test_hard_rules` and `test_pick_starter` macros. Normal and Hard saves from earlier versions load and play unchanged.
- The save layout is unchanged. No RAM or SRAM addresses moved.
- Don't load a Pick Starter save into a build from before this mode existed. Those builds treat any non-zero difficulty as Hard, so the game would play with Hard rules.


## Playtest checklist

New games:
- [ ] Normal: Pikachu is given as before, with classic rules
- [ ] Hard: Pikachu is given as before, with Set mode, no items in battle and gym level caps
- [ ] Pick Starter + Pikachu: identical to Normal (follower, escape scene, happiness)
- [ ] Pick Starter + a non-Pikachu starter (try one each of: a regular pick, a weak pick from the table, a legendary)

Story with a non-Pikachu starter:
- [ ] Picker: SELECT cycles types, base stats and level-5 moves; the prompt still names the right Pokémon
- [ ] Oak's lab: the rival comments on the pick (try an Eevee, a legendary, a weak pick and a regular pick)
- [ ] Bulbasaur/Charmander/Squirtle-line pick: the rival swaps for the counter starter, uses it in every rival battle (lab, Route 22, Cerulean, S.S. Anne, Pokémon Tower, Silph Co., Route 22, Champion) and evolves it
- [ ] Oak's lab: first rival battle, rival leaves, no Pikachu scene, Oak's advice line
- [ ] Viridian City parcel and Pokédex
- [ ] Viridian Forest and Brock
- [ ] Pewter Pokémon Center (no Pikachu wake-up scene)
- [ ] Mt. Moon (Jessie & James)
- [ ] Cerulean: Melanie gives Bulbasaur, Bill's house
- [ ] Route 24 Charmander
- [ ] S.S. Anne, Vermilion, Officer Jenny's Squirtle
- [ ] Pokémon Fan Club
- [ ] Celadon (Mansion, Game Corner / Rocket Hideout)
- [ ] Pokémon Tower
- [ ] Saffron (Silph Co.)
- [ ] Fuchsia, Safari Zone (with ¥0, refusing the gate guard 6+ times shows no garbage text)
- [ ] Summer Beach House (Route 19): a non-Pikachu Surf user can play Pikachu's Beach
- [ ] Cinnabar
- [ ] Elite Four, Champion, Hall of Fame (Oak names your starter correctly)
- [ ] Post-game

Regression in Normal and Hard:
- [ ] Every Pikachu scene above still plays with the starter Pikachu


## Release notes

**New: Pick Starter mode**

- New difficulty option, **PICK STARTER**: Normal rules, but you choose your starter from all 151 Pokémon in Oak's lab, using a scrollable list with front sprites.
- Picking a Pokémon other than Pikachu means no follower. Pikachu-only scenes are skipped or reworded, and Melanie's Bulbasaur no longer needs a happy Pikachu.
- Picking Pikachu gives the classic Yellow experience.
- Without a starter Pikachu, any party Pokémon that knows Surf can play Pikachu's Beach.
- Oak's lab now says "received **an** ABRA!" for names starting with a vowel.

**Fixes (all modes)**

- Link Colosseum cup rules (shorter sleep, lower freeze chance) no longer carry over into normal battles after a cup battle.
- The Safari Zone gate guard no longer prints garbage text and freezes the game after more than 5 refusals with no money.

**1.1.1**

- Fixed: in Pick Starter mode, the Summer Beach House posters printed garbage instead of their text.
- The picker shows the controls (in Oak's lead-in), warns before taking a Pokémon that can't attack at level 5, loads the sprite sooner, and shows the right sprite at the "So, you want …?" prompt.
- The Surfin' Dude names the Pokémon that knows Surf. The mode menu is titled "Select game mode", and the Pick Starter description says only a Pikachu starter follows you.

**1.2.0**

- Pick Starter picker: SELECT shows the highlighted Pokémon's base stats or its level-5 moves instead of its types.
- Pick Starter mode: your rival comments on your starter before your first battle.
- Pick Starter mode: pick a Bulbasaur, Charmander or Squirtle-line Pokémon and your rival takes the starter that beats it, as in Red/Blue, and keeps its line all game.
- Fixed (all modes): saving after a trade didn't store Pikachu's happiness and mood in the right place, and every save wrote them over 2 bytes of other saved data.

**Unreleased**

- **Catching:** the catch chance depends on the wild Pokémon's HP again (weaken it first). Ball factors are now Poké 12, Great 8, Ultra and Safari 5. In 1.2.0 a bug made every ball use 4, so Poké Balls and Great Balls are harder to use at full HP (they match the old chance at low HP), and Ultra and Safari Balls are somewhat harder than before but still better than Great Balls.
- Fixed: the Indigo Plateau lobby's Gym Guide blocked the only way to the Elite Four and the shops; he is back where he was before 1.1.0.
- Fixed: Fighting is no longer neutral against Fairy (it is resisted), is super effective against Steel, and Flying is resisted by Steel.
- Fixed: Golduck below Lv28 now learns Disable, Confusion, Bubblebeam and Screech.
- Fixed (Hard mode): a Pokémon above the level cap no longer drops levels when it gains exp (it gains none), Rare Candy refuses it, and your own Pokémon above the cap now disobey as intended (before, the effective limit was Lv55 below 8 badges).
- Fixed (Hard mode): a Hard-mode console and a Normal-mode console no longer desync in link battles; link battles use the Normal rules.
- Hard mode: the Options menu shows SET, the confirmation text says "trainer fights", and Rare Candy tells you when you're at the badge cap. The rules are listed in [hard_mode.md](hard_mode.md).
- A damaged save can no longer give the mode and starter bytes an out-of-range value.
- The ROM is 1 MiB, like the original, instead of 2 MiB. The ROM hash changes, so emulator save states from older builds no longer load (in-game saves are unaffected).

Pick Starter and the Normal and Hard rules, and existing saves, are otherwise unchanged.
