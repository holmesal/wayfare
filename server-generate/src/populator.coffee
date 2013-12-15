pop = require('debug')('pop')
{Geohash} = require('./utils/geohash')
Firebase = require 'firebase'
{EventEmitter} = require 'events'
{Canvas} = require './canvas'
Generators = require './generators'

class Populator

	numChunks: 9

	constructor: (@centerHash) ->
		pop "new populator created for center hash #{@centerHash}"
		# Init hashes
		@initHashes()
		# Init chunks
		@initChunks()

		@canvas = new Canvas @chunks

		@canvas.on 'stitched', =>
			@generate()
			@canvas.unstitch()


	initHashes: ->
		# Store first hash
		@hashes = [@centerHash]
		# Grab all of the surrounding hashes
		neighbors = Geohash.Neighbours @centerHash
		@hashes = @hashes.concat neighbors
		pop @hashes

	initChunks: ->
		@chunks = []
		for hash, idx in @hashes
			chunk = new Chunk hash, idx
			@chunks[idx] = chunk
			chunk.on 'loaded', @checkLoaded

	generate: ->
		Generators.Buildings.generate @canvas

	checkLoaded: =>
		@loaded = 0 if not @loaded
		@loaded++
		if @loaded is @numChunks
			# @populate()
			@clear()
			@canvas.stitch()

	clear: ->
		for chunk in @chunks
			chunk.clearAboveGround()
			chunk.save()



	populate: ->
		# Clear first - take this out later
		@clear()
		# for chunk in @chunks
			# chunk.doge()
		# @chunks[0].doge()
		pop "such doge. wow."
		

class Chunk extends EventEmitter

	constructor: (@hash, @position) ->
		# Init firebase
		@firebase()

	firebase: ->
		@ref = new Firebase "https://wander.firebaseio.com/world/#{@hash}"
		@ref.on 'value', (snapshot) =>
			chunk = snapshot.val()
			if chunk
				@meta = chunk.meta
				@blocks = chunk.blocks
				@loaded()

		# TODO - catch unloaded tiles
		@loaded()

	loaded: ->
		@emit 'loaded'

	clearAboveGround: ->
		for block in @blocks
			block.stack = block.stack[0...1]

	doge: ->
		for block in @blocks
			if block.stack[0] isnt 'road'
				if Math.random() > 0.8
					block.stack.push 'doge'
		@save()

	save: ->
		@ref.update
			blocks: @blocks





module.exports = 
	Populator: Populator