#!/usr/bin/python3

from concurrent.futures import ThreadPoolExecutor
from threading import Thread
import subprocess
import time
from configuration import env
import requests

office = list(map(float,env["OFFICE"].split(","))) if "OFFICE" in env else None
rtmp_host= env.get("RTMP_HOST",None)
webrtc_host= env.get("WEBRTC_HOST",None)

class Streamer(object):
    def __init__(self):
        super(Streamer, self).__init__()
        self._sensors={}
        Thread(target=self._watcher_thread).start()

    def get(self, sensor):
        if sensor not in self._sensors: return (None,None)
        return (self._sensors[sensor]["rtspuri"], self._sensors[sensor]["rtmpuri"])

    def set(self, sensor, rtspuri, simulation,streaming):
        if sensor in self._sensors: return self._sensors[sensor]["rtmpuri"]
        rtmpuri=rtmp_host+"/"+str(sensor)
        if streaming == "webrtc":
            r = self._webrtc(sensor, rtspuri, rtmpuri, simulation)
            self._sensors[sensor]={
                "rtspuri": rtspuri,
                "rtmpuri": rtmpuri,
                "streaming": "webrtc",
                "sim": simulation,
                "webrtc": r
            }
        else:
            p = self._spawn(rtspuri, rtmpuri,simulation)
            self._sensors[sensor]={
                "rtspuri": rtspuri,
                "rtmpuri": rtmpuri,
                "streaming": "ffmpeg",
                "sim": simulation,
                "ffmpeg": {
                    "process": p
                }
            }
        print(self._sensors[sensor], flush= True)
        return self._sensors[sensor]["rtmpuri"]

    def _get_sensors(self):
        try:
            uri=webrtc_host+"/api/rooms"
            r=requests.get(uri)
            if r.status_code==200 or r.status_code==201: return r.json()
            print("Exception: "+ r.text, flush=True)
        except Exception as e:
            print("Exception: "+str(e), flush=True)

    def _webrtc(self, sensor, rtspuri, rtmpuri, simulation=False):
        try:
            uri=webrtc_host+"/api/sensors"
            options={"sensor": sensor, "streaming_out": "enable"}
            r=requests.post(uri,params=options)
            if r.status_code==200 or r.status_code==201: return r.json()
            print("Exception: "+ r.text, flush=True)
        except Exception as e:
            print("Exception: "+str(e), flush=True)
  
    def _spawn(self, rtspuri, rtmpuri,simulation=False):
        cmd = ["ffmpeg", "-i",rtspuri,"-vcodec", "copy", "-an", "-f", "flv", rtmpuri]
        if simulation == True:
            cmd = ["ffmpeg", "-i",rtspuri,"-vcodec", "libx264", "-preset:v", "ultrafast", "-tune:v", "zerolatency", "-an", "-f", "flv", rtmpuri]
        print(cmd, flush=True)
        p = subprocess.Popen(cmd)
        return p

    def _watcher_thread(self):
        while True:
            tospawn=[]
            towebrtc=[]
            sensors=[item["sensor"] for itme in self._get_webrtc()]
            for sensor1 in self._sensors:
                if self._sensors[sensor1]["streaming"] == "webrtc":
                    if sensor1 not in sensors: towebrtc.append(sensor1)
                else:
                    if self._sensors[sensor1]["ffmpeg"]["process"].poll() != None:
                        tospawn.append(sensor1)

            for d1 in tospawn:
                print("Spawn sensor {} as ffmpeg thread exited".format(d1), flush=True)
                self._sensors[d1]["ffmpeg"]["process"] = self._spawn(self._sensors[d1]["rtspuri"], self._sensors[d1]["rtmpuri"], self._sensors[d1]["sim"])

            for d1 in towebrtc:
                print("Spawn sensor {} as webrtc room is closed".format(d1), flush=True)
                self._sensors[d1]["webrtc"] = self._webrtc(d1, self._sensors[d1]["rtspuri"], self._sensors[d1]["rtmpuri"], self._sensors[d1]["sim"])
                
            time.sleep(30)

