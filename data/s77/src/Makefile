#

SRCS=IPBlockRecord.cpp DbaIPBlockRecord.cpp locateIP.cpp
OBJS=${SRCS:%.cpp=%.o}
CC=g++
CXXFLAGS=-g -Wall -fPIC -I/usr/include -I/usr/include/soci -I/usr/include/mysql -I.
LDFLAGS=-g -lboost_date_time -lsoci_core -lsoci_mysql

##
# Targets
all: locateIP

%.cpp%.o:
	${CC} ${CXXFLAGS} -o $@ $<

locateIP: ${OBJS}
	${CC} ${LDFLAGS} -o $@ ${OBJS}

clean:
	\rm -f *.o locateIP

