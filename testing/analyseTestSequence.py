import os
import numpy as np
import time
from datetime import datetime

######################################
# Parameters
######################################
sequenceTxDir="seq/tx"
sequenceRxDir="seq/rx"

ITERATIONS = 10000
CHANNELS = 8
CORRELATION_RANGE = (0,10)

REPORT_PATH="REPORT.txt"
######################################
# Func definitions
######################################
def correlate(list1,list2,corrRange):
    corr=[]
    list1=np.array(list1)
    list2=np.array(list2)
    for i in range(corrRange[0],corrRange[1]):
        corr+=[np.sum((list1+i)==list2)]
    return corr

######################################
# Populate TX/RX pulse list
######################################

pulseListTx=eval("["+"[],"*CHANNELS+"]")
pulseListRx=eval("["+"[],"*CHANNELS+"]")

for i in range(0,ITERATIONS):
    
    filepathTx=os.path.join(sequenceTxDir, "seq_{:06d}.txt".format(i))
    f=open(filepathTx,"rb")
    dataTx=f.read()
    f.close()
    dataTx=np.frombuffer(dataTx,dtype=np.int64)
    
    for j in range(0,len(dataTx)):
        timestampAndCounterTx = (dataTx[j] >>0) & 0xffffffff
        maskTx = (dataTx[j]>>32) & 0xffffffff
        for k in range(0,CHANNELS):
            if (maskTx & (1<<k)) != 0:
                pulseListTx[k]+=[timestampAndCounterTx] 


    filepathRx=os.path.join(sequenceRxDir, "seq_{:06d}.txt".format(i))
    f=open(filepathRx,"rb")
    dataRx=f.read()
    f.close()
    dataRx=np.frombuffer(dataRx,dtype=np.int64)

    for j in range(0,len(dataRx)):
        timestampAndCounterRx = (dataRx[j] >>0) & 0xffffffff
        maskRx=                 (dataRx[j]>>32) & 0xffffffff
        for k in range(0,CHANNELS):
            if (maskRx & (1<<k)) != 0:
                pulseListRx[k]+=[timestampAndCounterRx] 


txtstr="------------------------------------------\n"
txtstr+="RX/TX REPORT {}\n".format(datetime.fromtimestamp(time.time()))
txtstr+="------------------------------------------\n"
txtstr+="GENERAL PARAMETERS:\n"
txtstr+="---> Iterations: {}\n".format(ITERATIONS)
txtstr+="---> Channels: {}\n".format(CHANNELS)
txtstr+="---> Correlation range: {}\n".format(CORRELATION_RANGE)

for i in range(0,CHANNELS):
    
    txtstr+="\n"
    txtstr+="CHANNEL: {}\n".format(i)
    txtstr+="---> Tx pulses: {}\n".format(len(pulseListTx[i]))
    txtstr+="---> Rx pulses: {}\n".format(len(pulseListRx[i]))
    if len(pulseListTx[i])==len(pulseListRx[i]):
        corr=correlate(pulseListTx[i],pulseListRx[i],CORRELATION_RANGE)
    else:
        corr="TX/RX have incompatible lengths"
    txtstr+="---> Correlation: {}\n".format(corr)

f=open(REPORT_PATH,"w+")
f.write(txtstr)
f.close()
print(txtstr)