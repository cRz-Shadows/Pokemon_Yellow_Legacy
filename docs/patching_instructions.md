# Patching Instructions

This release is a **patch**. Apply it to your own copy of the original
English Pokémon Yellow ROM to get the game. The ROM itself isn't included.

## What you need

- A **clean** English *Pokémon Yellow Version* ROM (.gb or .gbc both work).
  It must not be modified: no randomizer, no other hack, no earlier Yellow
  Legacy version.
- The `.bps` patch file from this zip.
- A patcher. Recommended: ROM Patcher JS, https://www.marcrobledo.com/RomPatcher.js/
  (works in any browser, including on phones).

## Steps

1. **Check your ROM first.** Load it in ROM Patcher JS (or any hash checker)
   and compare its SHA-1 with:

       {BASE_SHA1}

   If it doesn't match exactly, your ROM is modified or a different version,
   and the patched game may not work.
2. Apply the `.bps` patch to that ROM.
3. Check the patched ROM's SHA-1:

       {PATCHED_SHA1}

   If it doesn't match, start again from a clean ROM. Never apply the
   patch to an already patched ROM.
4. Rename the result to something like `Pokemon Yellow Legacy.gbc` and load
   it in your emulator (for example mGBA on PC, Delta on iPhone).

## Saves

- Before switching from an older Yellow Legacy version, **save in a Pokémon
  Center** and **back up your save file**.
- Normal and Hard saves keep working. Pick Starter is a new mode, chosen when
  starting a new game.
