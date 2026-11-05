"""Verify every independent ZIP before assembling or replacing any game file."""
import argparse,hashlib,json,shutil,tempfile,zipfile
from pathlib import Path,PurePosixPath

def sha(data):return hashlib.sha256(data).hexdigest()
def safe(name):
 p=PurePosixPath(name)
 if not name or '\\' in name or p.is_absolute() or '..' in p.parts or p.parts[0] in {'.git','node_modules'}:raise ValueError('Unsafe path: '+name)
 return p

def install(manifest,destination,archives,verify=False):
 m=json.loads(Path(manifest).read_text());assert m['format']==1
 expected={f['path']:f for f in m['files']};assert len(expected)==len(m['files'])
 for name in expected:safe(name)
 candidates=[p for p in Path(archives).rglob('*') if p.is_file() and p.suffix.lower()=='.zip' and not any(x in p.parts for x in ('.git','node_modules'))]
 selected=[]
 for part in m['parts']:
  matches=[p for p in candidates if p.stat().st_size==part['bytes'] and sha(p.read_bytes())==part['sha256']]
  if not matches:raise ValueError('Missing or corrupted part: '+part['name'])
  assert part['bytes']<=24000000
  selected.append((part,matches[0]))
 with tempfile.TemporaryDirectory(prefix='stellar-stage-') as temporary:
  stage=Path(temporary);seen=set()
  for part,archive in selected:
   with zipfile.ZipFile(archive) as z:
    for info in z.infolist():
     if info.is_dir():continue
     name=info.filename;safe(name)
     if name in seen or name not in expected or expected[name]['part']!=part['name']:raise ValueError('Duplicate/unexpected file: '+name)
     data=z.read(info);f=expected[name]
     if len(data)!=f['bytes'] or sha(data)!=f['sha256']:raise ValueError('File integrity failed: '+name)
     target=stage/name;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data);seen.add(name)
  if seen!=set(expected):raise ValueError('Incomplete assembly')
  if verify:return len(seen)
  dest=Path(destination).resolve();dest.mkdir(parents=True,exist_ok=True)
  # Resolve symlinks before any mutation, including parent symlinks in an old repository.
  for name in seen:
   target=dest/name
   if (target.exists() and not target.is_file()) or target.is_symlink() or not target.resolve().is_relative_to(dest):raise ValueError('Unsafe destination: '+name)
  old=dest/'.stellar-installed.json';obsolete=set()
  if old.exists():obsolete=set(json.loads(old.read_text()).get('files',[]))-seen
  # Old hashed build assets must not remain serving stale code after replacement.
  if (dest/'assets').is_dir():obsolete.update(str(p.relative_to(dest)) for p in (dest/'assets').rglob('*') if p.is_file() and str(p.relative_to(dest)) not in seen)
  obsolete.add('.github/workflows/deploy-pages.yml')
  for name in obsolete:
   safe(name);p=dest/name
   if p.is_file() and p.resolve().is_relative_to(dest):p.unlink()
  for name in sorted(seen):
   target=dest/name;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(stage/name,target)
  old.write_text(json.dumps({'version':m['version'],'revision':m['revision'],'files':sorted(seen)},indent=2)+'\n')
 return len(seen)
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--manifest',default='release-manifest.json');p.add_argument('--destination',default='.');p.add_argument('--archives',default='.');p.add_argument('--verify',action='store_true');a=p.parse_args()
 print('Verified files:',install(a.manifest,a.destination,a.archives,a.verify))
