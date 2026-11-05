from pathlib import Path
from PIL import Image
import json,shutil
root=Path(__file__).resolve().parents[1];source=Path('/workspace/generated_images/exec-1c05e795-e8b4-42a8-a4f8-dcf02ea9caeb.png');original=root/'art-source/canonical/ships-topdown.png';shutil.copyfile(source,original);im=Image.open(original).convert('RGBA');records=[r for r in json.loads((root/'src/content/canonical.json').read_text()) if r['category']=='naves'];assets=root/'public/assets/canonical'
for i,r in enumerate(records):
 tile=im.crop((round(i%6*im.width/6),round(i//6*im.height/8),round((i%6+1)*im.width/6),round((i//6+1)*im.height/8)));alpha=tile.getchannel('A').point(lambda a:0 if a<140 else a);tile.putalpha(alpha);bbox=tile.getbbox();tile=tile.crop(bbox) if bbox else tile;tile.thumbnail((216,216),Image.Resampling.LANCZOS);master=Image.new('RGBA',(256,256));master.alpha_composite(tile,((256-tile.width)//2,(256-tile.height)//2))
 for folder,size in [('ships',256),('lod1/ships',192),('lod2/ships',128)]:master.resize((size,size),Image.Resampling.LANCZOS).save(assets/folder/(r['code']+'.webp'),'WEBP',quality=88,method=2)
 if r['code'] in ['aurora','pioneer']:
  for skin,mult in [('default',(1,1,1)),('solar',(1.25,1,.7)),('stellar',(.8,.9,1.25)),('industrial',(.95,1.15,.85))]:
   channels=master.split();colored=Image.merge('RGBA',tuple(channels[j].point(lambda n,m=mult[j]:min(255,round(n*m))) for j in range(3))+(channels[3],));colored.save(assets/'designers'/f'{r["code"]}-{skin}.webp','WEBP',quality=88,method=2)
print('Imported 43 orthographic top-down ship designs and compatible paint variants.')
