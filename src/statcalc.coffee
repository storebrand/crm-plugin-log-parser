class StatCalc
	constructor: (arr, fnc) ->
		@average = null
		@v = null
		@dev = null
		@relDev = null

		if fnc
			@array = []
			for element in arr
				@array.push fnc(element)
		else
			@array = arr

	_formatResult: (num, numberOfDecimals) ->
		if numberOfDecimals
			@formatNumber(num, numberOfDecimals)
		else
			num

	_avg: ->
		sum = 0
		sum += value for value in @array
		return sum / @array.length

	avg: (numberOfDecimals) ->
		if not @average
			@average = @_avg()

		@_formatResult @average, numberOfDecimals

	_variance: ->
		avg = @avg()
		sum = 0

		sum += 	Math.pow value - avg, 2 for value in @array

		return sum / ( @array.length - 1)

	variance: (numberOfDecimals) ->
		if not @v
			@v = @_variance()

		@_formatResult @v, numberOfDecimals

	_deviation: ->
		return Math.sqrt @variance()

	deviation: (numberOfDecimals) ->
		if not @dev
			@dev = @_deviation()

		@_formatResult @dev, numberOfDecimals

	relDeviation: (numberOfDecimals) ->
		if not @relDev
			@relDev = (@deviation() / @avg()) * 100

		@_formatResult @relDev, numberOfDecimals

	formatNumber: (num, numberOfDecimals = 0) ->
		pow10s = Math.pow 10, numberOfDecimals or 0
		value = (if (numberOfDecimals) then Math.round(pow10s * num) / pow10s else num)

		if StatCalc.DECIMAL_SEPERATOR
			value = new String(value).replace '.', StatCalc.DECIMAL_SEPERATOR

		value
		
StatCalc.DECIMAL_SEPERATOR = null

exports.StatCalc = StatCalc