import os
import numpy as np
import time
import socket

######################################
# Parameters
######################################
sequenceTxDir="seq/tx"
sequenceRxDir="seq/rx"

TCP_IP = '192.168.1.199'
TCP_PORT = 6000
TIMEOUT=1

ITERATIONS = 10000
PULSE_WIDTH = 1 #10ns
PERIOD = 4 #4ms

#####################################
# Func/class definitions
#####################################
def sendData(data,conn):
    dataLen8=len(data)
    conn.sendall((dataLen8).to_bytes(4,byteorder="little"))
    conn.sendall(data)
    return

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


sendParamList([ITERATIONS,PULSE_WIDTH,PERIOD],s)
t=time.time()
for i in range(0,ITERATIONS):
    print("TX (cache transfer): {}    t: {:.3f} ms".format(i,(time.time()-t)*1000))
    t=time.time()
    filepath=os.path.join(sequenceTxDir, "seq_{:06d}.txt".format(i))
    f=open(filepath,"rb")
    data=f.read()
    f.close()
    sendData(data,s)

s.close()