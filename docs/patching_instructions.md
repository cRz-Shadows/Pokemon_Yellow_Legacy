# Patching Instructions

Each release is a **patch**. Apply it to your own copy of the original English
Pokémon Yellow ROM to get the game. The ROM itself isn't included.

## What you need

- A **clean** English *Pokémon Yellow Version* ROM (.gb or .gbc both work).
  It must not be modified: no randomizer, no other hack, no earlier Yellow
  Legacy version.
- The `.bps` patch file from the release zip (on the Releases page).
- A patcher. Recommended: ROM Patcher JS, https://www.marcrobledo.com/RomPatcher.js/
  (works in any browser, including on phones).

## Steps

1. **Check your ROM first.** Load it in ROM Patcher JS (or any hash checker)
   and compare its SHA-1 with:

       cc7d03262ebfaf2f06772c1a480c7d9d5f4a38e1

   If it doesn't match exactly, your ROM is modified or a different version,
   and the patched game may not work.
2. Apply the `.bps` patch to that ROM. ROM Patcher JS downloads the patched
   ROM when it's done.
3. **Check the patched ROM.** Load the downloaded file back into ROM Patcher
   JS (as the ROM) to see its SHA-1, and compare it with the one in the
   release notes (it is also at the end of the copy of these instructions in
   the release zip). If it doesn't match, start again from a clean ROM.
   Never apply the patch to an already patched ROM.
4. Name the result something like `Pokemon Yellow Legacy.gbc` and load it in
   your emulator (for example mGBA on PC, Delta on iPhone).

## Saves

- Before switching from an older Yellow Legacy version, **save in a Pokémon
  Center** and **back up your save file**.
- Emulators find the save by the ROM's file name. If the new ROM has a
  different name, rename your old `.sav` file to match it (same name, `.sav`
  extension), or the game will look like it has no save.
- Normal and Hard saves keep working. Pick Starter is a new mode, chosen when
  starting a new game.

## Pick Starter mode: things to know

- Choose **PICK STARTER** in the game mode menu when starting a new game. In
  Oak's lab you then pick any of the 151 Pokémon: UP/DOWN to look,
  LEFT/RIGHT to page, SELECT to see its base stats or level-5 moves, A to
  choose. You can't leave without choosing.
- Everything else uses Normal rules.
- Only a **PIKACHU** starter follows you around and gets the Pikachu scenes.
  With any other starter, Melanie in Cerulean City still gives you BULBASAUR,
  and any Pokémon that knows SURF can play Pikachu's Beach.
- Some picks (such as MAGIKARP, ABRA and SNORLAX) know no damaging move at
  level 5. The game warns you before you take one; they're a challenge pick.
