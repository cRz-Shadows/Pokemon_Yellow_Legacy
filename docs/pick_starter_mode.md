# Pick Starter Mode

Pick Starter is a third play mode alongside **Normal** and **Hard**. It plays like Normal mode, except that Professor Oak lets you choose **any of the 151 Pokémon** as your starter.


## Starting a game

1. Choose **NEW GAME**.
2. At **Select Difficulty**, choose **PICK STARTER** and confirm.
3. When Oak gives you your first Pokémon in his lab, a list of all 151 Pokémon opens instead.
   - **Up / Down** move one entry. Holding them scrolls.
   - **Left / Right** move a page.
   - The highlighted Pokémon's number, name, types and front sprite are shown. The sprite appears once you stop scrolling.
   - **A** asks "So, you want …?". **YES** takes it and **NO** returns to the list. You can't leave without choosing.


## Rules

- Everything except the starter follows **Normal** rules: Shift mode is allowed, items can be used in battle, and there are no gym level caps.
- The starter is a regular **level 5** of its species, with its usual Legacy stats and level-5 moves. It levels up and evolves normally.
- **If you pick Pikachu**, you get the usual starter Pikachu. It follows you, has happiness, and keeps every Pikachu scene, exactly as in Normal mode.
- **If you pick anything else:**
  - Nothing follows you.
  - The Pikachu-only scenes are skipped. They check for the starter Pikachu, as they do in Normal mode when Pikachu is in the PC.
  - In Oak's lab, the "Pikachu escapes its Poké Ball" scene is skipped. Oak then gives his usual battle advice instead of "talk to it and see how it feels".
  - **Melanie** (Cerulean City) gives you **Bulbasaur** without needing a happy Pikachu.
  - **Charmander** (Route 24) and **Squirtle** (Officer Jenny, Vermilion City) are available as usual, so all three classic starters can be obtained.
  - **Pikachu's Beach** (the surfing minigame in the Summer Beach House, Route 19) can be played with **any Pokémon in your party that knows Surf**, not just a Pikachu. The Surfin' Dude says "Your POKéMON knows how to SURF!". The minigame itself still shows Pikachu, and the beach-house posters and printer also unlock.


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
- At the start of the game, Oak still catches a wild Pikachu on Route 1. That Pikachu stays with him.


## Save compatibility

- The mode is stored in the existing difficulty byte: 0 = Normal, 1 = Hard, 2 = Pick Starter. Normal and Hard saves from earlier versions load and play unchanged.
- The save layout is unchanged. No RAM or SRAM addresses moved.
- Don't load a Pick Starter save into a build from before this mode existed. Those builds treat any non-zero difficulty as Hard, so the game would play with Hard rules.


## Playtest checklist

New games:
- [ ] Normal: Pikachu is given as before, with classic rules
- [ ] Hard: Pikachu is given as before, with Set mode, no items in battle and gym level caps
- [ ] Pick Starter + Pikachu: identical to Normal (follower, escape scene, happiness)
- [ ] Pick Starter + a non-Pikachu starter (try one each of: a regular pick, a weak pick from the table, a legendary)

Story with a non-Pikachu starter:
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
- Normal and Hard modes and existing saves are unchanged.
