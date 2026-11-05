"""Produce a full final release with disjoint ordinary ZIPs, each <=24,000,000 bytes."""
from pathlib import Path
import hashlib,json,subprocess,zipfile,zlib,shutil
root=Path(__file__).resolve().parents[1];out=root.parent/'stellar-final-1.0.0';out.mkdir(exist_ok=True)
skip={'.git','node_modules','dist','dist-pages','test-results','playwright-report','__pycache__'}
files={}
for p in sorted(root.rglob('*')):
 rel=p.relative_to(root)
 if p.is_file() and not any(x in skip for x in rel.parts) and p.suffix.lower() not in {'.zip','.pyc'} and str(rel) not in {'index.html','release-manifest.json','.stellar-installed.json'}:files[rel.as_posix()]=p
for p in sorted((root/'dist').rglob('*')):
 if p.is_file():files[p.relative_to(root/'dist').as_posix()]=p
sha=lambda b:hashlib.sha256(b).hexdigest()
# Partition by actual compressed payload plus a conservative per-entry ZIP overhead.
bins=[];current=[];size=0
for name,p in sorted(files.items(),key=lambda kv:(0 if kv[0] in {'index.html','sw.js'} or kv[0].startswith('assets/') else 1,kv[0])):
 data=p.read_bytes();compressed=len(zlib.compress(data,6))+len(name.encode())*2+256
 if compressed>23500000:raise ValueError('Individual asset too large: '+name)
 if current and size+compressed>23500000:bins.append(current);current=[];size=0
 current.append((name,p));size+=compressed
if current:bins.append(current)
parts=[];entries=[]
for index,group in enumerate(bins,1):
 name='STELLAR_OFFLINE_v1.0.0_FINAL_COMPLETO.zip' if len(bins)==1 else f'STELLAR_OFFLINE_v1.0.0_FINAL_PARTE_{index:02}_DE_{len(bins):02}.zip'
 target=out/name
 with zipfile.ZipFile(target,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  for path,p in group:
   data=p.read_bytes();z.writestr(path,data);entries.append({'path':path,'part':name,'bytes':len(data),'sha256':sha(data)})
 assert target.stat().st_size<=24000000
 with zipfile.ZipFile(target) as z:assert z.testzip() is None
 parts.append({'order':index,'name':name,'bytes':target.stat().st_size,'sha256':sha(target.read_bytes()),'files':len(group)})
revision=subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip()
manifest={'format':1,'version':'1.0.0','revision':revision,'maximumPartBytes':24000000,'totalFiles':len(entries),'parts':parts,'files':entries,'validation':{'reconstruction':'Run tools/install-release.py then npm ci, lint, test, build and Pages/offline smoke in an empty directory; see VALIDACAO_RECONSTRUCAO.txt delivered beside this manifest.'}}
(out/'release-manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
for source,name in [(root/'README.md','LEIA-ME_INSTALACAO.md'),(root/'MANIFEST_ENTREGA_FINAL.md','MANIFEST_ENTREGA_FINAL.md'),(root/'.github/workflows/stellar-legacy.yml','stellar-legacy.yml'),(root/'tools/install-release.py','install-release.py')]:shutil.copyfile(source,out/name)
print(json.dumps({'directory':str(out),'files':len(entries),'parts':parts},indent=2))
