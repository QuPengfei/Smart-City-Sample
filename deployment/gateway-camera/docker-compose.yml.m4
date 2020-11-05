include(../../script/loop.m4)
include(../../maintenance/db-init/sensor-info.m4)

version: "3.7"

services:

looplist(SCENARIO_NAME,defn(`SCENARIOS'),`
loop(`OFFICEIDX',1,defn(`NOFFICES'),`
    include(office.m4)
    ifelse(len(defn(`OFFICE_LOCATION')),0,,`
        include(camera.m4)
        include(discovery.m4)
    ')
')')
include(network.m4)
