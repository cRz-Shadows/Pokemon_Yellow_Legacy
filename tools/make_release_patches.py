#!/usr/bin/env python3
"""Make a BPS patch that turns a clean Pokémon Yellow ROM into the built ROM.

Usage: tools/make_release_patches.py BASE_ROM BUILT_ROM OUTPUT_PREFIX

Writes OUTPUT_PREFIX.bps, applies it to the base ROM to check that the result
is byte-identical to the built ROM, and packs it with the patching
instructions (docs/patching_instructions.md) into OUTPUT_PREFIX.zip.
BPS, unlike IPS, stores checksums of both ROMs, so patchers can detect the
wrong base ROM.
The base ROM must be the US Pokémon Yellow release (SHA-1 below).
"""

import hashlib
import os
import sys
import zipfile
import zlib

BASE_SHA1 = 'cc7d03262ebfaf2f06772c1a480c7d9d5f4a38e1'

# BPS: "BPS1", sizes, then SourceRead / TargetRead actions, then three CRC32s

SOURCE_READ, TARGET_READ = 0, 1


def bps_number(n):
    out = bytearray()
    while True:
        x = n & 0x7f
        n >>= 7
        if n == 0:
            out.append(0x80 | x)
            return bytes(out)
        out.append(x)
        n -= 1


def read_bps_number(data, i):
    n, shift = 0, 1
    while True:
        x = data[i]
        i += 1
        n += (x & 0x7f) * shift
        if x & 0x80:
            return n, i
        shift <<= 7
        n += shift


BLOCK = 8  # bytes hashed to find copy candidates


def match_length(a, ai, b, bi, limit):
    """Length of the common run of a[ai:] and b[bi:], up to limit."""
    n = 0
    step = 4096
    while n < limit and step:
        s = min(step, limit - n)
        if a[ai + n:ai + n + s] == b[bi + n:bi + n + s]:
            n += s
        else:
            step //= 8
    return n


def make_bps(base, target):
    """A delta BPS: copies from anywhere in the base ROM (SourceCopy) or from
    earlier output (TargetCopy), so moved code and data cost only a few bytes."""
    out = bytearray(b'BPS1')
    out += bps_number(len(base)) + bps_number(len(target)) + bps_number(0)
    source_index = {}
    for i in range(len(base) - BLOCK + 1):
        source_index.setdefault(base[i:i + BLOCK], i)
    target_index = {}
    source_rel = target_rel = 0
    literal_start = None
    pos, indexed = 0, 0

    def flush_literal(end):
        nonlocal literal_start
        if literal_start is not None:
            out.extend(bps_number(((end - literal_start - 1) << 2) | TARGET_READ))
            out.extend(target[literal_start:end])
            literal_start = None

    def relative(delta):
        return bps_number((abs(delta) << 1) | (delta < 0))

    n = len(target)
    while pos < n:
        while indexed + BLOCK <= pos:  # earlier output can be copied from
            target_index[target[indexed:indexed + BLOCK]] = indexed
            indexed += 1
        remaining = n - pos
        best_kind, best_len, best_from = None, 0, 0
        if pos < len(base):
            best_kind, best_len = SOURCE_READ, match_length(base, pos, target, pos, min(remaining, len(base) - pos))
        key = target[pos:pos + BLOCK]
        if len(key) == BLOCK:
            src = source_index.get(key)
            if src is not None:
                length = match_length(base, src, target, pos, min(remaining, len(base) - src))
                if length > best_len + 4:
                    best_kind, best_len, best_from = 2, length, src
            tgt = target_index.get(key)
            if tgt is not None:
                length = match_length(target, tgt, target, pos, remaining)
                if length > best_len + 4:
                    best_kind, best_len, best_from = 3, length, tgt
        if best_len < (4 if best_kind == SOURCE_READ else BLOCK):
            if literal_start is None:
                literal_start = pos
            pos += 1
            continue
        flush_literal(pos)
        out += bps_number(((best_len - 1) << 2) | best_kind)
        if best_kind == 2:
            out += relative(best_from - source_rel)
            source_rel = best_from + best_len
        elif best_kind == 3:
            out += relative(best_from - target_rel)
            target_rel = best_from + best_len
        pos += best_len
    flush_literal(n)
    out += zlib.crc32(base).to_bytes(4, 'little')
    out += zlib.crc32(target).to_bytes(4, 'little')
    out += zlib.crc32(out).to_bytes(4, 'little')
    return bytes(out)


