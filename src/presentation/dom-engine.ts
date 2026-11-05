/** Raster sprite compositor. No Canvas, WebGL, SVG gameplay or drawing context. */
export const RendererType={DOM:'dom'};
export class Rectangle{constructor(public x:number,public y:number,public width:number,public height:number){}}
type ImageSource={url:string;width:number;height:number;image?:HTMLImageElement};
export class Texture{
 static EMPTY=new Texture({source:{url:'',width:1,height:1}});
 source:ImageSource;frame:Rectangle;
 constructor(options:{source:ImageSource;frame?:Rectangle}){this.source=options.source;this.frame=options.frame||new Rectangle(0,0,options.source.width,options.source.height);}
 get width(){return this.frame.width;}get height(){return this.frame.height;}
}
const images=new Map<string,Promise<Texture>>();
export function releaseDecodedExcept(urls:Set<string>){for(const key of images.keys())if(!urls.has(key))images.delete(key);}
export const Assets={async load<T=Texture>(url:string):Promise<T>{if(!images.has(url))images.set(url,(async()=>{const image=new Image();image.decoding='async';image.src=url;await image.decode();return new Texture({source:{url,width:image.naturalWidth,height:image.naturalHeight,image}});})());return await images.get(url)! as T;}};
class Vector{constructor(public x=0,public y=0){}set(x:number,y=x){this.x=x;this.y=y;}}
export class Container{
 element=document.createElement('div');position=new Vector();scale=new Vector(1,1);rotation=0;children:Container[]=[];parent?:Container;visible=true;alpha=1;zIndex=0;_destroyed=false;
 constructor(){this.element.className='space-container';}
 addChild(...children:Container[]){for(const child of children){if(child.parent===this)continue;child.removeFromParent();child.parent=this;this.children.push(child);this.element.append(child.element);}return children[0];}
 removeFromParent(){if(this.parent){this.parent.children=this.parent.children.filter(c=>c!==this);this.parent=undefined;}this.element.remove();}
 destroy(){this._destroyed=true;this.removeFromParent();for(const child of [...this.children])child.destroy();}
 protected styleCache=new Map<string,string>();
 style(key:string,value:string){if(this.styleCache.get(key)!==value){this.styleCache.set(key,value);this.element.style.setProperty(key,value);}}
 sync(){this.style('display',this.visible?'':'none');if(!this.visible)return;this.style('transform',`translate3d(${this.position.x}px,${this.position.y}px,0) scale(${this.scale.x},${this.scale.y}) rotate(${this.rotation}rad)`);this.style('opacity',String(this.alpha));for(const child of this.children)child.sync();}
}
export class Sprite extends Container{
 anchor=new Vector();width:number;height:number;tint=0xffffff;private sourceUrl='';private ghost?:HTMLElement;private fade?:Animation;
 constructor(public texture=Texture.EMPTY){super();this.element.className='space-sprite';this.width=texture.width;this.height=texture.height;}
 override sync(){this.style('display',this.visible?'':'none');if(!this.visible)return;
  const f=this.texture.frame,source=this.texture.source,sx=this.width/f.width,sy=this.height/f.height;
  this.style('width',`${this.width}px`);this.style('height',`${this.height}px`);
  this.style('transform',`translate3d(${this.position.x-this.width*this.anchor.x}px,${this.position.y-this.height*this.anchor.y}px,0) rotate(${this.rotation}rad)`);
  this.style('transform-origin',`${this.anchor.x*100}% ${this.anchor.y*100}%`);
  if(this.sourceUrl!==source.url){if(this.sourceUrl&&this.element.classList.contains('ship-visual')){this.fade?.cancel();this.ghost?.remove();const ghost=document.createElement('div');ghost.style.cssText='position:absolute;inset:0;pointer-events:none;background-repeat:no-repeat';ghost.style.backgroundImage=this.element.style.backgroundImage;ghost.style.backgroundSize=this.element.style.backgroundSize;ghost.style.backgroundPosition=this.element.style.backgroundPosition;this.element.append(ghost);this.ghost=ghost;this.fade=ghost.animate([{opacity:1},{opacity:0}],{duration:140,fill:'forwards'});this.fade.onfinish=()=>ghost.remove();}this.sourceUrl=source.url;this.style('background-image',source.url?`url("${source.url}")`:'none');}
  this.style('background-size',`${source.width*sx}px ${source.height*sy}px`);this.style('background-position',`${-f.x*sx}px ${-f.y*sy}px`);this.style('opacity',String(this.alpha));
 }
}
export class Application{
 stage=new Container();surface=document.createElement('div');screen={width:1,height:1};renderer={type:RendererType.DOM,resolution:1};private callback?:(ticker:{deltaMS:number})=>void;private frame=0;private previous=0;private next=0;private requested=0;
 ticker={maxFPS:60,add:(callback:(t:{deltaMS:number})=>void)=>{this.callback=callback;this.requested=requestAnimationFrame(t=>this.loop(t));}};
 async init(options:{resizeTo:HTMLElement;resolution:number;[key:string]:unknown}){
  this.surface.className='space-scene';this.surface.tabIndex=0;this.surface.setAttribute('role','application');this.surface.append(this.stage.element);this.renderer.resolution=options.resolution;
  const resize=()=>{this.screen.width=options.resizeTo.clientWidth;this.screen.height=options.resizeTo.clientHeight;};resize();new ResizeObserver(resize).observe(options.resizeTo);
 }
 private loop(now:number){this.requested=requestAnimationFrame(t=>this.loop(t));if(document.hidden){this.previous=now;return;}const frameTime=1000/this.ticker.maxFPS;if(this.previous&&now+.75<this.next)return;const deltaMS=this.previous?now-this.previous:frameTime;this.previous=now;this.next=this.next?this.next+frameTime:now+frameTime;if(this.next<now-frameTime||this.next>now+frameTime*2)this.next=now+frameTime;this.callback?.({deltaMS});this.stage.sync();this.frame++;}
 destroy(){cancelAnimationFrame(this.requested);this.stage.destroy();this.surface.remove();}
}
