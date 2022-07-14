# SNMP Subagent


## Quick Start
```
$ make subagent-demon
$ sudo ./subagent-demon
```

## SNMP Installation from source

```
$ git clone git@github.com:net-snmp/net-snmp.git
$ cd net-snmp
$ ./configure
$ make
$ make install
```

### Configure SNMPD
1. locate snmpd.conf under `/etc/snmp/`
2. Add the following lines to snmpd.conf:
- `master agentx` #enable Agentx master agent support
- `rwcommunity public` 
- `rocommunity public`
3. restart snmp: `sudo systemctl restart snmpd`

## SNMPD Extension
There are three approaches to extend snmpd function. This repository is using AgentX approach and is built separately. The other two approaches are:
Approach 1:
1. write the MIB module (use `mib2c` to generate the template code, e.g. `env MIBS="NANOMETRICS-MIB" mib2c mib2c.mfd.conf nmxCentaurScalars`)
2. put the files generated in step 1 (`nmxCentaurScalar.c/h`) to `net-snmp/agent/mibgroup/`, and rebuild the net-snmp from the source:
- `./configure --with-mib-modules=nmxCentaurScalars`
- `make & make install`
3. Restart `snmpd` which now includes the newly added MIB module implementation.

Approach 2:
1. use `net-snmp-configure`:
- run `net-snmp-configure --compile-subagent mysubagent nmxCentaurScalars.c`
- `mysubagent` executable willd be generated after successfully built.
2. run `mysubagent` as root. It will connect with the master agent `snmpd` and start supporting the new MIB module.


## SNMP tools usages
1. send snmp get request for a MIB object
```
$ snmpget -c public localhost NANOMETRICS-MIB:nmxCentaurSohInteger.0
```
2. translate a MIB object to OID
```
$ snmptranslate -IR -On NANOMETRICS-MIB:nmxCentaurScalars
```
3. print the MIB tree structure starting from a MIB node
```
$ snmptranslate -IR -Tp NANOMETRICS-MIB:nmxCentaurScalars
```

## Run snmp and subagent for debugging (non-root)
```
$ snmp -f -Lo -C --rwcommunity=public --master=agentx --agentXSocket=tcp:localhost:1705 udp:1161
$ snmpget -c public localhost:1161 NANOMETRICS-MIB:nmxCentaurSohInteger.0
```



### Issues and Solutions
1. `libnetsnmpmibs.so.*` not found while executing the subagent
- verify that `libnetsnmpmibs.so.*` is located under /usr/local/lib/
- Add the path to LD_LIBRARY_PATH and run the subagent: `export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib`
- While running the subagent as root, the LD_LIBRARY_PATH doesn't work. `/usr/local/lib` needs to be added to `/etc/ld.so.conf` and then run `sudo ldconfig`.

2. Check if the custom mib module has been built into libnetsnmpmibs.so
- `nm /usr/local/lib/libnetsnmpmibs.so.40`
