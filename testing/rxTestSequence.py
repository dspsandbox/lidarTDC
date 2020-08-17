import os
import numpy as np
import time
import socket

######################################
# Parameters
######################################
sequenceTxDir="seq/tx"
sequenceRxDir="seq/rx"

TCP_IP = '192.168.1.200'
TCP_PORT = 6001
TIMEOUT=10

ITERATIONS = 10000
COUNTER_MAX = 250000    #2.5ms

#####################################
# Func/class definitions
#####################################
def recvData(conn):
    dataLen8=conn.recv(4)
    dataLen8 = int.from_bytes(dataLen8,byteorder="little")
    data="".encode()
    while(len(data)!=dataLen8):
        data += conn.recv(dataLen8-len(data))
    return (data,dataLen8)

def sendParamList(paramList,conn):
    for param in paramList:
        conn.sendall((param).to_bytes(4,byteorder="little"))
    return 

#####################################
# TX DATA
#####################################
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((TCP_IP, TCP_PORT))
s.settimeout(TIMEOUT)

sendParamList([ITERATIONS,COUNTER_MAX],s)
print("Please run txTestSequence. Timeout: {:.1f} s".format(TIMEOUT))
for i in range(0,ITERATIONS):
    data,_=recvData(s)
    if i==0: t=time.time()
    filepath=os.path.join(sequenceRxDir, "seq_{:06d}.txt".format(i))
    f=open(filepath,"wb")
    f.write(data)
    f.close()
    print("RX: {} t: {:.3f} ms".format(i,(time.time()-t)*1000))
    t=time.time()
s.close()