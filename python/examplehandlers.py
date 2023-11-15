#!/usr/bin/python

import tornado.web

from tornado.web import HTTPError
from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop
from tornado.options import define, options

from basehandler import BaseHandler

import time
import json
import pdb
from datetime import datetime


class MSLC(BaseHandler):
    def get(self):
        self.write('''
            <!DOCTYPE html>
            <html>
            <head>
            <link href="data:image/x-icon;base64,AAABAAEAEBAAAAEACABoBQAAFgAAACgAAAAQAAAAIAAAAAEACAAAAAAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAAAAc7XOAJzGzgB7tdYAISkxAHO1xgB7tc4AhLXWAPf3/wAhKSkASnuUAHu1xgCEtc4AWq3WAIS1xgCMtc4AY63WABAYEABrrb0AY63OABghOQDW7+8Aa63OADFzpQBrrcYAUpy9AHOtzgBKnM4A5+/3ADlzpQBCc5QASqXWALXe5wBKnMYAc63GAFqcvQAYISEAvd7nAHutxgBSnMYAnNbeACEhIQBSpc4AQkpSAKXW3gBSpcYAY6W9AFqlzgCc1ucAWqXGAMbn5wBClL0Aa6W9ANbn9wApOTkAa5ytAGultQA5lMYASpS9AHOlvQApOUoAa3NzAEqUtQBrpcYAe5ytAIScnABSlLUAlM7eAIzO7wAxQkoAWpS1AJzO3gBzvd4AnM7WAHu93gA5jL0Apc7eAHu91gCczucApc7WAIS93gApMTkAMVprAIS91gD3//8Arc7WAEKMtQCUpaUAhL3OAIy91gD///8AOVqEAHOUpQCMxt4AjL3OAEqMrQBjtdYAa7XeAITG5wCUvc4AMXu1AEpjcwBrtdYAlMbWAJS9xgBrtc4AlMbOAJzG1gBztdYAlMbnADGEtQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAATihYFkJCRgsOJgVYWWMGAAhdAWkaGC4uLiIiMTEBBgBaXVkBIiI0DF4mNC1kJxMAWkdZJhIYIiImYyYnM24hAAgsZUUJPDciD14MBjMzLwAVSVErXDg7DgsLDAwZOlAAJVUkKVdoagJPa14mPzE1AFQgJBFBQ1NdXk9MZ1MNWgBaMkpKUEgKK0BnAwYqKloAWjBHNmFsRj1SMS8TS2BaAFptRARNM1lTJy8QG2QIWgBaWmJhXRMjNCMtVhQ+WloAWlocEEoTOSoQbh1bW1RaAFpaWlofZDVUWloxXx5UWgBaWlpaZgdaWlpaWhYXWloAWlpaWmFaWlpaWlpaHFpaAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAA=" rel="icon" type="image/x-icon" />
            </head>
            <body>

            <h1>Database Queries</h1>

            <img src="https://upload.wikimedia.org/wikipedia/commons/b/b6/Image_created_with_a_mobile_phone.png" width=90 crossorigin="anonymous">


            ''')
        # now we can display the queries
        # as HTML
        for f in self.db.queries.find():
            f['time'] = datetime.fromtimestamp(f['time']).strftime('%c')
            self.write('<p style="color:blue">'+str(f)+'</p>')
            #if f['arg'] not in ['sleep','death']:
            #    self.write('<p style="color:blue">'+str(f)+'</p>')

        self.write('''
            </body>
            </html>
            ''')

class TestHandler(BaseHandler):
    def get(self):
        '''Write out to screen
        '''
        self.write("Test of Hello World, Add the number 2!!")

class PostHandlerAsGetArguments(BaseHandler):
    def post(self):
        ''' If a post request at the specified URL
        Respond with arg1 and arg1*4
        '''
        arg1 = self.get_float_arg("arg1",default=1.0)
        self.write_json({"arg1":arg1,"arg2":4*arg1})

    def get(self):
        '''respond with arg1*2
        '''
        arg1 = self.get_float_arg("arg1",default=3.0);
        # self.write("Get from Post Handler? " + str(arg1*2));
        self.write("Message from 2023: Hope Turi is deprecated! "+str(arg1)+"\n")
        self.write_json({"arg1":arg1,"arg2":2*arg1})

class JSONPostHandler(BaseHandler):
    def post(self):
        '''Respond with arg1 and arg1*4
        '''
        # could also test this with curl if you want:
        # curl -X POST -H "Content-Type: application/json" -d '{"arg":[5,3,1]}' localhost:8000/PostWithJson
        data = json.loads(self.request.body.decode("utf-8"))
        print(data)
        self.write_json(
            {"arg1":data['arg'][0]*2,
            "arg2":data['arg'],
            "arg3":[32,4.5,"Eric Rocks!","some_disagree"]})


class LogToDatabaseHandler(BaseHandler):
    def get(self):
        '''log query to database
        '''
        #pdb.set_trace() # to stop here and inspect
        
        vals = self.get_argument("arg")
        t = time.time()
        ip = self.request.remote_ip
        dbid = self.db.queries.insert_one(
            {"arg":vals,"time":t,"remote_ip":ip}
            )
        self.write_json({"id":str(dbid)})

# deprecated functionality 
# class FileUploadHandler(BaseHandler):
#     def post(self):
#         print(str(self.request))
#         # nginx should be setup for this to work properly
#         # you will need to forward the fields to get it running
#         # something with _name and _path
