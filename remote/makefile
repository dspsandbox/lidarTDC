
CC = g++
CFLAGS  = -g -Wall 


default: pulseAcqTest

pulseAcqTest:  pulseAcqTest.o pulseAcqLib.o 
	$(CC) $(CFLAGS) -o pulseAcqTest pulseAcqTest.o pulseAcqLib.o 

pulseAcqTest.o:  pulseAcqTest.cpp pulseAcqLib.h 
	$(CC) $(CFLAGS) -c pulseAcqTest.cpp

pulseAcqLib.o:  pulseAcqLib.cpp pulseAcqLib.h 
	$(CC) $(CFLAGS) -c pulseAcqLib.cpp

clean: 
	$(RM) pulseAcqTest *.o *~