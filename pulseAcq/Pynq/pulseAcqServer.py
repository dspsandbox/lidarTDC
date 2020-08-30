import time
import sys
from pynq import Overlay, MMIO, allocate
from pynq import MMIO
import numpy as np
import socket
ol = Overlay("pulseAcq.bit")

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

#DMA buffer size
bufferLen64=10000         #buffer len 64bit
bufferLen8=8*bufferLen64  #buffer len 8bit


####################################################
# Func/class definitions
####################################################
class PulseAcq():
    def __init__(self,GPIO_ADDRESS,GPIO_RANGE,DMA_ADDRESS,DMA_RANGE):
        self.gpio = MMIO(GPIO_ADDRESS, GPIO_RANGE)
        self.dma = MMIO(DMA_ADDRESS, DMA_RANGE)
        self.gpioDataOut=0
        return
        
    def setResetn(self,val):
        mask=0b1111111111111111111111110
        self.gpioDataOut=(self.gpioDataOut & mask) | (val << 0)
        self.gpio.write(0, self.gpioDataOut)
        return

    def setCounterMax(self,val):
        mask=0b0000000000000000000000001
        self.gpioDataOut=(self.gpioDataOut & mask) | (val << 1)
        self.gpio.write(0, self.gpioDataOut)
        return
    def getState(self):
        return self.gpio.read(0x0008) & 0b111
    
    def getStreamUpCounter(self):
        return (self.gpio.read(0x0008) >> 3)
        
    def dmaS2MMIsIdle(self):
        isIdle=bool(self.dma.read(0x34) & (1<<1))
        return isIdle
    
    def dmaS2MMConfig(self,bufferAddress):
        self.dma.write(0x48,bufferAddress)
        return
    
    def dmaS2MMRun(self,bufferBytesLen):
        self.dma.write(0x58,bufferBytesLen)
        return
    
    def dmaS2MMReset(self):
        self.dma.write(0x30,(1<<2))
        return
    
    def dmaS2MMHalt(self):
        self.dma.write(0x30,0)
        return 
    
    def dmaS2MMStart(self):
        self.dma.write(0x30,1)
        return

def sendData(data,conn):
    dataLen8=len(data)
    conn.sendall((dataLen8).to_bytes(4,byteorder="little"))
    conn.sendall(data)
    return

def recvParamList(conn,numberOfParam):
    paramList=[]
    for i in range(0,numberOfParam):
        paramList+=[int.from_bytes(conn.recv(4),byteorder="little")]
    return paramList

####################################################
# Instantiations and memory allocations
####################################################
pulseAcq=PulseAcq(GPIO_ADDRESS,GPIO_RANGE,DMA_ADDRESS,DMA_RANGE)      

#Dual buffer structure for simultaneus DMA and TCP operations
buffer0 = allocate(bufferLen64, dtype=np.uint64)
bufferAddress0=buffer0.physical_address
buffer1 = allocate(bufferLen64, dtype=np.uint64)
bufferAddress1=buffer1.physical_address
bufferList=[buffer0,buffer1]
bufferAddressList=[bufferAddress0,bufferAddress1]


####################################################
# Server
####################################################
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((TCP_IP, TCP_PORT))
s.listen(1)
while(1):
    s.settimeout(None)                                                       #Infinite timeout for waiting for
    print("Waiting for client connection request.")
    conn, addr = s.accept()                                                  #Wait for client
    print("Connection to client {} established.".format(addr))
    s.settimeout(TIMEOUT)                                                    #User defined timeout for data tx/rx.
    
    #Transfer parameters
    ITERATIONS,COUNTER_MAX=recvParamList(conn,numberOfParam=2)               
   
    #Config and reset
    pulseAcq.setCounterMax(COUNTER_MAX)
    pulseAcq.setResetn(0)                                                    #Disable pulse acquisition core
    pulseAcq.setResetn(1)                                                    #Enable pulse acquisition core
    
    #Run acquisition
    for i in range(0,ITERATIONS):
        # Restart, configure and run DMA engine
        pulseAcq.dmaS2MMHalt()
        pulseAcq.dmaS2MMReset()
        pulseAcq.dmaS2MMStart()
        pulseAcq.dmaS2MMConfig(bufferAddressList[(i+1)%2])                   #DMA writes into buffer[modulo2(i+1)]
        pulseAcq.dmaS2MMRun(bufferLen8)                  
        
        #For all iterations except first previous data are sent while pulse acquisistion is running
        if i>0:
            data=(bufferList[i%2][:streamUpCounter]).tobytes()               #Get bytes string of buffer[modulo2(i)]
            sendData(data,conn)                                                                                   

        while(not(pulseAcq.dmaS2MMIsIdle())): pass                           #Wait for pulse acquisition to finsh
        if i==0: t=time.time()
        print("{:03d}  t: {:.3f} ms".format(i,(time.time()-t)*1000))
        t=time.time()
        
        #Get info and rise error message if state is not 1 (idle)
        state = pulseAcq.getState()
        streamUpCounter = pulseAcq.getStreamUpCounter()  
        if state != (1<<0):
            print("Error. state: {} streamUpCounter: {}".format(state,streamUpCounter))
            break
            
        #Additional data transfer for last iteration 
        if i==(ITERATIONS-1):
            data=(bufferList[(i+1)%2][:streamUpCounter]).tobytes()           #Get bytes string of buffer[modulo2(i+1)]
            sendData(data,conn)       
        
        
    conn.close()
    print("Connection to client closed.")

