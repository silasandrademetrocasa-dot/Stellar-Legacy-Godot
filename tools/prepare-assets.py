"""Technical asset pipeline: grid slicing, black matte alpha extraction, resize, manifest.
No game art is painted procedurally. Sources were produced with image_gen.
"""
from PIL import Image
from pathlib import Path
import json, shutil, wave, math, struct, random
root=Path(__file__).resolve().parents[1]; assets=root/'public/assets';(assets/'sprites').mkdir(exist_ok=True)
sources={name:root/'art-source'/f'{name}.png' for name in ['ships','backgrounds','vfx','ui']}
manifest=[]
def save(im,path,id,**extra):
 im.save(assets/path,optimize=True);manifest.append({'id':id,'path':str(path),'width':im.width,'height':im.height,'pivot':[.5,.5],'frameCount':1,**extra})
def alpha(im):
 im=im.convert('RGBA');pixels=list(im.getdata());im.putdata([(r,g,b,0 if max(r,g,b)<12 else min(255,round((max(r,g,b)-12)*255/16))) for r,g,b,a in pixels]);return im
im=Image.open(sources['ships']);w,h=im.size;names=['ship0','ship1','ship2','ship3','ship4','enemy0','enemy1','enemy2','enemy3','enemy4','enemy5','station','drone0','drone1','aux','portal']
for i,name in enumerate(names):
 tile=alpha(im.crop((round(i%4*w/4),round(i//4*h/4),round((i%4+1)*w/4),round((i//4+1)*h/4)))).resize((256,256),Image.Resampling.LANCZOS);save(tile,Path('sprites')/(name+'.png'),name)
im=Image.open(sources['backgrounds']);w,h=im.size
for i,name in enumerate(['blue','red','industrial']):save(im.crop((i*w//3,0,(i+1)*w//3,h)).resize((768,1152),Image.Resampling.LANCZOS),Path('backgrounds')/(name+'.webp'),name)
im=alpha(Image.open(sources['vfx'])).resize((1024,1024),Image.Resampling.LANCZOS);save(im,Path('effects/vfx.png'),'vfx',frameCount=64,columns=8,rows=8,fps=12)
im=Image.open(sources['ui']);w,h=im.size
ui=['ore0','ore1','ore2','ore3','ore4','laser','shield','engine','credits','stellarium','medkit','ammo','lyra','nilo','logo','frame']
for i,name in enumerate(ui):
 tile=alpha(im.crop((round(i%4*w/4),round(i//4*h/4),round((i%4+1)*w/4),round((i//4+1)*h/4))))
 if name.startswith('ore'):save(tile.resize((128,128)),Path('sprites')/(name+'.png'),name)
 elif name in ['lyra','nilo']:save(tile.resize((256,256)),Path('portraits')/(name+'.png'),name)
 elif name=='logo':
  for size in [192,512]:
   # Opaque app tile; generated insignia centered with safe padding for Android mask.
   bg=Image.new('RGBA',(size,size),(7,18,31,255));logo=tile.resize((round(size*.72),round(size*.72)),Image.Resampling.LANCZOS);bg.alpha_composite(logo,((size-logo.width)//2,(size-logo.height)//2));save(bg,Path('icons')/f'icon-{size}.png',f'icon-{size}')
 elif name=='frame':save(tile.resize((128,128)),Path('items/frame.png'),'frame')
 else:save(tile.resize((128,128)),Path('items')/(name+'.png'),name)
for name in ['drone0','drone1','aux']:
 shutil.copyfile(assets/'sprites'/f'{name}.png',assets/'items'/f'{name}.png');manifest.append({'id':f'item-{name}','path':f'items/{name}.png','width':256,'height':256,'frameCount':1,'pivot':[.5,.5]})
# Generated crate and shared sprite atlas: technical packing of existing raster art.
crate=Image.open(root/'art-source/lootbox.png').convert('RGBA')
box=crate.getchannel('A').point(lambda a:255 if a>32 else 0).getbbox()
if box:
 crate=crate.crop(box)
crate.thumbnail((210,210),Image.Resampling.LANCZOS)
canvas=Image.new('RGBA',(256,256));canvas.alpha_composite(crate,((256-crate.width)//2,(256-crate.height)//2))
save(canvas,Path('sprites/lootbox.png'),'lootbox')
packed=names+['lootbox'];atlas=Image.new('RGBA',(1024,1280));registry={}
for i,name in enumerate(packed):
 x=(i%4)*256;y=(i//4)*256
 atlas.alpha_composite(Image.open(assets/'sprites'/f'{name}.png').convert('RGBA'),(x,y))
 registry[name]={'x':x,'y':y,'width':256,'height':256}
save(atlas,Path('sprites/atlas.png'),'scene-atlas',frameCount=len(packed))
(assets/'sprites/atlas.json').write_text(json.dumps(registry))
manifest.append({'id':'scene-atlas-registry','path':'sprites/atlas.json','frameCount':0})
# Original offline PCM sound synthesis is allowed for AUDIO, never used for game images.
sr=22050;random.seed(104)
for name,duration in [('shot',.15),('impact',.12),('explosion',.65),('reward',.6),('ui',.08),('engine',.4),('ambient',12)]:
 samples=[];low=0
 for i in range(round(sr*duration)):
  t=i/sr;v=0;decay=max(0,1-t/duration)
  if name=='shot':v=math.sin(2*math.pi*(1400*t-2800*t*t))*.27*decay**2
  elif name=='impact':v=(random.random()*2-1)*.27*decay**3
  elif name=='explosion':
   low=low*.85+(random.random()*2-1)*.15;v=low*.8*decay**1.5
  elif name=='reward':v=math.sin(2*math.pi*[523.25,659.25,783.99][min(2,int(t*5))]*t)*.17*math.sin(math.pi*t/duration)
  elif name=='ui':v=math.sin(2*math.pi*850*t)*.13*decay
  elif name=='engine':v=(math.sin(2*math.pi*65*t)+math.sin(2*math.pi*130*t))*.07*math.sin(math.pi*t/duration)
  else:v=(math.sin(2*math.pi*55*t)+.4*math.sin(2*math.pi*82.5*t)+.2*math.sin(2*math.pi*110*t))*.11*(.7+.3*math.sin(2*math.pi*t/12))
  samples.append(struct.pack('<h',round(max(-1,min(1,v))*32767)))
 path=assets/'audio'/f'{name}.wav'
 with wave.open(str(path),'wb') as wav:wav.setnchannels(1);wav.setsampwidth(2);wav.setframerate(sr);wav.writeframes(b''.join(samples))
 manifest.append({'id':name+'-audio','path':'audio/'+name+'.wav','duration':duration,'sampleRate':sr})
(assets/'manifest.json').write_text(json.dumps({'version':2,'license':'Original AI-generated visual assets for this project; original synthesized audio. See docs/ARTE_E_ASSETS.md','assets':manifest},indent=2))
print(f'{len(manifest)} assets prepared; sources preserved in art-source')
