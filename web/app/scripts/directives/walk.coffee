'use strict';

angular.module('tilemapApp')
  .directive('walk', ($timeout, $resource, $location, angularFire) ->
	template: '<canvas id="walkCanvas"></canvas>
	<div class="zoomContainer" ng-hide="true">
		<div ng-click="blockSize=blockSize+20">+</div>
		<div ng-click="blockSize=blockSize-20">-</div>
	</div>'
	restrict: 'E'
	scope:
		position: '='
	link: (scope, element, attrs) ->

		scope.nodeServer = "#{$location.protocol()}://#{$location.host()}:9300"

		scope.precision = 8

		scope.debug = false

		scope.chunks = []

		scope.camera = 
			x: 0
			y: 0

		scope.touch =
			x: 0.5
			y: 0.5

		scope.tileSources = {}
		scope.tileSources.grass = new Image
		scope.tileSources.grass.src = "http://minecraft-cube.comuv.com/textures/grass-top.png"
		scope.tileSources.road = new Image
		scope.tileSources.road.src = "http://i.imgur.com/eqpOX.png"
		# scope.tileSources.building = new Image
		# scope.tileSources.building.src = "http://img862.imageshack.us/img862/7013/woodenplanks.png"
		scope.tileSources.unknown = new Image
		scope.tileSources.unknown.src = "https://pbs.twimg.com/profile_images/378800000785385876/2746948649d44b5a8a050a87fd81259e.png"
		# scope.tileSources.bedrock = scope.tileSources.grass

		init = ->

			# scope.$watch 'hash', (hash) ->
			# 	console.log "hash is #{hash}"
			# 	if hash
			# 		console.log geohash.Neighbours(hash)
			# 		setupFirebase hash

			# scope.$watch 'world', (world) ->
			# 	if world and world.meta
			# 		initCanvas()
			# 		initHash()
					# drawChunk world
					# drawBlocks()

			# ios overscroll fix
			document.addEventListener 'touchmove', (e) ->
				e.preventDefault()

			scope.$watch 'position', (position) ->
				if position
					initCanvas()
					initHash()
					animate()

			# $timeout ->
			# 	scope.world.tiles[0].type = 'road'
			# , 10000

		initCanvas = ->
			scope.canvas = canvas = element.find('canvas')[0]
			scope.ctx = ctx = canvas.getContext '2d'
			# canvas.width = 600
			# canvas.height = 600*scope.world.meta.dims.y/scope.world.meta.dims.x
			canvas.width = window.innerWidth
			canvas.height = window.innerHeight
			ctx.width = canvas.width
			ctx.height = canvas.height

			ctx.strokeStyle = '#FFFFFF'
			ctx.lineWidth = 6

			width = canvas.width

			scope.blockSize = width / 8 #scope.world.meta.dims.x
			# console.log scope.blockSize

			# Init touch events
			initTouch()

		initTouch = ->

			scope.drag = 
				x: 0
				y: 0
			# Start touch
			Hammer(scope.canvas).on 'touch', updateTouch
			# Move touch
			Hammer(scope.canvas).on 'drag', updateDrag
			# End touch
			Hammer(scope.canvas).on 'release', (e) ->
				scope.camera.x += e.gesture.deltaX
				scope.camera.y += e.gesture.deltaY
				scope.drag =
					x: 0
					y: 0
				

		updateTouch = (e) ->
			e.preventDefault()
			scope.touch = 
				x: e.gesture.center.pageX / scope.ctx.width
				y: e.gesture.center.pageY / scope.ctx.height
			# console.log scope.touch

		updateDrag = (e) ->
			e.preventDefault()
			# console.log e
			scope.drag = 
				x: e.gesture.deltaX
				y: e.gesture.deltaY
			# console.log scope.touch

		initHash = ->
			#	1 	2 	3
			#	8	0	4
			#	7	6	5
			hash = getGeoHash scope.position
			neighbors = geohash.Neighbours hash
			# Start with the current hash
			scope.hashes = [hash]
			# Add the neighbors
			scope.hashes = scope.hashes.concat neighbors

			console.log scope.hashes

			# scope.offsets = {}
			# scope.offsets[hash] = {x:0,y:0}

			# console.groupCollapsed 'Loading chunks'
			
			for hash, idx in scope.hashes
				scope.chunks[idx] = new Chunk hash, idx
			

		

		# Gets a hash based on lat/long
		getGeoHash = (position) ->
			hash = GeoHasher.encode position.coords.latitude, position.coords.longitude
			# Cut to 8 digits for 36x19m size (at equator, this changes)
			hash[0...scope.precision]

		# drawChunk = (chunk) ->
		# 	# Draw a border around the chunk
		# 	chunkWidth = chunk.meta.dims.x
		# 	# scope.ctx.moveTo 0,0
		# 	scope.ctx.rect 0, 0, chunk.meta.dims.x*scope.blockSize, chunk.meta.dims.y*scope.blockSize
		# 	scope.ctx.stroke()
		# 	# Draw the blocks inside the chunk
		# 	drawBlocks chunk

		# drawBlocks = (chunk) ->
		# 	console.log 'drawing blocks!'
		# 	for block, idx in chunk.tiles
		# 		# Compute the offset
		# 		x0 = (idx % chunk.meta.dims.x) * scope.blockSize
		# 		y0 = (Math.floor(idx/chunk.meta.dims.x)) * scope.blockSize
		# 		# scope.ctx.moveTo x0, y0
		# 		# console.log "#{x0}, #{y0}"
		# 		scope.ctx.drawImage scope.tileSources[block.type], x0, y0, scope.blockSize, scope.blockSize

		# setupFirebase = (hash) ->
		# 	# Set up the firebase bindings
		# 	console.log hash
		# 	ref = new Firebase "https://wander.firebaseio.com/world/#{hash}"
		# 	p = angularFire ref, scope, 'world'
		# 	# Actually, this will be handled by the directive so you probably don't have to resolve it here

		# scope.camera = 
		# 	x: 0
		# 	y: 0

		animate = ->
			requestAnimationFrame animate
			draw()

		draw = ->
			# Add any touches
			# scope.camera.x += -(scope.touch.x-0.5)*10
			# scope.camera.y += -(scope.touch.y-0.5)*10
			# Clear things
			scope.ctx.clearRect 0, 0, scope.ctx.width, scope.ctx.height
			# Center the camera
			cx = scope.ctx.width/2 + scope.camera.x + scope.drag.x
			cy = scope.ctx.height/2 + scope.camera.y + scope.drag.y
			scope.ctx.translate cx, cy
			# Render the chunks
			renderChunks()
			# Uncenter
			scope.ctx.translate -cx, -cy

			# Draw the camera center
			drawCenter() if scope.debug

		renderChunks = ->
			# Shift by half the size of the first chunk, so things are centered
			scope.ctx.translate -scope.chunks[0].dims.x/2, -scope.chunks[0].dims.y/2 if scope.chunks[0].loaded
			for chunk in scope.chunks
				# if chunk.hash is 'drt2ugz9' and chunk.loaded
				# 	chunk.render()
					# console.log chunk.loaded
				if chunk.loaded
					chunk.render()

			# Shift back - probs not needed but hey why not
			scope.ctx.translate scope.chunks[0].dims.x/2, scope.chunks[0].dims.y/2 if scope.chunks[0].loaded

		drawCenter = ->
			# Draw a little dot
			scope.ctx.beginPath()
			scope.ctx.arc scope.ctx.width/2, scope.ctx.height/2, 5, 0, 2*Math.PI
			scope.ctx.stroke()




		class Chunk 
			constructor: (@hash, @position) ->
				@loaded = false
				@data = {}
				@ctx = scope.ctx
				# Create the offset
				@offset = @mapOffset position
				# Set up firebase with that chunk
				@initFirebase()

			initFirebase: ->
				ref = new Firebase "https://wander.firebaseio.com/world/#{@hash}"
				p = angularFire ref, scope, "chunks[#{@position}].data"
				p.then (response) =>
					if @data.meta
						@onload()
						console.log "Loaded chunk #{@hash}..."
						# @calcDims()
					else
						console.log "Chunk #{@hash} does not exist. Generating!"
						@generate()
				, (reason) =>
					console.error 'problem loading!'
					console.log reason
				, (update) =>
					console.log 'got notification!'

			onload: ->
				@loaded = true
				console.log "called for #{@hash}"
				@calcDims()
				# Later, will want to move this call to generate only
				# Or maybe have the node server just listen for changes on the entire db entity
				# Right now, only doing this for the center tile
				if @position is 0
					@goPopulate()

			calcDims: ->
				@dims = 
					x: scope.blockSize * @data.meta.dims.x
					y: scope.blockSize * @data.meta.dims.y

			goPopulate: ->
				url = "#{scope.nodeServer}/populate/:hash"
				Populator = $resource url
				stat = Populator.get
					hash: @hash

			render: ->
				@calcDims()
				# Move to the corner of the chunk
				dx = @offset.x * @dims.x
				dy = @offset.y * @dims.y
				@ctx.translate dx, dy

				# Draw things (now in chunk coordinates)
				@renderBlocks()
				@renderBorder() if scope.debug

				# Move back
				@ctx.translate -dx, -dy


			renderBorder: ->
				# Move to the corner of this chunk
				# Draw the border
				scope.ctx.beginPath()
				@ctx.rect 0, 0, @dims.x, @dims.y
				scope.ctx.stroke()

			renderBlocks: ->
				for block, idx in @data.blocks
					# Compute the offset
					x0 = (idx % @data.meta.dims.x) * scope.blockSize
					y0 = (Math.floor(idx/@data.meta.dims.x)) * scope.blockSize
					# Render each thing in the stack
					for tile in block.stack
						if scope.tileSources[tile]
							image = scope.tileSources[tile]
						else
							image = scope.tileSources.unknown
					# Draw the image (must be square)
					@ctx.drawImage image, x0, y0, scope.blockSize, scope.blockSize
					

			mapOffset: (position) ->
				switch position
					when 0
						{x:0,y:0}
					when 8
						{x:-1,y:0}
					when 1
						{x:-1,y:-1}
					when 2
						{x:0,y:-1}
					when 3
						{x:1,y:-1}
					when 4
						{x: 1,y:0} #1,0
					when 5
						{x:1,y:1}
					when 6
						{x:0,y:1}
					when 7
						{x:-1,y:1} #-1,1

			generate: =>
				console.log "Generating #{@hash}"
				# if @hash is 'drt2ugz9'
				@factory = new Factory @hash, (world) =>
					@data = world
					@onload()


		class Factory
			constructor: (@hash, @callback) ->
				# Make the bounding box
				@makeBbox()
				# Calculate meter dimensions
				@calcDims()

				@canvas = document.createElement 'canvas'
				@canvas.id = @hash
				@ctx = @canvas.getContext '2d'
				@ctx.width = @dims.meters.x
				@ctx.height = @dims.meters.y
				console.log @dims

				# document.appendChild @canvas
				document.getElementById("canvasContainer").appendChild(@canvas)

				# Fill with red
				# TODO - change linewidth based on type of thing
				@ctx.strokeStyle = "#FF0000"
				@ctx.lineWidth = 3


				# Nodes!
				@nodes = {}
				# Vocabulary of ways to look for. Keys are the types. Value is an array of tags to match on
				# Must match all of the tags
				# Bottom to top!
				@ways = [
					type: 'road'
					tag: 'highway'
				# ,
				# 	type: 'building'
				# 	tag: 'building'
				]

				@initThings()

				# Get the data from OSM to kick things off
				@getData()

			initThings: ->
				@things = []
				for way,idx in @ways
					@things[idx] = 
						type: way.type
						vectors: []

			makeBbox: ->
				decoded = GeoHasher.decode @hash

				@center = 
					lat: decoded.latitude[2]
					lon: decoded.longitude[2]


				@bbox = 
					clat: decoded.latitude[2] #
					clon: decoded.longitude[2] #
					minlat: decoded.latitude[0] #Math.min.apply Math, decoded.latitude
					maxlat: decoded.latitude[1] #Math.max.apply Math, decoded.latitude
					minlon: decoded.longitude[0] #Math.min.apply Math, decoded.longitude
					maxlon: decoded.longitude[1] #Math.max.apply Math, decoded.longitude

			calcDims: ->
				@dims = 
					meters: {}
					degrees: {}
				# BAD FORMULA DO NOT USE
				# parity = if @hash.length%2 is 0 then 0 else 1
				# exp = (5 * @hash.length - parity) / 2
				# height = 180 / Math.pow(2, exp)
				# exp = (5 * @hash.length - parity - 1) / 2
				# width = 180 / Math.pow(2, exp)

				@dims.degrees = 
					x: @bbox.maxlon - @bbox.minlon#width
					y: @bbox.maxlat - @bbox.minlat#height

				# @dims.degrees = 
				# 	x: width
				# 	y: height

				# How many meters in a degree of lat/lon at this latitude?
				rlat = @bbox.clat * Math.PI / 180
				mLat = 111132.92 - 559.82 * Math.cos(2*rlat) + 1.175*Math.cos(4*rlat)
				mLon = 111412.84 * Math.cos(rlat) - 93.5 * Math.cos(3*rlat)

				# Convert dims
				# Do I want to round this here or later on?
				@dims.meters = 
					x: Math.round @dims.degrees.x * mLon
					y: Math.round @dims.degrees.y * mLat

			getData: (bbox) ->
				url = 'http://overpass-api.de/api/interpreter'
				bboxString = "#{@bbox.minlat},#{@bbox.minlon},#{@bbox.maxlat},#{@bbox.maxlon}"
				q = "(node(#{bboxString});rel(bn)->.x;way(#{bboxString});node(w)->.x;rel(bw););out body;"
				GeoData = $resource url
				data = GeoData.get
					data: "[out:json];#{q}"
				, @parseData

			parseData: (data) =>
				# Grab roads, and ignore everything else
				console.log data
				console.groupCollapsed 'Ignoring elements'
				for thing in data.elements
					# Grab all of the nodes, regardless
					if thing.type is 'node'
						@nodes[thing.id] = thing
					else if thing.type is 'way'
						# Look through the recognized ways for a match
						# TODO - handle arrays, not just single tag presence
						found = false
						for way, idx in @ways
							if thing.tags?[way.tag]
								@things[idx].vectors.push thing
								found = true
						# if thing.tags?.highway
						# 	# Create if not already there
						# 	@things.push {type:'road',vectors:[]} if not @things.road
						# 	@things.road.vectors.push thing
						if not found
							console.log "ignoring #{JSON.stringify(thing.tags)}"
				console.groupEnd()

				console.log @things

				# Set normalized coordinates
				for id, node of @nodes
					node = @normalize node

				# Init blocks
				@initBlocks()

				# Draw onto the canvas
				@drawCanvas()

				# Assemble
				@buildWorld()
				console.log 'done!'
				console.log @world
				# $scope.toDraw =
				# 	dims: $scope.hash.dims.meters
				# 	nodes: $scope.nodes
				# 	roads: $scope.roads

			normalize: (item) ->
				item.y = (@bbox.maxlat - item.lat) / @dims.degrees.y
				item.x = (item.lon - @bbox.minlon) / @dims.degrees.x

			initBlocks: ->
				@blocks = []
				for idx in [0...@dims.meters.x*@dims.meters.y]
					@blocks[idx] = 
						stack: ['grass']

			drawCanvas: ->
				for thing in @things
					console.log "thing!"
					console.log thing
					# Clear the canvas
					@clearCanvas()
					# Draw the vectors
					@drawVectors thing.vectors
					# Parse the canvas data
					@parseCanvas thing.type

			clearCanvas: ->
				@ctx.clearRect 0, 0, @dims.meters.x, @dims.meters.y

			drawVectors: (vectors) ->
				for vector in vectors
					@ctx.beginPath()
					# scope.ctx.moveTo vector[0][0]*scope.size, vector[0][1]*scope.size # First point in vector
					for node_id,idx in vector.nodes
						node = @nodes[node_id]
						if idx is 0 # Only move for first element
							@ctx.moveTo node.x*@dims.meters.x, node.y*@dims.meters.y
						else # skip first point
							@ctx.lineTo node.x*@dims.meters.x, node.y*@dims.meters.y
					@ctx.stroke()

			parseCanvas: (type) ->
				data = @ctx.getImageData 0,0,@dims.meters.x,@dims.meters.y
				flat = (num for num in data.data by 4)
				
				for num,idx in flat
					if num > 0
						tile = 
							stack: [type]
						@blocks[idx] = tile

			buildWorld: ->
				@world = 
					center: @center
					meta: 
						dims: @dims.meters
						bbox: @bbox
					blocks: @blocks
				console.log 'building world:'
				console.log @world
				@callback @world
				@cleanUp()

			cleanUp: ->
				document.getElementById(@hash).remove()
			


		init()
				
  )
