#!/usr/bin/env python3
"""Reproducible Godot 4.5.2 checks with isolated saves, timeouts and error-log gates."""
import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import time

ROOT = Path(__file__).resolve().parents[1]
ERROR = re.compile(r'(?m)^(?:SCRIPT ERROR:|ERROR:)|Parse Error|instances leaked|resources still in use')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', default=os.environ.get('GODOT_BINARY', 'godot'))
    parser.add_argument('--logs', type=Path)
    parser.add_argument('--render', action='store_true', help='Also test desktop Compatibility; requires DISPLAY')
    args = parser.parse_args()
    godot = shutil.which(args.godot)
    if not godot:
        raise SystemExit('Godot executable not found; pass --godot /path/to/Godot_4.5.2')
    version = subprocess.check_output([godot, '--version'], text=True).strip()
    if not version.startswith('4.5.2.'):
        raise SystemExit(f'Expected Godot 4.5.2 (repository CI target), found {version}')
    logs = args.logs.resolve() if args.logs else Path(tempfile.mkdtemp(prefix='stellar-validation-'))
    logs.mkdir(parents=True, exist_ok=True)
    results = []
    print(f'Godot {version}; evidence: {logs}', flush=True)

    def run(label, command, limit=60, engine=False):
        start = time.monotonic()
        # Fresh per-command data directories prevent tests from changing player saves.
        with tempfile.TemporaryDirectory(prefix='stellar-profile-') as profile:
            env = os.environ.copy()
            env['XDG_DATA_HOME'] = profile
            try:
                process = subprocess.run(command, cwd=ROOT, env=env, text=True, stdout=subprocess.PIPE,
                                         stderr=subprocess.STDOUT, timeout=limit)
                output, code = process.stdout, process.returncode
            except subprocess.TimeoutExpired as error:
                raw = error.stdout or b''
                output = raw.decode(errors='replace') if isinstance(raw, bytes) else raw
                output += f'\nTIMEOUT after {limit}s\n'
                code = 124
        (logs / f'{label}.log').write_text(output)
        ok = code == 0 and (not engine or not ERROR.search(output))
        results.append({'check': label, 'passed': ok, 'exit_code': code, 'seconds': round(time.monotonic() - start, 3)})
        print(f'{"PASS" if ok else "FAIL"} {label}', flush=True)
        if not ok:
            print(output[-12000:], flush=True)
            (logs / 'results.json').write_text(json.dumps({'godot': version, 'results': results}, indent=2) + '\n')
            raise SystemExit(1)

    run('static-assets', [sys.executable, str(ROOT / 'tools/audit_assets.py'), '--output', str(logs / 'asset-inventory.json')])
    run('project-plan', [sys.executable, str(ROOT / 'tools/check_project_plan.py')])
    common = [godot, '--headless', '--audio-driver', 'Dummy', '--path', str(ROOT)]
    run('import', [*common, '--editor', '--import'], limit=600, engine=True)
    for source in sorted([*ROOT.glob('scripts/**/*.gd'), *ROOT.glob('tests/*.gd')]):
        label = 'parse-' + source.relative_to(ROOT).as_posix().replace('/', '-').removesuffix('.gd')
        run(label, [*common, '--check-only', '--script', 'res://' + source.relative_to(ROOT).as_posix()], engine=True)
    run('main-smoke', [*common, '--quit-after', '120'], engine=True)
    run('relay-demo-smoke', [*common, '--quit-after', '120', 'res://scenes/relays/demo_reles.tscn'], engine=True)
    for test in ['aurora', 'fleet', 'assets', 'relays', 'effects', 'design_system']:
        run(f'test-{test}', [*common, '--script', f'res://tests/test_{test}.gd'], engine=True)
    if args.render:
        run('rendering', [godot, '--path', str(ROOT), '--audio-driver', 'Dummy', '--rendering-method',
                          'gl_compatibility', '--script', 'res://tests/test_rendering.gd', '--', str(logs / 'screenshots')],
            limit=120, engine=True)
    (logs / 'results.json').write_text(json.dumps({'godot': version, 'results': results}, indent=2) + '\n')
    print(f'PASS: {len(results)} checks; no Android device/FPS measurement performed.', flush=True)


if __name__ == '__main__':
    main()
