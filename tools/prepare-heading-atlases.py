"""Technical raster atlas assembly from existing original art; eight compass headings."""
from pathlib import Path
from PIL import Image
import json
root=Path(__file__).resolve().parents[1];assets=root/'public/assets/canonical';ships=[r for r in json.loads((root/'src/content/canonical.json').read_text()) if r['category']=='naves'];dest=assets/'heading';dest.mkdir(exist_ok=True)
for index,r in enumerate(ships):
 sources=[(r['code'],assets/'ships'/f'{r["code"]}.webp',225 if index<16 else 180)]
 if r['code'] in ['aurora','pioneer']:
  sources += [(r['code']+'-'+skin,assets/'designers'/f'{r["code"]}-{skin}.webp',180) for skin in ['solar','stellar','industrial']]
 for name,path,base in sources:
  art=Image.open(path).convert('RGBA');sheet=Image.new('RGBA',(512,256))
  for i in range(8):
   frame=art.rotate(base-i*45,Image.Resampling.BICUBIC,expand=True);frame.thumbnail((112,112),Image.Resampling.LANCZOS);sheet.alpha_composite(frame,(i%4*128+(128-frame.width)//2,i//4*128+(128-frame.height)//2))
  sheet.save(dest/(name+'.webp'),'WEBP',quality=85,method=6)
print('Prepared',len(list(dest.glob('*.webp'))),'eight-heading raster atlases')
