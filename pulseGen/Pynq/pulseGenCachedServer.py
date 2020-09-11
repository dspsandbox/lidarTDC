import time
import sys
from pynq import Overlay, MMIO, allocate
from pynq import MMIO
import numpy as np
import socket
import os
ol = Overlay("pulseGen.bit")

####################################################
# Parameters
####################################################
# Physical addresses
GPIO_ADDRESS=0x41200000
GPIO_RANGE=0x10000
DMA_ADDRESS=0x40400000
DMA_RANGE=0x10000

TCP_IP = sys.argv[1]
TCP_PORT = int(sys.argv[2])
TIMEOUT = 0.1
CACHE_DIR = "cache"

#Pulse parameters
PULSE_WIDTH=2 # In units of 10ns

#DMA buffer size
bufferLen64=10000         #buffer len 64bit
bufferLen8=8*bufferLen64  #buffer len 8bit

####################################################
# Func/class definitions
####################################################
class PulseGen():
    def __init__(self,GPIO_ADDRESS,GPIO_RANGE,DMA_ADDRESS,DMA_RANGE):
        self.gpio = MMIO(GPIO_ADDRESS, GPIO_RANGE)
        self.dma = MMIO(DMA_ADDRESS, DMA_RANGE)
        self.gpioDataOut=0
        return
        
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
    def setPulseWidth(self,val):
        mask=0b00000000000000000000000011
        self.gpioDataOut=(self.gpioDataOut & mask) | (val << 2)
        self.gpio.write(0, self.gpioDataOut)
        return
    def getState(self):
        return self.gpio.read(0x0008) & 0b111
    
    def getStreamDownCounter(self):
        return (self.gpio.read(0x0008) >> 3)
        
    def dmaMM2SIsIdle(self):
        isIdle=bool(self.dma.read(0x4) & (1<<1))
        return isIdle
    
    def dmaMM2SConfig(self,bufferAddress):
        self.dma.write(0x18,bufferAddress)
        return
    
    def dmaMM2SRun(self,bufferBytesLen):
        self.dma.write(0x28,bufferBytesLen)
        return
    
    def dmaMM2SReset(self):
        self.dma.write(0x0,(1<<2))
        return
    
    def dmaMM2SHalt(self):
        self.dma.write(0x0,0)
        return 
    
    def dmaMM2SStart(self):
        self.dma.write(0x0,1)
        return
        
        
def recvData(conn):
    dataLen8=conn.recv(4)
    dataLen8 = int.from_bytes(dataLen8,byteorder="little")
    data="".encode()
    while(len(data)!=dataLen8):
        data += conn.recv(dataLen8-len(data))
    return (data,dataLen8)

def recvParamList(conn,numberOfParam):
    paramList=[]
    for i in range(0,numberOfParam):
        paramList+=[int.from_bytes(conn.recv(4),byteorder="little")]
    return paramList

####################################################
# Instantiations and memory allocations
####################################################
pulseGen=PulseGen(GPIO_ADDRESS,GPIO_RANGE,DMA_ADDRESS,DMA_RANGE)      

#Dual buffer structure for simultaneus DMA and file operations
buffer0 = allocate(bufferLen64, dtype=np.uint64)
bufferAddress0=buffer0.physical_address
buffer1 = allocate(bufferLen64, dtype=np.uint64)
bufferAddress1=buffer1.physical_address
bufferList=[buffer0,buffer1]
bufferAddressList=[bufferAddress0,bufferAddress1]

if not(os.path.isdir(CACHE_DIR)): os.makedirs(CACHE_DIR)
####################################################
# Server
####################################################
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((TCP_IP, TCP_PORT))
s.listen(1)                                                              
while(1):
    s.settimeout(None)                                                       #Infinite timeout for waiting for client 
    print("Waiting for client connection request.")
    conn, addr = s.accept()                                                  #Wait for client
    print("Connection to client {} established.".format(addr))
    s.settimeout(TIMEOUT)                                                    #User defined timeout for data tx/rx.
    
    #Transfer parameters
    ITERATIONS,PULSE_WIDTH,PERIOD = recvParamList(conn,numberOfParam=3)
    
    #Transfer cache, i.e. save locally the pulse sequences to be executed
    t=time.time()
    for i in range(0,ITERATIONS):
        data,dataLen8=recvData(conn)
        filepath=os.path.join(CACHE_DIR, "seq_{:06d}.txt".format(i))
        f=open(filepath,"wb+")
        f.write(data)
        f.close()
    print("Cache transfer completed in {:.3f} ms.".format((time.time()-t)*1000))
    
    #Config and reset
    pulseGen.setPulseWidth(PULSE_WIDTH)
    pulseGen.setResetn(1)                                                     #Enable pulse generator core
    
    #Run pulse sequences
    for i in range(0,ITERATIONS):
        if i>0:
            while((time.time()-t)*1000<PERIOD): pass                          #Halt execution to match period
        else:
            t=time.time()
        print("{:03d}  t: {:.3f} ms".format(i,(time.time()-t)*1000))
        t=time.time()
        
        #1st iteration requires to read data before running DMA 
        if i==0:
            filepath=os.path.join(CACHE_DIR, "seq_{:06d}.txt".format(i))
            f=open(filepath,"rb")
            data=f.read()
            f.close()
            dataLen8=len(data)
            dataLen64=int(dataLen8/8)
            np.copyto(bufferList[0][:dataLen64],np.frombuffer(data,dtype=np.uint64))  #Copy data to DMA buffer[0]
            dataLen64_0=dataLen64                                                     #Save datalen8 of first iteration 
            
        # Restart, configure and run DMA engine
        pulseGen.dmaMM2SHalt()
        pulseGen.dmaMM2SReset()
        pulseGen.dmaMM2SStart()
        pulseGen.dmaMM2SConfig(bufferAddressList[i%2])                                #DMA reads from buffer[modulo2(i)]
        pulseGen.dmaMM2SRun(dataLen8)                                            
        
        pulseGen.setTrig(1)                                                           #Set trigger HIGH (starts pulse generator core)
        pulseGen.setTrig(0)                                                           #Set trigger LOW
        
        #Read next data while pulse generator is running
        if i < (ITERATIONS-1):                                                 
            filepath=os.path.join(CACHE_DIR, "seq_{:06d}.txt".format(i+1))
            f=open(filepath,"rb")
            data=f.read()
            f.close()
            dataLen8=len(data)           
            dataLen64=int(dataLen8/8)
            np.copyto(bufferList[(i+1)%2][:dataLen64],np.frombuffer(data,dtype=np.uint64))  #Copy data to DMA buffer[mudulo2(i+1)]
            
        while(pulseGen.getState()==(1<<1)): pass                                            #Wait for pulse generator to finish
        
        #Get info and rise error message if state is not 1 (idle) or streamDownCounter is different to dataLen64
        streamDownCounter = pulseGen.getStreamDownCounter()                   
        state=pulseGen.getState()
        if state!= (1<<0) or (i==0 and dataLen64_0 !=streamDownCounter) or (i>0 and dataLen64 !=streamDownCounter)   :
            print("Error. state: {} downStreamCounter: {}".format(state,streamDownCounter))
            break
        
    pulseGen.setResetn(0)                                                                    #Disable pulse generator core    
    conn.close()
    print("Connection to client closed.")
