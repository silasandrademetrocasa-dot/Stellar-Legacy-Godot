"""Technical raster atlas assembly from existing original art; eight compass headings."""
from pathlib import Path
from PIL import Image
import json
root=Path(__file__).resolve().parents[1];assets=root/'public/assets/canonical';ships=[r for r in json.loads((root/'src/content/canonical.json').read_text()) if r['category']=='naves'];dest=assets/'heading';dest.mkdir(exist_ok=True)
for index,r in enumerate(ships):
 sources=[(r['code'],assets/'ships'/f'{r["code"]}.webp',0)]
 if r['code'] in ['aurora','pioneer']:
  sources += [(r['code']+'-'+skin,assets/'designers'/f'{r["code"]}-{skin}.webp',0) for skin in ['solar','stellar','industrial']]
 for name,path,base in sources:
  art=Image.open(path).convert('RGBA');art.thumbnail((104,104),Image.Resampling.LANCZOS);baseframe=Image.new('RGBA',(128,128));baseframe.alpha_composite(art,((128-art.width)//2,(128-art.height)//2));sheet=Image.new('RGBA',(512,256))
  for i in range(8):
   frame=baseframe.rotate(base-i*45,Image.Resampling.BICUBIC,expand=False);sheet.alpha_composite(frame,(i%4*128,i//4*128))
  sheet.save(dest/(name+'.webp'),'WEBP',quality=85,method=2)
print('Prepared',len(list(dest.glob('*.webp'))),'eight-heading raster atlases')
