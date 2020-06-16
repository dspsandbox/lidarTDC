# lidarTDC
## System requirements
* Time-to-digital converter (TDC) for atmospheric Lidar applications
* Temporal resolution better than 10 ns 
* Integration time of up to 2 ms
* Trigger input
* 8 bit temporal timestamp prefix
* External ref clk (10MHz)

## System architecture
![System architecture](doc/lidarTDC.png)
* **Central Control System**. Central control, orchestration and analaysis unit. Configures peripheral devices via ethernet.
* **Cora-Z7-07**. Digilent low cost development board (see [here](https://store.digilentinc.com/cora-z7-zynq-7000-single-core-and-dual-core-options-for-arm-fpga-soc-development)) featuring a Xilinx Zynq 7007 SoC FPGA, 1Gbps Ethernet PHY, RAM memory, USB hub, 45 Arduino compatible IOs (3.3V CMOS)...
* **Zynq7007 FPGA**. System on a chip. Contains a 32bit-ARM processing system (PS) and programable logic (PL). 
* **RAM**. 512MB DDR3 memory. Accessible to both PS and PL (via DMA).
* **Python Server**. Devoted to the configuration/operation of the PL. It is has direct access to the data stored in the RAM memory. Communication with the Central Control System is performed over the 1Gbps etherent PHY.  
 * **FSM**. Finite state machine implementing the TDC logic. Expected temporal resolution: 5ns (sampling on both edges of a 100 MHz clk). Operational modes: 
    * Direct: photon timestamps are saved on RAM. Data at RAM has to be readout before starting a new measurement.
    * Histogram: the accumulated counts for each time bin are saved on RAM. During a measurement the counters are are incremented by 1 if a photon has been received during the correspondig time bin. We expect to use 16 bit counters (at least 2^15-1 measurement results can be combined before readout). 
* **PLL**. Phase lock loop. 
* **DMA**. Direct memory access. Streams data from RAM to FSM and vice-versa. 

