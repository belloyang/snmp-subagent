#
# Warning: you may need more libraries than are included here on the
# build line.  The agent frequently needs various libraries in order
# to compile pieces of it, but is OS dependent and we can't list all
# the combinations here.  Instead, look at the libraries that were
# used when linking the snmpd master agent and copy those to this
# file.
#

CC=gcc

TARGETS=subagent-demon snmpdemoapp asyncapp

NET_SNMP_CONFIG=net-snmp-config
CFLAGS=`$(NET_SNMP_CONFIG) --cflags` -Wall -Wextra -Werror \
	-Wno-unused-parameter
BUILDLIBS=`$(NET_SNMP_CONFIG) --libs`
BUILDAGENTLIBS=`$(NET_SNMP_CONFIG) --agent-libs`
OUTDIR=./bin

# shared library flags (assumes gcc)
DLFLAGS=-fPIC -shared

all: $(TARGETS)

snmpdemoapp: snmpdemoapp.o
	$(CC) -o $@ $@.o $(BUILDLIBS)

asyncapp: asyncapp.o
	$(CC) -o $@ $@.o $(BUILDLIBS)

subagent-demon: subagent-demon.o nstAgentSubagentObject.o nmxCentaurScalars.o nstAgentPluginObject.o
	$(CC) -o ${OUTDIR}/$@ $@.o nstAgentSubagentObject.o nmxCentaurScalars.o nstAgentPluginObject.o $(BUILDAGENTLIBS)

clean:
	rm -f -- *.o $(TARGETS)

nmxCentaurScalars.o: mibgroup/nmxCentaurScalars.c 
	$(CC) $(CFLAGS) $(DLFLAGS) -c -o $@ mibgroup/nmxCentaurScalars.c

nstAgentSubagentObject.o: mibgroup/nstAgentSubagentObject.c 
	$(CC) $(CFLAGS) $(DLFLAGS) -c -o $@ mibgroup/nstAgentSubagentObject.c

nstAgentPluginObject.o: mibgroup/nstAgentPluginObject.c Makefile
	$(CC) $(CFLAGS) $(DLFLAGS) -c -o $@ mibgroup/nstAgentPluginObject.c


nstAgentPluginObject.so: mibgroup/nstAgentPluginObject.o Makefile
	$(CC) $(CFLAGS) $(DLFLAGS) -o $@ mibgroup/nstAgentPluginObject.o
