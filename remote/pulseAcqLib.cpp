#include <iostream>
#include <fstream>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <chrono>
#include "pulseAcqLib.h"
using namespace std;


/*********************************************************************
* class constructor
*
* Creates mappings from physical memory to virtual memory for GPIO 
* register, DMA register and data BUFFER. 
*********************************************************************/
PulseAcq::PulseAcq(void){
	static const std::string memFilePath = "/dev/mem";
	int fd;

	if ((fd = open(memFilePath.c_str(), O_RDWR)) < 0) {
		cout << "ERROR: Cannot open memory file." << endl;
		exit(-1);
	}

	gpioReg = (uint32_t*) mmap(NULL, GPIO_ADDRESS_RANGE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, GPIO_ADDRESS_OFFSET);
	dmaReg = (uint32_t*) mmap(NULL, DMA_ADDRESS_RANGE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, DMA_ADDRESS_OFFSET);
	i2cReg = (uint32_t*) mmap(NULL, I2C_ADDRESS_RANGE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, I2C_ADDRESS_OFFSET);
	buffer = (uint64_t*) mmap(NULL, BUFFER_ADDRESS_RANGE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, BUFFER_ADDRESS_OFFSET);
	
	close(fd);
};

/*********************************************************************
* class destructor
*
* Removes memory mappings.
*********************************************************************/
PulseAcq::~PulseAcq(void){
	munmap((void*)gpioReg,GPIO_ADDRESS_RANGE);
	munmap((void*)dmaReg,DMA_ADDRESS_RANGE);
	munmap((void*)i2cReg,I2C_ADDRESS_RANGE);
	munmap((void*)buffer,BUFFER_ADDRESS_RANGE);
};

/*********************************************************************
* setResetn 
*
* Negated reset.
* 
* @param val 0->reset asserted, 1->reset deasserted.
*********************************************************************/
void PulseAcq::setResetn(bool val){	
	int mask = 0b1111111111111111111111110;
	gpioData = (gpioData & mask) | val;
	gpioReg[0x0/4] = gpioData;
};

/*********************************************************************
* setCounterMax
*
* Defines the max value of the internal counter that keeps track of 
* the integration time.
* 
* @param val Max integration time in units of 10ns.
*********************************************************************/
void PulseAcq::setCounterMax(int val){
	int mask=0b0000000000000000000000001;
	gpioData = (gpioData & mask) | (val << 1);
	gpioReg[0x0/4] = gpioData;
};

/*********************************************************************
* getState 
*
* @return 0->off, 1->idle, 2->run, 4->error. 
*********************************************************************/
int PulseAcq::getState(void){
	int mask = 0b000000000000000000000000111;
	return(gpioReg[0x8/4] & mask);
};

/*********************************************************************
* getStreamUpCounter 
*
* Retrieves the successfully transferred DMA samples, i.e. number of 
* captured pulse events.
*
* @return Transmitted samples.
*********************************************************************/
int PulseAcq::getStreamUpCounter(void){
	int mask = 0b111111111111111111111111000;
	return((gpioReg[0x8/4] & mask) >> 3);
};

/*********************************************************************
* dmaS2MMStart 
*
* Starts stream to memory mapped DMA channel.
*********************************************************************/
void PulseAcq::dmaS2MMStart(void){
	dmaReg[0x30/4] = 1;
};

/*********************************************************************
* dmaS2MMHalt 
*
* Halts stream to memory mapped DMA channel.
*********************************************************************/
void PulseAcq::dmaS2MMHalt(void){
	dmaReg[0x30/4] = 0;
};

/*********************************************************************
* dmaS2MMReset 
*
* Resets stream to memory mapped DMA channel.
*********************************************************************/
void PulseAcq::dmaS2MMReset(void){
	dmaReg[0x30/4] = (1 << 2);
};

/*********************************************************************
* dmaS2MMConfig 
*
* Configures the buffer address offset for the stream to memory mapped 
* DMA channel.
* 
* @param bufferAddress Buffer address offset in bytes. Please make sure 
*                      to be within a memory region that has been reserved 
*                      for DMA operations.
*********************************************************************/
void PulseAcq::dmaS2MMConfig(int bufferAddress){
	dmaReg[0x48/4] = (uint32_t) bufferAddress;
}; 

