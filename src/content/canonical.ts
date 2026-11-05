import data from './canonical.json' with {type:'json'};
export type CatalogRecord={name:string;code:string;category:string;role:string;currency:string;referencePrice:number|null;labPrice:number;status:string;attributes:Record<string,any>};
export const canonical=data as CatalogRecord[];
export const group=(name:string)=>canonical.filter(r=>r.category===name);
export const record=(code:string)=>canonical.find(r=>r.code===code)!;
export const canonicalResources=group('recursos');
export const canonicalShips=group('naves');
export const canonicalEquipment=group('equipamentos');
export const canonicalNpcs=group('npcs');
export const canonicalMaps=group('mapas');
export const plannedContent=group('npcs futuros');
export const labBalance={shopMultiplier:1,rewardMultiplier:1,resourceMultiplier:1,missileCooldown:6,farmHours:8,autopilotInterval:500};
export const resourceAliases:Record<string,string>={ferron:'ferro',cryon:'silicio',virel:'cobalto',ferrite:'titanio',solarium:'cristal',duracite:'duracite',voidite:'voidite'};
export const resourceKey=(code:string)=>resourceAliases[code]||code;
export const legacyShipCodes=['aurora','pioneer','bastion','valkyrie','sovereign'];
export const legacyItemCodes:Record<string,string>={laser1:'arc-1',laser2:'arc-p1',laser3:'arc-2',laser4:'arc-4',shield1:'vsh-1',shield2:'vsh-2',shield3:'aeg-1',shield4:'aeg-2',engine1:'thr-1',engine2:'thr-2',engine3:'thr-4',drone1:'halo',drone2:'nova',aux1:'aux-9',aux2:'aux-9',aux3:'aux-9'};
export const resolveShip=(id:string)=>legacyShipCodes[Number(id.replace('ship',''))]&&id.startsWith('ship')?legacyShipCodes[Number(id.replace('ship',''))]:id;
export const resolveItem=(id:string)=>legacyItemCodes[id]||id;
export function iconFor(r:CatalogRecord){return r.category==='naves'?`canonical/ships/${r.code}.webp`:r.category==='npcs'?`canonical/npcs/${r.code}.webp`:r.category==='npcs futuros'?`canonical/npcs/${canonicalNpcs.find(n=>r.code.startsWith(n.code))?.code||'scavenger'}.webp`:r.category==='mapas'?`canonical/maps/${r.code}.webp`:r.category==='recursos'?`sprites/ore${Math.max(0,canonicalResources.indexOf(r))%5}.png`:r.category==='faccoes'?'icons/icon-192.png':r.category==='municao laser'||r.category==='misseis'?'items/ammo.png':r.attributes.class==='laser'?'items/laser.png':r.attributes.class==='shield'?'items/shield.png':r.attributes.class==='speed'?'items/engine.png':r.code==='halo'?'sprites/drone0.png':r.code==='nova'?'sprites/drone1.png':'sprites/aux.png';}
