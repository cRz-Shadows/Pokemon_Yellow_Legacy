#!/usr/bin/env python3
"""Compare a build against the base branch's build, one section at a time.

Sections (each prints Markdown on stdout):
  roms   whether each ROM changed. Fails if EXPECT_IDENTICAL_ROM=1 (set by the
         expect-identical-rom label) and a ROM changed.
  save   whether the save layout changed: the saved WRAM ranges and SRAM
         symbols must keep their addresses, or old save files would load
         incorrectly. Fails if it changed, unless ALLOW_SAVE_LAYOUT_CHANGE=1
         (set by the save-layout-change label).
  banks  free space per ROM bank and how it changed. Never fails.

Usage: compare_builds.py roms|save|banks BASE_DIR HEAD_DIR
If BASE_DIR has no build (no base commit, or it doesn't build), the section
is skipped with a note.
"""

import hashlib
import os
import re
import sys

ROMS = ['pokemon_yellow_legacy', 'pokemon_yellow_legacy_debug']
NAME_LENGTH = 11

# WRAM ranges copied to and from SRAM by engine/menus/save.asm
SAVED_RANGES = [
    ('wPlayerName', None),
    ('wMainDataStart', 'wMainDataEnd'),
    ('wSpriteDataStart', 'wSpriteDataEnd'),
    ('wPartyDataStart', 'wPartyDataEnd'),
    ('wBoxDataStart', 'wBoxDataEnd'),
]


def sha1(path):
    with open(path, 'rb') as f:
        return hashlib.sha1(f.read()).hexdigest()


def read_syms(path):
    """label -> (bank, address); exported constants ("value name") are skipped"""
    syms = {}
    with open(path) as f:
        for line in f:
            parts = line.split(';')[0].split()
            if len(parts) == 2 and ':' in parts[0]:
                bank, addr = parts[0].split(':')
                syms[parts[1]] = (int(bank, 16), int(addr, 16))
    return syms


def save_layout(syms):
    """Returns (ranges, saved): the saved ranges' bounds, and name -> (bank,
    address) for every symbol inside a saved range or in SRAM."""
    ranges = {}
    for start, end in SAVED_RANGES:
        lo = syms[start][1]
        hi = syms[end][1] if end else lo + NAME_LENGTH
        ranges[start] = (lo, hi)
    saved = {}
    for name, (bank, addr) in syms.items():
        if 0xa000 <= addr < 0xc000 or any(lo <= addr < hi for lo, hi in ranges.values()):
            saved[name] = (bank, addr)
    return ranges, saved


def save_layout_changes(base_syms, head_syms):
    """Compares the save layout by name. Returns (problems, notes).

    Every saved symbol of the base build must keep its address. A name that is
    gone counts as a rename (a note, not a problem) only if a name that is new
    in this build now sits at its old address."""
    base_ranges, base_saved = save_layout(base_syms)
    head_ranges, head_saved = save_layout(head_syms)
    problems, notes = [], []
    for name in base_ranges:
        if base_ranges[name] != head_ranges[name]:
            (blo, bhi), (hlo, hhi) = base_ranges[name], head_ranges[name]
            problems.append(f'range `{name}` moved: ${blo:04x}-${bhi:04x} → ${hlo:04x}-${hhi:04x}')
    new_names = {n: v for n, v in head_saved.items() if n not in base_saved}
    for name, (bank, addr) in sorted(base_saved.items(), key=lambda item: item[1]):
        where = f'{bank:02x}:${addr:04x}'
        if name in head_saved:
            if head_saved[name] != (bank, addr):
                hb, ha = head_saved[name]
                problems.append(f'`{name}` moved from {where} to {hb:02x}:${ha:04x}')
        else:
            renamed = sorted(n for n, v in new_names.items() if v == (bank, addr))
            if renamed:
                notes.append(f'`{name}` at {where} is now `{", ".join(renamed)}` (renamed)')
            else:
                problems.append(f'`{name}` at {where} is gone')
    base_addrs = set(base_saved.values())
    for name, (bank, addr) in sorted(new_names.items(), key=lambda item: item[1]):
        if (bank, addr) not in base_addrs:
            notes.append(f'new `{name}` at {bank:02x}:${addr:04x} (fine if it uses previously unused space)')
    return problems, notes


