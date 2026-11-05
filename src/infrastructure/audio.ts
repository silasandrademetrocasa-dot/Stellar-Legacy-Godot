export class Sound{
 context?:AudioContext;buffers=new Map<string,AudioBuffer>();volume=0.35;musicVolume=0.15;music?:AudioBufferSourceNode;gain?:GainNode;
 async start(){if(!this.context)this.context=new AudioContext();await this.context.resume();for(const id of ['shot','impact','explosion','reward','ui','engine','ambient']){if(!this.buffers.has(id)){const response=await fetch(`${import.meta.env.BASE_URL}assets/audio/${id}.wav`);this.buffers.set(id,await this.context.decodeAudioData(await response.arrayBuffer()));}}
 if(!this.music){this.music=this.context.createBufferSource();this.music.buffer=this.buffers.get('ambient')||null;this.music.loop=true;this.gain=this.context.createGain();this.gain.gain.value=this.musicVolume;this.music.connect(this.gain).connect(this.context.destination);this.music.start();}}
 play(id:string){if(!this.context||this.context.state!=='running'||!this.buffers.has(id))return;const source=this.context.createBufferSource(),gain=this.context.createGain();source.buffer=this.buffers.get(id)||null;gain.gain.value=this.volume;source.connect(gain).connect(this.context.destination);source.start();}
 set(sfx:number,music:number){this.volume=sfx;this.musicVolume=music;if(this.gain)this.gain.gain.value=music;}
}
