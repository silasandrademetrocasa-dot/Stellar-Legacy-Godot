"""Contract tests: incomplete/corrupt sets never mutate an old checkout."""
import importlib.util,json,hashlib,tempfile,zipfile
from pathlib import Path
spec=importlib.util.spec_from_file_location('installer',Path(__file__).with_name('install-release.py'));module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
sha=lambda b:hashlib.sha256(b).hexdigest()
with tempfile.TemporaryDirectory() as temp:
 root=Path(temp);old=root/'old';old.mkdir();(old/'index.html').write_text('old');(old/'keep.txt').write_text('unrelated');(old/'assets').mkdir();(old/'assets/stale.js').write_text('stale');parts=root/'parts';parts.mkdir();files=[];pmeta=[]
 for i,(name,data) in enumerate([('index.html',b'new'),('src/game.ts',b'new source')]):
  p=parts/f'arbitrary-upload-{i}.zip'
  with zipfile.ZipFile(p,'w') as z:z.writestr(name,data)
  pmeta.append({'name':f'part-{i}.zip','bytes':p.stat().st_size,'sha256':sha(p.read_bytes())});files.append({'path':name,'bytes':len(data),'sha256':sha(data),'part':f'part-{i}.zip'})
 manifest=root/'release-manifest.json';manifest.write_text(json.dumps({'format':1,'version':'test','revision':'test','files':files,'parts':pmeta}))
 missing=parts/'arbitrary-upload-1.zip';saved=missing.read_bytes();missing.unlink()
 try:module.install(manifest,old,parts);raise AssertionError('accepted missing part')
 except ValueError:pass
 assert (old/'index.html').read_text()=='old'
 missing.write_bytes(saved+b'corrupt')
 try:module.install(manifest,old,parts);raise AssertionError('accepted corrupt part')
 except ValueError:pass
 assert (old/'index.html').read_text()=='old'
 missing.write_bytes(saved);assert module.install(manifest,old,parts)==2
 assert (old/'index.html').read_text()=='new' and (old/'src/game.ts').exists() and (old/'keep.txt').read_text()=='unrelated' and not (old/'assets/stale.js').exists()
 module.install(manifest,old,parts);assert (old/'index.html').read_text()=='new'
 print('PASS: arbitrary ZIP names, full overwrite, old managed-asset removal, unrelated-file preservation, missing/corrupted-part rejection before mutation, repeat installation.')
