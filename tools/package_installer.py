#!/usr/bin/env python3
"""Build dependency-ordered updates for the existing mobile ZIP installer."""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[1]
LIMIT = 25_000_000  # Decimal MB, stricter than 25 MiB.
PREFIX = 'StellarLegacy-Godot/'


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT, text=True).strip()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--base', default='ed7158b792cb021b7f56955e244c4bd105a517a4')
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--single', action='store_true', help='Put assets and code in one self-contained update when it fits')
    parser.add_argument('--label', default='StellarLegacy_Codex')
    args = parser.parse_args()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    if not args.label or PurePosixPath(args.label).name != args.label or "\\" in args.label:
        raise SystemExit('Label must be a filename stem')
    base, head = git('rev-parse', args.base), git('rev-parse', 'HEAD')
    groups = [[], []]
    excluded = []
    for row in git('diff', '--name-status', '--no-renames', base, head).splitlines():
        status, name = row.split('\t', 1)
        if status not in ('A', 'M'):
            raise SystemExit('Installer delivery must not delete files: ' + row)
        path = PurePosixPath(name)
        if path.parts[0] == '.github':
            excluded.append(name)  # Installer explicitly rejects this directory.
            continue
        if path.is_absolute() or '..' in path.parts or path.parts[0] == '.git' or name.lower().endswith('.zip'):
            raise SystemExit('Forbidden installer path: ' + name)
        if (ROOT / name).is_symlink():
            raise SystemExit('Symlinks are not supported: ' + name)
        groups[0 if path.parts[0] == 'assets' else 1].append(name)
    if args.single:
        groups = [groups[0] + groups[1]]
        names = [args.label + '_ATUALIZACAO.zip']
    else:
        names = [args.label + '_PARTE_1_ASSETS.zip', args.label + '_PARTE_2_CORRECOES.zip']
    parts = []
    for index, (name, files) in enumerate(zip(names, groups), start=1):
        target = output / name
        with zipfile.ZipFile(target, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
            for file in sorted(files):
                archive.write(ROOT / file, PREFIX + file)
        with zipfile.ZipFile(target) as archive:
            if archive.testzip() is not None:
                raise SystemExit('Archive CRC failed: ' + name)
            expanded = sum(entry.file_size for entry in archive.infolist())
            if len(archive.infolist()) > 2000 or expanded > 200 * 1024 * 1024:
                raise SystemExit('Archive exceeds installer limits: ' + name)
        size = target.stat().st_size
        if size >= LIMIT:
            target.unlink()
            raise SystemExit('Part exceeds 25 MB; split dependency groups further: ' + name)
        parts.append({'order': index, 'file': name, 'bytes': size, 'expanded_bytes': expanded,
                      'sha256': hashlib.sha256(target.read_bytes()).hexdigest(), 'paths': sorted(files)})
        print(f'{name}: {size / 1_000_000:.2f} MB, {len(files)} files, CRC passed')
    manifest = {'base_commit': base, 'source_commit': head, 'max_part_bytes': LIMIT,
                'install_order': [part['file'] for part in parts], 'parts': parts,
                'excluded_installer_forbidden_paths': excluded}
    (output / 'MANIFESTO_INSTALACAO.json').write_text(json.dumps(manifest, indent=2) + '\n')
    (output / 'SHA256SUMS.txt').write_text(''.join(f"{part['sha256']}  {part['file']}\n" for part in parts))


if __name__ == '__main__':
    main()
