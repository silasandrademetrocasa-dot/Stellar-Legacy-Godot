from pathlib import Path
import re,json,unicodedata
root=Path(__file__).resolve().parents[1];text=(root/'docs/GDD_ENTREGA_UNICA.md').read_text()
def table(heading):
 block=text.split(heading,1)[1].split('\n### ',1)[0]
 rows=[]
 for line in re.search(r'(?m)^\|.*(?:\n\|.*)*',block).group().splitlines():
  if line.startswith('|'):
   cells=[x.strip() for x in line.strip('|').split('|')]
   if not all(set(x)<=set('-: ') for x in cells):rows.append(cells)
 return rows[1:]
def number(s):
 if s in ['None','—','']:return None
 m=re.search(r'[\d.]+',s)
 return int(m.group().replace('.','')) if m else None
records=[]
for group in ['faccoes','naves','equipamentos','municao laser','misseis','recursos','npcs','npcs futuros','mapas']:
 block=text.split('## '+group+' — ',1)[1].split('\n## ',1)[0]
 for row in block.splitlines():
  if not row.startswith('|') or '`' not in row:continue
  cells=[x.strip() for x in row.strip('|').split('|')];name,code,category,cost=cells
  price=number(cost);future=group=='npcs futuros';locked='EVENTO' in category or (price==0 and group not in ['faccoes','naves'])
  records.append({'name':name,'code':code.strip('`'),'category':group,'role':category,'currency':'stellarium' if 'STL' in cost else 'credits','referencePrice':price,'labPrice':max(1,price) if price else 0,'status':'FUTURO' if future else 'EVENTO' if locked else 'ADAPTAR','attributes':{}})
byname={r['name']:r for r in records}
for row in table('### 07.1 '):
 name,role,hp,lasers,gen,speed,cargo,extra,cost,markers=row
 r=byname[name];r['attributes']={'hp':number(hp),'lasers':number(lasers),'generators':number(gen),'speed':number(speed),'cargo':number(cargo),'extras':number(extra),'markers':markers};r['status']='EVENTO' if 'Evento' in markers else 'INICIAL' if name=='Aurora' else 'ADAPTAR'
for row in table('### 07.2 '):
 name,cls,attrs,cost,rule=row;r=byname[name];r['attributes']={'class':cls,'description':attrs};r['status']='EVENTO' if 'Evento' in rule or 'Exclusivo' in cost else 'BLOQUEADO' if 'indisponível' in rule else 'ADAPTAR'
 for key,pattern in [('damage',r'Dano: (\d+)'),('speed',r'Vel\.: (\d+)'),('shield',r'Escudo: (\d+)'),('slots',r'Slots: (\d+)'),('cargo',r'Porão \+: (\d+)'),('absorption',r'Absorção: (\d+)')]:
  m=re.search(pattern,attrs)
  if m:r['attributes'][key]=int(m[1])
for row in table('### 07.3 '):
 name,kind,effect,pack,cost=row;r=byname[name];r['attributes']={'multiplier':number(effect) if kind=='Laser' else 1,'drain':name=='SIP-2','damage':number(effect) if kind=='Míssil' else 0,'quantity':number(pack)}
for row in table('### 07.4 '):
 r=byname[row[0]];r['attributes']={'sellReference':number(row[1]),'sell':round((number(row[1]) or 0)*.001)}
for heading in ['### 07.5 ','### 07.6 ']:
 for row in table(heading):
  r=byname[row[0]];r['attributes']={k:number(v) for k,v in zip(['hp','shield','damage','xp','credits','stellarium'],row[1:7])}
  if heading=='### 07.5 ':r['attributes']['drops']=row[7]
for row in table('### 07.7 '):
 name,tier,risk,size,ore,pop,portals=row;r=byname[name];width,height=[int(n) for n in size.split('×')];r['attributes']={'tier':int(tier),'risk':risk,'width':width,'height':height,'ore':ore,'population':pop,'portals':portals}
assert len(records)==177,len(records)
(root/'src/content/canonical.json').write_text(json.dumps(records,ensure_ascii=False,indent=2))
print('177 registros canônicos importados com preços e atributos de referência.')
