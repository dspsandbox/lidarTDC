import mmap
import time

def writeAxi32(addr,val):
    with open("/dev/mem", "w+b") as f:
        offsetCoarse=int(addr/mmap.PAGESIZE)*mmap.PAGESIZE
        offsetFine=addr%mmap.PAGESIZE
        mm = mmap.mmap(f.fileno(),mmap.PAGESIZE,offset=offsetCoarse)
        mm.seek(offsetFine)
        mm.write(val.to_bytes(4, byteorder = 'little'))
        mm.close()
    return

def readAxi32(addr):
    with open("/dev/mem", "w+b") as f:
        offsetCoarse=int(addr/mmap.PAGESIZE)*mmap.PAGESIZE
        offsetFine=addr%mmap.PAGESIZE
        mm = mmap.mmap(f.fileno(),mmap.PAGESIZE,offset=offsetCoarse)
        mm.seek(offsetFine)
        data=mm.read(4)
        mm.close()
    return int.from_bytes(data,byteorder='little')


state = True

for i in range(0,10):
    writeAxi32(0x41200000, int(state))
    print(i, state)
    state = not(state)
    time.sleep(1)