'use strict';

angular.module('tilemapApp')
  .directive('viewer', ($timeout, angularFire) ->
	templateUrl: './views/partials/viewer.html'
	restrict: 'E'
	scope:
		world: '='
		hash: '='
	link: (scope, element, attrs) ->

		scope.tileSources = {}
		scope.tileSources.grass = new Image
		scope.tileSources.grass.src = "http://minecraft-cube.comuv.com/textures/grass-top.png"
		scope.tileSources.road = new Image
		scope.tileSources.road.src = "http://i.imgur.com/eqpOX.png"

		init = ->

			scope.$watch 'hash', (hash) ->
				console.log "hash is #{hash}"
				if hash
					setupFirebase hash

			scope.$watch 'world', (world) ->
				if world and world.meta
					initCanvas()
					drawBlocks()

			# $timeout ->
			# 	scope.world.tiles[0].type = 'road'
			# , 10000

		initTiles = ->
			for tile in scope.tileSources
				tile.image = new ImageObj

		initCanvas = ->
			scope.canvas = canvas = element.find('canvas')[0]
			scope.ctx = ctx = canvas.getContext '2d'
			canvas.width = 600
			canvas.height = 600*scope.world.meta.dims.y/scope.world.meta.dims.x
			ctx.width = canvas.width
			ctx.height = canvas.height

			ctx.strokeStyle = '#333333'
			ctx.lineWidth = 1

			width = canvas.width

			# For now, base on 12 blocks across
			scope.blockSize = width / scope.world.meta.dims.x
			# console.log scope.blockSize

		drawBlocks = ->
			console.log 'drawing blocks!'
			for tile, idx in scope.world.tiles
				# Compute the offset
				x0 = (idx % scope.world.meta.dims.x) * scope.blockSize
				y0 = (Math.floor(idx/scope.world.meta.dims.x)) * scope.blockSize
				# scope.ctx.moveTo x0, y0
				# console.log "#{x0}, #{y0}"
				scope.ctx.drawImage scope.tileSources[tile.type], x0, y0, scope.blockSize, scope.blockSize

		setupFirebase = (hash) ->
			# Set up the firebase bindings
			console.log hash
			ref = new Firebase "https://wander.firebaseio.com/world/#{hash}"
			p = angularFire ref, scope, 'world'
			# Actually, this will be handled by the directive so you probably don't have to resolve it here



		init()
				
  )
