class WorkMonitor
	constructor: (@name, @fncComplete) ->
		@count = 0
		@maxCount = 0
		@complete = false
		@lastProgress = 0
	
	initialized: () ->
		@complete = true
		console.log '[%s]: All tasks are initialized, waiting for completion...', @name
	
	addTask: () ->
		@count++
		@maxCount = @count
		
	markOneTaskAsComplete: () ->
		@count--
		
		progress = @count / @maxCount		

		# console.log '[%s]: [%d]', @name, progress

		if @complete and @count is 0
			console.log '[%s]: All tasks are complete', @name
			@fncComplete()

exports.WorkMonitor = WorkMonitor