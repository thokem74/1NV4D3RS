"""Generate original deterministic synth assets using Python's standard library."""
import math, random, struct, wave
from pathlib import Path
RATE=22050
OUT=Path(__file__).resolve().parents[1]/'assets/audio'
OUT.mkdir(parents=True,exist_ok=True)
def save(name,data,loop=False):
 with wave.open(str(OUT/(name+'.wav')),'wb') as f:
  f.setnchannels(1); f.setsampwidth(2); f.setframerate(RATE)
  f.writeframes(b''.join(struct.pack('<h',int(max(-1,min(1,v))*26000)) for v in data))
rng=random.Random(94)
for name,freq,end,length,noise in [('shoot',1200,400,.09,0),('hit',180,55,.12,.3),('explosion',100,25,.42,.7),('pickup',400,1300,.28,0),('dash',140,900,.2,.2),('warning',240,180,.6,.1)]:
 data=[]; phase=0
 for i in range(int(RATE*length)):
  t=i/RATE; u=t/length; phase+=2*math.pi*(freq+(end-freq)*u)/RATE
  data.append((math.sin(phase)*(1-noise)+rng.uniform(-1,1)*noise)*(1-u)**2*.55)
 save(name,data)
# Eight bars at 120 BPM, seamless 16 second arrangement.
length=16; data=[0.0]*int(RATE*length)
notes=[40,40,47,52,43,43,50,55,36,36,43,48,38,38,45,50]
for step in range(64):
 start=int(step*.25*RATE); midi=notes[(step//4)%16]+(12 if step%4==3 else 0)
 freq=440*2**((midi-69)/12)
 for j in range(int(.24*RATE)):
  t=j/RATE; env=min(1,t/.008)*math.exp(-t*15)
  data[start+j]+=(math.sin(2*math.pi*freq*t)+.25*math.sin(4*math.pi*freq*t))*.16*env
 if step%2==0:
  for j in range(int(.18*RATE)):
   t=j/RATE; data[start+j]+=.25*math.sin(2*math.pi*(42*t+7*(1-math.exp(-t*35))))*math.exp(-t*25)
 for j in range(int(.045*RATE)):
  t=j/RATE; data[start+j]+=rng.uniform(-1,1)*.045*math.exp(-t*80)
 if step%4==2:
  for j in range(int(.11*RATE)):
   t=j/RATE; data[start+j]+=rng.uniform(-1,1)*.09*math.exp(-t*30)
save('music',data)
