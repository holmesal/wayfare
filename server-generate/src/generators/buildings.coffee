{Generator} = require './generator'

generate = (canvas) ->
	# Create a new building object, pass in the canvas
	buildingGenerator = new BuildingGenerator canvas
	# Call the place method, to kick off the generation
	buildingGenerator.place()

# Building generator finds outlines for each building
class BuildingGenerator extends Generator

	place: ->
		@log 'generating buildings'
		# Pick a size

		# Pick how many buildings
		@count = 10

		# Pick how many retries before giving up with less than @count placed
		@maxAttempts = 20

		while @attempts < @maxAttempts
			size = 
				x: 11
				y: 11
			# Find a random placement and check the size
			@randomPlace size

	generate: (pos, size) ->
		@buildings = [] if not @buildings
		# Create a new building
		@buildings.push new Building pos, size, @canvas

		# For now, just fill in the footprints
		
			# else	
			# 	@blocks[global.x][global.y].stack.push 'doge'
	



# Building lays everything out internally 
class Building
	constructor: (@pos, @size, @canvas) ->
		@blocks = @canvas.blocks
		@walls()

	initBlocks: ->
		for col in [0...@size.x]
			@blocks[col] = []

	walls: ->
		@canvas.localLoop @pos, @size, (block, local, global) =>
			if local.x is 0 or local.y is 0 or local.x is @size.x-1 or local.y is @size.y-1
				@blocks[global.x][global.y].stack.push 'building'
		# Knock out a door
		doorBlock = @at(Math.floor(@size.x/2),@size.y-1)
		doorBlock.stack[doorBlock.stack.length-1] = 'doge'

	at: (x, y) ->
		@blocks[@pos.x+x][@pos.y+y]


# class Building
module.exports = 
	generate: generate