pop = require('debug')('pop')
{Geohash} = require('./utils/geohash')
Firebase = require 'firebase'
{EventEmitter} = require 'events'

class Populator

	numChunks: 9

	constructor: (@centerHash) ->
		pop "new populator created for center hash #{@centerHash}"
		# Init hashes
		@initHashes()
		# Init chunks
		@initChunks()


	initHashes: ->
		# Store first hash
		@hashes = [@centerHash]
		# Grab all of the surrounding hashes
		neighbors = Geohash.Neighbours @centerHash
		@hashes = @hashes.concat neighbors

	initChunks: ->
		@chunks = []
		for hash, idx in @hashes
			chunk = new Chunk hash, idx
			@chunks[idx] = chunk
			chunk.on 'loaded', @checkLoaded

	checkLoaded: =>
		@loaded = 0 if not @loaded
		@loaded++
		if @loaded is @numChunks
			@populate()

	clear: ->
		for chunk in @chunks
			chunk.clearAboveGround()

	populate: ->
		# Clear first - take this out later
		@clear()
		for chunk in @chunks
			chunk.doge()
		pop "such doge. wow."
		

class Chunk extends EventEmitter

	constructor: (@hash, @position) ->
		# Init firebase
		@firebase()

	firebase: ->
		@ref = new Firebase "https://wander.firebaseio.com/world/#{@hash}"
		@ref.once 'value', (snapshot) =>
			chunk = snapshot.val()
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
		@ref.update
			blocks: @blocks





module.exports = 
	Populator: Populator