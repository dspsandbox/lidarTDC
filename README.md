# lidarTDC
## System requirements
* Time-to-digital converter with a temporal resolution better than 10 ns and an integration time of up to 2 ms.
* Trigger input
* 8 bit temporal timestamp prefix
* External ref clk (10MHz)

## System architecture
![System architecture](doc/lidarTDC.png)

| Item          | Description |
| ------------- | ------------- |
| Central Control System  |  On-board computer. Etherent connectivity to external measurement equipment. |
| Cora-Z7-07  | Content Cell  |
