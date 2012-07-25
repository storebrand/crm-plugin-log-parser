mongoose = require 'mongoose'
fs = require 'fs'
monitor = require './workmonitor'
statcalc = require './statcalc'

mongoose.connect 'mongodb://localhost/plugins-log-test'

LogEntry = require './models/logentry'

entities = [
	'email'
	'phonecall'
	'task'
	'letter'
]

events = [
	'PreSetStateDynamicEntity'
	'PostSetStateDynamicEntity'
]

threshold = 0
decs = 4
statcalc.StatCalc.DECIMAL_SEPERATOR = ','
server = '456'

counter = new monitor.WorkMonitor "Main", () ->
	fs.writeFile 'results/' + server + '/summary-' + server + '.csv', summary, (err) ->
		if not err
			console.log 'Summary completed!'

	mongoose.connection.close()

summary = 'Combination;Average;Variance;Standard deviation;Rel. deviation (%)\n'

processEntityEvent = (entity, event) ->
	LogEntry.where('entity', entity).where('event', event).where('server', server).where('time').gt(threshold).sort('time', -1).exec (err, docs) ->
		content = 'Severity;Ms;Event\n'
		
		for doc in docs
			content += doc.severity + ";" + doc.time + ';' + doc.event + '\n'
		
		calc = new statcalc.StatCalc docs, (element) -> element.time

		avg = calc.avg decs
		variance = calc.variance decs
		deviation = calc.deviation decs
		relDeviation = calc.relDeviation decs

		summary += entity + '-' + event + ';' + avg + ';' + variance + ';' + deviation + ';' + relDeviation + '\n'
		
		fileName = 'results/' + server + '/result-' + entity + '-' + event + '.csv'

		fs.writeFile fileName, content, (err) ->
			if not err
				console.log 'Result file [%s] completed!', fileName
				counter.markOneTaskAsComplete()

for entity in entities
	for event in events
		counter.addTask()
		processEntityEvent entity, event

counter.initialized()