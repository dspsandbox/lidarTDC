import os
import numpy as np

sequenceTxDir="seq/tx"
sequenceRxDir="seq/rx"

ITERATIONS=10000
SAMPLES=1000
COUNTER_MIN=5
COUNTER_MAX=200000  #2.0ms
COUNTER_MIN_STEP=4  #40ns min spacing between pulses 


for i in range(0,ITERATIONS):
    counterList=np.cumsum(np.random.rand(SAMPLES))
    counterList=np.floor(counterList * COUNTER_MAX / counterList[-1])   #Normalize to max length
    counterList=COUNTER_MIN+counterList+np.cumsum(COUNTER_MIN_STEP*np.ones(SAMPLES))   
    counterList = np.array(counterList,dtype=np.int64)

    timestampList=SAMPLES*[i%256]

    maskList=np.floor(1+255*np.random.rand(SAMPLES))
    maskList=np.array(maskList,dtype=np.int64)

    data=np.zeros(SAMPLES,dtype=np.int64)
    for j in range(0,SAMPLES):
        data[j] = (maskList[j]<<32) | (timestampList[j]<<24) | (counterList[j]<<0) 
    f=open(os.path.join(sequenceTxDir,"seq_{:06d}.txt".format(i)),"wb+")
    f.write(data.tobytes())
    f.close()

