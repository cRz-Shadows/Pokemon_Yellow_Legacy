# Pick Starter Mode

Pick Starter is a third play mode alongside **Normal** and **Hard**. It plays like Normal mode, except that you choose **any of the 151 Pokémon** for Professor Oak to catch as your starter.

A printable player guide covering all the modes, Pick Starter and patching is in [player_guide.pdf](player_guide.pdf) (source: [player_guide.md](player_guide.md)).


## Starting a game

1. Choose **NEW GAME**.
2. At **Select game mode**, choose **PICK STARTER** and confirm. The description says that only a Pikachu starter follows you.
3. Right away, before the boy/girl choice and Oak's speech, the game says that Professor Oak will catch a Pokémon for you, explains the controls and opens a list of all 151 Pokémon.
   - **Up / Down** move one entry. Holding them scrolls, and the list wraps around at both ends.
   - **Left / Right** move a page.
   - The highlighted Pokémon's number, name, types and front sprite are shown. The sprite appears once you stop scrolling (after about 12 frames).
   - **Select** switches the info next to the sprite between its **types**, its **base stats** (HP, Attack, Defense, Speed, Special) and the **moves it will know** at level 5. The choice stays while you scroll. The moves come from the same code that gives you the Pokémon, so they're exactly what you get.
   - **A** asks "So, you want …?". For a Pokémon with no damaging move at level 5, it adds "It can't attack yet. Are you sure?". **YES** takes it and **NO** returns to the list. You can't leave without choosing.
   - The debug build's quick start skips the mode menu, so test Pick Starter with a regular new game.
4. The intro then goes on as usual: boy or girl, Oak's speech and the names.
5. When you head for Route 1, Oak stops you in the tall grass and catches the Pokémon you picked, where he catches Pikachu in Normal mode.
6. In Oak's lab, when you take the Poké Ball on his table, Oak gives you that Pokémon with his usual words ("this is the #MON I caught earlier").

Saves made in Pick Starter mode before this change, before getting a starter, have no pick stored. For them Oak catches a Pikachu in the tall grass, as in earlier versions, and the list opens in Oak's lab instead ("I caught a PIKACHU earlier, but my research covers every #MON!").


## Rules

