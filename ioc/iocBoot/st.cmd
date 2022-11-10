#!/opt/epics-R3.15.9/modules/ether_ip-ether_ip-3-3/bin/linux-x86_64/eipIoc

epicsEnvSet("ETHERIP", "/opt/epics-R3.15.9/modules/ether_ip-ether_ip-3-3")
epicsEnvSet("IOC", "/opt/ioc")

cd "${ETHERIP}"

# Load dbd, register the drvEtherIP .. commands
dbLoadDatabase("dbd/eipIoc.dbd")
eipIoc_registerRecordDeviceDriver(pdbbase)

# Initialize EtherIP driver, define PLCs
EIP_buffer_limit(450)
drvEtherIP_init()
EIP_verbosity(7)
drvEtherIP_define_PLC("Micro820", "10.0.28.82", 0)

cd "${IOC}"
dbLoadRecords("database/st.db", "PLC=Micro820")

cd iocBoot
iocInit()
