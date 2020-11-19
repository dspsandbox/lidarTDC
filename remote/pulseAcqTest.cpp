#include <iostream>
#include <unistd.h>
#include <sstream>
#include <iostream>
#include <iomanip>
#include "pulseAcqLib.h"
using namespace std;



PulseAcq pulseAcq;
int iterations,counterMax, streamUpCounter, state, counter, mask, timestamp;
int i2cAddress, i2cDataWrite, i2cDataRead, i2cDataLen;


int main() {
    //Parameters
    counterMax = 250000; //Integration time in units of 10ns
    iterations = 4;
    i2cAddress = 15;
    i2cDataLen = 4;    
    //Init config
    pulseAcq.setCounterMax(counterMax);               //Set integration time
    pulseAcq.dmaS2MMHalt();                           //Halt DMA
    pulseAcq.dmaS2MMReset();                          //Reset DMA
    pulseAcq.dmaS2MMConfig(BUFFER_ADDRESS_OFFSET);    //Config buffer address offset
    pulseAcq.dmaS2MMStart();                          //Start DMA engine
    pulseAcq.setResetn(1);                            //Enable acquisistion logic
    pulseAcq.i2cHalt();
    pulseAcq.i2cReset();
    pulseAcq.i2cConfig();
    pulseAcq.i2cStart();
    


    
    for(int i = 0; i<iterations; i++){
        //Acquisition
        pulseAcq.dmaS2MMRun(BUFFER_ADDRESS_RANGE);        //Run DMA engine
        while(pulseAcq.dmaS2MMIsIdle() == false){};       //Wait until acquisistion is finished
        streamUpCounter = pulseAcq.getStreamUpCounter();  //Get number of acquired pulse events
        state = pulseAcq.getState();                      //Get state of acquisiston logic
        //I2C
        //i2cDataWrite = i;    
        //pulseAcq.i2cWrite(i2cAddress, (unsigned char*) &i2cDataWrite, i2cDataLen);
        //pulseAcq.i2cRead(i2cAddress, (unsigned char*) &i2cDataRead, i2cDataLen);

        //Print results
        cout << endl;
        cout << "Iteration: " + std::to_string(i) << endl;
        cout << "I2C read: " + std::to_string(i2cDataRead) << endl;
        cout << "Number of samples: " + std::to_string(streamUpCounter) << endl;
        cout << "State: "+ std::to_string(state) + " (0->off 1->idle 2->run 4->error)" << endl;
        cout << "Pulse sequence:"<< endl; 
        cout << "| COUNTER | TIMESTAMP | MASK |"<< endl; 
        for(int j = 0; j<streamUpCounter; j++){
            counter =    pulseAcq.buffer[j] & 0x0000000000ffffff;
            timestamp = (pulseAcq.buffer[j] & 0x00000000ff000000) >> 24;
            mask =      (pulseAcq.buffer[j] & 0xffffffff00000000) >> 32;
            
            cout << "| ";
            cout << std::setw(7) << std::setfill(' ') << counter;
            cout << " | ";
            cout << std::setw(9) << std::setfill(' ') << timestamp;
            cout << " | ";
            cout << std::setw(4) << std::setfill(' ') << mask;
            cout << " |" << endl;
            
    	}
    }
    
    //Stop config
    pulseAcq.setResetn(0);                            //Disable acquisistion logic     
	
    return 0;
}