- Everything except the starter follows **Normal** rules: Shift mode is allowed, items can be used in battle, and there are no gym level caps.
- The starter is a regular **level 5** of its species, with its usual Legacy stats and level-5 moves. It levels up and evolves normally.
- **If you pick Pikachu**, you get the usual starter Pikachu. It follows you, has happiness, and keeps every Pikachu scene, exactly as in Normal mode. Your rival keeps his Eevee.
- **If you pick anything else:**
  - Nothing follows you.
  - The Pikachu-only scenes are skipped. They check for the starter Pikachu, as they do in Normal mode when Pikachu is in the PC.
  - Your rival counters your pick: he swaps his Eevee for a Pokémon that beats yours (see [The rival's counter](#the-rivals-counter)).
  - In Oak's lab, your rival comments on your pick before your first battle. An Eevee like his ("Copycat!"), a legendary or Mew, or a Pokémon that can't attack yet gets its own comment, followed by "But I know what beats it: a …!". Otherwise he names the Pokémon he wants ("Your PIDGEY? Then I want a GEODUDE!"). Both end with "Gramps! I'm going to swap my EEVEE!".
  - In Oak's lab, the "Pikachu escapes its Poké Ball" scene is skipped. Oak then gives his usual battle advice instead of "talk to it and see how it feels".
  - **Melanie** (Cerulean City) gives you **Bulbasaur** without needing a happy Pikachu.
  - **Charmander** (Route 24) and **Squirtle** (Officer Jenny, Vermilion City) are available as usual, so all three classic starters can be obtained.


## The rival's counter

When you take your Pokémon in Oak's lab, your rival (who has just taken his Eevee) picks the Pokémon that beats it, and keeps that Pokémon's line in every rival battle.

- **Bulbasaur, Charmander or Squirtle line:** the starter that beats it, as in Red/Blue. Charmander against the Bulbasaur line, Squirtle against the Charmander line, Bulbasaur against the Squirtle line.
- **Pikachu:** none. He keeps his Eevee, exactly as in Normal mode.
- **Anything else:** the best counter by the game's type chart (`data/types/type_matchups.asm`), from this list:

  | Rival's Pokémon | Its types | Teams it joins |
  |---|---|---|
  | Squirtle | Water | his Squirtle teams (the Vaporeon team's teammates) |
  | Charmander | Fire | his Charmander teams (the Flareon team's) |
  | Bulbasaur | Grass/Poison | his Bulbasaur teams (the Jolteon team's) |
  | Machop | Fighting | the Bulbasaur teams |
  | Geodude | Rock/Ground | the Squirtle teams |
  | Magnemite | Electric/Steel | the Bulbasaur teams |
  | Drowzee | Psychic | the Charmander teams |
  | Gastly | Ghost/Dark | the Charmander teams |
  | Jynx | Ice/Psychic | the Squirtle teams |
  | Clefairy | Fairy | the Bulbasaur teams |

  He takes the one whose type hits your Pokémon hardest (counting both of your Pokémon's types, so ×4 beats ×2). On a tie, he takes the one your Pokémon's types hit least. On another tie, he takes the first in the list. If none of them is super effective, he keeps his Eevee and only comments on your Pokémon's type. With the current type chart every pick has a super-effective counter. Only the types of the Pokémon he picks count, not those of its evolutions.

The counter replaces the starter in those teams and evolves by its usual level: Machop becomes Machoke at Lv28 and Machamp at Lv38, Geodude Graveler at Lv25 and Golem at Lv38, Magnemite Magneton at Lv30, Drowzee Hypno at Lv26, Gastly Haunter at Lv25 and Gengar at Lv42. Clefairy, which evolves with a Moon Stone, becomes Clefable from Lv30. Jynx doesn't evolve. Its moves are the ones it learns by level. The rival's other Pokémon come from his usual Legacy teams for that starter, picked so that he never has two of the same line. His Champion rematch team is unchanged, and no Eeveelution stands in the Champion's room after the Hall of Fame.

The table below lists the rival's Pokémon for every pick. It is generated by `tools/rival_counters.py`, which models the game's code, and a unit test checks that it is up to date.

<!-- rival counters: generated by tools/rival_counters.py -->

| Your Pokémon | Types | Rival's Pokémon |
|---|---|---|
| BULBASAUR | GRASS/POISON | CHARMANDER |
| IVYSAUR | GRASS/POISON | CHARMANDER |
| VENUSAUR | GRASS/POISON | CHARMANDER |
| CHARMANDER | FIRE | SQUIRTLE |
| CHARMELEON | FIRE | SQUIRTLE |
| CHARIZARD | FIRE/DRAGON | SQUIRTLE |
| SQUIRTLE | WATER | BULBASAUR |
| WARTORTLE | WATER | BULBASAUR |
| BLASTOISE | WATER/STEEL | BULBASAUR |
| CATERPIE | BUG | CHARMANDER |
| METAPOD | BUG | CHARMANDER |
| BUTTERFREE | BUG/FLYING | GEODUDE |
| WEEDLE | BUG/POISON | CHARMANDER |
| KAKUNA | BUG/POISON | CHARMANDER |
| BEEDRILL | BUG/POISON | CHARMANDER |
| PIDGEY | NORMAL/FLYING | GEODUDE |
| PIDGEOTTO | NORMAL/FLYING | GEODUDE |
| PIDGEOT | NORMAL/FLYING | GEODUDE |
| RATTATA | NORMAL | MACHOP |
| RATICATE | NORMAL | MACHOP |
| SPEAROW | NORMAL/FLYING | GEODUDE |
| FEAROW | NORMAL/FLYING | GEODUDE |
| EKANS | POISON | GEODUDE |
| ARBOK | POISON | GEODUDE |
| PIKACHU | ELECTRIC | EEVEE, as in Normal mode |
| RAICHU | ELECTRIC | GEODUDE |
| SANDSHREW | GROUND | SQUIRTLE |
| SANDSLASH | GROUND | SQUIRTLE |
| NIDORAN♀ | POISON | GEODUDE |
| NIDORINA | POISON | GEODUDE |
| NIDOQUEEN | POISON/GROUND | SQUIRTLE |
| NIDORAN♂ | POISON | GEODUDE |
| NIDORINO | POISON | GEODUDE |
| NIDOKING | POISON/GROUND | SQUIRTLE |
| CLEFAIRY | FAIRY | BULBASAUR |
| CLEFABLE | FAIRY | BULBASAUR |
| VULPIX | FIRE | SQUIRTLE |
| NINETALES | FIRE | SQUIRTLE |
| JIGGLYPUFF | FAIRY/NORMAL | MAGNEMITE |
| WIGGLYTUFF | FAIRY/NORMAL | MAGNEMITE |
| ZUBAT | POISON/FLYING | MAGNEMITE |
| GOLBAT | POISON/FLYING | MAGNEMITE |
| ODDISH | GRASS/POISON | CHARMANDER |
| GLOOM | GRASS/POISON | CHARMANDER |
| VILEPLUME | GRASS/POISON | CHARMANDER |
| PARAS | BUG/GRASS | CHARMANDER |
| PARASECT | BUG/GRASS | CHARMANDER |
| VENONAT | BUG/POISON | CHARMANDER |
| VENOMOTH | BUG/POISON | CHARMANDER |
| DIGLETT | GROUND | SQUIRTLE |
| DUGTRIO | GROUND | SQUIRTLE |
| MEOWTH | NORMAL | MACHOP |
| PERSIAN | NORMAL | MACHOP |
| PSYDUCK | WATER/PSYCHIC | MAGNEMITE |
| GOLDUCK | WATER/PSYCHIC | MAGNEMITE |
| MANKEY | FIGHTING | DROWZEE |
| PRIMEAPE | FIGHTING | DROWZEE |
| GROWLITHE | FIRE/DARK | SQUIRTLE |
| ARCANINE | FIRE/DARK | SQUIRTLE |
| POLIWAG | WATER | BULBASAUR |
| POLIWHIRL | WATER/FIGHTING | BULBASAUR |
| POLIWRATH | WATER/FIGHTING | BULBASAUR |
| ABRA | PSYCHIC | GASTLY |
| KADABRA | PSYCHIC | GASTLY |
| ALAKAZAM | PSYCHIC | GASTLY |
| MACHOP | FIGHTING | DROWZEE |
| MACHOKE | FIGHTING | DROWZEE |
| MACHAMP | FIGHTING | DROWZEE |
| BELLSPROUT | GRASS/POISON | CHARMANDER |
| WEEPINBELL | GRASS/POISON | CHARMANDER |
| VICTREEBEL | GRASS/POISON | CHARMANDER |
| TENTACOOL | WATER/POISON | MAGNEMITE |
| TENTACRUEL | WATER/POISON | MAGNEMITE |
| GEODUDE | ROCK/GROUND | SQUIRTLE |
| GRAVELER | ROCK/GROUND | SQUIRTLE |
| GOLEM | ROCK/GROUND | SQUIRTLE |
| PONYTA | FIRE | SQUIRTLE |
| RAPIDASH | FIRE | SQUIRTLE |
| SLOWPOKE | WATER/PSYCHIC | MAGNEMITE |
| SLOWBRO | WATER/PSYCHIC | MAGNEMITE |
| MAGNEMITE | ELECTRIC/STEEL | GEODUDE |
| MAGNETON | ELECTRIC/STEEL | GEODUDE |
| FARFETCH'D | NORMAL/FLYING | GEODUDE |
| DODUO | NORMAL/FLYING | GEODUDE |
| DODRIO | NORMAL/FLYING | GEODUDE |
| SEEL | WATER | BULBASAUR |
| DEWGONG | WATER/ICE | MACHOP |
| GRIMER | POISON | GEODUDE |
| MUK | POISON | GEODUDE |
| SHELLDER | WATER | BULBASAUR |
| CLOYSTER | WATER/ICE | MACHOP |
| GASTLY | GHOST/DARK | CLEFAIRY |
| HAUNTER | GHOST/DARK | CLEFAIRY |
| GENGAR | GHOST/DARK | CLEFAIRY |
| ONIX | ROCK/GROUND | SQUIRTLE |
| DROWZEE | PSYCHIC | GASTLY |
| HYPNO | PSYCHIC | GASTLY |
| KRABBY | WATER | BULBASAUR |
| KINGLER | WATER | BULBASAUR |
| VOLTORB | ELECTRIC | GEODUDE |
| ELECTRODE | ELECTRIC | GEODUDE |
| EXEGGCUTE | GRASS/PSYCHIC | CHARMANDER |
| EXEGGUTOR | GRASS/PSYCHIC | CHARMANDER |
| CUBONE | GROUND | SQUIRTLE |
| MAROWAK | GROUND | SQUIRTLE |
| HITMONLEE | FIGHTING | DROWZEE |
| HITMONCHAN | FIGHTING | DROWZEE |
| LICKITUNG | NORMAL | MACHOP |
| KOFFING | POISON | GEODUDE |
| WEEZING | POISON | GEODUDE |
| RHYHORN | GROUND/ROCK | SQUIRTLE |
| RHYDON | GROUND/ROCK | SQUIRTLE |
| CHANSEY | NORMAL | MACHOP |
| TANGELA | GRASS | BULBASAUR |
| KANGASKHAN | NORMAL | MACHOP |
| HORSEA | WATER | BULBASAUR |
| SEADRA | WATER | BULBASAUR |
| GOLDEEN | WATER | BULBASAUR |
| SEAKING | WATER | BULBASAUR |
| STARYU | WATER | BULBASAUR |
| STARMIE | WATER/PSYCHIC | MAGNEMITE |
| MR.MIME | PSYCHIC/FAIRY | MAGNEMITE |
| SCYTHER | BUG/FLYING | GEODUDE |
| JYNX | ICE/PSYCHIC | MAGNEMITE |
| ELECTABUZZ | ELECTRIC | GEODUDE |
| MAGMAR | FIRE | SQUIRTLE |
| PINSIR | BUG | CHARMANDER |
| TAUROS | NORMAL | MACHOP |
| MAGIKARP | WATER | BULBASAUR |
| GYARADOS | WATER/DRAGON | CLEFAIRY |
| LAPRAS | WATER/ICE | MACHOP |
| DITTO | NORMAL | MACHOP |
| EEVEE | NORMAL | MACHOP |
| VAPOREON | WATER | BULBASAUR |
| JOLTEON | ELECTRIC | GEODUDE |
| FLAREON | FIRE | SQUIRTLE |
| PORYGON | NORMAL | MACHOP |
| OMANYTE | ROCK/WATER | BULBASAUR |
| OMASTAR | ROCK/WATER | BULBASAUR |
| KABUTO | ROCK/WATER | BULBASAUR |
| KABUTOPS | ROCK/WATER | BULBASAUR |
| AERODACTYL | ROCK/FLYING | GEODUDE |
| SNORLAX | NORMAL | MACHOP |
| ARTICUNO | ICE/FLYING | GEODUDE |
| ZAPDOS | ELECTRIC/FLYING | GEODUDE |
| MOLTRES | FIRE/FLYING | GEODUDE |
| DRATINI | DRAGON | CLEFAIRY |
| DRAGONAIR | DRAGON | CLEFAIRY |
| DRAGONITE | DRAGON/FLYING | JYNX |
| MEWTWO | PSYCHIC/DARK | CLEFAIRY |
| MEW | PSYCHIC | GASTLY |

<!-- end of rival counters -->
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
- At the start of the game, Oak catches the Pokémon you picked in the tall grass north of Pallet Town, instead of a Pikachu.


## Save compatibility

- The mode is stored in the existing difficulty byte: 0 = Normal, 1 = Hard, 2 = Pick Starter. The byte is a set of flags (bit 0 = Hard rules, bit 1 = pick the starter), so these values keep their meaning; the code checks it with the `test_hard_rules` and `test_pick_starter` macros. Normal and Hard saves from earlier versions load and play unchanged.
- The save layout is unchanged. No RAM or SRAM addresses moved.
- The rival's counter is stored in his existing starter byte (`wRivalStarter`): 1 to 3 for the Eeveelutions, 4 to 6 for the Bulbasaur, Charmander and Squirtle teams, and above that the same teams with one of the other counters (`RIVAL_COUNTER_LINE_STEP` in `constants/pokemon_constants.asm`). Saves from earlier versions keep their values.
- A Pick Starter save made before this version, before getting a starter, opens the list in Oak's lab (see [Starting a game](#starting-a-game)). Saves that already have their starter are unaffected.
- Don't load a Pick Starter save into a build from before this mode existed. Those builds treat any non-zero difficulty as Hard, so the game would play with Hard rules.


## Playtest checklist

New games:
- [ ] Normal: Pikachu is given as before, with classic rules
- [ ] Hard: Pikachu is given as before, with Set mode, no items in battle and gym level caps
- [ ] Pick Starter + Pikachu: identical to Normal (follower, escape scene, happiness)
- [ ] Pick Starter + a non-Pikachu starter (try one each of: a regular pick, a weak pick from the table, a legendary)

Story with a non-Pikachu starter:
- [ ] Picker: opens right after the mode is confirmed, before the boy/girl choice; SELECT cycles types, base stats and level-5 moves; the prompt still names the right Pokémon; the intro continues normally afterwards
- [ ] Pallet Town grass: Oak catches the picked Pokémon (its cry plays; Pikachu: its voice clip as usual)
- [ ] Oak's lab: Oak gives the picked Pokémon with his usual words ("the #MON I caught earlier")
- [ ] Oak's lab: the rival comments on the pick and swaps his Eevee (try an Eevee, a legendary, a weak pick and a regular pick)
- [ ] Bulbasaur/Charmander/Squirtle-line pick: the rival swaps for the counter starter, uses it in every rival battle (lab, Route 22, Cerulean, S.S. Anne, Pokémon Tower, Silph Co., Route 22, Champion) and evolves it
- [ ] Other picks: the rival's counter (see the table) is in every rival battle and evolves (try a Rattata: Machop, Machoke from the Pokémon Tower, Machamp at Silph Co.; and a Clefairy-countered pick such as Dratini: Clefable from the Pokémon Tower)
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

**1.3.0**

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

**Unreleased**

- Pick Starter mode: you pick your starter right after choosing the mode, before the intro, and Oak catches it in the tall grass north of Pallet Town instead of a Pikachu. In his lab he gives it to you as the Pokémon he caught earlier.
- Pick Starter mode: the rival counters every pick except Pikachu. Besides the Red/Blue counters for the Bulbasaur, Charmander and Squirtle lines, he picks a Pokémon that beats yours by type: Squirtle, Charmander, Bulbasaur, Machop, Geodude, Magnemite, Drowzee, Gastly, Jynx or Clefairy. He keeps its line in every rival battle and evolves it by level. He still comments on an Eevee, a legendary or a Pokémon that can't attack yet, then says what he wants instead.
- Pick Starter saves made before getting a starter in an earlier version open the list in Oak's lab.
- The rival's "swapping my EEVEE" line no longer has its "!" covered by the ▼ arrow.
- New player guide: [player_guide.pdf](player_guide.pdf).
- New types for nine Pokémon: Charizard Fire/Dragon, Blastoise Water/Steel, Gyarados Water/Dragon, Poliwhirl Water/Fighting, Growlithe Fire/Dark, Psyduck and Golduck Water/Psychic, and Jigglypuff and Wigglytuff Fairy/Normal (Fairy is now their first type).
