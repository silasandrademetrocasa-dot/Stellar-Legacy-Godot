import {describe,it,expect} from 'vitest';
import {graphicsProfiles,renderResolution} from '../content/graphics';
import {PerformanceMeter} from '../presentation/performance';
describe('mobile workload and optional diagnostics',()=>{
 it('low and medium actually reduce resolution, simultaneous effects and frame cap',()=>{const l=graphicsProfiles.low,m=graphicsProfiles.medium,h=graphicsProfiles.high;expect(l.effects).toBeLessThan(m.effects);expect(m.effects).toBeLessThan(h.effects);expect(l.impacts).toBe(false);expect(m.impacts).toBe(true);expect(m.fps).toBe(30);expect(h.fps).toBe(60);expect(renderResolution('low',3,1920,1080)).toBeLessThan(renderResolution('medium',3,1920,1080));expect(renderResolution('medium',3,1920,1080)).toBeLessThan(renderResolution('high',3,1920,1080));});
 it('caps pixel fill workload and never exceeds device DPR',()=>{for(const q of ['low','medium','high'] as const){const r=renderResolution(q,3,3840,2160);expect(r*r*3840*2160).toBeLessThanOrEqual(graphicsProfiles[q].pixels+1);expect(renderResolution(q,.5,800,400)).toBeLessThanOrEqual(.5);}});
 it('counts slow real frame intervals rather than clamping them to 100ms',()=>{const meter=new PerformanceMeter();meter.frame(1000);meter.frame(1200);meter.frame(1400);meter.frame(1600);expect(meter.fps).toBe(5);expect(meter.p95).toBe(200);meter.reset();expect(meter.samples).toHaveLength(0);meter.frame(10000);expect(meter.samples).toHaveLength(0);});
});
