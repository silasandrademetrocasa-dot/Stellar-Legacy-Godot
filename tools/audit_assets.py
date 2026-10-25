#!/usr/bin/env python3
"""Read-only GLB/resource audit using only Python's standard library."""
import argparse
import collections
import hashlib
import json
import math
from pathlib import Path
import re
import struct

ROOT = Path(__file__).resolve().parents[1]


def inspect_glb(path):
    data = path.read_bytes()
    magic, version, size = struct.unpack_from('<4sII', data)
    if magic != b'glTF' or version != 2 or size != len(data):
        raise ValueError(f'{path}: invalid GLB header')
    offset, document, binary = 12, None, b''
    while offset < len(data):
        length, kind = struct.unpack_from('<II', data, offset)
        offset += 8
        if length % 4 or offset + length > len(data):
            raise ValueError(f'{path}: invalid chunk length')
        chunk = data[offset:offset + length]
        if kind == 0x4E4F534A:
            document = json.loads(chunk)
        elif kind == 0x004E4942:
            binary = chunk
        offset += length
    if document is None:
        raise ValueError(f'{path}: missing JSON chunk')
    views = document.get('bufferViews', [])
    for view in views:
        if view.get('buffer', 0) != 0 or view.get('byteOffset', 0) + view['byteLength'] > len(binary):
            raise ValueError(f'{path}: invalid embedded buffer view')
    for image in document.get('images', []):
        uri = image.get('uri')
        if uri and not uri.startswith('data:') and not (path.parent / uri).is_file():
            raise ValueError(f'{path}: missing image {uri}')
        if 'bufferView' in image and not 0 <= image['bufferView'] < len(views):
            raise ValueError(f'{path}: invalid image buffer view')
    accessors = document.get('accessors', [])
    for accessor in accessors:
        if 'bufferView' in accessor and not 0 <= accessor['bufferView'] < len(views):
            raise ValueError(f'{path}: invalid accessor buffer view')
        for key in ('min', 'max'):
            if any(not math.isfinite(value) for value in accessor.get(key, [])):
                raise ValueError(f'{path}: non-finite accessor bounds')
    triangles, surfaces = 0, 0
    materials = document.get('materials', [])
    for mesh in document.get('meshes', []):
        for primitive in mesh['primitives']:
            surfaces += 1
            if 'material' in primitive and not 0 <= primitive['material'] < len(materials):
                raise ValueError(f'{path}: invalid material reference')
            if primitive.get('mode', 4) == 4:
                source = primitive.get('indices', primitive['attributes']['POSITION'])
                triangles += accessors[source]['count'] // 3
    entry = {
        'path': path.relative_to(ROOT).as_posix(),
        'sha256': hashlib.sha256(data).hexdigest(),
        'bytes': len(data), 'triangles': triangles, 'surfaces': surfaces,
        'materials': len(materials), 'images': len(document.get('images', [])),
        'animation_clips': len(document.get('animations', [])),
    }
    if path.parent.name == 'ships':
        # Current ship nodes are authored in a common coordinate frame.
        if any(set(node).intersection(('matrix', 'translation', 'rotation', 'scale')) for node in document['nodes']):
            raise ValueError(f'{path}: ship transforms changed; re-audit authored axes/bounds')
        positions = [accessors[p['attributes']['POSITION']] for m in document['meshes'] for p in m['primitives']]
        low = [min(a['min'][i] for a in positions) for i in range(3)]
        high = [max(a['max'][i] for a in positions) for i in range(3)]
        entry['authored_bounds'] = {'min': low, 'max': high, 'size': [high[i] - low[i] for i in range(3)]}
    return entry


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path)
    parser.add_argument('--write-ships', type=Path)
    args = parser.parse_args()
    entries = [inspect_glb(path) for path in sorted((ROOT / 'assets').rglob('*.glb'))]
    broken = []
    for source in [ROOT / 'project.godot', *ROOT.glob('scripts/**/*.gd'), *ROOT.glob('scenes/**/*.tscn')]:
        for path in re.findall(r'"(res://[^"\n]+)"', source.read_text()):
            if '%' not in path and not (ROOT / path[6:]).exists():
                broken.append(f'{source.relative_to(ROOT)}: {path}')
    if broken:
        raise ValueError('Broken literal resource paths:\n' + '\n'.join(broken))
    recovered = json.loads((ROOT / 'docs/audit/integrated-assets.json').read_text())
    for record in recovered:
        if hashlib.sha256((ROOT / record['path']).read_bytes()).hexdigest() != record['sha256']:
            raise ValueError('Recovered source differs: ' + record['path'])
    ships = [entry for entry in entries if entry['path'].startswith('assets/ships/')]
    manifest = ROOT / 'docs/audit/ship-assets.json'
    if args.write_ships:
        args.write_ships.write_text(json.dumps(ships, indent=2) + '\n')
    elif manifest.exists() and json.loads(manifest.read_text()) != ships:
        raise ValueError('Ship source changed: compare original GLBs and update audit consciously')
    totals = collections.defaultdict(lambda: {'models': 0, 'triangles': 0, 'surfaces': 0})
    for entry in entries:
        category = Path(entry['path']).parent.name
        totals[category]['models'] += 1
        totals[category]['triangles'] += entry['triangles']
        totals[category]['surfaces'] += entry['surfaces']
    result = {'models': len(entries), 'categories': dict(totals), 'assets': entries, 'broken_literal_paths': broken}
    if args.output:
        args.output.write_text(json.dumps(result, indent=2) + '\n')
    print(f"STATIC ASSETS: {len(entries)} GLBs valid; source hashes and literal paths passed")
    for category, totals in result['categories'].items():
        print(f"  {category}: {totals['models']} models, {totals['triangles']} triangles, {totals['surfaces']} surfaces")


if __name__ == '__main__':
    main()
