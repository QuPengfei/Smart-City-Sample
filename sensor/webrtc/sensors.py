#!/usr/bin/python3

from tornado import web, gen
from tornado.concurrent import run_on_executor
from concurrent.futures import ThreadPoolExecutor
from watcher import RoomWatcher
from urllib.parse import unquote,quote
from db_query import DBQuery
from owtapi import OWTAPI
from configuration import env

dbhost=env["DBHOST"]
office=list(map(float,env["OFFICE"].split(",")))
streaming_limit=int(env["WEBRTC_STREAMING_LIMIT"])
webrtchost=env.get("WEBRTC_HOST",None)
rtmp_host= env.get("RTMP_HOST",None)
watcher=RoomWatcher()

class SensorsHandler(web.RequestHandler):
    def __init__(self, app, request, **kwargs):
        super(SensorsHandler, self).__init__(app, request, **kwargs)
        self.executor=ThreadPoolExecutor(4)
        self._db=DBQuery(index="sensors", office=office, host=dbhost)
        self._owt=OWTAPI()

    def check_origin(self, origin):
        return True

    def _room_details(self, sensor, name, room, stream_in, stream_out):
        details={
            "sensor": sensor,
            "name": name,
            "room": room,
            "stream": stream_in,
        }
        if webrtchost:
            details["url"]="{}?roomid={}&streamid={}&office={}".format(webrtchost,room,stream_in,quote(",".join(list(map(str,office)))))
        return details

    def _streaming_out(self, sensor, room, stream_in):
        rtmp_uri=rtmp_host+"/"+str(sensor)
        stream=self._owt.start_streaming_outs(room=room,url=rtmp_uri,video_from=stream_in)
        return (stream,rtmp_uri) if stream else (None,None)


    @run_on_executor
    def _create_room(self, sensor, streaming_out):
        r=list(self._db.search("_id='{}'".format(sensor),size=1))
        if not r: return (404, "Sensor Not Found")

        location=r[0]["_source"]["location"]
        protocol= "udp" if 'simsn' in  r[0]['_source'].keys() else "tcp"
        name="{},{} - {}".format(location["lat"],location["lon"], sensor)
        room,stream_in,stream_out=watcher.get(name)
        if room and stream_in:
            return self._room_details(sensor, name, room, stream_in, stream_out)

        room=self._owt.create_room(name=name, p_limit=streaming_limit)
        rtsp_url=r[0]["_source"]["rtspuri"]
        stream_in=self._owt.start_streaming_ins(room=room,rtsp_url=rtsp_url,protocol=protocol) if room else None
        if not stream_in: return (503, "Exception when post Streaming-ins")

        stream_out=None
        if streaming_out == "enable":
            stream_out,rtmp_uri=self._streaming_out(sensor,room,stream_in)
            if not stream_out: return (503, "Exception when post Streaming-outs")

        watcher.set(name, room, stream_in, stream_out)
        return self._room_details(sensor, name, room, stream_in, stream_out)

    @gen.coroutine
    def post(self):
        sensor=unquote(self.get_argument("sensor"))
        streaming_out=unquote(self.get_argument("streaming_out","disable"))

        r=yield self._create_room(sensor,streaming_out)
        if isinstance(r, dict):
            self.write(r)
        else:
            self.set_status(r[0],r[1])

