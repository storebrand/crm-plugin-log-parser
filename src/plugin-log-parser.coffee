flr = require './fileutils'
monitor = require './workmonitor'
mongoose = require 'mongoose'
LogEntry = require './models/logentry'

patterns =
	dateTime: /^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})/
	guid: /(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})/
	any: /(.*)/
	comb: /^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})(.*)(INFO |WARN |ERROR|DEBUG) Entity:(.*) Message:(.*) User:(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1}) Id:(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})? Time: (.*)ms/
		
class LogFileParser
	constructor: (@server, @file, @regex) ->

	parse: (callback) ->
		console.log '*** About to parse [%s] ***', @file

		reader = new flr.FileLineReader @file

		while reader.hasNextLine()
			line = reader.nextLine()
			
			matches = line.match @regex
			
			if matches
				entry = new LogEntry()
				
				entry.date = new Date matches[1]
				entry.severity = matches[3].trim()
				entry.entity = matches[4]
				entry.event = matches[5]
				entry.user = matches[6]
				entry.id = matches[12]
				entry.time = matches[18]
				entry.server = @server

				callback entry

		console.log '\n*** Done parsing [%s] ***\n', @file

class EntryStacks
	constructor: (@fncFlush) ->
		@_reset()
		@stacksize = 1000

	_reset: ->
		@stacks = []
		@currentStackIndex = 0

	add: (element) ->
		if @stacks.length is 0
			@stacks.push []
			@currentStackIndex = 0
		else
			if @stacks[@currentStackIndex].length < @stacksize
				@stacks[@currentStackIndex].push element
			else
				# console.log 'New stack is created, number of stacks [%d]', @stacks.length
				@stacks.push []
				@currentStackIndex++
				@stacks[@currentStackIndex].push element

server = 456

folderReader = new flr.FolderReader 'files/' + server
files = folderReader.readSync()
regex = new RegExp patterns.comb

mongoose.connect 'mongodb://localhost/plugins-log-test'

processStacks = (stacks, stackIndex, callback) ->
	stackMonitor = new monitor.WorkMonitor 'Stack-' + stackIndex, () ->
		if stackIndex < stacks.length - 1
			processStacks stacks, stackIndex + 1, callback
		else
			callback()

	for entry in stacks[stackIndex]
		stackMonitor.addTask()

		entry.save (err) ->
			if err
				console.log err
				process.exit 1

			stackMonitor.markOneTaskAsComplete()

	stackMonitor.initialized()

processFiles = (files, fileIndex) ->
	file = files[fileIndex]

	stacks = new EntryStacks()
	p = new LogFileParser server, file, regex
	
	p.parse (entry) ->
		stacks.add entry	

	processStacks stacks.stacks, 0, () ->
		if fileIndex < files.length - 1
			processFiles files, fileIndex + 1
		else
			console.log 'All files are processed, closing DB-connection'
			mongoose.connection.close()

processFiles files, 0