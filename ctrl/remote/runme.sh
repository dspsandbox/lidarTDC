#!/bin/bash

#Load bitstream
echo 0 > /sys/class/fpga_manager/fpga0/flags 
cp bitstream.bin /lib/firmware/
echo bitstream.bin > /sys/class/fpga_manager/fpga0/firmware

#Compile script
make  

#Run script
./pulseAcqTest


