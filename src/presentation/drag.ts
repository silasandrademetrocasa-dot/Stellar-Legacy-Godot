/** One captured pointer, shared by flight map and radar. Camera transform stays live while held. */
export class MapDrag {
  pointer:number|null=null;client:{x:number;y:number}|null=null;
  constructor(element:HTMLElement,enabled:()=>boolean,down:(x:number,y:number)=>boolean,move:(x:number,y:number)=>void,cancel:()=>void=()=>{}){
    const update=(e:PointerEvent)=>{this.client={x:e.clientX,y:e.clientY};move(e.clientX,e.clientY);};
    element.addEventListener('pointerdown',e=>{if(this.pointer!==null||e.button!==0||!enabled())return;if(!down(e.clientX,e.clientY))return;this.pointer=e.pointerId;element.setPointerCapture(e.pointerId);update(e);e.preventDefault();});
    element.addEventListener('pointermove',e=>{if(e.pointerId===this.pointer)update(e);});
    const end=(e:PointerEvent)=>{if(e.pointerId!==this.pointer)return;this.pointer=null;this.client=null;if(e.type!=='pointerup')cancel();};
    element.addEventListener('pointerup',end);element.addEventListener('pointercancel',e=>{end(e);});element.addEventListener('lostpointercapture',end);
    window.addEventListener('blur',()=>this.reset());
  }
  reset(){this.pointer=null;this.client=null;}
}
