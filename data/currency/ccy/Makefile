CFLAGS=-Wall -g
#CFLAGS=-Wall -g -I/usr/include -I/usr/include/c++/4.4.4
ccy_tst: ccy_tst.o ccy.o
	g++ $(CFLAGS) -o ccy_tst ccy_tst.o ccy.o


ccy_tst.o: ccy.h ccy_tst.cpp
	g++ $(CFLAGS) -c ccy_tst.cpp

ccy.o: ccy.h ccy.cpp
	g++ $(CFLAGS) -c ccy.cpp

dist:
	tar -cvf ccy.tar *h *cpp Makefile *.vcproj *.sln README
