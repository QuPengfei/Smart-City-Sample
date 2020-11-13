
ifelse(defn(`DISCOVER_SIMULATED_CAMERA'),`true',`dnl

    defn(`OFFICE_NAME')-camera-discovery:
        image: defn(`REGISTRY_PREFIX')smtc_onvif_discovery:latest
        restart: always
        environment:
            PORT_SCAN: "-Pn"
            SIM_HOST: ifelse(eval(defn(`NCAMERAS')>0),1,"loop(`CAMERAIDX',1,defn(`NCAMERAS'),`defn(`OFFICE_NAME')-simulated-cameras:eval(defn(`CAMERA_RTSP_PORT')+defn(`CAMERAIDX')*defn(`CAMERA_PORT_STEP')-defn(`CAMERA_PORT_STEP'))/')",":0")
            SIM_PREFIX: "`cams'ifelse(defn(`SCENARIO_NAME'),`traffic',1,2)`o'defn(`OFFICEIDX')ifelse(defn(`SCENARIO_NAME'),`traffic',c,q)"
            OFFICE: "defn(`OFFICE_LOCATION')"
            DBHOST: ifelse(defn(`CAMERA_GATEWAY'),`enable',"http://defn(`OFFICE_NAME')-gateway-service:8080/offices","http://ifelse(defn(`NOFFICES'),1,db,defn(`OFFICE_NAME')-db)-service:9200")
ifelse(defn(`CAMERA_GATEWAY'),`enable',`
            WEBRTC_HOST: "http://defn(`OFFICE_NAME')-gateway-service:8080/offices"
            STREAMING_FROM: "defn(`CAMERA_STREAMING_FROM')"
            GW_RTMP_HOST: "rtmp://defn(`OFFICE_NAME')-gateway-service:1935/sensors"
            RTMP_HOST: "rtmp://defn(`OFFICE_NAME')-streaming-service:1935/sensors"')
            CAMERA_GATEWAY_ENABLE: defn(`CAMERA_GATEWAY')
            SERVICE_INTERVAL: "30"
            NO_PROXY: "*"
            no_proxy: "*"
        volumes:
            - /etc/localtime:/etc/localtime:ro
        networks:
            - defn(`OFFICE_NAME')
ifelse(defn(`CAMERA_GATEWAY'),`disable',`
        deploy:
            placement:
                constraints:
                    - node.labels.vcac_zone!=yes
')

ifelse(defn(`SCENARIO_NAME'),`stadium',`
    defn(`OFFICE_NAME')-camera-discovery-crowd:
        image: defn(`REGISTRY_PREFIX')smtc_onvif_discovery:latest
        restart: always
        environment:
            PORT_SCAN: "-Pn"
            SIM_HOST: ifelse(eval(defn(`NCAMERAS2')>0),1,"loop(`CAMERAIDX',1,defn(`NCAMERAS2'),`defn(`OFFICE_NAME')-simulated-cameras-crowd:eval(defn(`CAMERA_RTSP_PORT')+defn(`CAMERAIDX')*defn(`CAMERA_PORT_STEP')-defn(`CAMERA_PORT_STEP'))/')",":0")
            SIM_PREFIX: "`cams2o'defn(`OFFICEIDX')w"
            OFFICE: "defn(`OFFICE_LOCATION')"
            DBHOST: ifelse(defn(`CAMERA_GATEWAY'),`enable',"http://defn(`OFFICE_NAME')-gateway-service:8080/offices","http://ifelse(defn(`NOFFICES'),1,db,defn(`OFFICE_NAME')-db)-service:9200")
ifelse(defn(`CAMERA_GATEWAY'),`enable',`
            WEBRTC_HOST: "http://defn(`OFFICE_NAME')-gateway-service:8080/offices"
            STREAMING_FROM: "defn(`CAMERA_STREAMING_FROM')"
            GW_RTMP_HOST: "rtmp://defn(`OFFICE_NAME')-gateway-service:1935/sensors"
            RTMP_HOST: "rtmp://defn(`OFFICE_NAME')-streaming-service:1935/sensors"')
            CAMERA_GATEWAY_ENABLE: defn(`CAMERA_GATEWAY')
            SERVICE_INTERVAL: "30"
            NO_PROXY: "*"
            no_proxy: "*"
        volumes:
            - /etc/localtime:/etc/localtime:ro
        networks:
            - defn(`OFFICE_NAME')
ifelse(defn(`CAMERA_GATEWAY'),`disable',`
        deploy:
            placement:
                constraints:
                    - node.labels.vcac_zone!=yes
')

    defn(`OFFICE_NAME')-camera-discovery-entrance:
        image: defn(`REGISTRY_PREFIX')smtc_onvif_discovery:latest
        restart: always
        environment:
            PORT_SCAN: "-Pn"
            SIM_HOST: ifelse(eval(defn(`NCAMERAS3')>0),1,"loop(`CAMERAIDX',1,defn(`NCAMERAS3'),`defn(`OFFICE_NAME')-simulated-cameras-entrance:eval(defn(`CAMERA_RTSP_PORT')+defn(`CAMERAIDX')*defn(`CAMERA_PORT_STEP')-defn(`CAMERA_PORT_STEP'))/')",":0")
            SIM_PREFIX: "`cams2o'defn(`OFFICEIDX')e"
            OFFICE: "defn(`OFFICE_LOCATION')"
            DBHOST: ifelse(defn(`CAMERA_GATEWAY'),`enable',"http://defn(`OFFICE_NAME')-gateway-service:8080/offices","http://ifelse(defn(`NOFFICES'),1,db,defn(`OFFICE_NAME')-db)-service:9200")
ifelse(defn(`CAMERA_GATEWAY'),`enable',`
            WEBRTC_HOST: "http://defn(`OFFICE_NAME')-gateway-service:8080/offices"
            STREAMING_FROM: "defn(`CAMERA_STREAMING_FROM')"
            GW_RTMP_HOST: "rtmp://defn(`OFFICE_NAME')-gateway-service:1935/sensors"
            RTMP_HOST: "rtmp://defn(`OFFICE_NAME')-streaming-service:1935/sensors"')
            CAMERA_GATEWAY_ENABLE: defn(`CAMERA_GATEWAY')
            SERVICE_INTERVAL: "30"
            NO_PROXY: "*"
            no_proxy: "*"
        volumes:
            - /etc/localtime:/etc/localtime:ro
        networks:
            - defn(`OFFICE_NAME')
ifelse(defn(`CAMERA_GATEWAY'),`disable',`
        deploy:
            placement:
                constraints:
                    - node.labels.vcac_zone!=yes

')
')')

ifelse(defn(`DISCOVER_IP_CAMERA'),`true',`dnl

    defn(`OFFICE_NAME')-ipcamera-discovery:
        image: defn(`REGISTRY_PREFIX')smtc_onvif_discovery:latest
        restart: always
        environment:
            OFFICE: "defn(`OFFICE_LOCATION')"
            DBHOST: ifelse(defn(`CAMERA_GATEWAY'),`enable',"http://defn(`OFFICE_NAME')-gateway-service:8080/offices","http://ifelse(defn(`NOFFICES'),1,db,defn(`OFFICE_NAME')-db)-service:9200")
ifelse(defn(`CAMERA_GATEWAY'),`enable',`
            WEBRTC_HOST: "http://defn(`OFFICE_NAME')-gateway-service:8080/offices"
            STREAMING_FROM: "defn(`CAMERA_STREAMING_FROM')"
            GW_RTMP_HOST: "rtmp://defn(`OFFICE_NAME')-gateway-service:1935/sensors"
            RTMP_HOST: "rtmp://defn(`OFFICE_NAME')-streaming-service:1935/sensors"')
            CAMERA_GATEWAY_ENABLE: defn(`CAMERA_GATEWAY')
            SERVICE_INTERVAL: "30"
            NO_PROXY: "*"
            no_proxy: "*"
        volumes:
            - /etc/localtime:/etc/localtime:ro
        networks:
            - defn(`OFFICE_NAME')
ifelse(defn(`CAMERA_GATEWAY'),`disable',`
        deploy:
            placement:
                constraints:
                    - node.labels.vcac_zone!=yes
')')

