#include <iostream>
#include <unistd.h>
#include <sstream>
#include <iostream>
#include <iomanip>
#include "pulseAcqLib.h"
using namespace std;

//I2C PARAM


PulseAcq pulseAcq;
int iterations,counterMax, streamUpCounter, state, counter, mask, timestamp;
int i2cAddress, i2cDataWrite, i2cDataRead, i2cDataLen, i2cTimeout_us, i2cReturnVal;


int main() {
    //Acquisition parameters
    counterMax = 250000;   //Integration time in units of 10ns
    iterations = 1;        //Iterations of the acquisistion cycle
    
    //I2C parameters
    i2cAddress = 15;       //Slave address
    i2cDataLen = 1;        //Data len in bytes
    i2cTimeout_us = 1000;  //Timeout in us

    //i2c config
    pulseAcq.i2cHalt();
    pulseAcq.i2cReset();
    pulseAcq.i2cConfig();
    pulseAcq.i2cStart();

    for(int i = 0; i<iterations; i++){
        //Acquisition
        pulseAcq.setResetn(1);                                                 //Enable acquisistion logic
        pulseAcq.setCounterMax(counterMax);                                    //Set integration time
        pulseAcq.dmaS2MMHalt();                                                //DMA
        pulseAcq.dmaS2MMReset();                         
        pulseAcq.dmaS2MMConfig(BUFFER_ADDRESS_OFFSET,BUFFER_ADDRESS_RANGE);    
        pulseAcq.dmaS2MMStart();                          
        pulseAcq.dmaS2MMRun();       
        while(pulseAcq.dmaS2MMIsIdle() == false){};                           //Wait until acquisistion is finished
        streamUpCounter = pulseAcq.getStreamUpCounter();                      //Get number of acquired pulse events
        state = pulseAcq.getState();                                          //Get state of acquisiston logic
        pulseAcq.setResetn(0);                                                //Disable acquisistion logic 
        
        //Print results
        cout << endl;
        cout << "Iteration: " + std::to_string(i) << endl;
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

        //i2c write
        i2cDataWrite = i;    
        i2cReturnVal = pulseAcq.i2cWrite(i2cAddress, (unsigned char*) &i2cDataWrite, i2cDataLen, i2cTimeout_us);
        if(i2cReturnVal == 0){
            cout << "I2C write successful."<< endl; 
        }
        else{
            cout << "Error: I2C write timeout. Please verify ACK bit of I2C slave device."<< endl; 
            pulseAcq.i2cHalt();
            pulseAcq.i2cReset();
            pulseAcq.i2cConfig();
            pulseAcq.i2cStart();
        }

        //i2c read
        i2cReturnVal = pulseAcq.i2cRead(i2cAddress, (unsigned char*) &i2cDataRead, i2cDataLen, i2cTimeout_us);
        if(i2cReturnVal == 0){
            cout << "I2C read successful. Data: " + std::to_string(i2cDataRead) << endl; 
        }
        else{
            cout << "Error: I2C read timeout. Please verify ACK bit of I2C slave device." << endl; 
            pulseAcq.i2cHalt();
            pulseAcq.i2cReset();
            pulseAcq.i2cConfig();
            pulseAcq.i2cStart();
        }
    }          
    return 0;
}

