# lidarTDC
## System requirements
* Time-to-digital converter (TDC) for atmospheric Lidar applications
* Temporal resolution <= 10 ns 
* Integration time >= 2 ms
* Multiple input ports (N >= 5)
* Trigger input
* 8 bit temporal timestamp prefix
* External ref clk (10MHz)

## System architecture
![System architecture](doc/lidarTDC.png)
* **Central Control System**. Central control, orchestration and analysis unit. Configures peripheral devices via ethernet.
* **Cora-Z7-10**. Digilent low cost development board (see [here](https://store.digilentinc.com/cora-z7-zynq-7000-single-core-and-dual-core-options-for-arm-fpga-soc-development)) featuring a Xilinx Zynq 7010 SoC FPGA, 1Gbps Ethernet PHY, RAM memory, USB hub, 45 Arduino compatible IOs (3.3V CMOS)...
* **Zynq7010 FPGA**. System on a chip. Contains a 32bit-ARM processing system (PS) and programable logic (PL). 
* **RAM**. 512MB DDR3 memory. Accessible to both PS and PL (via DMA).
* **Python Server**. Devoted to the configuration/operation of the PL. It is has direct access to the data stored in the RAM memory. Communication with the Central Control System is performed over the 1Gbps etherent PHY.  
 * **FSM**. Finite state machine implementing the TDC logic. Minimum pulse width: 5ns (use IDDR to sample at both edges of 100 MHz clk and OR gate the outputs Q1 and Q2). Temporal resolution: 10ns (rising edge of 100 MHz clk). Minimum pulse separation: 20 ns. 64bit time stamping: 
    * 23-00 : counter (max integration time: 167 ms).
    * 31-24 : external timestamp. 
    * 63-32 : mask (used to mark the inputs on which a rising edge has been detected). Max number of detectors: 32.
* **PLL**. Phase lock loop. 
* **DMA**. Direct memory access. Streams 64bit timestamps from FSM to RAM. 

## Getting started
1. Download the SD card image [Pynq-Cora-Z7-10-2.5.img](https://drive.google.com/file/d/1jq1uyC-ckTANllmxDi5jF78LoCh2kb4u/view?usp=sharing). 

2. Write SD card image. For instruction see [here](https://pynq.readthedocs.io/en/v2.5.1/appendix.html#writing-the-sd-card-image).

3. Configure jumper J2 of the Cora-Z7 board for microSD card boot. Further information is available in the [Cora-Z7 reference manual](https://reference.digilentinc.com/reference/programmable-logic/cora-z7/reference-manual).  

4. Power up the device and connect it to your ethernet router/switch.

5. Find the IP address of the device. This is most easily achieved by entering the configuration panel of your router or by using a network scanning tool.

6. SSH into your Cora-Z7-10 (usr: xilinx pwd: xilinx):
```
ssh xilinx@X.X.X.X
```
where *X.X.X.X* is the IP address found in the previous step.

7. Change the etherent settings to use a static IP address.  
```
sudo vi /etc/network/interfaces.d/eth0
```
And change the *eth0* interface configuration to
```
auto eth0
iface eth0 inet dhcp 
          
auto eth0:1
iface eth0:1 inet static
address Y.Y.Y.Y
netmask Z.Z.Z.Z
```
where *Y.Y.Y.Y* is the new static IP and *Z.Z.Z.Z* the netmask.

8. Power off/on the device. 
