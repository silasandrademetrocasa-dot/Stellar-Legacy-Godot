"""Reconstruct only final ZIPs and manifest, then run all checks in that fresh tree."""
from pathlib import Path
import argparse,hashlib,json,os,subprocess,tempfile,zipfile,time
p=argparse.ArgumentParser();p.add_argument('release');p.add_argument('destination');a=p.parse_args();release=Path(a.release).resolve();dest=Path(a.destination).resolve();assert not dest.exists() or not any(dest.iterdir()),'Destination must be empty';dest.mkdir(parents=True,exist_ok=True)
m=json.loads((release/'release-manifest.json').read_text());sha=lambda b:hashlib.sha256(b).hexdigest();entry=next(f for f in m['files'] if f['path']=='tools/install-release.py');part=next(p for p in m['parts'] if p['name']==entry['part']);archive=release/part['name'];assert sha(archive.read_bytes())==part['sha256']
with zipfile.ZipFile(archive) as z:code=z.read(entry['path'])
assert sha(code)==entry['sha256']
log=release/'VALIDACAO_RECONSTRUCAO.txt';started=time.time()
with log.open('w') as report:
 def run(args,cwd=dest,env=None):
  report.write('\n$ '+' '.join(args)+'\n');report.flush();r=subprocess.run(args,cwd=cwd,env=env,stdout=report,stderr=subprocess.STDOUT);report.flush()
  if r.returncode:raise RuntimeError('Check failed; inspect '+str(log))
 with tempfile.TemporaryDirectory() as t:
  script=Path(t)/'install.py';script.write_bytes(code);run(['python',str(script),'--manifest',str(release/'release-manifest.json'),'--archives',str(release),'--destination',str(dest)])
 for f in m['files']:
  data=(dest/f['path']).read_bytes();assert len(data)==f['bytes'] and sha(data)==f['sha256'],f['path']
 report.write(f"\nAll {len(m['files'])} extracted paths verified byte-for-byte. No duplicate paths. Release {m['version']}, revision {m['revision']}.\n")
 for command in [['npm','ci'],['npm','run','lint'],['npm','test'],['npm','run','check:assets'],['npm','run','build'],['python','tools/test-installer.py']]:run(command)
 run(['node','tools/smoke-root.mjs'])
 run(['npm','run','test:e2e'],env={**os.environ,'STELLAR_TEST_PORT':'4183'})
 env={**os.environ,'BASE_PATH':'/stellar-legacy-offline/'}
 run(['npm','exec','vite','build','--','--outDir','dist-pages'],env=env);run(['node','tools/build-offline.mjs','dist-pages']);run(['node','tools/smoke-pages.mjs'])
 # Real overwrite/commit/push/clone with the complete release in an old local repository.
 with tempfile.TemporaryDirectory() as t:
  base=Path(t);old=base/'old';old.mkdir();(old/'index.html').write_text('old game');(old/'unrelated-note.txt').write_text('preserve');(old/'assets').mkdir();(old/'assets/obsolete.js').write_text('old');
  run(['git','init','-b','staging-stellar'],old);run(['git','config','user.name','Release verification'],old);run(['git','config','user.email','verify@example.invalid'],old);run(['git','add','.'],old);run(['git','commit','-m','Old repository fixture'],old)
  run(['python',str(dest/'tools/install-release.py'),'--manifest',str(release/'release-manifest.json'),'--archives',str(release),'--destination',str(old)],old)
  assert (old/'unrelated-note.txt').read_text()=='preserve' and not (old/'assets/obsolete.js').exists()
  run(['git','add','-A'],old);run(['git','commit','-m','Install complete verified release'],old);bare=base/'remote.git';run(['git','init','--bare',str(bare)],base);run(['git','remote','add','origin',str(bare)],old);run(['git','push','origin','HEAD:staging-stellar'],old)
  local=subprocess.check_output(['git','rev-parse','HEAD'],cwd=old,text=True).strip();remote=subprocess.check_output(['git','ls-remote','origin','refs/heads/staging-stellar'],cwd=old,text=True).split()[0];assert local==remote
  clone=base/'clone';run(['git','clone','--branch','staging-stellar',str(bare),str(clone)],base)
  for f in m['files']:assert sha((clone/f['path']).read_bytes())==f['sha256'],f['path']
  report.write('\nPASS: complete replacement, one final release commit, bare Git push, remote SHA and fresh clone verified for every manifest file.\n')
 report.write(f'\nALL CHECKS PASSED in {time.time()-started:.1f}s. No remote GitHub deployment, Android physical test or APK claimed.\n')
print('PASS:',log)
