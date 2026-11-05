import {it,expect} from 'vitest';
import {compassFrame} from '../core/navigation';
it('selects all eight compass frames, including Bastion reverse headings',()=>{for(let i=0;i<8;i++)expect(compassFrame(i*Math.PI/4,(i+4)%8)).toBe(i);expect(compassFrame(-Math.PI/2,0)).toBe(6);expect(compassFrame(2*Math.PI,4)).toBe(0);});
it('keeps frames stable at octant boundaries',()=>{expect(compassFrame(24*Math.PI/180,0)).toBe(0);expect(compassFrame(32*Math.PI/180,0)).toBe(1);});
