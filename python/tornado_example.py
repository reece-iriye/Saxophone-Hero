#!/usr/bin/python
'''Starts and runs the tornado with BaseHandler '''

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
import examplehandlers as eh

# Setup information for tornado class (see import above)
define("port", default=8000,
       help="run on the given port", type=int)

pp = PrettyPrinter(indent=4)

# Utility to be used when creating the Tornado server
# Contains the handlers and the database connection
class Application(tornado.web.Application):
    def __init__(self):
        '''Store necessary handlers,
        connect to database
        '''

        handlers = [(r"/[/]?",             BaseHandler), # raise 404
                    (r"/GetExample[/]?",   eh.TestHandler), 
                    (r"/DoPost[/]?",       eh.PostHandlerAsGetArguments),
                    (r"/PostWithJson[/]?", eh.JSONPostHandler),
                    (r"/MSLC[/]?",         eh.MSLC), # custom class that we can add to
                    ]


        try:
            self.client  = MongoClient(serverSelectionTimeoutMS=5) # local host, default port
            print('=================================')
            print('==========MONGO DB INFO==========')
            print(self.client.server_info()) # force pymongo to look for possible running servers, error if none running
            # if we get here, at least one instance of pymongo is running
            self.db = self.client.exampledatabase # database with labeledinstances, models
            handlers.append((r"/SaveToDatabase[/]?",eh.LogToDatabaseHandler)) # add new handler for database
            print('=================================')
            
        except ServerSelectionTimeoutError as inst:
            print('=================================')
            print('\033[1m'+'Could not initialize database connection, skipping, Error Details:'+'\033[0m')
            print(inst)
            print('=================================')

        settings = {'debug':True}
        print('=================================')
        print('==========HANDLER INFO===========')
        pp.pprint(handlers)
        tornado.web.Application.__init__(self, handlers, **settings)

    def __exit__(self):
        print('closing database...')
        self.client.close()


def main():
    '''Create server, begin IOLoop 
    '''
    tornado.options.parse_command_line()
    http_server = HTTPServer(Application(), xheaders=True)
    http_server.listen(options.port)
    IOLoop.instance().start()

if __name__ == "__main__":
    main()
