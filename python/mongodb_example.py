#!/usr/bin/python


from pymongo import MongoClient

client = MongoClient()

db=client.exampledatabase
collect1 = db.queries

for document in collect1.find():
	print document