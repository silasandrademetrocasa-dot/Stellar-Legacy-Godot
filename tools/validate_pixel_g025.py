#!/usr/bin/env python3
"""Quick pre-export check for Stellar Legacy G0.25 Pixel Art."""
from pathlib import Path
import json,re
root = Path(__file__).resolve().parents[1]
assert (root/'routes.json').is_file() and (root/'WebRouteRegistry.gd').is_file()
data=json.loads((root/'routes.json').read_text(encoding='utf-8'))
assert len(data['web_id_to_godot_route']) >= 23
for kind,at_least in [('ships',13),('npcs',16)]:
    sprites=list((root/'assets/pixel/map_units'/kind).glob('*.png'))
    assert len(sprites)>=at_least,(kind,len(sprites))
    # PIL only available locally; on Actions use stdlib IHDR to validate pixels.
    import struct
    for file in sprites:
        raw=file.read_bytes()
        assert raw[:8]==b'\x89PNG\r\n\x1a\n' and struct.unpack_from('>II',raw,16)==(512,256),str(file)
assert not list((root/'assets').rglob('*.glb')),'Imported GLBs remain in game package'
for source in [root/'project.godot',*root.glob('scripts/**/*.gd'),*root.glob('scenes/**/*.tscn')]:
    contents=source.read_text(encoding='utf-8')
    if source.suffix=='.gd': assert '.glb' not in contents, source
    for hit in re.finditer(r'"(res://[^"\n]+)"', contents):
        path=hit.group(1)
        if '%' not in path and not (root/path[6:]).exists():
            raise AssertionError(f'Missing reference in {source.name}: {path}')
print('G0.25 OK: 23 Web routes, PNG atlases and no imported GLB, literal references valid.')
