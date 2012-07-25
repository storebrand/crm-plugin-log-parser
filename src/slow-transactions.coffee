mongoose = require 'mongoose'
mongoose.connect 'mongodb://localhost/plugins-log-test'

LogEntry = require './models/logentry'

q = time:
		$gt: 1000

query = LogEntry.where('time').gt(1000).sort('time', -1).exec (err, docs) ->
	for doc in docs
		console.log doc.date + ';' + doc.time + ';' + doc.message
	