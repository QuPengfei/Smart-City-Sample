#!/usr/bin/python3

from tornado import web, gen
from tornado.concurrent import run_on_executor
from concurrent.futures import ThreadPoolExecutor
from urllib.parse import unquote
from owtapi import OWTAPI
from watcher import RoomWatcher
from configuration import env
import json

streaming_limit=int(env["WEBRTC_STREAMING_LIMIT"])
watcher=RoomWatcher(inactive=5)

class RoomsHandler(web.RequestHandler):
    def __init__(self, app, request, **kwargs):
        super(RoomsHandler, self).__init__(app, request, **kwargs)
        self.executor=ThreadPoolExecutor(4)
        self._owt=OWTAPI()

    def check_origin(self, origin):
        return True

    @run_on_executor
    def _get_rooms(self):
        return self._owt.list_room()

    @gen.coroutine
    def get(self):
        rooms=yield self._get_rooms()
        self.write(rooms)

    @run_on_executor
    def _create_room(self, name, sinfo):
        room=self._owt.create_room(name=name,p_limit=streaming_limit)
        watcher.set(name, room)
        return room

    @gen.coroutine
    def put(self):
        sinfo=json.loads(unquote(self.get_argument("sensorinfo")))
        name="{},{}:camera:mobile_camera".format(sinfo["lat"],sinfo["lon"])
        room=yield self._create_room(name, sinfo)
        self.write({"room":room})
