import os
import zynqUbuntuLIB


#PARAMETERS
IP = '192.168.1.200'
SSH_PORT =  22
SSH_USER = 'ubuntu'
SSH_PWD = 'temppwd'
BASE_DIR_LOCAL = os.path.dirname(os.path.realpath(__file__))
BASE_DIR_REMOTE = "/home/" + SSH_USER + "/MY_ZYNQ_PROJECT/"

BITSTREAM_BIT = os.path.join(os.path.dirname(os.path.realpath(__file__)),"pulseAcq.bit")
BITSTREAM_BIN = os.path.join(os.path.dirname(os.path.realpath(__file__)),"..","remote","bitstream.bin")

#INSTANTIATE ZYNQ 
zynq = zynqUbuntuLIB.zynq(IP,SSH_PORT,SSH_USER,SSH_PWD,BASE_DIR_LOCAL,BASE_DIR_REMOTE)

#CONFIGURE ZYNQ
zynq.bootgen("zynq",BITSTREAM_BIT,BITSTREAM_BIN)
zynq.sshConnect()
zynq.initbaseDirRemote()

zynq.transferFile(BITSTREAM_BIN)
#zynq.transferFile("testScript.py")
zynq.transferFile("../remote/runme.sh")
zynq.transferFile("../remote/pulseAcqLib.cpp")
zynq.transferFile("../remote/pulseAcqLib.h")
zynq.transferFile("../remote/pulseAcqTest.cpp")
zynq.transferFile("../remote/makefile")

zynq.loadBitstream()
#zynq.executePython("testScript.py")
zynq.executeBash("runme.sh")

zynq.sshDisconnect()