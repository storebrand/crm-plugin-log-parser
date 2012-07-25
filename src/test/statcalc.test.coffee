statcalc = require '../statcalc'
sinon = require 'sinon'

values = [
	2
	4
	4
	4
	5
	5
	7
	9
]

calcBasic = new statcalc.StatCalc values

elements = []

for value in values
	elements.push {
		value: value
	}

calcDerivedValues = new statcalc.StatCalc elements, (element) -> element.value

describe "StatCalc basic tests", ->
	it "should calculate average", ->        
    	calcBasic.avg().should.equal 5

	it "should calculate variance", ->
	    calcBasic.variance(3).should.equal 4.571

    it "should calculate deviation", ->
	    calcBasic.deviation(3).should.equal 2.138

	it "should calculate relative deviation", ->
	    calcBasic.relDeviation(3).should.equal 0.428

describe "StatCalc derived values tests", ->
	it "should calculate average", ->        
    	calcDerivedValues.avg().should.equal 5

	it "should calculate variance", ->
	    calcDerivedValues.variance(3).should.equal 4.571

    it "should calculate deviation", ->
	    calcDerivedValues.deviation(3).should.equal 2.138

    it "should calculate relative deviation", ->
	    calcDerivedValues.relDeviation(3).should.equal 0.428

describe "StatCalc cache values", ->
	it "should only call methods once", ->        
    	calc = new statcalc.StatCalc values

    	sinon.spy calc, '_avg'
    	sinon.spy calc, '_variance'
    	sinon.spy calc, '_deviation'

    	calc.avg().should.equal 5
    	calc.variance(3).should.equal 4.571
    	calc.deviation(3).should.equal 2.138
    	calc.relDeviation(3).should.equal 0.428

    	calc._avg.callCount.should.equal 1
    	calc._variance.callCount.should.equal 1
    	calc._deviation.callCount.should.equal 1

describe "StatCalc derived values tests", ->
	it "should format number with given number of decimals", ->       
    	calcBasic.formatNumber(4.571428571, 2).should.equal 4.57
    	calcBasic.formatNumber(4.571428571, 1).should.equal 4.6