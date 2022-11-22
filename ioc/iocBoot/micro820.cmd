#!/opt/epics-R3.15.9/modules/StreamDevice-2.8.16/bin/linux-x86_64/streamApp

epicsEnvSet("STREAMDEVICE",         "/opt/epics-R3.15.9/modules/StreamDevice-2.8.16 ")
epicsEnvSet("IOC",                  "/root/ioc-micro820"                   )
epicsEnvSet("STREAM_PROTOCOL_PATH", "$(IOC)/protocol"                               )

epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES", "1048576")

cd ${STREAMDEVICE}
dbLoadDatabase("dbd/streamApp.dbd")
streamApp_registerRecordDeviceDriver(pdbbase)

# Configure IP Acess Port
drvAsynIPPortConfigure ("CH1", "10.0.28.xx:xxxx")

cd ${IOC}

dbLoadRecords("database/micro820.db", "device = Micro820PLC, port = CH1")

cd iocBoot
iocInit
