/** Raw rendered-frame intervals, including slow frames (never ticker delta's clamp). */
export class PerformanceMeter {
  samples:number[]=[];total=0;last=0;updated=0;fps=0;frameMs=0;p95=0;p50=0;p99=0;sceneMs=0;
  reset(){this.samples=[];this.total=0;this.last=0;this.updated=0;this.fps=0;this.frameMs=0;this.p95=0;this.p50=0;this.p99=0;this.sceneMs=0;}
  frame(now:number){
    if(this.last){const ms=now-this.last;if(ms>0){this.samples.push(ms);this.total++;if(this.samples.length>120)this.samples.shift();}}
    this.last=now;
    if(now-this.updated>=500&&this.samples.length){
      this.updated=now;this.frameMs=this.samples.reduce((a,b)=>a+b,0)/this.samples.length;this.fps=1000/this.frameMs;
      const sorted=[...this.samples].sort((a,b)=>a-b);this.p95=sorted[Math.ceil(sorted.length*.95)-1];this.p50=sorted[Math.ceil(sorted.length*.5)-1];this.p99=sorted[Math.ceil(sorted.length*.99)-1];
    }
  }
  scene(ms:number){this.sceneMs=this.sceneMs?this.sceneMs*.9+ms*.1:ms;}
}
