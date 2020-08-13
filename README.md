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
 * **FSM**. Finite state machine implementing the TDC logic. Expected temporal resolution: 10ns (sampling on rising edge of a 100 MHz clk). 64bit time stamping: 
    * 23-00 : counter (max integration time: 167 ms ).
    * 31-24 : external timestamp. 
    * 63-32 : mask (used to mark the inputs on which a rising edge has been detected). Max number of detectors: 32.
* **PLL**. Phase lock loop. 
* **DMA**. Direct memory access. Streams 64bit timestamps from FSM to RAM. 

