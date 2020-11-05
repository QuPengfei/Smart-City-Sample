include(platform.m4)
include(../../../script/loop.m4)
include(../../../maintenance/db-init/sensor-info.m4)
define(`STREAMING_LIMIT',10)

looplist(SCENARIO_NAME,defn(`SCENARIOS'),`
loop(OFFICEIDX,1,defn(`NOFFICES'),`
include(office.m4)
ifelse(len(defn(`OFFICE_LOCATION')),0,,`

ifelse(defn(`CAMERA_GATEWAY'),`enable',`

apiVersion: v1
kind: Service
metadata:
  name: defn(`OFFICE_NAME')-streaming-service
  labels:
    app: defn(`OFFICE_NAME')-streaming
spec:
  ports:
    - port: 1935
      targetPort: 1935
  selector:
    app: defn(`OFFICE_NAME')-streaming

--- 

apiVersion: apps/v1
kind: Deployment
metadata:
  name: defn(`OFFICE_NAME')-streaming
  labels:
     app: defn(`OFFICE_NAME')-streaming
spec:
  replicas: 1
  selector:
    matchLabels:
      app: defn(`OFFICE_NAME')-streaming
  template:
    metadata:
      labels:
        app: defn(`OFFICE_NAME')-streaming
    spec:
      enableServiceLinks: false
      containers:
        - name: defn(`OFFICE_NAME')-streaming
          image: defn(`REGISTRY_PREFIX')smtc_streaming:latest
          imagePullPolicy: IfNotPresent
          command: [ "/bin/bash", "-ce", "tail -f /dev/null & /usr/local/sbin/nginx" ]
          ports:
            - containerPort: 1935
          env:
            - name: NO_PROXY
              value: "*"
            - name: no_proxy
              value: "*"
          volumeMounts:
            - mountPath: /etc/localtime
              name: timezone
              readOnly: true
            - mountPath: /var/www/video
              name: video-archive
          resources:
            limits:
              cpu: "4"
      volumes:
          - name: timezone
            hostPath:
                path: /etc/localtime
                type: File
          - name: video-archive
            emptyDir:
              medium: Memory
              sizeLimit: 150Mi
PLATFORM_NODE_SELECTOR(`Xeon')dnl

---
')')')')