/*********************************************************************
* dmaS2MMRun 
*
* Runs the stream to memory mapped DMA channel. 
*
* @param bufferBytesLen Buffer size. Please make sure that the total 
*                       number of bytes transfered in a single  
*                       DMA operation stays below this value.
*********************************************************************/
void PulseAcq::dmaS2MMRun(int bufferBytesLen){
	dmaReg[0x58/4] = (uint32_t) bufferBytesLen;
};

/*********************************************************************
* dmaS2MMIsIdle 
*
* Verifies if stream to memory mapped DMA channel is idle. 
*
* @return 0-> DMA running 1-> DMA idle
*********************************************************************/
bool PulseAcq::dmaS2MMIsIdle(void){
	return((bool) (dmaReg[0x34/4] & (1 << 1)));
};

/*********************************************************************
* i2cStart 
*
* Starts i2c logic.
*********************************************************************/
void PulseAcq::i2cStart(void){
	
	i2cReg[0x100/4] = 1;
	
};

/*********************************************************************
* i2cHalt
*
* Halts i2c logic.
*********************************************************************/
void PulseAcq::i2cHalt(void){
	i2cReg[0x100/4] = 0;
};

/*********************************************************************
* i2cConfig
*
* Configures RX buffer to max depth
*********************************************************************/
void PulseAcq::i2cConfig(void){
	i2cReg[0x120/4] = 0xf;
	i2cReg[0x100/4] = 2;
};

/*********************************************************************
* i2cReset
*
* Soft resets i2c logic and clears tx fifo. 
*********************************************************************/
void PulseAcq::i2cReset(void){
	i2cReg[0x40/4] = 0xA;
};

/*********************************************************************
* i2cRead
*
* Read from I2C slave 
*
* @param address I2C slave address.
* @param *dataRx Data pointer.
* @param dataLen Data length in bytes.
* @param timeout_us I2C read timeout (in us). 
* @param return 0 -> successful read 1-> timeout
*********************************************************************/
int PulseAcq::i2cRead(int address, unsigned char *dataRx, int dataLen, int timeout_us){
	int returnVal = 0;
	auto t_start = std::chrono::high_resolution_clock::now();
	i2cReg[0x108/4] = (1 << 8) | (address << 1) | 1;
	i2cReg[0x108/4] = (1 << 9) | dataLen;
	for(int i = 0; i < dataLen; i++){
		while(1){  
			if((i2cReg[0x104/4] & (1 << 6)) == 0){         //RX FIFO not empty
				returnVal |= 0;
				break;
			}			

			auto t_now = std::chrono::high_resolution_clock::now();
			double elapsed_time_us = std::chrono::duration<double, std::micro>(t_now-t_start).count();
			if(elapsed_time_us > timeout_us){              //Timeout
				returnVal |= 1;	
				break;
			}
		}

		*dataRx = i2cReg[0x10C/4] & 0xff;
		dataRx++;
	}
	return returnVal;
};



/*********************************************************************
* i2cWrite
*
* Write to I2C slave 
*
* @param address I2C slave address.
* @param *dataTx Data pointer.
* @param dataLen Data length in bytes.
* @param timeout_us I2C write timeout (in us). 
* @param return 0 -> successful write 1-> timeout
*********************************************************************/
int PulseAcq::i2cWrite(int address, unsigned char *dataTx, int dataLen, int timeout_us){
	int returnVal = 0;
	auto t_start = std::chrono::high_resolution_clock::now();
	i2cReg[0x108/4] = (1 << 8) | (address << 1) | 0;
	for(int i = 0; i < (dataLen - 1); i++){
		i2cReg[0x108/4] = *dataTx;
		dataTx++;
	}
	i2cReg[0x108/4] = (1 << 9) | *dataTx;

	while(1){  
			if((i2cReg[0x104/4] & (1 << 7)) != 0){         //TX FIFO empty
				returnVal |= 0;
				break;
			}			

			auto t_now = std::chrono::high_resolution_clock::now();
			double elapsed_time_us = std::chrono::duration<double, std::micro>(t_now-t_start).count();
			if(elapsed_time_us > timeout_us){              //Timeout
				returnVal |= 1;	
				break;
			}
		}
	return returnVal;
};
