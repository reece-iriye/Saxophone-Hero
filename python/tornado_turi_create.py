#!/usr/bin/python
'''Starts and runs the scikit learn server'''

# For this to run properly, MongoDB must be running
#    Navigate to where mongo db is installed and run
#    something like $./mongod --dbpath "/data/db"
#    might need to use sudo (yikes!)

# database imports
from pymongo import MongoClient
from pymongo.errors import ServerSelectionTimeoutError


# tornado imports
import tornado.web
from tornado.web import HTTPError
from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop
from tornado.options import define, options

# other imports
from pprint import PrettyPrinter

# custom imports
from basehandler import BaseHandler
import turihandlers as th
import examplehandlers as eh

# Setup information for tornado class
define("port", default=8000, help="run on the given port", type=int)

pp = PrettyPrinter(indent=4)

# Utility to be used when creating the Tornado server
# Contains the handlers and the database connection
class Application(tornado.web.Application):
    def __init__(self):
        '''Store necessary handlers,
           connect to database
        '''

        handlers = [(r"/[/]?", BaseHandler),
                    (r"/Handlers[/]?",        th.PrintHandlers),
                    (r"/AddDataPoint[/]?",    th.UploadLabeledDatapointHandler),
                    (r"/GetNewDatasetId[/]?", th.RequestNewDatasetId),
                    (r"/UpdateModel[/]?",     th.UpdateModelForDatasetId),     
                    (r"/PredictOne[/]?",      th.PredictOneFromDatasetId),  
                    (r"/GetExample[/]?",      eh.TestHandler),
                    (r"/DoPost[/]?",          eh.PostHandlerAsGetArguments),
                    (r"/PostWithJson[/]?",    eh.JSONPostHandler),
                    (r"/MSLC[/]?",            eh.MSLC),             
                    ]

        self.handlers_string = str(handlers)

        try:
            print('=================================')
            print('====ATTEMPTING MONGO CONNECT=====')
            self.client  = MongoClient(serverSelectionTimeoutMS=50) # local host, default port
            print(self.client.server_info()) # force pymongo to look for possible running servers, error if none running
            # if we get here, at least one instance of pymongo is running
            self.db = self.client.turidatabase # database with labeledinstances, models
            
        except ServerSelectionTimeoutError as inst:
            print('Could not initialize database connection, stopping execution')
            print('Are you running a valid local-hosted instance of mongodb?')
            print('   Make sure that mongo db is installed and running')
            print('   using the "brew services start mongodb-community@6.0" command')
            #raise inst

        self.clf = {} # the classifier model (in-class assignment, this is now a dictionary!)
        # but depending on your implementation, you may not need to change it  ¯\_(ツ)_/¯

        print('=================================')
        print('==========HANDLER INFO===========')
        pp.pprint(handlers)

        settings = {'debug':True}
        tornado.web.Application.__init__(self, handlers, **settings)

    def __exit__(self):
        self.client.close() # just in case


def main():
    '''Create server, begin IOLoop 
    '''
    tornado.options.parse_command_line()
    http_server = HTTPServer(Application(), xheaders=True)
    http_server.listen(options.port)
    IOLoop.instance().start()

if __name__ == "__main__":
    main()
