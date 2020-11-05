
networks:
looplist(SCENARIO_NAME,defn(`SCENARIOS'),`
loop(`OFFICEIDX',1,defn(`NOFFICES'),`
    include(office.m4)
    ifelse(len(defn(`OFFICE_LOCATION')),0,,`
    defn(`OFFICE_NAME'):
        driver: bridge
    ')
')')
