import paramiko
import os
import pathlib
import shutil
import time


class zynq():
    def __init__(self,IP,SSH_PORT,SSH_USER,SSH_PWD,BASE_DIR_LOCAL,BASE_DIR_REMOTE):
        #IP
        self.IP=IP
        #SSH/SFTP
        self.SSH=None
        self.SFTP=None
        self.SSH_PORT=SSH_PORT
        self.SSH_USER=SSH_USER
        self.SSH_PWD=SSH_PWD
        #DIRECTORIES
        self.baseDirLocal=BASE_DIR_LOCAL
        self.baseDirRemote=BASE_DIR_REMOTE
        return
###############################################################################
    def sshConnect(self):
        self.SSH = paramiko.SSHClient()
        self.SSH.load_system_host_keys()
        self.SSH.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self.SSH.connect(self.IP, port=self.SSH_PORT,username=self.SSH_USER,password=self.SSH_PWD)
        self.SFTP = self.SSH.open_sftp()
        return
###############################################################################
    def sshDisconnect(self):
        self.SSH.close()
        return
###############################################################################
    def sshExecCommand(self,command):
        stdin, stdout,stderr=self.SSH.exec_command(command)
        stdoutContent=(stdout.read()).decode()
        stderrContent=(stderr.read()).decode()
        stderrContent=stderrContent.replace("[sudo] password for ubuntu: ","")
        if len(stdoutContent)>0:
            print("stdout: "+stdoutContent)
        if len(stderrContent)>0:
            print("stderr: "+stderrContent)
        return
###############################################################################
    def initbaseDirRemote(self):
        self.sshExecCommand("if ! test -d "+self.baseDirRemote+"; then mkdir " +self.baseDirRemote+"; fi ")
        return
###############################################################################
    def bootgen(self,arch,bitstreamPathBIT,bitstreamPathBIN): #Generate .bin file using bootgen
        #Create tempDir
        tempDir = "temp_{}".format(time.time())
        os.makedirs(tempDir)

        #Bootgen
        if arch=="zynq":
            f=open(os.path.join(tempDir,"Full_Bitstream.bif"),"wb+")
            f.write(("all:{"+str(pathlib.Path(bitstreamPathBIT).as_posix())+"}").encode())
            f.close()

            f=open(os.path.join(tempDir,"bootgen.tcl"),"wb+")
            f.write(("exec cmd /C bootgen -image "+str(pathlib.Path(tempDir,"Full_Bitstream.bif").as_posix())+" -arch zynq -w -process_bitstream bin").encode())
            f.close()
            
        elif arch=="zynqmp":
            f=open(os.path.join(tempDir,"Full_Bitstream.bif"),"wb+")
            f.write(("all:{[destination_device = pl] "+str(pathlib.Path(bitstreamPathBIT).as_posix())+"}").encode())
            f.close()

            f=open(os.path.join(tempDir,"bootgen.tcl"),"wb+")
            f.write(("exec cmd /C bootgen -image "+str(pathlib.Path(tempDir,"Full_Bitstream.bif").as_posix())+" -arch zynqmp -w -process_bitstream bin").encode())
            f.close()

        else:
            print("ERROR: arch should be zynq or zynqmp")
            return
        
        #Run bootgen
        os.system("vivado -mode batch -source "+str(pathlib.Path(tempDir,"bootgen.tcl").as_posix()))
        #Copy .bin to Resources
        shutil.copyfile(bitstreamPathBIT+".bin",bitstreamPathBIN)
        #Remove originally created .bin file
        os.remove(bitstreamPathBIT+".bin")
        #Clean Vivado .log and .jou files
        os.system("del *.jou *.log")
        #Clean temp folder
        shutil.rmtree(tempDir)
        return

###############################################################################
    def transferFile(self,filePathLocal,filePathRemote="auto"):
        if filePathRemote == "auto":
            filePathRemote = os.path.join(self.baseDirRemote,os.path.basename(filePathLocal))
        self.SFTP.put(filePathLocal,filePathRemote)
        return
###############################################################################
    def loadBitstream(self):
        self.sshExecCommand("echo "+self.SSH_PWD+" | sudo -S echo 0 > /sys/class/fpga_manager/fpga0/flags ;sudo cp "+os.path.join(self.baseDirRemote,"bitstream.bin")+" /lib/firmware/ ;sudo echo bitstream.bin > /sys/class/fpga_manager/fpga0/firmware")
        return
###############################################################################
    def executePython(self,filePath):
        self.sshExecCommand("echo "+self.SSH_PWD+" | sudo -S python3 "+os.path.join(self.baseDirRemote,filePath))
        return
###############################################################################
    def executeBash(self,filePath):
        self.sshExecCommand("echo "+self.SSH_PWD+" | sudo -S chmod +x "+os.path.join(self.baseDirRemote,filePath))
        self.sshExecCommand("cd " + self.baseDirRemote  + "; echo "+self.SSH_PWD + " | sudo -S ./" + filePath)
        return
