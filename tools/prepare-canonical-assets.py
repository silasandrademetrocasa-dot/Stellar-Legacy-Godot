from PIL import Image
from pathlib import Path
import json
root=Path(__file__).resolve().parents[1];out=root/'public/assets';sources=root/'art-source/canonical';sources.mkdir(parents=True,exist_ok=True)
paths={'ships-a':'exec-b55327a0-2318-4149-80fd-41fbc09e2751.png','ships-b':'exec-a452e06f-cabb-48fd-be76-9a6cc591d278.png','ships-c':'exec-515ffdf8-6d39-4197-bff0-253d42f4de30.png','npcs-a':'exec-510a4b63-dffc-4203-bd2f-b658d9d73598.png','npcs-b':'exec-6018f1a7-a101-4e19-86ce-629d7364ba70.png','npcs-c':'exec-e2cde823-f48f-4f6d-a873-2a793a2936b9.png','maps':'exec-42d278e5-a9a5-4f1b-867e-8ae6e9195781.png','directions':'exec-29da3873-fbb7-4b64-a20d-b77fe9dd8112.png','designers':'exec-17013a87-a74c-43c1-96a0-596a62aac5bb.png','protocols':'exec-b6decdc2-62b2-4385-bcce-729bf4eab3a5.png','drone-designers':'exec-832298f0-6ba2-4ba8-a73a-5ebfb93936b7.png','stations':'exec-146c2758-f4f3-4b85-b75b-66e991f57774.png'}
for name,path in paths.items():
 if not (sources/(name+'.png')).exists():raise FileNotFoundError('Fonte de arte ausente: '+name)
data=json.loads((root/'src/content/canonical.json').read_text());manifest=json.loads((out/'manifest.json').read_text());manifest['assets']=[a for a in manifest['assets'] if not a['path'].startswith('canonical/')]
def alpha(image):
 image=image.convert('RGBA');pixels=list(image.getdata());image.putdata([(r,g,b,0 if max(r,g,b)<10 else min(255,round((max(r,g,b)-10)*255/14))) for r,g,b,a in pixels]);return image
def tile(name,index,cols=4,rows=4,transparent=True):
 im=Image.open(sources/(name+'.png'));w,h=im.size;box=(round(index%cols*w/cols),round(index//cols*h/rows),round((index%cols+1)*w/cols),round((index//cols+1)*h/rows));im=im.crop(box);return alpha(im) if transparent else im

def save(im,path,id,size):
 path='canonical/'+path;manifest['assets']=[a for a in manifest['assets'] if a['path']!=path];dest=out/path;dest.parent.mkdir(parents=True,exist_ok=True);im=im.resize(size,Image.Resampling.LANCZOS);im.save(dest,'WEBP',quality=88,method=6);manifest['assets'].append({'id':id,'path':path,'width':im.width,'height':im.height,'frameCount':1,'pivot':[.5,.5]})
for category,prefix in [('naves','ships'),('npcs','npcs')]:
 for i,r in enumerate([r for r in data if r['category']==category]):
  im=tile(prefix+'-'+['a','b','c'][i//16],i%16)
  save(im,f'{prefix}/{r["code"]}.webp',r['code']+'-art',(256,256))
  save(im,f'lod1/{prefix}/{r["code"]}.webp',r['code']+'-lod1',(192,192))
  save(im,f'lod2/{prefix}/{r["code"]}.webp',r['code']+'-lod2',(128,128))
map_records=[r for r in data if r['category']=='mapas']
old=Image.open(root/'art-source/backgrounds.png')
for i,r in enumerate(map_records):
 im=old.crop((0,0,old.width//3,old.height)) if i==0 else old.crop((2*old.width//3,0,old.width,old.height)) if i==13 else tile('maps',i-1,3,4,False)
 save(im,f'maps/{r["code"]}.webp',r['code']+'-art',(768,768))
 save(im,f'lod1/maps/{r["code"]}.webp',r['code']+'-lod1',(512,512))
 save(im,f'lod2/maps/{r["code"]}.webp',r['code']+'-lod2',(384,384))
for i in range(8):save(tile('directions',i,4,2),f'directions/{i}.webp','aurora-front-'+str(i),(256,256))
for i,name in enumerate(['aurora-default','aurora-solar','aurora-stellar','aurora-industrial','pioneer-default','pioneer-solar','pioneer-stellar','pioneer-industrial','halo-default','halo-solar','nova-stellar','aux-spare','aux-default','aux-solar','aux-stellar','aux-industrial']):save(tile('designers',i),f'designers/{name}.webp',name+'-designer',(256,256))
for tier in range(3):
 for family in range(5):save(tile('protocols',tier*5+family,5,3),f'protocols/{family}-{tier+1}.webp',f'protocol-{family}-{tier+1}',(128,128))
for row,model in enumerate(['halo','nova']):
 for col,design in enumerate(['default','solar','stellar','industrial']):save(tile('drone-designers',row*4+col,4,2),f'designers/{model}-{design}.webp',f'{model}-{design}-designer',(256,256))
for i,faction in enumerate(['terra-alliance','mars-dominion','jupiter-federation']):save(tile('stations',i,3,1),f'stations/{faction}.webp',f'station-{faction}',(384,384))
# Pack only the primitives still used by the cumulative DOM scene.
registry={};names=['station','drone0','drone1','aux','portal','lootbox']+[f'ore{i}' for i in range(5)];atlas=Image.new('RGBA',(1024,768))
for i,name in enumerate(names):
 x=i%4*256;y=i//4*256;im=Image.open(out/'sprites'/f'{name}.png').convert('RGBA').resize((256,256),Image.Resampling.LANCZOS);atlas.alpha_composite(im,(x,y));registry[name]={'x':x,'y':y,'width':256,'height':256}
atlas.save(out/'sprites/atlas.png',optimize=True);(out/'sprites/atlas.json').write_text(json.dumps(registry))
obsolete={f'sprites/ship{i}.png' for i in range(5)}|{f'sprites/enemy{i}.png' for i in range(6)}
for path in obsolete:(out/path).unlink(missing_ok=True)
manifest['assets']=[a for a in manifest['assets'] if a['path'] not in obsolete]
for a in manifest['assets']:
 if a['id']=='scene-atlas':a.update(width=1024,height=768,frameCount=11)
manifest['version']=3;(out/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2));print(len(manifest['assets']),'assets catalogados')
