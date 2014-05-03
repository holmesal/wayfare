debug = require 'debug'

class Generator

	log: debug 'gen'

	constructor: (@canvas) ->
		@maxPlaceAttempts = 20
		@log 'new generator'
		@blocks = @canvas.blocks
		@attempts = 0

	randomPlace: (size) ->
		if @attempts then @attempts++ else @attempts=0
		if @attempts < @maxPlaceAttempts
			@log '--- placing building'
			pos =
				x: Math.floor(Math.random()*@canvas.dims.x)
				y: Math.floor(Math.random()*@canvas.dims.y)
			@log "trying #{pos.x}, #{pos.y}"
			# Check the area to see if the given thing will fit
			fits = @checkFit pos, size
			if fits
				# Place the blocks
				@generate pos, size

	checkFit: (pos, size) ->
		fits = true
		@canvas.localLoop pos, size, (block, local, global) ->
			if block
				if block.stack[block.stack.length-1] isnt 'grass'
					fits = false
			else
				fits = false

		@log "fit is #{fits}"
		fits

	doge: (pos) ->
		@blocks[pos.x][pos.y].stack.push 'doge'



module.exports = 
	Generator: Generator