def read_bank_space(path):
    """'ROMX bank #1' -> free bytes, from an rgblink .map file"""
    space = {}
    bank = None
    with open(path) as f:
        lines = f.readlines()
    for line in lines:
        m = re.match(r'(ROM0|ROMX) bank #(\d+):', line)
        if m:
            bank = f'{m[1]} {int(m[2])}'
            continue
        m = re.match(r'\s*TOTAL EMPTY: \$([0-9a-fA-F]+) bytes', line)
        if m and bank:
            space[bank] = int(m[1], 16)
            bank = None
    return space


def compare_roms(base, head):
    out = ['### ROM changes', '| ROM | Result |', '|---|---|']
    changed = False
    for rom in ROMS:
        same = sha1(f'{base}/{rom}.gbc') == sha1(f'{head}/{rom}.gbc')
        changed |= not same
        out.append(f'| `{rom}.gbc` | {"identical to base" if same else "**changed**"} |')
    failed = False
    if os.environ.get('EXPECT_IDENTICAL_ROM') == '1':
        out.append('')
        if changed:
            failed = True
            out.append('**The `expect-identical-rom` label is set, but a ROM changed.** '
                       'Remove the label if this PR is meant to change the game.')
        else:
            out.append('The `expect-identical-rom` label is set and the ROMs are identical.')
    return out, failed


def compare_save_layout(base, head):
    out = ['### Save layout']
    problems, notes = save_layout_changes(read_syms(f'{base}/{ROMS[0]}.sym'), read_syms(f'{head}/{ROMS[0]}.sym'))
    failed = False
    if problems:
        allowed = os.environ.get('ALLOW_SAVE_LAYOUT_CHANGE') == '1'
        failed = not allowed
        out.append('**The save layout changed**, so saves from the base build may not load correctly.'
                   + (' Allowed by the `save-layout-change` label.' if allowed else
                      ' If this is intended, add the `save-layout-change` label to the PR and re-run the jobs.'))
        out.extend(f'- {p}' for p in problems[:50])
        if len(problems) > 50:
            out.append(f'- …and {len(problems) - 50} more')
    else:
        out.append('Unchanged: every saved WRAM and SRAM variable is at the same address.')
    if notes:
        out.append('')
        out.extend(f'- {n}' for n in notes[:30])
    return out, failed


def unlisted_bank_space(rom_path, listed):
    """rgblink's map lists only the banks it placed sections in; the ROM's
    other banks are empty padding. Returns their free bytes."""
    banks = os.path.getsize(rom_path) // 0x4000
    return max(banks - len(listed), 0) * 0x4000


def compare_bank_space(base, head):
    out = ['### Free ROM space']
    base_space = read_bank_space(f'{base}/{ROMS[0]}.map')
    head_space = read_bank_space(f'{head}/{ROMS[0]}.map')
    changed = [b for b in head_space if head_space[b] != base_space.get(b)]
    total_base = sum(base_space.values()) + unlisted_bank_space(f'{base}/{ROMS[0]}.gbc', base_space)
    total_head = sum(head_space.values()) + unlisted_bank_space(f'{head}/{ROMS[0]}.gbc', head_space)
    out.append(f'Total free: {total_head:,} bytes ({total_head - total_base:+,} vs base), '
               'including banks with nothing placed in them.')
    if changed:
        tightest = min(changed, key=lambda b: head_space[b])
        out.append(f'Tightest bank this PR changed: {tightest} ({head_space[tightest]} bytes free).')
        out.append('')
        out.append('| Bank | Free (base) | Free (this PR) | Change |')
        out.append('|---|---:|---:|---:|')
        for b in changed:
            old = base_space.get(b, 0)
            out.append(f'| {b} | {old} | {head_space[b]} | {head_space[b] - old:+} |')
    else:
        out.append('No bank changed size.')
    return out, False


SECTIONS = {
    'roms': ('ROM changes', compare_roms),
    'save': ('Save layout', compare_save_layout),
    'banks': ('Free ROM space', compare_bank_space),
}


def main():
    if len(sys.argv) != 4 or sys.argv[1] not in SECTIONS:
        sys.exit(__doc__)
    title, compare = SECTIONS[sys.argv[1]]
    base, head = sys.argv[2], sys.argv[3]
    if not os.path.exists(f'{base}/{ROMS[0]}.gbc'):
        print(f'### {title}')
        print('Skipped: there is no base build to compare with '
              '(no base commit, or the base commit does not build).')
        return 0
    out, failed = compare(base, head)
    print('\n'.join(out))
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
