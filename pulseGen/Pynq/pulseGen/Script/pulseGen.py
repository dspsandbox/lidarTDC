import time
import sys
from pynq import Overlay, MMIO, allocate
from pynq import MMIO
import numpy as np
ol = Overlay("pulseGen.bit")

GPIO_ADDRESS=0x41200000
GPIO_RANGE=0x10000
DMA_ADDRESS=0x40400000
DMA_RANGE=0x10000
PULSE_DURATION=5

counterList=np.arange(100,50000,10)
timestampList=[0,]*len(counterList)
maskList=[1,]*len(counterList)

counterList=np.arange(100,50000,10)
timestampList=np.array(timestampList)
maskList=np.array(maskList)

class PulseGen():
    def __init__(self,GPIO_ADDRESS,GPIO_RANGE,DMA_ADDRESS,DMA_RANGE):
        self.gpio = MMIO(GPIO_ADDRESS, GPIO_RANGE)
        self.dma = MMIO(DMA_ADDRESS, DMA_RANGE)
        self.gpioDataOut=0
        
    def setResetn(self,val):
        mask=0b11111111111111111111111110
        self.gpioDataOut=(self.gpioDataOut & mask) | (val << 0)
        self.gpio.write(0, self.gpioDataOut)
        return
    def setTrig(self,val):
        mask=0b11111111111111111111111101
        self.gpioDataOut=(self.gpioDataOut & mask) | (val << 1)
        self.gpio.write(0, self.gpioDataOut)
        return
    def setPulseDuration(self,val):
        mask=0b00000000000000000000000011
        self.gpioDataOut=(self.gpioDataOut & mask) | (val << 2)
        self.gpio.write(0, self.gpioDataOut)
        return
    def getState(self):
        return self.gpio.read(0x0008)
        
    def dmaIsIdle(self):
        isIdle=bool(self.dma.read(0x4) & (1<<1))
        return isIdle
    
    def dmaConfig(self,bufferAddress):
        self.dma.write(0x18,bufferAddress)
        return
    
    def dmaRun(self,bufferBytesLen):
        self.dma.write(0x28,bufferLen)
        return
    
    def dmaStart(self):
        self.dma.write(0x0,(1<<16)|1)
        return 
    
    def dmaStop(self):
        self.dma.write(0x0,0)
        return 

    
pulseGen=PulseGen(GPIO_ADDRESS,GPIO_RANGE,DMA_ADDRESS,DMA_RANGE)      



bufferLen=len(counterList)
bufferType=np.uint64

bufferAux=[]
for i in range(bufferLen):
        bufferAux+=[(maskList[i]<<32)| (timestampList[i]<<24) | counterList[i]]
bufferAux=np.array(bufferAux,dtype=bufferType)

buffer = allocate(bufferLen, dtype=bufferType)
bufferAddress=buffer.physical_address
bufferBytesLen=buffer.nbytes

pulseGen.setPulseDuration(PULSE_DURATION)
pulseGen.dmaStart()
pulseGen.dmaConfig(bufferAddress)


tList=[]
t=time.time()
for i in range(0,1000000):   
    np.copyto(buffer,bufferAux)
    pulseGen.setResetn(1)
    pulseGen.dmaRun(bufferBytesLen)
    pulseGen.setTrig(1)
    pulseGen.setTrig(0)
    while(not(pulseGen.dmaIsIdle())): pass
    pulseGen.setResetn(0)
    tList+=[time.time()-t]
    t=time.time()
    
print("Mean: {:.3f} ms   Std: {:.3f} ms   Min: {:.3f} ms   Max: {:.3f} ms".format(np.mean(tList)*1e3,np.std(tList)*1e3,min(tList)*1e3,max(tList)*1e3))
    
  
