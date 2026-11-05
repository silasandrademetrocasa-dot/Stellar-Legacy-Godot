export type Quality = 'low' | 'medium' | 'high';
export const graphicsProfiles = {
  low: {label:'Baixo · desempenho',fps:30,dpr:0.75,pixels:650_000,effects:3,effectFps:8,effectLife:0.32,impacts:false,collect:false,parallax:0,hudMs:350},
  medium: {label:'Médio · equilibrado',fps:30,dpr:1,pixels:1_100_000,effects:10,effectFps:10,effectLife:0.5,impacts:true,collect:true,parallax:0.45,hudMs:250},
  high: {label:'Alto · qualidade',fps:60,dpr:2,pixels:4_000_000,effects:28,effectFps:12,effectLife:0.65,impacts:true,collect:true,parallax:1,hudMs:150},
} as const;
export function renderResolution(quality:Quality,dpr:number,width:number,height:number){const p=graphicsProfiles[quality];return Math.min(dpr,p.dpr,Math.sqrt(p.pixels/Math.max(1,width*height)));}
