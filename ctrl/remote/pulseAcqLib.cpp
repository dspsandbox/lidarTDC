#include <iostream>
#include <fstream>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
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
	gpioReg[0x0] = gpioData;
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
	gpioReg[0x0] = gpioData;
};

/*********************************************************************
* getState 
*
* @return 0->off, 1->idle, 2->run, 4->error. 
*********************************************************************/
int PulseAcq::getState(void){
	int mask = 0b000000000000000000000000111;
	return(gpioReg[0x2] & mask);
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
	return((gpioReg[0x2] & mask) >> 3);
};

/*********************************************************************
* dmaS2MMStart 
*
* Starts stream to memory mapped DMA channel.
*********************************************************************/
void PulseAcq::dmaS2MMStart(void){
	dmaReg[0xC] = 1;
};

/*********************************************************************
* dmaS2MMHalt 
*
* Halts stream to memory mapped DMA channel.
*********************************************************************/
void PulseAcq::dmaS2MMHalt(void){
	dmaReg[0xC] = 0;
};

/*********************************************************************
* dmaS2MMReset 
*
* Resets stream to memory mapped DMA channel.
*********************************************************************/
void PulseAcq::dmaS2MMReset(void){
	dmaReg[0xC] = (1 << 2);
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
	dmaReg[0x12] = (uint32_t) bufferAddress;
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
	dmaReg[0x16] = (uint32_t) bufferBytesLen;
};

/*********************************************************************
* dmaS2MMIsIdle 
*
* Verifies if stream to memory mapped DMA channel is idle. 
*
* @return 0-> DMA running 1-> DMA idle
*********************************************************************/
bool PulseAcq::dmaS2MMIsIdle(void){
	return((bool) (dmaReg[0xD] & (1 << 1)));
};