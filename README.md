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

## Initial setup
1. Download the SD card image [Pynq-Cora-Z7-10-2.5.img](https://drive.google.com/file/d/1jq1uyC-ckTANllmxDi5jF78LoCh2kb4u/view?usp=sharing). 

2. Write SD card image. For instruction see [here](https://pynq.readthedocs.io/en/v2.5.1/appendix.html#writing-the-sd-card-image).

3. Configure jumper J2 of the Cora-Z7 board for microSD card boot. Further information is available in the [Cora-Z7 reference manual](https://reference.digilentinc.com/reference/programmable-logic/cora-z7/reference-manual).  

4. Power up the device and connect it to your ethernet router/switch.

5. Find the automatically assigned IP address of the device. This is most easily achieved by entering the configuration panel of your router or by using a network scanning tool.

6. SSH into your Cora-Z7-10 (usr: xilinx pwd: xilinx):
```
ssh xilinx@<IP address>
```

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
address <static IP address>
netmask <netmask>
```

8. Power off/on the device. 

9. Create a network drive linked to the Samba file server running on your Pynq machine:

| File server property  | Value  | 
|---|---|
| url   | //<static IP address>/xilinx  | 
| usr   | xilinx | 
| pwd   | xilinx  | 

### pulseAcq

10. Using the file server, navigate to */xilinx/pynq/overlays/*.

11. Create a folder called */xilinx/pynq/overlays/pulseAcq* and copy in it the [pulseAcq.bit, pulseAcq.tcl and pulseAcq.hwh files](https://github.com/dspsandbox/lidarTDC/tree/master/pulseAcq/Pynq/pulseAcq).


12. Using the file server, navigate to */xilinx/jupyter_notebooks*.

13. Create a folder called */xilinx/jupyter_notebooks/pulseAcq* and copy in it the [pulseAcq.ipynb and pulseAcqServer.py files](https://github.com/dspsandbox/lidarTDC/tree/master/pulseAcq/Pynq).

### pulseGen
10. Using the file server, navigate to */xilinx/pynq/overlays/*.

11. Create a folder called *pynq/overlays/pulseGen* and copy in it the [pulseGen.bit, pulseGen.tcl and pulseGen.hwh files](https://github.com/dspsandbox/lidarTDC/tree/master/pulseGen/Pynq/pulseGen).

12. Using the file server, navigate to */xilinx/jupyter_notebooks*.

13. Create a folder called */xilinx/jupyter_notebooks/pulseGen* and copy in it the [pulseGen.ipynb, pulseGenServer.py and pulseGenCachedServer.py files](https://github.com/dspsandbox/lidarTDC/tree/master/pulseAcq/Pynq).

## Wiring and port assignements
### pulseAcq

|Pin|Direction|IO Standard|Description|
|---|---|---|---|
| 0 | In | LVCMOS 3.3V | Pulse channel 0 | 
| 1 | In | LVCMOS 3.3V | Pulse channel 1 | 
| 2 | In | LVCMOS 3.3V | Pulse channel 2 | 
| 3 | In | LVCMOS 3.3V | Pulse channel 3 | 
| 4 | In | LVCMOS 3.3V | Pulse channel 4 | 
| 5 | In | LVCMOS 3.3V | Pulse channel 5 | 
| 6 | In | LVCMOS 3.3V | Pulse channel 6 | 
| 7 | In | LVCMOS 3.3V | Pulse channel 7 | 
| 8 | In | LVCMOS 3.3V | Ref clk (10 MHz) | 
| 9 | In | LVCMOS 3.3V | Trig (rising edge) | 
| 26 | In | LVCMOS 3.3V | Timestamp bit 0 | 
| 27 | In | LVCMOS 3.3V | Timestamp bit 1 | 
| 28 | In | LVCMOS 3.3V | Timestamp bit 2 | 
| 29 | In | LVCMOS 3.3V | Timestamp bit 3 | 
| 30 | In | LVCMOS 3.3V | Timestamp bit 4 | 
| 31 | In | LVCMOS 3.3V | Timestamp bit 5 | 
| 32 | In | LVCMOS 3.3V | Timestamp bit 6 | 
| 33 | In | LVCMOS 3.3V | Timestamp bit 7 | 

### pulseGen 
|Pin|Direction|IO Standard|Description|
|---|---|---|---|
| 0 | Out | LVCMOS 3.3V | Pulse channel 0 | 
| 1 | Out | LVCMOS 3.3V | Pulse channel 1 | 
| 2 | Out | LVCMOS 3.3V | Pulse channel 2 | 
| 3 | Out | LVCMOS 3.3V | Pulse channel 3 | 
| 4 | Out | LVCMOS 3.3V | Pulse channel 4 | 
| 5 | Out | LVCMOS 3.3V | Pulse channel 5 | 
| 6 | Out | LVCMOS 3.3V | Pulse channel 6 | 
| 7 | Out | LVCMOS 3.3V | Pulse channel 7 | 
| 8 | Out | LVCMOS 3.3V | Ref clk (10 MHz) | 
| 9 | Out | LVCMOS 3.3V | Trig (rising edge) | 
| 26 | Out | LVCMOS 3.3V | Timestamp bit 0 | 
| 27 | Out | LVCMOS 3.3V | Timestamp bit 1 | 
| 28 | Out | LVCMOS 3.3V | Timestamp bit 2 | 
| 29 | Out | LVCMOS 3.3V | Timestamp bit 3 | 
| 30 | Out | LVCMOS 3.3V | Timestamp bit 4 | 
| 31 | Out | LVCMOS 3.3V | Timestamp bit 5 | 
| 32 | Out | LVCMOS 3.3V | Timestamp bit 6 | 
| 33 | Out | LVCMOS 3.3V | Timestamp bit 7 | 

## Running the Jupyter notebooks

1. Connect to the Jupyter notebook server by introducing the static IP address of your Cora-Z7 board into your web browser (pwd: xilinx).

### pulseAcq

2. Within your Jupyter notebook server, navigate to the *pulseAcq* directory and open the [pulseAcq.ipynb](https://github.com/dspsandbox/lidarTDC/blob/master/pulseAcq/Pynq/pulseAcq.ipynb). This interactive notebook is a basic example of the pulseAcq operation. 

### pulseGen

2. Within your Jupyter notebook server, navigate to the *pulseGen* directory and open the [pulseGen.ipynb](https://github.com/dspsandbox/lidarTDC/blob/master/pulseGen/Pynq/pulseGen.ipynb). This interactive notebook is a basic example of the pulseGen operation. 

## Running the TCP servers
1. SSH into your Cora-Z7-10 (usr: xilinx pwd: xilinx):
```
ssh xilinx@<static IP address>
```
### pulseAcq

2. Navigate to the *jupyter_notebooks/pulseAcq* folder.

```
cd jupyter_notebooks/pulseAcq
```

3. Execute the *pulseAcqServer.py* script

```
sudo python3 pulseAcqServer.py <static IP address> <TCP port>
```


### pulseGen

2. Navigate to the *jupyter_notebooks/pulseGen* folder.

```
cd jupyter_notebooks/pulseGen
```

3. Execute the *pulseGenCachedServer.py* script

```
sudo python3 pulseGenCachedServer.py <static IP address> <TCP port>
```

```
sudo python3 pulseGenCachedServer.py <static IP address> <TCP port>
```

## Communication between Host PC and TCP servers

Each communication consists of the following data packets:
### pulseAcq (using *pulseAcqServer.py*)
| Data packet| Direction | Length (bytes)| Description |
|---|---|---|---|
| <ITER> | Host PC -> TCP server | 4  | Number of trigger events |
| <COUNTER_MAX> | Host PC -> TCP server | 4  | Max integration time for each trigger event (in units of 10ns) |
| DATA_LEN_0 |  TCP server ->  Host PC | 4  | Trigger 0: length of the following data packet(in units of bytes) |
| DATA_0 |  TCP server ->  Host PC | DATA_LEN_0  | Trigger 0: concatenated 64 bit timestamps |
| DATA_LEN_1 | TCP server ->  Host PC | 4  | Trigger 1: length of the  following data packet (in units of bytes) |
| DATA_1 | TCP server ->  Host PC | DATA_LEN_1  | Trigger 1: concatenated 64 bit timestamps |
| ... | ... | ... | ... |
| DATA_LEN_<ITER - 1> |  TCP server ->  Host PC | 4  | Trigger <ITER - 1>: length of the  following data packet (in units of bytes) |
| DATA_<ITER - 1> | TCP server ->  Host PC | DATA_LEN_<ITER - 1> | Trigger <ITER - 1>: concatenated 64 bit timestamps |

**NOTE**: Pulse acquisition starts after receiving the <ITER> and <COUNTER_MAX> parameters. 

   
### pulseGen (using *pulseGenCachedServer.py*)
| <ITER> | Host PC -> TCP server | 4  | Number of trigger events |
| <PULSE_WIDTH> | Host PC -> TCP server | 4  | Pulse width (in units of 10ns) |
| <PERIOD> | Host PC -> TCP server | 4  | Time between trigger events (in units of 1ms) |
| DATA_LEN_0 |  Host PC -> TCP server | 4  | Trigger 0: length of the following data packet(in units of bytes) |
| DATA_0 |  Host PC -> TCP server | DATA_LEN_0  | Trigger 0: concatenated 64 bit timestamps |
| DATA_LEN_1 | Host PC -> TCP server | 4  | Trigger 1: length of the  following data packet (in units of bytes) |
| DATA_1 | Host PC -> TCP server | DATA_LEN_1  | Trigger 1: concatenated 64 bit timestamps |
| ... | ... | ... | ... |
| DATA_LEN_<ITER - 1> |  Host PC -> TCP server | 4  | Trigger <ITER - 1>: length of the  following data packet (in units of bytes) |
| DATA_<ITER - 1> | Host PC -> TCP server | DATA_LEN_<ITER - 1> | Trigger <ITER - 1>: concatenated 64 bit timestamps |   

**NOTE**: The *pulseGenCachedServer.py* script caches all timestamps on local RAM. After receiving the data for the last trigger event the sequential execution is started.
