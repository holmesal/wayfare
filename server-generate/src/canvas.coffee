{EventEmitter} = require 'events'
can = require('debug')('can')

class Canvas extends EventEmitter

	constructor: (@chunks) ->
		console.log 'new canvas!'
		@blocks = []

	stitch: ->
		@dims =
			x: @chunks[2].meta.dims.x + @chunks[3].meta.dims.x + @chunks[4].meta.dims.x
			y: @chunks[2].meta.dims.y + @chunks[1].meta.dims.y + @chunks[8].meta.dims.y
		can "Dims #{@dims.x}, #{@dims.y}"
		for chunk, pos in @chunks
			can "placing chunk #{chunk.hash} at position #{pos}"
			# Get the offset
			offset = @getOffset pos
			# Loop through the blocks in the chunk, and place, accounting for offset
			@placeChunk chunk, offset
		# @doge()
		@emit 'stitched'

	unstitch: ->
		for chunk, pos in @chunks
			can "pulling chunk #{chunk.hash} at position #{pos}"
			# Get the offset
			offset = @getOffset pos
			# Get the chunk from the canvas
			@getChunk chunk, offset
			chunk.save()

	doge: ->
		for col, x in @blocks
			for block, y in col
				if y is 0 or x is 0 or x is @dims.x-1 or y is @dims.y-1
					if @blocks[x][y].stack[0] isnt 'road'
						@blocks[x][y].stack.push 'doge'

				if @blocks[x][y+1]?.stack[0] is 'road' or @blocks[x][y-1]?.stack[0] is 'road' or @blocks[x-1]?[y]?.stack[0] is 'road' or @blocks[x+1]?[y]?.stack[0] is 'road'
					if @blocks[x][y].stack[0] isnt 'road'
						@blocks[x][y].stack.push 'doge'

		@unstitch()


	placeChunk: (chunk, offset) ->
		for block, idx in chunk.blocks
			# Get the dims
			x = idx%chunk.meta.dims.x + offset.x
			y = Math.floor(idx/chunk.meta.dims.x) + offset.y
			# Place the block
			if not @blocks[x]
				@blocks[x] = []
			@blocks[x][y] = block

	getChunk: (chunk, offset) ->
		# Take the canvas and update the individual blocks
		for block, idx in chunk.blocks
			# Get the dims
			x = idx%chunk.meta.dims.x + offset.x
			y = Math.floor(idx/chunk.meta.dims.x) + offset.y
			# can x + ', ' + y
			# Update the block with the canvas block
			chunk.blocks[idx] = @blocks[x][y]
		# Save the chunk
		chunk.save()

	getOffset: (pos) ->
		switch pos
			when 0
				{x: @chunks[1].meta.dims.x, y: @chunks[3].meta.dims.y}
			when 1
				{x: 0, y: 0}
			when 2
				{x: @chunks[2].meta.dims.x, y: 0}
			when 3
				{x: @chunks[2].meta.dims.x + @chunks[3].meta.dims.x, y: 0}
			when 4
				{x: @chunks[0].meta.dims.x + @chunks[1].meta.dims.x, y: @chunks[4].meta.dims.y}
			when 5
				{x: @chunks[7].meta.dims.x + @chunks[8].meta.dims.x, y: @chunks[4].meta.dims.y + @chunks[5].meta.dims.y}
			when 6
				{x: @chunks[8].meta.dims.x, y: @chunks[3].meta.dims.y + @chunks[3].meta.dims.y}
			when 7
				{x: 0, y: @chunks[2].meta.dims.y + @chunks[1].meta.dims.y}
			when 8
				{x: 0, y: @chunks[2].meta.dims.y}

	localLoop: (pos, size, callback) ->
		for localx in [0...size.x]
			for localy in [0...size.y]
				local = 
					x: localx
					y: localy
				global = 
					x: pos.x + localx #global + local
					y: pos.y + localy
				if @blocks[global.x]?[global.y]
					block = @blocks[global.x][global.y]
				else
					block = undefined

				callback block, local, global


module.exports = 
	Canvas: Canvas