def apply_bps(base, patch):
    assert patch[:4] == b'BPS1'
    assert zlib.crc32(patch[:-4]) == int.from_bytes(patch[-4:], 'little'), 'patch CRC'
    assert zlib.crc32(base) == int.from_bytes(patch[-12:-8], 'little'), 'source CRC'
    i = 4
    source_size, i = read_bps_number(patch, i)
    target_size, i = read_bps_number(patch, i)
    metadata_size, i = read_bps_number(patch, i)
    i += metadata_size
    assert source_size == len(base)
    out = bytearray()
    source_rel = target_rel = 0
    end = len(patch) - 12
    while i < end:
        n, i = read_bps_number(patch, i)
        action, length = n & 3, (n >> 2) + 1
        if action == SOURCE_READ:
            out += base[len(out):len(out) + length]
        elif action == TARGET_READ:
            out += patch[i:i + length]
            i += length
        else:
            d, i = read_bps_number(patch, i)
            delta = -(d >> 1) if d & 1 else d >> 1
            if action == 2:  # SourceCopy
                source_rel += delta
                out += base[source_rel:source_rel + length]
                source_rel += length
            else:  # TargetCopy (may overlap the bytes it produces)
                target_rel += delta
                for _ in range(length):
                    out.append(out[target_rel])
                    target_rel += 1
    assert len(out) == target_size
    assert zlib.crc32(out) == int.from_bytes(patch[-8:-4], 'little'), 'target CRC'
    return bytes(out)


def sha1(data):
    return hashlib.sha1(data).hexdigest()


def main():
    if len(sys.argv) != 4:
        sys.exit(__doc__.strip())
    base_path, target_path, prefix = sys.argv[1:4]
    with open(base_path, 'rb') as f:
        base = f.read()
    with open(target_path, 'rb') as f:
        target = f.read()
    if sha1(base) != BASE_SHA1:
        sys.exit(f'{base_path} is not a clean Pokémon Yellow ROM (SHA-1 {sha1(base)}, '
                 f'expected {BASE_SHA1})')
    patch = make_bps(base, target)
    if apply_bps(base, patch) != target:
        sys.exit(f'applying the patch does not reproduce {target_path}')
    with open(f'{prefix}.bps', 'wb') as f:
        f.write(patch)
    print(f'{prefix}.bps: {len(patch):,} bytes, verified')
    instructions = os.path.join(os.path.dirname(__file__), '..', 'docs', 'patching_instructions.md')
    with open(instructions, encoding='utf-8') as f:
        text = f.read()
    text = (text.rstrip('\n') + '\n\n## This release\n\n'
            f'- Patch: `{os.path.basename(prefix)}.bps`\n'
            f'- Base ROM SHA-1: `{BASE_SHA1}`\n'
            f'- Patched ROM SHA-1: `{sha1(target)}`\n')
    folder = os.path.basename(prefix)
    with zipfile.ZipFile(f'{prefix}.zip', 'w', zipfile.ZIP_DEFLATED) as z:
        z.writestr(f'{folder}/{folder}.bps', patch)
        z.writestr(f'{folder}/Patching Instructions.txt', text)
    print(f'{prefix}.zip: written')
    print(f'Base ROM SHA-1:    {BASE_SHA1}')
    print(f'Patched ROM SHA-1: {sha1(target)}')


if __name__ == '__main__':
    main()
