# lidarTDC
## System requirements
* Time-to-digital converter (TDC) for atmospheric Lidar applications
* Temporal resolution better than 10 ns 
* Integration time of up to 2 ms.
* Trigger input
* 8 bit temporal timestamp prefix
* External ref clk (10MHz)

## System architecture
![System architecture](doc/lidarTDC.png)
* **Central Control System** Measurement control and analaysis unit. Configures peripheral devices via ethernet.
* **Cora-Z7-07**. Digilent low cost development board (see [here](https://store.digilentinc.com/cora-z7-zynq-7000-single-core-and-dual-core-options-for-arm-fpga-soc-development)) featuring a Xilinx Zynq 7007 SoC FPGA, 1Gbps Ethernet PHY, RAM memory, USB hub, 45 Arduino compatible IOs (3.3V CMOS)...|
* **Zynq7007 FPGA**. System on a chip. Contains a 32bit-ARM processing system (PS) and programable logic (PL). |
* **RAM**. 512MB DDR3 memory. Accessible to both PS and PL (via DMA).|
* **Python Server**. Devoted to the configuration/operation of the PL. It is has direct access to the data stored in the RAM memory. Control commands and data connected are transferred via the 1Gbps etherent PHY.  |
 * **FSM**. Finite state machine implementing the TDC logic. Expected temporal resolution: 5ns (sampling on both edges of a 100 MHz clk). Operational modes: 
    * Direct: only received photon timestamps are saved on RAM.
    * Histogram: the accumulated counts for each time bin are saved on RAM. During a measurement the counter of that particular time bin is incremented by 1 when a photon has been received. 
* **PLL**. Phase lock loop. |
* **DMA**. Direct memory access. Streams data from RAM to FSM and vice-versa. 

