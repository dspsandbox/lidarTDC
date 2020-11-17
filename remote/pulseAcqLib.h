#ifndef PULSEACQLIB_H
#define PULSEACQLIB_H

//Define interface address offsets and range
#define GPIO_ADDRESS_OFFSET 0x41200000
#define GPIO_ADDRESS_RANGE 0x10000
#define DMA_ADDRESS_OFFSET 0x40400000
#define DMA_ADDRESS_RANGE 0x10000
//Define buffer address offset and range. Within reserved memory region [0x10000000,0x20000000]
#define BUFFER_ADDRESS_OFFSET 0x10000000 
#define BUFFER_ADDRESS_RANGE 0x100000
//Define max buffer length (in units of 64 bits)
#define MAX_BUFFER_LEN = 100000

class PulseAcq{
private: 
	uint32_t gpioData = 0;
	volatile uint32_t *gpioReg;
    volatile uint32_t *dmaReg;
public:
    volatile uint64_t *buffer;

    //Contructor & destructor
	PulseAcq(void);
    ~PulseAcq(void);
	
    // General management 
    void setResetn(bool val);
	void setCounterMax(int val);
    int getState(void);
    int getStreamUpCounter(void);
    
    //DMA
    void dmaS2MMStart(void);
    void dmaS2MMHalt(void);
    void dmaS2MMReset(void);
    void dmaS2MMConfig(int bufferAddress); 
    void dmaS2MMRun(int bufferBytesLen);
    bool dmaS2MMIsIdle(void);
};



#endif // !PULSEACQLIB_H